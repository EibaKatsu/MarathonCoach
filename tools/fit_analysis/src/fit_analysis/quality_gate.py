"""FIT quality classification for deterministic custom analysis."""

from __future__ import annotations

from typing import Dict, List

from .schemas import FitActivityData, QualityGateResult
from .segmenter import build_intervals


def evaluate_quality(fit_data: FitActivityData, race_distance_km: float, rules: Dict[str, object]) -> QualityGateResult:
    config = rules["quality_gate"]
    intervals = build_intervals(fit_data.records)
    total_time_sec = sum(interval.delta_time_sec for interval in intervals) or 1.0
    total_distance_m = max(_last_distance_m(fit_data), fit_data.session.get("total_distance", 0.0) or 0.0)
    actual_distance_km = total_distance_m / 1000.0

    stop_speed_mps = float(config["stop_speed_mps"])
    gps_jump_speed_mps = float(config["gps_jump_speed_mps"])
    outlier_min = float(config["pace_outlier_min_sec_per_km"])
    outlier_max = float(config["pace_outlier_max_sec_per_km"])
    min_interval_sec = float(config["min_interval_sec"])

    stop_time_sec = 0.0
    hr_missing_time_sec = 0.0
    gps_jump_time_sec = 0.0
    pace_outlier_time_sec = 0.0

    for interval in intervals:
        if interval.delta_time_sec < min_interval_sec:
            continue
        if interval.speed_mps is None or interval.speed_mps <= stop_speed_mps:
            stop_time_sec += interval.delta_time_sec
        if interval.heart_rate_bpm is None:
            hr_missing_time_sec += interval.delta_time_sec
        if interval.speed_mps is not None and interval.speed_mps >= gps_jump_speed_mps:
            gps_jump_time_sec += interval.delta_time_sec
        if interval.pace_sec_per_km is None or interval.pace_sec_per_km < outlier_min or interval.pace_sec_per_km > outlier_max:
            pace_outlier_time_sec += interval.delta_time_sec

    metrics = {
        "distance_ratio": round(actual_distance_km / race_distance_km, 4) if race_distance_km > 0 else 0.0,
        "stop_ratio": round(stop_time_sec / total_time_sec, 4),
        "hr_missing_ratio": round(hr_missing_time_sec / total_time_sec, 4),
        "gps_jump_ratio": round(gps_jump_time_sec / total_time_sec, 4),
        "pace_outlier_ratio": round(pace_outlier_time_sec / total_time_sec, 4),
        "actual_distance_km": round(actual_distance_km, 3),
    }

    reasons: List[str] = []
    applied_checks: List[str] = []
    usable = config["usable"]
    caution = config["caution"]

    if metrics["distance_ratio"] < float(caution["min_distance_ratio"]):
        reasons.append("距離不足が大きく、レース分析としては非推奨です。")
        applied_checks.append("distance_ratio_reject")
    if metrics["hr_missing_ratio"] > float(caution["max_hr_missing_ratio"]):
        reasons.append("心拍欠損が多く、心拍ベース補正の信頼性が低いです。")
        applied_checks.append("hr_missing_reject")
    if metrics["gps_jump_ratio"] > float(caution["max_gps_jump_ratio"]):
        reasons.append("GPSジャンプが多く、ペース分析の信頼性が低いです。")
        applied_checks.append("gps_jump_reject")

    if reasons:
        return QualityGateResult(
            status="not_recommended",
            metrics=metrics,
            reasons=reasons,
            applied_checks=applied_checks,
        )

    if metrics["distance_ratio"] < float(usable["min_distance_ratio"]):
        reasons.append("想定レース距離に対して短めです。参考値として扱ってください。")
        applied_checks.append("distance_ratio_caution")
    if metrics["stop_ratio"] > float(usable["max_stop_ratio"]):
        reasons.append("停止区間が多く、ペース解釈に注意が必要です。")
        applied_checks.append("stop_ratio_caution")
    if metrics["hr_missing_ratio"] > float(usable["max_hr_missing_ratio"]):
        reasons.append("心拍欠損があり、補正幅は保守的に見る必要があります。")
        applied_checks.append("hr_missing_caution")
    if metrics["gps_jump_ratio"] > float(usable["max_gps_jump_ratio"]):
        reasons.append("GPSジャンプがあり、区間ペースにノイズが含まれます。")
        applied_checks.append("gps_jump_caution")
    if metrics["pace_outlier_ratio"] > float(usable["max_pace_outlier_ratio"]):
        reasons.append("外れペースがやや多く、区間平均の解釈に注意が必要です。")
        applied_checks.append("pace_outlier_caution")

    status = "usable_with_caution" if reasons else "usable"
    if not reasons:
        reasons.append("レース分析に使える品質です。")
        applied_checks.append("usable_ok")
    return QualityGateResult(status=status, metrics=metrics, reasons=reasons, applied_checks=applied_checks)


def _last_distance_m(fit_data: FitActivityData) -> float:
    for record in reversed(fit_data.records):
        if record.distance_m is not None:
            return float(record.distance_m)
    return 0.0
