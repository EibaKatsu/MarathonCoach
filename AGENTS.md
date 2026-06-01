# AGENTS

このファイルは MarathonCoach リポジトリの索引です。
通常版の正は `docs/spec/core.md`、GateChecker の正は `apps/GateChecker/README.md` とし、細部は各分割先ファイルを参照してください。

## 重要ファイル（大文字）
- `AGENTS.md`: 本ファイル（索引）
- `PRODUCT.md`: プロダクト価値・対象・スコープ
- `PROCESS.md`: 実装/検証/PR/レビュー/マージの必須運用
- `RELEASE.md`: 公開方針と公開判定
- `TASKS.md`: 実行タスク管理

## 正となる仕様
- `docs/spec/core.md`: MarathonCoach / RaceNavi Core の通常版仕様
- `docs/spec/custom_code.md`: カスタムコード仕様
- `apps/GateChecker/README.md`: GateChecker の単一アプリ + Race Code 方針

## スキル
A skill is a set of local instructions stored in a `SKILL.md` file.

### Available skills
- `ciq-simulator-launch`
  - status: `active`
  - trigger: `シミュレーション起動` / `run simulator`
  - path: `skills/ciq-simulator-launch/SKILL.md`
- `custom-code-generator`
  - status: `active`
  - trigger: `カスタムコード`
  - path: `skills/custom-code-generator/SKILL.md`
- `gatechecker-global-build`
  - status: `active`
  - trigger: `GateChecker をビルドして` / `GateChecker global build`
  - path: `skills/gatechecker-global-build/SKILL.md`
- `gatechecker-race-definition`
  - status: `active`
  - trigger: `GateCheckerに○○の関門データを設定して` / `大会設定ファイルを作って` / `大会名から race 定義を作って`
  - path: `skills/gatechecker-race-definition/SKILL.md`
- `gatechecker-release-package`
  - status: `legacy`
  - trigger: `GateChecker の release package を作って` / `署名付き .iq を作って`
  - path: `skills/gatechecker-release-package/SKILL.md`
  - notes: 通常は使わない。日常作業は `gatechecker-global-build` と Race Code 追加フローを使う。
- `new-gatechecker-race`
  - status: `active`
  - trigger: `新規関門ガイド大会追加` / `GateChecker に新しい大会を追加して`
  - path: `skills/new-gatechecker-race/SKILL.md`
- `note-post-writer`
  - status: `active`
  - trigger: `note投稿文を作って` / `note記事の下書きを作って` / `既存のnoteの流れを見て次の記事案を出して`
  - path: `skills/note-post-writer/SKILL.md`
- `x-post-writer`
  - status: `active`
  - trigger: `X投稿文を作って` / `次の投稿を考えて` / `ポスト文を考えて`
  - path: `skills/x-post-writer/SKILL.md`

### How to use skills
- Trigger rules: ユーザーがスキル名やトリガー文言を指定したらそのスキルを使う。
- Read policy: まず `SKILL.md` を開き、必要な参照ファイルだけ読む。
- Script policy: `scripts/` がある場合はスクリプト実行を優先する。
- GateChecker policy: 通常フローは `race_defs` 更新 -> `generate_gatechecker_all_races.py` -> `build_gatechecker_global.sh`。大会別アプリ生成の legacy workflow は通常使わない。

## 仕様（小文字）
- `docs/spec/core.md`: 通常版の仕様
- `docs/spec/custom_code.md`: カスタムコード仕様
- `docs/spec/ui.md`: UI方針、文言、多言語、レイアウト
- `docs/spec/logic_hr_zone.md`: レースプロファイル/HR ZONE/CAP anchor ロジック
- `docs/spec/logic_action.md`: ACTION判定
- `docs/spec/logic_drift.md`: DRIFT廃止メモ
- `docs/spec/logic_fuel.md`: 補給仕様の廃止メモ
- `docs/spec/distance_cards.md`: 距離通知廃止メモ
- `docs/dev/message_integration_memo.md`: MessageInGarmin風カード統合メモ

## 開発運用（小文字）
- `docs/dev/step_plan.md`: 段階開発STEPと進行状況
- `docs/dev/simulator_checklist.md`: シミュレーション確認観点
- `docs/dev/debug_logging.md`: 不具合切り分け時の診断ログ方針

## 公開運用（小文字）
- `docs/release/store_submission.md`: Garmin Store申請準備
- `docs/release/beta_test.md`: ベータテスト運用
- `docs/release/promotion.md`: 宣伝準備

## ポリシー（小文字）
- `docs/policy/privacy.md`: プライバシー方針（簡易）
- `docs/policy/terms.md`: 利用ルール（簡易）

## 実行ルール要約
- コード修正時は原則として `修正 -> テスト -> PR作成 -> 独立レビュー -> マージ` を実施する。
- ユーザーが「ローカルのみ」と明示した場合のみ、`PR作成/独立レビュー/マージ` を省略できる。
- 新機能追加は原則ストップし、公開に必要な品質向上を優先する。
- RaceNavi Core の判断で迷った場合は `docs/spec/core.md` を正とし、古いメモや legacy タスク記述より優先する。
- GateChecker の判断で迷った場合は `apps/GateChecker/README.md` を正とし、単一アプリ + Race Code 方針を優先する。
- 原因未特定のクラッシュや異常系では、まず `PROCESS.md` の診断ログ方針に従って `入力値 / 判定結果 / 表示値` を採取し、原因特定前に推測の修正やフォールバック追加を進めない。
- Codex への実行モード指定は、今後の既定として `/fast off` を維持する。

## 秘密鍵運用
- `developer_key` は今回の作業対象外。
- `developer_key` の削除・再生成・移動・コミットは禁止。
- 必要な参照は既存の `CIQ_DEV_KEY` / `CIQ_RELEASE_KEY` 運用に従い、鍵の中身は表示しない。

## 備考
- `AGENT.md` は廃止し、以後は本構成を正とする。
