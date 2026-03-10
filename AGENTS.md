# AGENTS

このファイルは MarathonCoach プロジェクトのエントリーポイントです。
詳細仕様は分割先ファイルを参照してください。

## 重要ファイル（大文字）
- `AGENTS.md`: 本ファイル（索引）
- `PRODUCT.md`: プロダクト価値・対象・スコープ
- `PROCESS.md`: 実装/検証/PR/レビュー/マージの必須運用
- `RELEASE.md`: 公開方針と公開判定
- `TASKS.md`: 実行タスク管理

## スキル
A skill is a set of local instructions stored in a `SKILL.md` file.

### Available skills
- `ciq-simulator-launch`: `シミュレーション起動` / `run simulator` 指示時に使用
  - `skills/ciq-simulator-launch/SKILL.md`
- `custom-code-generator`: `カスタムコード` 指示時に使用
  - `skills/custom-code-generator/SKILL.md`

### How to use skills
- Trigger rules: ユーザーがスキル名やトリガー文言を指定したらそのスキルを使う。
- Read policy: まず `SKILL.md` を開き、必要な参照ファイルだけ読む。
- Script policy: `scripts/` がある場合はスクリプト実行を優先する。

## 仕様（小文字）
- `docs/spec/core.md`: 通常版の仕様
- `docs/spec/custom_mode.md`: カスタムモード仕様
- `docs/spec/ui.md`: UI方針、文言、多言語、レイアウト
- `docs/spec/logic_hr_zone.md`: レースプロファイル/HR ZONEロジック
- `docs/spec/logic_action.md`: ACTION判定
- `docs/spec/logic_drift.md`: DRIFT検知
- `docs/spec/logic_fuel.md`: FUEL判定、LAPリセット、表示優先
- `docs/spec/distance_cards.md`: 距離通知カード

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

## 備考
- `AGENT.md` は廃止し、以後は本構成を正とする。
