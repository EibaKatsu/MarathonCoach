"""Deterministic interval and phase segmentation."""

from __future__ import annotations

from dataclasses import replace
from typing import Iterable, List

from .schemas import FitRecord, IntervalSample


def build_intervals(records: List[FitRecord]) -> List[IntervalSample]:
    sorted_records = sorted(records, key=lambda record: record.timestamp)
    intervals: List[IntervalSample] = []
    last_distance_m = 0.0

    for start, end in zip(sorted_records, sorted_records[1:]):
        delta_time_sec = (end.timestamp - start.timestamp).total_seconds()
        if delta_time_sec <= 0:
            continue

        start_distance_m = _resolve_distance(start.distance_m, last_distance_m)
        end_distance_m = _resolve_distance(end.distance_m, start_distance_m)
        if end_distance_m < start_distance_m:
            end_distance_m = start_distance_m
        last_distance_m = end_distance_m

        delta_distance_m = end_distance_m - start_distance_m
        speed_mps = end.speed_mps
        if speed_mps is None and delta_time_sec > 0:
            speed_mps = delta_distance_m / delta_time_sec
        pace_sec_per_km = end.pace_sec_per_km
        if pace_sec_per_km is None and speed_mps and speed_mps > 0:
            pace_sec_per_km = 1000.0 / speed_mps

        heart_rate_values = [value for value in [start.heart_rate_bpm, end.heart_rate_bpm] if value is not None]
        heart_rate_bpm = None
        if heart_rate_values:
            heart_rate_bpm = sum(heart_rate_values) / len(heart_rate_values)

        intervals.append(
            IntervalSample(
                start_time=start.timestamp,
                end_time=end.timestamp,
                delta_time_sec=delta_time_sec,
                start_distance_m=start_distance_m,
                end_distance_m=end_distance_m,
                delta_distance_m=delta_distance_m,
                midpoint_distance_km=((start_distance_m + end_distance_m) / 2.0) / 1000.0,
                speed_mps=speed_mps,
                pace_sec_per_km=pace_sec_per_km,
                heart_rate_bpm=heart_rate_bpm,
            )
        )
    return intervals


def slice_intervals_by_distance(
    intervals: Iterable[IntervalSample], start_km: float, end_km: float
) -> List[IntervalSample]:
    sliced: List[IntervalSample] = []
    start_m = start_km * 1000.0
    end_m = end_km * 1000.0

    for interval in intervals:
        if interval.delta_distance_m > 0:
            overlap_start = max(start_m, interval.start_distance_m)
            overlap_end = min(end_m, interval.end_distance_m)
            overlap_distance_m = max(0.0, overlap_end - overlap_start)
            if overlap_distance_m <= 0:
                continue
            ratio = overlap_distance_m / interval.delta_distance_m
            sliced.append(
                replace(
                    interval,
                    delta_time_sec=interval.delta_time_sec * ratio,
                    start_distance_m=overlap_start,
                    end_distance_m=overlap_end,
                    delta_distance_m=overlap_distance_m,
                    midpoint_distance_km=((overlap_start + overlap_end) / 2.0) / 1000.0,
                )
            )
            continue

        if start_km <= interval.midpoint_distance_km < end_km:
            sliced.append(interval)
    return sliced


def _resolve_distance(value: float | None, fallback: float) -> float:
    if value is None:
        return fallback
    return float(value)
