"""Validation for AI-generated client-facing narratives."""

from __future__ import annotations

import re
from typing import Any, Dict, List

from .prompt_builder import SECTION_HEADINGS
from .schemas import NarrativeValidationResult


def validate_narrative_markdown(
    markdown: str,
    narrative_input: Dict[str, Any],
    llm_config: Dict[str, Any],
) -> NarrativeValidationResult:
    issues: List[str] = []
    required_sections_found = {}
    lines = markdown.splitlines()

    title_present = bool(lines and lines[0].startswith("# "))
    if not title_present:
        issues.append("タイトル行がありません。")

    for heading in SECTION_HEADINGS:
        matched = bool(re.search(rf"^#{{1,2}}\s+{re.escape(heading)}\s*$", markdown, flags=re.MULTILINE))
        required_sections_found[heading] = matched
        if not matched:
            issues.append(f"必須セクションが不足しています: {heading}")
        elif re.search(
            rf"^#{{1,2}}\s+{re.escape(heading)}\s*$\n\s*(?:\n|$|#{{1,2}}\s)",
            markdown,
            flags=re.MULTILINE,
        ):
            issues.append(f"セクションが空です: {heading}")

    if narrative_input["custom_code"] not in markdown:
        issues.append("Custom Code が一致しません。")

    tokens_to_check = [
        narrative_input["goal_time"],
        narrative_input["goal_pace"],
        narrative_input["evidence"]["pace_25_35"],
        narrative_input["evidence"]["pace_after_35"],
        narrative_input["evidence"]["pace_drop_after_35"],
        str(narrative_input["evidence"]["hr_after_35_avg"]),
        str(narrative_input["evidence"]["hr_rise_late"]),
    ]
    for token in tokens_to_check:
        if token and token not in markdown:
            issues.append(f"必須数値が本文に見つかりません: {token}")

    for item in narrative_input["recommended_setting"].values():
        required_tokens = [
            item["label"],
            item["range"],
            str(item["sample_avg_hr_bpm"]),
            item["sample_avg_pace"],
            str(item["final"]),
        ]
        if not all(token in markdown for token in required_tokens):
            issues.append(f"区間設定の記載が不足しています: {item['label']}")

    banned_counts: Dict[str, int] = {}
    for term in llm_config.get("style", {}).get("avoid_terms", []):
        count = markdown.count(term)
        banned_counts[term] = count
        if count > 0:
            issues.append(f"禁止語が含まれています: {term}")

    return NarrativeValidationResult(
        ok=not issues,
        title_present=title_present,
        required_sections_found=required_sections_found,
        banned_terms_count=banned_counts,
        issues=issues,
    )
