"""C2 code encoder/decoder compatible with MarathonCoach."""

from __future__ import annotations

from typing import Dict, Iterable, List

from .schemas import PHASE_NAMES

BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
PREFIX = "C2"
PAYLOAD_LEN = 10
CHECKSUM_LEN = 2
PAIR_MOD = 36 * 36
MIN_BPM = 30
MAX_BPM = 260


class CodeFormatError(ValueError):
    """Raised when a C2 code is malformed."""


def encode_c2(s1: int, s2: int, s3: int, s4: int, s5: int) -> str:
    values = [s1, s2, s3, s4, s5]
    for value in values:
        _validate_bpm(value)
    payload = "".join(_to_base36_pair(value) for value in values)
    base = PREFIX + payload
    code = base + _checksum(base)
    decoded = decode_c2(code)
    if [decoded[name] for name in PHASE_NAMES] != values:
        raise CodeFormatError("Encoded C2 code failed round-trip validation")
    return code


def decode_c2(code: str) -> Dict[str, int]:
    normalized = _normalize_code(code)
    expected_len = len(PREFIX) + PAYLOAD_LEN + CHECKSUM_LEN
    if len(normalized) != expected_len:
        raise CodeFormatError(f"C2 code must be {expected_len} characters after normalization")
    if not normalized.startswith(PREFIX):
        raise CodeFormatError("C2 code must start with C2")
    payload = normalized[len(PREFIX) : len(PREFIX) + PAYLOAD_LEN]
    checksum_text = normalized[-CHECKSUM_LEN:]
    expected_checksum = _checksum(PREFIX + payload)
    if checksum_text != expected_checksum:
        raise CodeFormatError("C2 code checksum mismatch")

    values = [_from_base36_pair(payload[index : index + 2]) for index in range(0, PAYLOAD_LEN, 2)]
    for value in values:
        _validate_bpm(value)
    return {name: value for name, value in zip(PHASE_NAMES, values)}


def validate_c2(code: str) -> bool:
    try:
        decode_c2(code)
        return True
    except CodeFormatError:
        return False


def _normalize_code(text: str) -> str:
    out: List[str] = []
    for ch in str(text):
        upper = ch.upper()
        if upper in BASE36:
            out.append(upper)
    return "".join(out)


def _validate_bpm(value: int) -> None:
    if int(value) != value:
        raise CodeFormatError("C2 payload values must be integers")
    if value < MIN_BPM or value > MAX_BPM:
        raise CodeFormatError(f"C2 payload values must be in {MIN_BPM}..{MAX_BPM}")


def _to_base36_pair(value: int) -> str:
    hi = value // 36
    lo = value % 36
    return BASE36[hi] + BASE36[lo]


def _from_base36_pair(text: str) -> int:
    if len(text) != 2:
        raise CodeFormatError("Base36 pair must be 2 characters")
    return (BASE36.index(text[0]) * 36) + BASE36.index(text[1])


def _checksum(text: str) -> str:
    total = 0
    for index, ch in enumerate(text):
        if ch in BASE36:
            total += (index + 1) * BASE36.index(ch)
    return _to_base36_pair(total % PAIR_MOD)
