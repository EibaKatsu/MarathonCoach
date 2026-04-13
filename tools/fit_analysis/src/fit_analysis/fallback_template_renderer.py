"""Deterministic fallback renderer for client-facing delivery text."""

from __future__ import annotations

from typing import Any, Dict, List


def render_fallback_client_markdown(narrative_input: Dict[str, Any]) -> str:
    setting_lines = []
    view_lines = []
    conclusion_caps = ", ".join(
        f"{item['label']} {item['final']}bpm"
        for item in narrative_input["recommended_setting"].values()
    )
    for item in narrative_input["recommended_setting"].values():
        setting_lines.append(
            f"- {item['label']}（{item['range']}）: {item['baseline']}bpm → {item['final']}bpm（{item['delta']:+d}bpm）"
        )
        view_lines.append(f"- {item['label']}（{item['range']}）: {item['final']}bpm を上限の目安にします。")

    evidence = narrative_input["evidence"]
    seven = narrative_input["seven_points"]
    hearing = narrative_input["hearing"]

    sections = [
        f"# {narrative_input['race_name']} 向けご提案設定",
        "## 今回の結論",
        (
            f"{narrative_input['recommended_terms']['final_cap']}は、"
            f"{conclusion_caps}"
            "です。後半の失速を減らしながら、終盤まで心拍を使いやすくする方向で調整しています。"
        ),
        "## 目標",
        f"- 目標タイム: {narrative_input['goal_time']}",
        f"- 目標ペース: {narrative_input['goal_pace']}",
        f"- レース種別: {narrative_input['profile']}",
        "## 今回のご提案設定",
        *setting_lines,
        "## なぜこの設定にしたか",
        f"- 25〜35km は {evidence['pace_25_35']}、35km以降は {evidence['pace_after_35']} で、後半に {evidence['pace_drop_after_35']} の失速が出ています。",
        f"- 35km以降の平均心拍は {evidence['hr_after_35_avg']}bpm、後半の心拍上昇幅は {evidence['hr_rise_late']}bpm でした。",
        *[f"- {line}" for line in narrative_input["adjustment_summary"]],
        "## 区間ごとの見方",
        *view_lines,
        "## 今回の分析で見えたこと",
        f"- {seven['start']}",
        f"- {seven['mid']}",
        f"- {seven['around_30k']}",
        f"- {seven['after_35k']}",
        f"- {seven['hr_trend']}",
        f"- {seven['finish_room']}",
        "## ヒアリング内容の反映",
        f"- 暑さ: {hearing['heat']}",
        f"- 補給: {hearing['fueling']}",
        f"- 胃腸トラブル: {hearing['stomach_issue']}",
        f"- けいれん: {hearing['cramp']}",
        f"- 当日のメモ: {hearing['condition_note']}",
        "## 再調整の目安",
        f"- {seven['next_direction']}",
        f"- 制約要因として「{narrative_input['limit_factor']}」が続く場合は、次回ログで再確認してください。",
        "## 専用設定コード",
        narrative_input["custom_code"],
    ]
    return "\n".join(sections).rstrip() + "\n"
