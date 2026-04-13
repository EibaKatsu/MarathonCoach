"""Rule-based CAP adjustments layered on top of the baseline."""

from __future__ import annotations

from typing import Any, Dict, List, Tuple

from .schemas import AdjustmentRecord, BaselineResult, HearingInput, PHASE_NAMES


def apply_adjustments(
    baseline: BaselineResult,
    metrics: Dict[str, Any],
    hearing: HearingInput,
    quality_status: str,
    rules: Dict[str, Any],
) -> Dict[str, Any]:
    applied: List[AdjustmentRecord] = []
    totals = {phase: 0 for phase in PHASE_NAMES}
    baseline_values = dict(baseline.values)

    if quality_status != "not_recommended":
        for rule_id in ["early_restraint", "mid_stabilize", "late_fade_protection", "late_reserve_boost"]:
            record = _evaluate_performance_rule(rule_id, rules["adjustments"][rule_id], baseline_values, metrics)
            if record.triggered:
                applied.append(record)
                _merge_deltas(totals, record.deltas)

    hearing_records = _evaluate_hearing_rules(hearing, rules["hearing_adjustments"])
    for record in hearing_records:
        applied.append(record)
        _merge_deltas(totals, record.deltas)

    final_values = {}
    for phase in PHASE_NAMES:
        final_values[phase] = max(30, min(260, baseline_values[phase] + totals[phase]))

    return {
        "final_values": final_values,
        "total_deltas": totals,
        "applied_rules": applied,
        "reference_only": quality_status == "not_recommended",
    }


def _evaluate_performance_rule(
    rule_id: str,
    config: Dict[str, Any],
    baseline_values: Dict[str, int],
    metrics: Dict[str, Any],
) -> AdjustmentRecord:
    thresholds = config["thresholds"]
    phase_metrics = metrics["phases"]
    reasons: List[str] = []
    snapshots: Dict[str, Any] = {}

    if rule_id == "early_restraint":
        conditions = {
            "s1_hr_over": _value_or_low(phase_metrics["S1"]["avg_hr_bpm"]) >= baseline_values["S1"] + float(thresholds["s1_hr_over_cap_bpm"]),
            "s2_hr_over": _value_or_low(phase_metrics["S2"]["avg_hr_bpm"]) >= baseline_values["S2"] + float(thresholds["s2_hr_over_cap_bpm"]),
            "early_fast": _value_or_high(metrics["early_pace_diff_sec"]) <= -float(thresholds["early_pace_faster_than_goal_sec"]),
            "late_drop": _value_or_low(metrics["pace_drop_35_plus_sec"]) >= float(thresholds["pace_drop_35_plus_sec"]),
        }
        if conditions["s1_hr_over"]:
            reasons.append(f"S1平均心拍が基準より{phase_metrics['S1']['avg_hr_bpm'] - baseline_values['S1']:.0f}bpm高い")
        if conditions["s2_hr_over"]:
            reasons.append(f"S2平均心拍が基準より{phase_metrics['S2']['avg_hr_bpm'] - baseline_values['S2']:.0f}bpm高い")
        if conditions["early_fast"]:
            reasons.append(f"前半平均ペースが目標より{abs(metrics['early_pace_diff_sec']):.0f}秒/km速い")
        if conditions["late_drop"]:
            reasons.append(f"35km以降の失速幅が{metrics['pace_drop_35_plus_sec']:.0f}秒/km")
        snapshots = {
            "s1_avg_hr_bpm": phase_metrics["S1"]["avg_hr_bpm"],
            "s2_avg_hr_bpm": phase_metrics["S2"]["avg_hr_bpm"],
            "early_pace_diff_sec": metrics["early_pace_diff_sec"],
            "pace_drop_35_plus_sec": metrics["pace_drop_35_plus_sec"],
        }
        triggered = sum(1 for matched in conditions.values() if matched) >= int(config["min_conditions"])
        return AdjustmentRecord(rule_id=rule_id, label=config["label"], triggered=triggered, deltas=dict(config["deltas"]) if triggered else {}, reasons=reasons, snapshots=snapshots)

    if rule_id == "mid_stabilize":
        conditions = {
            "hr_rise": _value_or_low(metrics["hr_rise_25_35_vs_s2_bpm"]) >= float(thresholds["hr_rise_25_35_vs_s2_bpm"]),
            "mid_pace_loss": _value_or_low(_safe_sub(metrics["avg_pace_25_35_sec_per_km"], metrics["goal_pace_sec_per_km"])) >= float(thresholds["pace_25_35_slower_than_goal_sec"]),
            "s3_variability": _value_or_low(phase_metrics["S3"]["pace_variability_sec"]) >= float(thresholds["s3_pace_variability_sec"]),
        }
        if conditions["hr_rise"]:
            reasons.append(f"25〜35kmの心拍上昇がS2比で{metrics['hr_rise_25_35_vs_s2_bpm']:.0f}bpm")
        if conditions["mid_pace_loss"]:
            reasons.append(f"25〜35km平均ペースが目標より{_safe_sub(metrics['avg_pace_25_35_sec_per_km'], metrics['goal_pace_sec_per_km']):.0f}秒/km遅い")
        if conditions["s3_variability"]:
            reasons.append(f"S3のペースばらつきが{phase_metrics['S3']['pace_variability_sec']:.0f}秒/km")
        snapshots = {
            "hr_rise_25_35_vs_s2_bpm": metrics["hr_rise_25_35_vs_s2_bpm"],
            "avg_pace_25_35_sec_per_km": metrics["avg_pace_25_35_sec_per_km"],
            "s3_pace_variability_sec": phase_metrics["S3"]["pace_variability_sec"],
        }
        triggered = sum(1 for matched in conditions.values() if matched) >= int(config["min_conditions"])
        return AdjustmentRecord(rule_id=rule_id, label=config["label"], triggered=triggered, deltas=dict(config["deltas"]) if triggered else {}, reasons=reasons, snapshots=snapshots)

    if rule_id == "late_fade_protection":
        hr_over = _safe_sub(metrics["avg_hr_35_plus_bpm"], baseline_values["S4"])
        conditions = {
            "pace_drop": _value_or_low(metrics["pace_drop_35_plus_sec"]) >= float(thresholds["pace_drop_35_plus_sec"]),
            "late_hr_over": _value_or_low(hr_over) >= float(thresholds["hr_35_plus_over_s4_cap_bpm"]),
        }
        if conditions["pace_drop"]:
            reasons.append(f"35km以降のペース低下が{metrics['pace_drop_35_plus_sec']:.0f}秒/km")
        if conditions["late_hr_over"]:
            reasons.append(f"35km以降平均心拍がS4基準より{hr_over:.0f}bpm高い")
        snapshots = {
            "pace_drop_35_plus_sec": metrics["pace_drop_35_plus_sec"],
            "avg_hr_35_plus_bpm": metrics["avg_hr_35_plus_bpm"],
            "s4_baseline_bpm": baseline_values["S4"],
        }
        triggered = sum(1 for matched in conditions.values() if matched) >= int(config["min_conditions"])
        return AdjustmentRecord(rule_id=rule_id, label=config["label"], triggered=triggered, deltas=dict(config["deltas"]) if triggered else {}, reasons=reasons, snapshots=snapshots)

    if rule_id == "late_reserve_boost":
        s5_hr_room = _safe_sub(baseline_values["S5"], phase_metrics["S5"]["avg_hr_bpm"])
        conditions = {
            "small_drop": _value_or_high(metrics["pace_drop_35_plus_sec"]) <= float(thresholds["max_pace_drop_35_plus_sec"]),
            "finish_gain": _value_or_high(metrics["finish_kick_sec"]) <= -float(thresholds["finish_kick_gain_sec"]),
            "s5_hr_room": _value_or_low(s5_hr_room) >= float(thresholds["s5_hr_room_bpm"]),
        }
        if conditions["small_drop"]:
            reasons.append(f"35km以降の失速幅が{metrics['pace_drop_35_plus_sec']:.0f}秒/km以内")
        if conditions["finish_gain"]:
            reasons.append(f"S5平均ペースがS4より{abs(metrics['finish_kick_sec']):.0f}秒/km速い")
        if conditions["s5_hr_room"]:
            reasons.append(f"S5平均心拍に基準比{float(s5_hr_room):.0f}bpmの余地がある")
        snapshots = {
            "pace_drop_35_plus_sec": metrics["pace_drop_35_plus_sec"],
            "finish_kick_sec": metrics["finish_kick_sec"],
            "s5_hr_room_bpm": s5_hr_room,
        }
        triggered = sum(1 for matched in conditions.values() if matched) >= int(config["min_conditions"])
        return AdjustmentRecord(rule_id=rule_id, label=config["label"], triggered=triggered, deltas=dict(config["deltas"]) if triggered else {}, reasons=reasons, snapshots=snapshots)

    raise ValueError(f"Unsupported adjustment rule: {rule_id}")


def _evaluate_hearing_rules(hearing: HearingInput, config: Dict[str, Any]) -> List[AdjustmentRecord]:
    records: List[AdjustmentRecord] = []

    if hearing.heat_impact in set(config["heat_guard"]["accepted_values"]):
        records.append(
            AdjustmentRecord(
                rule_id="heat_guard",
                label=config["heat_guard"]["label"],
                triggered=True,
                deltas=dict(config["heat_guard"]["deltas"]),
                reasons=[f"ヒアリングで暑熱影響が {hearing.heat_impact} と申告された"],
                snapshots={"heat_impact": hearing.heat_impact},
            )
        )

    if hearing.fueling_actual in set(config["fueling_guard"]["accepted_values"]):
        records.append(
            AdjustmentRecord(
                rule_id="fueling_guard",
                label=config["fueling_guard"]["label"],
                triggered=True,
                deltas=dict(config["fueling_guard"]["deltas"]),
                reasons=[f"補給実績が {hearing.fueling_actual} と申告された"],
                snapshots={"fueling_actual": hearing.fueling_actual},
            )
        )

    if hearing.stomach_issue:
        records.append(
            AdjustmentRecord(
                rule_id="stomach_guard",
                label=config["stomach_guard"]["label"],
                triggered=True,
                deltas=dict(config["stomach_guard"]["deltas"]),
                reasons=["胃腸トラブル申告があるため後半側を保守化"],
                snapshots={"stomach_issue": True},
            )
        )

    if hearing.cramp:
        records.append(
            AdjustmentRecord(
                rule_id="cramp_guard",
                label=config["cramp_guard"]["label"],
                triggered=True,
                deltas=dict(config["cramp_guard"]["deltas"]),
                reasons=["けいれん申告があるため終盤側を保守化"],
                snapshots={"cramp": True},
            )
        )

    return records


def _merge_deltas(target: Dict[str, int], delta: Dict[str, int]) -> None:
    for phase, value in delta.items():
        target[phase] += int(value)


def _safe_sub(left: Any, right: Any) -> Any:
    if left is None or right is None:
        return None
    return float(left) - float(right)


def _value_or_low(value: Any) -> float:
    if value is None:
        return float("-inf")
    return float(value)


def _value_or_high(value: Any) -> float:
    if value is None:
        return float("inf")
    return float(value)
