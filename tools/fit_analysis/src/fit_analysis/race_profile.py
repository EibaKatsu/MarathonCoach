"""Race profile and phase boundary resolution."""

from __future__ import annotations

from typing import Dict, List

from .schemas import PHASE_NAMES, PhaseBoundary


def resolve_race_profile(race_distance_km: float, rules: Dict[str, object]) -> str:
    profile_rules = rules["race_profile"]
    if race_distance_km <= float(profile_rules["short_distance_max_km"]):
        return "SHORT"
    if abs(race_distance_km - float(profile_rules["half_distance_km"])) <= float(
        profile_rules["half_tolerance_km"]
    ):
        return "HALF"
    return "FULL"


def build_phase_boundaries(race_distance_km: float, rules: Dict[str, object]) -> List[PhaseBoundary]:
    progress = rules["race_profile"]["phase_progress"]
    edges = [0.0, float(progress["S1_end"]), float(progress["S2_end"]), float(progress["S3_end"]), float(progress["S4_end"]), 1.0]
    boundaries: List[PhaseBoundary] = []
    for index, name in enumerate(PHASE_NAMES):
        start_progress = edges[index]
        end_progress = edges[index + 1]
        boundaries.append(
            PhaseBoundary(
                name=name,
                index=index,
                start_km=round(race_distance_km * start_progress, 4),
                end_km=round(race_distance_km * end_progress, 4),
                start_progress=start_progress,
                end_progress=end_progress,
            )
        )
    return boundaries


def resolve_phase_name(distance_km: float, boundaries: List[PhaseBoundary]) -> str:
    for boundary in boundaries:
        if distance_km < boundary.end_km:
            return boundary.name
    return boundaries[-1].name
