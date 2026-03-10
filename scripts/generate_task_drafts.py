#!/usr/bin/env python3
"""
Generate draft markdown outputs from TASKS.md.

This script creates:
- tasks/README.md
- tasks/<heading-folder>/draft.md
"""

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


ROOT = Path(__file__).resolve().parents[1]
TASKS_MD = ROOT / "TASKS.md"
OUTPUT_DIR = ROOT / "tasks"


HEADING_FOLDER_MAP: Dict[str, str] = {
    "0": "00_public-policy",
    "1-1": "01-1_feature-freeze-spec",
    "1-2": "01-2_code-cleanup",
    "1-3": "01-3_supported-devices",
    "2-1": "02-1_unit-checks",
    "2-2": "02-2_abnormal-checks",
    "2-3": "02-3_field-run-checks",
    "3-1": "03-1_store-assets",
    "3-2": "03-2_package-and-submit",
    "4": "04_beta-test-ops",
    "4-1": "04-1_tester-recruitment",
    "5-1": "05-1_custom-product-design",
    "5-2": "05-2_custom-intake-flow",
    "5-3": "05-3_analysis-delivery-flow",
    "6": "06_fit-analysis-tooling",
    "7": "07_pricing-payment-rules",
    "8": "08_privacy-terms",
    "9-1": "09-1_base-funnels",
    "9-2": "09-2_value-messaging",
    "9-3": "09-3_sns-announcement",
    "10": "10_support-ops",
    "11": "11_post-release-metrics",
    "12": "12_this-week-priority",
    "13": "13_pre-release-gate",
}


HUMAN_KEYWORDS = [
    "実走",
    "実機",
    "テスター",
    "募集",
    "配布",
    "X",
    "Threads",
    "申請フォームへ登録",
    "支払い方法",
    "支払い",
    "審査",
    "ストア",
    "アップデート方針",
]


@dataclass
class Heading:
    key: str
    title: str
    level: int


@dataclass
class TaskItem:
    priority: str
    title: str
    status: str = "未着手"
    owner: str = "自分"
    memo_lines: List[str] = field(default_factory=list)


def classify_execution(title: str) -> str:
    if any(keyword in title for keyword in HUMAN_KEYWORDS):
        return "human"
    return "hybrid"


def build_draft_block(task: TaskItem) -> str:
    title = task.title
    if "通常版の提供範囲を1文で定義" in title:
        return (
            "- 提案文(案):\n"
            "  - レース中に判断を減らすため、目標タイムと走行状況に連動して行動・補給を提示するGarminデータフィールド。\n"
            "- 調整ポイント:\n"
            "  - 対象距離\n"
            "  - 無料提供範囲"
        )
    if "カスタム版の提供範囲を1文で定義" in title:
        return (
            "- 提案文(案):\n"
            "  - FIT分析とヒアリング結果を基に、個別最適化した設定値とカスタムコードを提供する伴走型サービス。\n"
            "- 調整ポイント:\n"
            "  - 納品物の範囲\n"
            "  - 料金に含むサポート回数"
        )
    if "提供範囲を1文で定義" in title:
        return (
            "- 提案文(案):\n"
            "  - レース中に判断を減らすため、目標タイムと走行状況に連動して行動・補給を提示するGarminデータフィールド。\n"
            "- 調整ポイント:\n"
            "  - 対象距離\n"
            "  - 通常版/カスタム版の境界"
        )
    if "対象ユーザー像" in title:
        return (
            "- ユーザー像(案):\n"
            "  - フル完走〜サブ4を目指す市民ランナー\n"
            "  - 補給タイミングやペース判断に不安がある人\n"
            "  - Garminウォッチを普段から使っている人\n"
            "- 除外条件(案):\n"
            "  - 医療的判断を求める用途"
        )
    if "比較表" in title:
        return (
            "| 項目 | 通常版 | カスタム版 |\n"
            "|---|---|---|\n"
            "| 提供内容 |  |  |\n"
            "| 利用シーン |  |  |\n"
            "| 料金 |  |  |\n"
            "| サポート |  |  |\n"
            "| 備考 |  |  |"
        )
    if "フォーム" in title:
        return (
            "- 目的: このフォームで収集する意思決定情報を明確化する\n"
            "- 入力項目案:\n"
            "  - 必須: 氏名/ハンドル、連絡先、使用機種\n"
            "  - 必須: 主なレース距離、試せる時期\n"
            "  - 任意: ラン歴、改善したい課題\n"
            "  - 同意: 利用規約/プライバシー同意\n"
            "- 送信後フロー:\n"
            "  - 受付通知\n"
            "  - 対応担当アサイン\n"
            "  - 返信SLA"
        )
    if "説明文" in title or "案内文" in title or "投稿文" in title or "告知文" in title:
        return (
            "- 見出し(案): レース中の判断負荷を減らすマラソン支援フィールド\n"
            "- 本文(下書き):\n"
            "  - 誰向けか: 補給やペース判断に不安があるランナー向け\n"
            "  - 何が解決されるか: 通知と表示で迷いを減らす\n"
            "  - 使い方の要点: 初回設定後はレース中に画面を確認するだけ\n"
            "  - 次のアクション: ベータ参加/ストア導線へ誘導\n"
            "- 注意事項: 過度な効能表現を避ける"
        )
    if "テンプレート" in title:
        return (
            "- セクション案:\n"
            "  - 概要\n"
            "  - 前提条件\n"
            "  - 入力値\n"
            "  - 出力値\n"
            "  - 注意点\n"
            "  - 問い合わせ先"
        )
    if "チェック" in title or "確認" in title:
        return (
            "- チェック観点:\n"
            "  - 正常系\n"
            "  - 境界値\n"
            "  - 異常系\n"
            "- 記録項目:\n"
            "  - 実施日時\n"
            "  - 端末/環境\n"
            "  - 結果(OK/NG)\n"
            "  - 備考"
        )
    if (
        "方針" in title
        or "ポリシー" in title
        or "ルール" in title
        or "確定" in title
        or "固定" in title
        or "決める" in title
        or "最終決定" in title
        or "最終化" in title
        or "見直す" in title
    ):
        return (
            "- 決定候補: A / B / C\n"
            "- 比較基準:\n"
            "  - ユーザー価値\n"
            "  - 実装/運用コスト\n"
            "  - リスク\n"
            "- 採用案(初期提案): A\n"
            "- 採用理由(初期提案): 公開前の運用負荷を最小化しやすい\n"
            "- 保留事項: 実運用データ取得後に再評価"
        )
    if "一覧" in title or "リスト" in title:
        return (
            "- 項目1:\n"
            "- 項目2:\n"
            "- 項目3:\n"
            "- 補足:"
        )
    if "削除" in title or "整理" in title:
        return (
            "- 対象の洗い出し\n"
            "- 削除/整理の判断基準\n"
            "- 影響範囲\n"
            "- 実施ログ"
        )
    if "出力する" in title:
        return (
            "- 実行コマンド:\n"
            "- 出力先:\n"
            "- 検証観点:\n"
            "- 失敗時の切り分け:"
        )
    return (
        "- 目的(案): 公開準備の判断を前倒しし、作業の手戻りを減らす\n"
        "- 成果物の最小要件(案): 1ページで判断可能な粒度\n"
        "- 草案内容(案): 現状・決定事項・保留事項・次アクション\n"
        "- 未確定事項: 実測や外部審査が必要な項目"
    )


def build_manual_steps(task: TaskItem, execution: str) -> str:
    title = task.title
    if execution == "human":
        if "実走" in title:
            return (
                "1. 実走の日時・コース・距離を事前に決める\n"
                "2. 走行中に視認性/通知タイミング/通知疲れを記録する\n"
                "3. 走行後に結果を `tasks` 配下の該当草案へ反映する"
            )
        if "X" in title or "Threads" in title or "投稿" in title:
            return (
                "1. 必要なら X/Threads アカウントを開設し、プロフィールと導線URLを整備する\n"
                "2. 草案文を最終調整し、投稿日時と再告知日時を決めて公開する\n"
                "3. 反応数・応募数を記録し、次の投稿改善に反映する"
            )
        if "募集" in title or "テスター" in title:
            return (
                "1. 草案を基に募集要件・受付方法・対象機種を最終決定する\n"
                "2. 実際の募集運用(告知、応募受付、返信)を実施する\n"
                "3. 応募状況を集計し、不足機種帯の追加募集に反映する"
            )
        if "申請フォームへ登録" in title or "ストア" in title:
            return (
                "1. 草案で不足項目がないか確認する\n"
                "2. Garmin Store 側フォームへ手入力で登録する\n"
                "3. 受付結果(審査IDやステータス)を記録する"
            )
        return (
            "1. この草案を意思決定の下書きとして確認する\n"
            "2. 実作業(外部サービス操作/実機操作)を実施する\n"
            "3. 実施結果を該当ファイルへ追記し、`TASKS.md` を更新する"
        )

    return (
        "1. 草案の空欄を埋めて最終版にする\n"
        "2. 必要に応じて関連ドキュメントへ転記する\n"
        "3. `TASKS.md` のステータスとメモを更新する"
    )


def build_done_criteria(task: TaskItem, execution: str) -> str:
    if execution == "human":
        return (
            "- 手作業を完了し、結果の証跡(スクリーンショット/URL/ログ)が残っている\n"
            "- `TASKS.md` の対象項目が更新されている"
        )
    return (
        "- 草案が最終化され、関連ドキュメントへ反映済み\n"
        "- `TASKS.md` の対象項目が更新されている"
    )


def parse_tasks(md_text: str) -> Dict[str, Dict[str, object]]:
    h2_re = re.compile(r"^##\s+(\d+(?:-\d+)?)\.\s+(.+?)\s*$")
    h3_re = re.compile(r"^###\s+(\d+(?:-\d+)?)\.\s+(.+?)\s*$")
    task_re = re.compile(r"^- \[ \] `(?P<priority>P\d)` (?P<title>.+?)\s*$")
    kv_re = re.compile(r"^\s+-\s+(ステータス|担当|メモ):\s*(.*)$")
    memo_sub_re = re.compile(r"^\s{4,}-\s+(.*)$")

    data: Dict[str, Dict[str, object]] = {}
    current_h2: Optional[Heading] = None
    current_h3: Optional[Heading] = None
    current_task: Optional[TaskItem] = None
    memo_mode = False

    def ensure_heading(heading: Heading) -> None:
        if heading.key not in data:
            data[heading.key] = {"heading": heading, "tasks": []}

    lines = md_text.splitlines()
    for raw_line in lines:
        line = raw_line.rstrip("\n")

        m2 = h2_re.match(line)
        if m2:
            current_h2 = Heading(key=m2.group(1), title=m2.group(2), level=2)
            current_h3 = None
            current_task = None
            memo_mode = False
            ensure_heading(current_h2)
            continue

        m3 = h3_re.match(line)
        if m3:
            current_h3 = Heading(key=m3.group(1), title=m3.group(2), level=3)
            current_task = None
            memo_mode = False
            ensure_heading(current_h3)
            continue

        mt = task_re.match(line)
        if mt:
            current_task = TaskItem(priority=mt.group("priority"), title=mt.group("title"))
            memo_mode = False
            active_heading = current_h3 if current_h3 is not None else current_h2
            if active_heading is None:
                continue
            ensure_heading(active_heading)
            data[active_heading.key]["tasks"].append(current_task)
            continue

        if current_task is None:
            memo_mode = False
            continue

        mkv = kv_re.match(line)
        if mkv:
            key, value = mkv.group(1), mkv.group(2).strip()
            if key == "ステータス":
                current_task.status = value or current_task.status
                memo_mode = False
            elif key == "担当":
                current_task.owner = value or current_task.owner
                memo_mode = False
            elif key == "メモ":
                memo_mode = True
                if value:
                    current_task.memo_lines.append(value)
            continue

        if memo_mode:
            mm = memo_sub_re.match(line)
            if mm:
                current_task.memo_lines.append(mm.group(1).strip())
                continue
            if line.strip() == "":
                continue
            memo_mode = False

    return data


def render_folder_doc(heading: Heading, tasks: List[TaskItem]) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines: List[str] = []
    lines.append(f"# {heading.key}. {heading.title}")
    lines.append("")
    lines.append(f"- Source: `TASKS.md`")
    lines.append(f"- Generated: `{now}`")
    lines.append("- Note: 草案のため、最終決定は人間が行う前提")
    lines.append("")

    for idx, task in enumerate(tasks, 1):
        execution = classify_execution(task.title)
        lines.append(f"## T{idx:02d} [{task.priority}] {task.title}")
        lines.append("")
        lines.append(f"- 元ステータス: {task.status}")
        lines.append(f"- 元担当: {task.owner}")
        lines.append(f"- 実行区分: {execution}")
        if task.memo_lines:
            lines.append("- 元メモ:")
            for memo in task.memo_lines:
                lines.append(f"  - {memo}")
        lines.append("")
        lines.append("### 成果物草案")
        lines.append(build_draft_block(task))
        lines.append("")
        lines.append("### あなたの実施手順")
        lines.append(build_manual_steps(task, execution))
        lines.append("")
        lines.append("### 完了条件")
        lines.append(build_done_criteria(task, execution))
        lines.append("")
        lines.append("### 証跡メモ")
        lines.append("- 実施日:")
        lines.append("- 記録URL/ファイル:")
        lines.append("- 残課題:")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def build_folder_name(heading_key: str) -> str:
    if heading_key in HEADING_FOLDER_MAP:
        return HEADING_FOLDER_MAP[heading_key]
    return f"z_{heading_key.replace('-', '_')}"


def main() -> None:
    if not TASKS_MD.exists():
        raise SystemExit("TASKS.md not found")

    parsed = parse_tasks(TASKS_MD.read_text(encoding="utf-8"))
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Clean only generated heading folders. Keep README if present and recreate it.
    for path in OUTPUT_DIR.iterdir():
        if path.is_dir():
            shutil.rmtree(path)

    summary_lines: List[str] = []
    summary_lines.append("# Task Drafts")
    summary_lines.append("")
    summary_lines.append("- Source: `TASKS.md`")
    summary_lines.append("- Scope: 見出しごとの草案を `draft.md` に生成")
    summary_lines.append("- Execution labels:")
    summary_lines.append("  - `hybrid`: 草案は自動生成、最終確定は手作業")
    summary_lines.append("  - `human`: 外部操作・実機確認など手作業主体")
    summary_lines.append("")

    ordered_keys = list(parsed.keys())
    ordered_keys.sort(key=lambda x: [int(p) for p in x.split("-")])

    for key in ordered_keys:
        heading = parsed[key]["heading"]
        tasks = parsed[key]["tasks"]
        if not tasks:
            continue
        folder = OUTPUT_DIR / build_folder_name(key)
        folder.mkdir(parents=True, exist_ok=True)
        draft_path = folder / "draft.md"
        draft_path.write_text(render_folder_doc(heading, tasks), encoding="utf-8")

        summary_lines.append(f"- `{folder.relative_to(ROOT)}`: {len(tasks)} tasks")

    summary_lines.append("")
    summary_lines.append("## Usage")
    summary_lines.append("")
    summary_lines.append("```bash")
    summary_lines.append("python3 scripts/generate_task_drafts.py")
    summary_lines.append("```")
    summary_lines.append("")

    (OUTPUT_DIR / "README.md").write_text("\n".join(summary_lines), encoding="utf-8")


if __name__ == "__main__":
    main()
