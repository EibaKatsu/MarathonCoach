"""Baseline CAP calculation aligned with MarathonCoach core logic."""

from __future__ import annotations

from typing import Any, Dict, Optional

from .schemas import BaselineResult, PHASE_NAMES, RunnerProfile, round_nearest


def calculate_baseline(profile_name: str, runner: RunnerProfile, rules: Dict[str, Any]) -> BaselineResult:
    config = rules["baseline"]
    heart_rate_bounds = config["heart_rate_bounds"]
    min_bpm = int(heart_rate_bounds["min_bpm"])
    max_bpm = int(heart_rate_bounds["max_bpm"])
    source = _resolve_source(runner, min_bpm, max_bpm)
    if source == "CAP_SOURCE_NONE":
        raise ValueError("Profile does not provide enough HR anchors to compute baseline CAP")

    anchor_lthr = None
    if source == "CAP_SOURCE_LTHR_PROPERTY":
        anchor_lthr = _normalize_hr(runner.lthr_bpm, min_bpm, max_bpm)
    elif source == "CAP_SOURCE_LTHR_DEVICE":
        anchor_lthr = _normalize_hr(runner.device_lthr_bpm, min_bpm, max_bpm)

    debug: Dict[str, Any] = {"ratios": {}, "raw_caps": {}, "clips": {}}
    values: Dict[str, int] = {}
    for index, phase in enumerate(PHASE_NAMES):
        ratio = _resolve_ratio(config, profile_name, index, source)
        raw_cap = _resolve_base_cap(source, ratio, anchor_lthr, runner.max_hr, runner.resting_hr)
        if raw_cap is None:
            raise ValueError(f"Could not resolve baseline CAP for {phase} using {source}")
        upper = _resolve_upper_clip(config, profile_name, source, anchor_lthr, runner.max_hr, min_bpm, max_bpm)
        lower = _resolve_lower_clip(runner.resting_hr, min_bpm, max_bpm)
        capped = raw_cap
        if upper is not None and capped > upper:
            capped = upper
        if capped < lower:
            capped = float(lower)
        rounded = round_nearest(capped)
        if rounded is None:
            raise ValueError("Rounded baseline CAP unexpectedly became null")
        if upper is not None and rounded > upper:
            rounded = int(upper)
        if rounded < lower:
            rounded = lower
        rounded = max(min_bpm, min(max_bpm, rounded))
        values[phase] = rounded
        debug["ratios"][phase] = ratio
        debug["raw_caps"][phase] = round(raw_cap, 3)
        debug["clips"][phase] = {"upper": upper, "lower": lower}

    return BaselineResult(
        profile=profile_name,
        source=source,
        anchor_lthr_bpm=anchor_lthr,
        values=values,
        debug=debug,
    )


def _resolve_source(runner: RunnerProfile, min_bpm: int, max_bpm: int) -> str:
    if _is_valid_hr(runner.lthr_bpm, min_bpm, max_bpm):
        return "CAP_SOURCE_LTHR_PROPERTY"
    if _is_valid_hr(runner.device_lthr_bpm, min_bpm, max_bpm):
        return "CAP_SOURCE_LTHR_DEVICE"
    if _is_valid_hr(runner.max_hr, min_bpm, max_bpm) and _is_valid_hr(runner.resting_hr, min_bpm, max_bpm) and int(runner.max_hr) > int(runner.resting_hr):
        return "CAP_SOURCE_HRR"
    if _is_valid_hr(runner.max_hr, min_bpm, max_bpm):
        return "CAP_SOURCE_MAXHR"
    return "CAP_SOURCE_NONE"


def _resolve_ratio(config: Dict[str, Any], profile_name: str, phase_index: int, source: str) -> float:
    if source in {"CAP_SOURCE_LTHR_PROPERTY", "CAP_SOURCE_LTHR_DEVICE"}:
        return float(config["ratios"]["lthr"][profile_name][phase_index])
    if source == "CAP_SOURCE_HRR":
        return float(config["ratios"]["hrr"][profile_name][phase_index])
    if source == "CAP_SOURCE_MAXHR":
        return float(config["ratios"]["maxhr"][profile_name][phase_index])
    raise ValueError(f"Unsupported baseline source: {source}")


def _resolve_base_cap(
    source: str,
    ratio: float,
    anchor_lthr: Optional[int],
    max_hr: Optional[int],
    resting_hr: Optional[int],
) -> Optional[float]:
    if source in {"CAP_SOURCE_LTHR_PROPERTY", "CAP_SOURCE_LTHR_DEVICE"}:
        if anchor_lthr is None:
            return None
        return anchor_lthr * ratio
    if source == "CAP_SOURCE_HRR":
        if max_hr is None or resting_hr is None or max_hr <= resting_hr:
            return None
        return resting_hr + ((max_hr - resting_hr) * ratio)
    if source == "CAP_SOURCE_MAXHR":
        if max_hr is None:
            return None
        return max_hr * ratio
    return None


def _resolve_upper_clip(
    config: Dict[str, Any],
    profile_name: str,
    source: str,
    anchor_lthr: Optional[int],
    max_hr: Optional[int],
    min_bpm: int,
    max_bpm: int,
) -> Optional[int]:
    clipping = config["clipping"][profile_name]
    upper = None
    allow_max_hr_clip = _can_apply_max_hr_clip(config, source, anchor_lthr, max_hr, min_bpm, max_bpm)
    if profile_name in {"FULL", "HALF"} and source in {"CAP_SOURCE_LTHR_PROPERTY", "CAP_SOURCE_LTHR_DEVICE"} and anchor_lthr is not None:
        upper = int(anchor_lthr + clipping["lthr_plus"])
    if allow_max_hr_clip and max_hr is not None:
        limit = int(max_hr - clipping["maxhr_minus"])
        upper = limit if upper is None else min(upper, limit)
    return upper


def _resolve_lower_clip(resting_hr: Optional[int], min_bpm: int, max_bpm: int) -> int:
    normalized = _normalize_hr(resting_hr, min_bpm, max_bpm)
    if normalized is not None:
        return normalized + 1
    return 1


def _can_apply_max_hr_clip(
    config: Dict[str, Any],
    source: str,
    anchor_lthr: Optional[int],
    max_hr: Optional[int],
    min_bpm: int,
    max_bpm: int,
) -> bool:
    normalized_max = _normalize_hr(max_hr, min_bpm, max_bpm)
    if normalized_max is None:
        return False
    if source not in {"CAP_SOURCE_LTHR_PROPERTY", "CAP_SOURCE_LTHR_DEVICE"}:
        return True
    if anchor_lthr is None:
        return False
    minimum_gap = int(config["min_plausible_maxhr_above_lthr_bpm"])
    return normalized_max >= anchor_lthr + minimum_gap


def _is_valid_hr(value: Optional[int], min_bpm: int, max_bpm: int) -> bool:
    return _normalize_hr(value, min_bpm, max_bpm) is not None


def _normalize_hr(value: Optional[int], min_bpm: int, max_bpm: int) -> Optional[int]:
    if value is None:
        return None
    rounded = round_nearest(float(value))
    if rounded is None:
        return None
    if rounded < min_bpm or rounded > max_bpm:
        return None
    return rounded
