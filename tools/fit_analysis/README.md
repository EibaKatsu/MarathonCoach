# fit_analysis

`fit_analysis` は、MarathonCoach のカスタム版運用向けに使うローカル CLI ツールです。公開版アプリへ FIT 自動取り込みや分析 UI を入れるためのものではなく、サービス提供側で「同じ入力なら同じ出力」を優先して個別設定を作るための外部分析ツールとして設計しています。

このツールは Garmin の `.fit`、ランナープロファイル、ヒアリング情報、固定ルールファイルを入力にして、通常版ロジック準拠の baseline CAP、ルールベース補正後の S1〜S5、理由つきレポート、C2 形式の Custom Code を出力します。加えて、client delivery 文章は AI または deterministic template で生成できます。

## 役割

- MarathonCoach 通常版アプリの心拍 CAP ロジックを、外部分析ツールとして再現する
- FIT とヒアリングをもとに、deterministic な補正ルールで S1〜S5 を調整する
- 納品用の `JSON / Markdown / HTML / text` をまとめて出力する
- `rule_version` と入力 hash を残し、後から同条件で追跡できるようにする
- AI を使う場合も、文章整形だけに責務を限定する

## インストール

`garmin-fit-sdk` と `PyYAML` を使います。開発時は次のどちらかで実行してください。

```bash
cd tools/fit_analysis
python3 -m pip install -e .
python3 -m fit_analysis.cli --help
```

または一時実行なら:

```bash
PYTHONPATH=tools/fit_analysis/src python3 -m fit_analysis.cli --help
```

ローカルに `tools/fit_analysis/_vendor` がある場合は、そこに入った Garmin 公式 SDK も自動で探索します。

## AI 文章生成について

- 数値計算はこれまでどおり deterministic です
- AI が担当するのは `client_delivery.md` / `client_delivery.html` の文章化だけです
- AI は `analysis_result.json` を直接書き換えません
- AI には、`analysis_result.json` から抽出した `narrative_input` 相当の構造化データだけを渡します
- AI が失敗した場合は deterministic template に自動 fallback できます

責務分離:

- deterministic:
  - `fit_loader.py`
  - `quality_gate.py`
  - `race_profile.py`
  - `metric_engine.py`
  - `baseline_engine.py`
  - `adjustment_engine.py`
  - `code_encoder.py`
- AI / client report:
  - `prompt_builder.py`
  - `narrative_generator.py`
  - `narrative_validator.py`
  - `fallback_template_renderer.py`
  - `client_delivery_renderer.py`

## 入力ファイル形式

### 1. `activity.fit`

- Garmin Connect などから取得した `.fit`
- v1 は 1 ファイル入力
- 必須読込列:
  - `timestamp`
  - `distance`
  - `heart_rate`
  - `speed` または `enhanced_speed`
  - `pace` 相当値

### 2. `runner_profile.json`

最低限、次のキーを受け取ります。

```json
{
  "runner_id": "runner-001",
  "goal_race": "Tokyo Marathon",
  "race_distance_km": 42.195,
  "goal_time": "4:00:00",
  "pb_full": "4:07:30",
  "pb_half": "1:53:40",
  "lthr_bpm": 160,
  "device_lthr_bpm": 158,
  "max_hr": 186,
  "resting_hr": 50,
  "watch_model": "Forerunner 255"
}
```

### 3. `hearing.json`

最低限、次のキーを受け取ります。

```json
{
  "condition_note": "後半に脚が重くなった",
  "heat_impact": "none",
  "fueling_actual": "late",
  "stomach_issue": false,
  "cramp": true,
  "limit_factor": "後半の脚持ち",
  "next_plan_preference": "balanced"
}
```

### 4. `rules_v1.yaml`

次を保持します。

- 品質判定閾値
- baseline 係数表
- 安全クリップ
- 補正ルール閾値
- ヒアリング起因の保守補正
- 7項目説明文の判定閾値

## 実行方法

```bash
cd tools/fit_analysis
python3 -m fit_analysis.cli \
  --fit /path/to/activity.fit \
  --profile tests/fixtures/sample_runner_profile.json \
  --hearing tests/fixtures/sample_hearing.json \
  --rules configs/rules_v1.yaml \
  --out /tmp/fit-analysis-output \
  --generated-at 2026-04-13T00:00:00+00:00
```

`--generated-at` は golden test や再生成比較向けの固定値オプションです。省略時は現在 UTC を `audit.json` と `analysis_result.json` に記録します。

### client delivery を template で作る

```bash
python3 -m fit_analysis.cli \
  --fit /path/to/activity.fit \
  --profile tests/fixtures/sample_runner_profile.json \
  --hearing tests/fixtures/sample_hearing.json \
  --rules configs/rules_v1.yaml \
  --client-report-mode template \
  --out /tmp/fit-analysis-output
```

### client delivery を AI 優先、失敗時 fallback で作る

```bash
export OPENAI_API_KEY=YOUR_KEY

python3 -m fit_analysis.cli \
  --fit /path/to/activity.fit \
  --profile tests/fixtures/sample_runner_profile.json \
  --hearing tests/fixtures/sample_hearing.json \
  --rules configs/rules_v1.yaml \
  --client-report-mode auto \
  --llm-model gpt-5 \
  --save-llm-audit true \
  --out /tmp/fit-analysis-output
```

### AI 生成を必須にする

```bash
export OPENAI_API_KEY=YOUR_KEY

python3 -m fit_analysis.cli \
  --fit /path/to/activity.fit \
  --profile tests/fixtures/sample_runner_profile.json \
  --hearing tests/fixtures/sample_hearing.json \
  --rules configs/rules_v1.yaml \
  --client-report-mode ai \
  --llm-model gpt-5 \
  --llm-timeout 30 \
  --out /tmp/fit-analysis-output
```

`ai` モードでは LLM 呼び出しや validation が失敗すると明示的にエラー終了します。`auto` モードでは AI を試したあと、失敗時に template fallback します。

## AI 関連設定

既定設定は `configs/llm_v1.yaml` です。

```yaml
provider: openai
model: gpt-5
temperature: 0.2
max_output_tokens: 1800
timeout_sec: 30
save_audit: true
save_raw_response: true
```

必要な環境変数:

- `OPENAI_API_KEY`
- 任意: `OPENAI_MODEL`
- 任意: `OPENAI_BASE_URL`
- 任意: `OPENAI_ORGANIZATION`
- 任意: `OPENAI_PROJECT`

## 出力物

- `analysis_result.json`
  - 機械可読の主出力
  - baseline、指標、補正ルール、最終 S1〜S5、C2 コードを含む
- `delivery_report.md`
  - 一般ランナー向けの Markdown レポート
- `delivery_report.html`
  - シンプルなブラウザ閲覧用 HTML
- `custom_code.txt`
  - 最終 C2 コード 1 行
- `audit.json`
  - 入力ファイル名、sha256、使用ルール、適用ルール、生成日時を記録
- `client_delivery.md`
  - クライアント向け納品文章の Markdown
- `client_delivery.html`
  - クライアント向け納品文章の HTML
- `llm_generation_audit.json`
  - AI 生成時、または template/auto の監査ログ

## ロジックの分離

- `baseline_engine.py`
  - MarathonCoach 通常版仕様どおりに baseline CAP を決める
  - 優先順位は `property LTHR -> device LTHR -> HRR -> MaxHR`
  - direct CAP は入力に使わない
- `adjustment_engine.py`
  - baseline へ後付けで固定ルール補正を適用する
  - 前半抑制、中盤安定化、終盤失速対策、終盤余力、ヒアリング保守補正を管理する

この分離により、「通常版ロジック由来の基準値」と「個別調整由来の差分」を JSON / audit / レポートで追跡できます。

## 再現性の担保

- 数値決定はすべて固定ルールベース
- 係数表と閾値は `configs/rules_v1.yaml` に固定
- JSON 出力は `sort_keys=True` で安定化
- C2 コードは encode 後に decode して往復検証
- 入力 `.fit` / `json` / `yaml` の hash を `audit.json` に保存
- テンプレート文面は固定で、自由生成文を使わない
- golden test では `--generated-at` を固定して比較
- AI を使う場合も、validator で必須セクション・主要数値・Custom Code 一致を確認
- AI 出力が不正なら `auto` で template fallback、`ai` ではエラー終了

## ルール更新時の注意

- `rules_v1.yaml` の値を変えると、同じ入力でも結果が変わります
- ルール更新時は `version` を必ず更新してください
- baseline 係数や clip 条件を変える場合は、通常版 `docs/spec/logic_hr_zone.md` と整合しているか確認してください
- golden test の expected も更新し、差分を確認してください
- `llm_v1.yaml` の更新は文章スタイルと LLM 呼び出し条件に影響します
- `llm_v1.yaml` を変えても deterministic な数値計算結果は変わりません

## テスト

```bash
PYTHONPATH=tools/fit_analysis/src:tools/fit_analysis/_vendor \
python3 -m unittest discover -s tools/fit_analysis/tests -t .
```

テスト内容:

- race profile 判定
- phase segmentation
- baseline 算出
- adjustment rule 適用
- C2 encode/decode
- quality gate
- deterministic e2e golden
- narrative_input 組み立て
- validator
- fallback 切り替え
- mocked LLM success / failure
- template / auto / ai 相当の client delivery e2e

## `llm_generation_audit.json` の見方

主なフィールド:

- `mode`
  - `template / ai / auto`
- `provider`, `model`
  - 利用した LLM 設定
- `prompt_version`
  - prompt のバージョン
- `prompt`
  - system / user prompt
- `input_hash`
  - narrative input の hash
- `narrative_input`
  - AI に渡した構造化データ
- `raw_response`
  - LLM の生応答
  - `save_raw_response: false` なら保存しません
- `validation_result`
  - 必須セクションや数値一致の検証結果
- `fallback_used`
  - fallback が使われたかどうか
- `error`
  - 失敗時の理由

## 注意事項

- このツールは医療判断を行うものではありません
- 体調異常、痛み、既往歴、熱中症リスクなどの医学的判断は別途必要です
- MarathonCoach 公開版アプリとは役割が異なります
  - 公開版: レース中の 1 画面ダッシュボード
  - 本ツール: サービス提供側で行うレース後分析と個別設定作成
