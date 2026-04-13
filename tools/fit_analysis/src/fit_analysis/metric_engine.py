"""Metric calculation over deterministic race segments."""

from __future__ import annotations

import math
from typing import Any, Dict, List

from .schemas import FitActivityData, PhaseBoundary, RunnerProfile, round_nearest
from .segmenter import build_intervals, slice_intervals_by_distance


def calculate_metrics(
    fit_data: FitActivityData,
    runner: RunnerProfile,
    boundaries: List[PhaseBoundary],
    quality_metrics: Dict[str, float],
) -> Dict[str, Any]:
    intervals = build_intervals(fit_data.records)
    goal_pace = runner.goal_pace_sec_per_km

    phase_metrics: Dict[str, Dict[str, Any]] = {}
    for boundary in boundaries:
        phase_intervals = slice_intervals_by_distance(intervals, boundary.start_km, boundary.end_km)
        summary = _summarize_bucket(phase_intervals)
        summary["start_km"] = boundary.start_km
        summary["end_km"] = boundary.end_km
        summary["goal_pace_diff_sec"] = _round(summary["avg_pace_sec_per_km"] - goal_pace) if summary["avg_pace_sec_per_km"] is not None else None
        phase_metrics[boundary.name] = summary

    overall = _summarize_bucket(intervals)
    early = _summarize_bucket(slice_intervals_by_distance(intervals, 0.0, boundaries[1].end_km))
    km25_35 = _summarize_bucket(slice_intervals_by_distance(intervals, 25.0, 35.0))
    km35_finish = _summarize_bucket(slice_intervals_by_distance(intervals, 35.0, runner.race_distance_km))

    metrics: Dict[str, Any] = {
        "overall": overall,
        "phases": phase_metrics,
        "goal_pace_sec_per_km": _round(goal_pace),
        "goal_pace_diff_sec": _round(overall["avg_pace_sec_per_km"] - goal_pace) if overall["avg_pace_sec_per_km"] is not None else None,
        "early_pace_diff_sec": _round(early["avg_pace_sec_per_km"] - goal_pace) if early["avg_pace_sec_per_km"] is not None else None,
        "avg_hr_25_35_bpm": km25_35["avg_hr_bpm"],
        "avg_hr_35_plus_bpm": km35_finish["avg_hr_bpm"],
        "avg_pace_25_35_sec_per_km": km25_35["avg_pace_sec_per_km"],
        "avg_pace_35_plus_sec_per_km": km35_finish["avg_pace_sec_per_km"],
        "pace_drop_35_plus_sec": _delta(km35_finish["avg_pace_sec_per_km"], km25_35["avg_pace_sec_per_km"]),
        "heart_rate_rise_bpm": _delta(km35_finish["avg_hr_bpm"], phase_metrics["S1"]["avg_hr_bpm"]),
        "hr_rise_25_35_vs_s2_bpm": _delta(km25_35["avg_hr_bpm"], phase_metrics["S2"]["avg_hr_bpm"]),
        "finish_kick_sec": _delta(phase_metrics["S5"]["avg_pace_sec_per_km"], phase_metrics["S4"]["avg_pace_sec_per_km"]),
        "stop_ratio": quality_metrics["stop_ratio"],
        "hr_missing_ratio": quality_metrics["hr_missing_ratio"],
    }
    return metrics


def _summarize_bucket(intervals: List[Any]) -> Dict[str, Any]:
    total_time_sec = sum(interval.delta_time_sec for interval in intervals)
    total_distance_m = sum(interval.delta_distance_m for interval in intervals)
    pace_samples = [interval.pace_sec_per_km for interval in intervals if interval.pace_sec_per_km is not None]
    hr_weighted = sum(interval.heart_rate_bpm * interval.delta_time_sec for interval in intervals if interval.heart_rate_bpm is not None)
    hr_time = sum(interval.delta_time_sec for interval in intervals if interval.heart_rate_bpm is not None)

    avg_hr = None
    if hr_time > 0:
        avg_hr = round_nearest(hr_weighted / hr_time)
    avg_pace = None
    if total_distance_m > 0 and total_time_sec > 0:
        avg_pace = total_time_sec / (total_distance_m / 1000.0)
    variability = None
    if pace_samples:
        mean = sum(pace_samples) / len(pace_samples)
        variance = sum((sample - mean) ** 2 for sample in pace_samples) / len(pace_samples)
        variability = math.sqrt(variance)

    return {
        "avg_hr_bpm": avg_hr,
        "avg_pace_sec_per_km": _round(avg_pace),
        "pace_variability_sec": _round(variability),
        "distance_km": _round(total_distance_m / 1000.0),
        "time_sec": _round(total_time_sec),
    }


def _delta(left: Any, right: Any) -> Any:
    if left is None or right is None:
        return None
    return _round(float(left) - float(right))


def _round(value: Any) -> Any:
    if value is None:
        return None
    return round(float(value), 3)
