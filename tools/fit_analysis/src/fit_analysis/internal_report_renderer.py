"""Deterministic internal report rendering."""

from __future__ import annotations

import html
from pathlib import Path
from string import Template
from typing import Any, Dict, List

from .schemas import HearingInput, PhaseBoundary, RenderedReport, RunnerProfile


def render_reports(
    runner: RunnerProfile,
    hearing: HearingInput,
    rule_version: str,
    quality: Dict[str, Any],
    boundaries: List[PhaseBoundary],
    baseline: Dict[str, int],
    final_values: Dict[str, int],
    deltas: Dict[str, int],
    applied_rules: List[Dict[str, Any]],
    metrics: Dict[str, Any],
    custom_code: str,
    summary_items: List[Dict[str, str]],
) -> RenderedReport:
    templates_dir = Path(__file__).resolve().parents[2] / "templates"
    markdown_template = Template((templates_dir / "delivery_report.md.j2").read_text())
    html_template = Template((templates_dir / "delivery_report.html.j2").read_text())

    zone_table = _build_zone_table(boundaries, baseline, final_values, deltas)
    adjustment_lines = _build_adjustment_lines(applied_rules)
    reason_lines = _build_reason_lines(metrics, applied_rules)
    summary_lines = "\n".join(f"- {item['label']}: {item['text']}" for item in summary_items)
    hearing_lines = _build_hearing_lines(hearing, applied_rules)
    race_usage_lines = _build_race_usage_lines(boundaries, final_values)
    recalibration_lines = _build_recalibration_lines(quality, hearing)

    markdown = markdown_template.safe_substitute(
        goal_race=runner.goal_race,
        runner_id=runner.runner_id,
        quality_status=quality["status"],
        rule_version=rule_version,
        goal_time_text=format_duration_jp(runner.goal_time_seconds),
        goal_pace_text=format_pace_jp(runner.goal_pace_sec_per_km),
        race_distance_km=f"{runner.race_distance_km:.3f}".rstrip("0").rstrip("."),
        race_profile=quality["race_profile"],
        zone_table=zone_table,
        adjustment_lines=adjustment_lines,
        reason_lines=reason_lines,
        summary_lines=summary_lines,
        hearing_lines=hearing_lines,
        race_usage_lines=race_usage_lines,
        custom_code=custom_code,
        recalibration_lines=recalibration_lines,
    )

    html_text = html_template.safe_substitute(
        meta_html=_paragraph_html(
            f"対象レース: {runner.goal_race} / ランナーID: {runner.runner_id} / 品質判定: {quality['status']} / 使用ルール: {rule_version}"
        ),
        goal_html=_list_html(
            [
                f"目標タイム: {format_duration_jp(runner.goal_time_seconds)}",
                f"目標ペース: {format_pace_jp(runner.goal_pace_sec_per_km)}",
                f"レース距離: {runner.race_distance_km:.3f}".rstrip("0").rstrip(".") + "km",
                f"プロファイル: {quality['race_profile']}",
            ]
        ),
        zone_table_html=_zone_table_html(boundaries, baseline, final_values, deltas),
        adjustment_html=_list_html(_split_bullets(adjustment_lines)),
        reason_html=_list_html(_split_bullets(reason_lines)),
        summary_html=_list_html(_split_bullets(summary_lines)),
        hearing_html=_list_html(_split_bullets(hearing_lines)),
        race_usage_html=_list_html(_split_bullets(race_usage_lines)),
        custom_code=html.escape(custom_code),
        recalibration_html=_list_html(_split_bullets(recalibration_lines)),
    )
    return RenderedReport(markdown=markdown.rstrip() + "\n", html=html_text.rstrip() + "\n")


def build_summary_items(
    metrics: Dict[str, Any],
    rules: Dict[str, Any],
    hearing: HearingInput,
) -> List[Dict[str, str]]:
    summary_rules = rules["summary_rules"]
    phase_metrics = metrics["phases"]

    early_diff = metrics["early_pace_diff_sec"]
    if early_diff is None:
        early_text = "前半の入り方は判定保留です。"
    elif early_diff <= float(summary_rules["fast_start_sec"]):
        early_text = f"前半は目標より{abs(early_diff):.0f}秒/km速く、入りが強めでした。"
    elif early_diff <= float(summary_rules["controlled_start_sec"]):
        early_text = f"前半は目標差{early_diff:.0f}秒/kmで、おおむね狙いどおりです。"
    else:
        early_text = f"前半は目標より{early_diff:.0f}秒/km遅く、抑え気味でした。"

    s3_var = phase_metrics["S3"]["pace_variability_sec"]
    if s3_var is None:
        mid_stability = "中盤の安定度は判定保留です。"
    elif s3_var <= float(summary_rules["stable_variability_sec"]):
        mid_stability = f"中盤のペースばらつきは{s3_var:.0f}秒/kmで安定しています。"
    elif s3_var >= float(summary_rules["unstable_variability_sec"]):
        mid_stability = f"中盤のペースばらつきが{s3_var:.0f}秒/kmと大きめです。"
    else:
        mid_stability = f"中盤のペースばらつきは{s3_var:.0f}秒/kmで、やや揺れがあります。"

    mid_drop = _safe(metrics["avg_pace_25_35_sec_per_km"], metrics["goal_pace_sec_per_km"])
    if mid_drop is None:
        wall_text = "30km前後の崩れ始めは判定保留です。"
    elif mid_drop >= float(summary_rules["mid_drop_sec"]):
        wall_text = f"30km前後で目標より{mid_drop:.0f}秒/km遅れ始めています。"
    else:
        wall_text = f"30km前後でも目標差は{mid_drop:.0f}秒/km以内に収まっています。"

    late_drop = metrics["pace_drop_35_plus_sec"]
    if late_drop is None:
        late_text = "35km以降の失速度は判定保留です。"
    elif late_drop >= float(summary_rules["severe_drop_sec"]):
        late_text = f"35km以降は{late_drop:.0f}秒/kmの大きな失速が出ています。"
    elif late_drop >= float(summary_rules["mid_drop_sec"]):
        late_text = f"35km以降は{late_drop:.0f}秒/kmの失速が見られます。"
    else:
        late_text = f"35km以降の失速幅は{late_drop:.0f}秒/kmで比較的小さめです。"

    hr_rise = metrics["heart_rate_rise_bpm"]
    if hr_rise is None:
        hr_text = "心拍の上がり方は判定保留です。"
    elif hr_rise >= float(summary_rules["hr_rise_high_bpm"]):
        hr_text = f"後半で心拍が{hr_rise:.0f}bpm上がっており、負荷上昇が大きいです。"
    elif hr_rise >= float(summary_rules["hr_rise_mild_bpm"]):
        hr_text = f"後半で心拍が{hr_rise:.0f}bpm上がっており、想定内の上昇です。"
    else:
        hr_text = f"心拍上昇は{hr_rise:.0f}bpmで穏やかです。"

    finish_kick = metrics["finish_kick_sec"]
    if finish_kick is None:
        reserve_text = "終盤の粘り余地は判定保留です。"
    elif late_drop is not None and late_drop >= float(summary_rules["mid_drop_sec"]):
        reserve_text = "終盤の粘り余地は限定的で、前半から余力を残す設計が向いています。"
    elif finish_kick <= -float(summary_rules["finish_gain_sec"]):
        reserve_text = f"終盤はS4比で{abs(finish_kick):.0f}秒/km上げられており、余力があります。"
    else:
        reserve_text = "終盤の上げ幅は限定的で、先に余力を残す設計が向いています。"

    next_policy = "次回設定方針は現状維持ベースです。"
    if hearing.next_plan_preference == "conservative":
        next_policy = "次回設定方針は保守寄りで、前半から中盤を少し低めに置きます。"
    elif hearing.next_plan_preference == "aggressive_finish":
        next_policy = "次回設定方針は終盤重視で、S5にだけ上げ余地を残します。"
    elif late_drop is not None and late_drop >= float(summary_rules["mid_drop_sec"]):
        next_policy = "次回設定方針は前半から中盤を抑え、35km以降の失速を減らす方向です。"

    return [
        {"label": "前半の入り方", "text": early_text},
        {"label": "中盤の安定度", "text": mid_stability},
        {"label": "30km前後の崩れ始め", "text": wall_text},
        {"label": "35km以降の失速度", "text": late_text},
        {"label": "心拍の上がり方", "text": hr_text},
        {"label": "終盤の粘り余地", "text": reserve_text},
        {"label": "次回設定方針", "text": next_policy},
    ]


def format_duration_jp(total_seconds: float) -> str:
    seconds = int(round(total_seconds))
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60
    if secs == 0:
        return f"{hours}時間{minutes:02d}分"
    return f"{hours}時間{minutes:02d}分{secs:02d}秒"


def format_pace_jp(sec_per_km: float | None) -> str:
    if sec_per_km is None:
        return "--"
    total = int(round(sec_per_km))
    minutes = total // 60
    seconds = total % 60
    return f"{minutes}分{seconds:02d}秒/km"


def _build_zone_table(
    boundaries: List[PhaseBoundary],
    baseline: Dict[str, int],
    final_values: Dict[str, int],
    deltas: Dict[str, int],
) -> str:
    lines = [
        "| 区間 | 距離 | 基準CAP | 最終CAP | 差分 |",
        "| --- | --- | --- | --- | --- |",
    ]
    for boundary in boundaries:
        delta = deltas[boundary.name]
        lines.append(
            f"| {boundary.name} | {boundary.start_km:.1f}〜{boundary.end_km:.1f}km | {baseline[boundary.name]}bpm | {final_values[boundary.name]}bpm | {delta:+d}bpm |"
        )
    return "\n".join(lines)


def _zone_table_html(
    boundaries: List[PhaseBoundary],
    baseline: Dict[str, int],
    final_values: Dict[str, int],
    deltas: Dict[str, int],
) -> str:
    rows = [
        "<table><thead><tr><th>区間</th><th>距離</th><th>基準CAP</th><th>最終CAP</th><th>差分</th></tr></thead><tbody>"
    ]
    for boundary in boundaries:
        rows.append(
            "<tr>"
            f"<td>{html.escape(boundary.name)}</td>"
            f"<td>{boundary.start_km:.1f}〜{boundary.end_km:.1f}km</td>"
            f"<td>{baseline[boundary.name]}bpm</td>"
            f"<td>{final_values[boundary.name]}bpm</td>"
            f"<td>{deltas[boundary.name]:+d}bpm</td>"
            "</tr>"
        )
    rows.append("</tbody></table>")
    return "".join(rows)


def _build_adjustment_lines(applied_rules: List[Dict[str, Any]]) -> str:
    if not applied_rules:
        return "- 追加補正なし"
    lines = []
    for record in applied_rules:
        delta_text = ", ".join(f"{phase} {value:+d}" for phase, value in record["deltas"].items())
        reasons = " / ".join(record["reasons"])
        lines.append(f"- {record['label']}: {delta_text} ({reasons})")
    return "\n".join(lines)


def _build_reason_lines(metrics: Dict[str, Any], applied_rules: List[Dict[str, Any]]) -> str:
    lines = [f"- 目標ペースは {format_pace_jp(metrics['goal_pace_sec_per_km'])} です。"]
    if metrics["avg_pace_25_35_sec_per_km"] is not None and metrics["avg_pace_35_plus_sec_per_km"] is not None:
        lines.append(
            "- 25〜35kmは "
            f"{format_pace_jp(metrics['avg_pace_25_35_sec_per_km'])} / "
            f"35km以降は {format_pace_jp(metrics['avg_pace_35_plus_sec_per_km'])} "
            f"で、差は {metrics['pace_drop_35_plus_sec']:.0f}秒/km です。"
        )
    if metrics["avg_hr_35_plus_bpm"] is not None:
        lines.append(
            f"- 35km以降の平均心拍は {metrics['avg_hr_35_plus_bpm']}bpm、心拍上昇幅は {metrics['heart_rate_rise_bpm']:.0f}bpm です。"
        )
    if applied_rules:
        lines.append(f"- 発火した補正ルールは {len(applied_rules)} 件です。")
    return "\n".join(lines)


def _build_hearing_lines(hearing: HearingInput, applied_rules: List[Dict[str, Any]]) -> str:
    lines = [
        f"- 暑熱影響: {hearing.heat_impact}",
        f"- 補給実績: {hearing.fueling_actual}",
        f"- 胃腸トラブル: {'あり' if hearing.stomach_issue else 'なし'}",
        f"- けいれん: {'あり' if hearing.cramp else 'なし'}",
    ]
    hearing_rule_ids = {"heat_guard", "fueling_guard", "stomach_guard", "cramp_guard"}
    fired = [record["label"] for record in applied_rules if record["rule_id"] in hearing_rule_ids]
    if fired:
        lines.append(f"- ヒアリング起因の補正: {', '.join(fired)}")
    else:
        lines.append("- ヒアリング起因の追加補正はありません。")
    return "\n".join(lines)


def _build_race_usage_lines(boundaries: List[PhaseBoundary], final_values: Dict[str, int]) -> str:
    lines = []
    for boundary in boundaries:
        lines.append(
            f"- {boundary.name} ({boundary.start_km:.1f}〜{boundary.end_km:.1f}km): 心拍を {final_values[boundary.name]}bpm 以下で運用"
        )
    lines.append("- 心拍が上限に張り付く展開なら、まずペースではなく上限維持を優先してください。")
    return "\n".join(lines)


def _build_recalibration_lines(quality: Dict[str, Any], hearing: HearingInput) -> str:
    lines = []
    if quality["status"] != "usable":
        lines.append("- 今回ログは参考分析扱いです。次回は停止の少ない本番近いログで再評価してください。")
    if hearing.limit_factor:
        lines.append(f"- 主な制約要因として「{hearing.limit_factor}」が挙がっているため、その改善後に再評価すると差が見やすいです。")
    if hearing.condition_note:
        lines.append(f"- コンディションメモ: {hearing.condition_note}")
    if not lines:
        lines.append("- 次回も同条件のレースログが取れたら、このコードを基準に微修正してください。")
    return "\n".join(lines)


def _paragraph_html(text: str) -> str:
    return f"<p>{html.escape(text)}</p>"


def _list_html(lines: List[str]) -> str:
    items = "".join(f"<li>{html.escape(line)}</li>" for line in lines if line)
    return f"<ul>{items}</ul>"


def _split_bullets(text: str) -> List[str]:
    out = []
    for line in text.splitlines():
        cleaned = line.strip()
        if cleaned.startswith("- "):
            out.append(cleaned[2:])
        elif cleaned:
            out.append(cleaned)
    return out


def _safe(left: Any, right: Any) -> float | None:
    if left is None or right is None:
        return None
    return float(left) - float(right)
