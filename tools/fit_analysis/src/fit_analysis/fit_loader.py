"""FIT loading with Garmin's official Python SDK."""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

from .schemas import FitActivityData, FitRecord, round_nearest


class FitLoaderError(RuntimeError):
    """Raised when FIT loading or decoding fails."""

    def __init__(self, message: str, code: str, details: Optional[Dict[str, Any]] = None) -> None:
        super().__init__(message)
        self.code = code
        self.details = details or {}


def load_fit(path: str) -> FitActivityData:
    sdk = _import_sdk()
    fit_path = Path(path)
    if not fit_path.exists():
        raise FitLoaderError(f"FIT file not found: {path}", code="fit_not_found")

    raw = fit_path.read_bytes()
    file_hash = hashlib.sha256(raw).hexdigest()
    if not raw:
        raise FitLoaderError("FIT file is empty", code="fit_empty")

    try:
        stream_for_validation = sdk.Stream.from_byte_array(raw)
        decoder_for_validation = sdk.Decoder(stream_for_validation)
        if not decoder_for_validation.is_fit():
            raise FitLoaderError("Input file is not a FIT file", code="fit_invalid_header")
        integrity_ok = bool(decoder_for_validation.check_integrity())

        stream = sdk.Stream.from_byte_array(raw)
        decoder = sdk.Decoder(stream)
        messages, errors = decoder.read()
    except FitLoaderError:
        raise
    except Exception as exc:  # noqa: BLE001
        raise FitLoaderError(
            "FIT decoding failed",
            code="fit_decode_failed",
            details={"exception": str(exc)},
        ) from exc

    if errors:
        raise FitLoaderError(
            "FIT decoding returned errors",
            code="fit_decode_errors",
            details={"errors": [str(error) for error in errors]},
        )

    record_mesgs = list(messages.get("record_mesgs", []))
    if len(record_mesgs) < 2:
        raise FitLoaderError(
            "FIT file does not contain enough record messages for analysis",
            code="fit_records_insufficient",
            details={"record_count": len(record_mesgs)},
        )

    records = [_convert_record(message) for message in record_mesgs if message.get("timestamp") is not None]
    if len(records) < 2:
        raise FitLoaderError(
            "FIT file does not contain enough timestamped records",
            code="fit_records_timestamp_missing",
        )

    session_mesgs = list(messages.get("session_mesgs", []))
    session = dict(session_mesgs[0]) if session_mesgs else {}
    messages_summary = {
        key: len(value) if isinstance(value, list) else 0
        for key, value in sorted(messages.items(), key=lambda item: item[0])
    }

    return FitActivityData(
        path=str(fit_path),
        file_hash=file_hash,
        integrity_ok=integrity_ok,
        records=records,
        session=session,
        messages_summary=messages_summary,
    )


def _convert_record(message: Dict[str, Any]) -> FitRecord:
    distance_m = _optional_float(message.get("distance"))
    speed_mps = _first_valid_float(message.get("enhanced_speed"), message.get("speed"))
    pace_sec_per_km = None
    if speed_mps is not None and speed_mps > 0:
        pace_sec_per_km = 1000.0 / speed_mps

    heart_rate = None
    if message.get("heart_rate") is not None:
        heart_rate = round_nearest(float(message["heart_rate"]))

    return FitRecord(
        timestamp=message["timestamp"],
        distance_m=distance_m,
        heart_rate_bpm=heart_rate,
        speed_mps=speed_mps,
        pace_sec_per_km=pace_sec_per_km,
    )


def _optional_float(value: Any) -> Optional[float]:
    if value in (None, ""):
        return None
    return float(value)


def _first_valid_float(*values: Any) -> Optional[float]:
    for value in values:
        if value in (None, ""):
            continue
        numeric = float(value)
        if numeric >= 0:
            return numeric
    return None


def _import_sdk():
    try:
        import garmin_fit_sdk  # type: ignore

        return garmin_fit_sdk
    except ModuleNotFoundError:
        vendor_path = Path(__file__).resolve().parents[2] / "_vendor"
        if str(vendor_path) not in sys.path and vendor_path.exists():
            sys.path.insert(0, str(vendor_path))
        try:
            import garmin_fit_sdk  # type: ignore

            return garmin_fit_sdk
        except ModuleNotFoundError as exc:
            raise FitLoaderError(
                "garmin-fit-sdk is not installed. Install dependencies before running FIT analysis.",
                code="fit_sdk_missing",
            ) from exc
