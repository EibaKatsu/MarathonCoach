"""Shared schemas and deterministic parsing helpers."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Any, Dict, List, Optional

PHASE_NAMES = ["S1", "S2", "S3", "S4", "S5"]
PROFILE_NAMES = ["FULL", "HALF", "SHORT"]
CAP_SOURCES = [
    "CAP_SOURCE_NONE",
    "CAP_SOURCE_CUSTOM_CODE",
    "CAP_SOURCE_LTHR_PROPERTY",
    "CAP_SOURCE_LTHR_DEVICE",
    "CAP_SOURCE_HRR",
    "CAP_SOURCE_MAXHR",
]


def round_nearest(value: Optional[float]) -> Optional[int]:
    if value is None:
        return None
    if value >= 0:
        return int(value + 0.5)
    return -int((-value) + 0.5)


def parse_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    text = str(value).strip().lower()
    return text in {"1", "true", "yes", "y", "on", "あり", "はい"}


def parse_duration_to_seconds(value: Any) -> Optional[int]:
    if value is None or value == "":
        return None
    if isinstance(value, (int, float)):
        return int(value)

    text = str(value).strip()
    if text.isdigit():
        return int(text)

    normalized = (
        text.lower()
        .replace("時間", ":")
        .replace("分", ":")
        .replace("秒", "")
        .replace("h", ":")
        .replace("m", ":")
        .replace("s", "")
    )
    parts = [part for part in normalized.split(":") if part != ""]
    if not parts:
        return None

    if len(parts) == 2:
        hours = int(parts[0])
        minutes = int(parts[1])
        seconds = 0
    elif len(parts) == 3:
        hours = int(parts[0])
        minutes = int(parts[1])
        seconds = int(parts[2])
    else:
        raise ValueError(f"Unsupported duration format: {value}")
    return (hours * 3600) + (minutes * 60) + seconds


def to_plain_dict(value: Any) -> Any:
    if hasattr(value, "__dataclass_fields__"):
        return {k: to_plain_dict(v) for k, v in asdict(value).items()}
    if isinstance(value, dict):
        return {k: to_plain_dict(v) for k, v in value.items()}
    if isinstance(value, list):
        return [to_plain_dict(v) for v in value]
    if isinstance(value, datetime):
        return value.isoformat()
    return value


@dataclass(frozen=True)
class RunnerProfile:
    runner_id: str
    goal_race: str
    race_distance_km: float
    goal_time: Any
    pb_full: Optional[Any] = None
    pb_half: Optional[Any] = None
    lthr_bpm: Optional[int] = None
    device_lthr_bpm: Optional[int] = None
    max_hr: Optional[int] = None
    resting_hr: Optional[int] = None
    watch_model: Optional[str] = None

    @property
    def goal_time_seconds(self) -> int:
        parsed = parse_duration_to_seconds(self.goal_time)
        if parsed is None or parsed <= 0:
            raise ValueError("goal_time must resolve to a positive number of seconds")
        return parsed

    @property
    def goal_pace_sec_per_km(self) -> float:
        return self.goal_time_seconds / self.race_distance_km

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "RunnerProfile":
        return cls(
            runner_id=str(data["runner_id"]),
            goal_race=str(data["goal_race"]),
            race_distance_km=float(data["race_distance_km"]),
            goal_time=data["goal_time"],
            pb_full=data.get("pb_full"),
            pb_half=data.get("pb_half"),
            lthr_bpm=_optional_int(data.get("lthr_bpm")),
            device_lthr_bpm=_optional_int(data.get("device_lthr_bpm")),
            max_hr=_optional_int(data.get("max_hr")),
            resting_hr=_optional_int(data.get("resting_hr")),
            watch_model=data.get("watch_model"),
        )


@dataclass(frozen=True)
class HearingInput:
    condition_note: str = ""
    heat_impact: str = "none"
    fueling_actual: str = "as_planned"
    stomach_issue: bool = False
    cramp: bool = False
    limit_factor: str = ""
    next_plan_preference: str = "balanced"

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "HearingInput":
        return cls(
            condition_note=str(data.get("condition_note", "")),
            heat_impact=str(data.get("heat_impact", "none")).strip().lower(),
            fueling_actual=str(data.get("fueling_actual", "as_planned")).strip().lower(),
            stomach_issue=parse_bool(data.get("stomach_issue")),
            cramp=parse_bool(data.get("cramp")),
            limit_factor=str(data.get("limit_factor", "")),
            next_plan_preference=str(data.get("next_plan_preference", "balanced")).strip().lower(),
        )


@dataclass(frozen=True)
class PhaseBoundary:
    name: str
    index: int
    start_km: float
    end_km: float
    start_progress: float
    end_progress: float


@dataclass(frozen=True)
class FitRecord:
    timestamp: datetime
    distance_m: Optional[float]
    heart_rate_bpm: Optional[int]
    speed_mps: Optional[float]
    pace_sec_per_km: Optional[float]


@dataclass(frozen=True)
class FitActivityData:
    path: str
    file_hash: str
    integrity_ok: bool
    records: List[FitRecord]
    session: Dict[str, Any]
    messages_summary: Dict[str, int]


@dataclass(frozen=True)
class IntervalSample:
    start_time: datetime
    end_time: datetime
    delta_time_sec: float
    start_distance_m: float
    end_distance_m: float
    delta_distance_m: float
    midpoint_distance_km: float
    speed_mps: Optional[float]
    pace_sec_per_km: Optional[float]
    heart_rate_bpm: Optional[float]


@dataclass(frozen=True)
class QualityGateResult:
    status: str
    metrics: Dict[str, float]
    reasons: List[str]
    applied_checks: List[str]


@dataclass(frozen=True)
class BaselineResult:
    profile: str
    source: str
    anchor_lthr_bpm: Optional[int]
    values: Dict[str, int]
    debug: Dict[str, Any]


@dataclass(frozen=True)
class AdjustmentRecord:
    rule_id: str
    label: str
    triggered: bool
    deltas: Dict[str, int]
    reasons: List[str] = field(default_factory=list)
    snapshots: Dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class RenderedReport:
    markdown: str
    html: str


@dataclass(frozen=True)
class PromptBundle:
    version: str
    system_prompt: str
    user_prompt: str


@dataclass(frozen=True)
class NarrativeValidationResult:
    ok: bool
    title_present: bool
    required_sections_found: Dict[str, bool]
    banned_terms_count: Dict[str, int]
    issues: List[str] = field(default_factory=list)


@dataclass(frozen=True)
class LLMRequestResult:
    provider: str
    model: str
    markdown: str
    raw_response: Dict[str, Any]


@dataclass(frozen=True)
class ClientDeliveryArtifacts:
    markdown: str
    html: str
    audit: Optional[Dict[str, Any]]
    narrative_input: Dict[str, Any]
    validation: NarrativeValidationResult


def _optional_int(value: Any) -> Optional[int]:
    if value in (None, ""):
        return None
    return int(value)
