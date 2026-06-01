---
name: gatechecker-race-definition
description: GateChecker の race definition を単一アプリ + Race Code 方針で作成または更新するスキル。`race_id`、`courses[].course_id`、`courses[].course_name`、`courses[].race_code` を揃え、`race_defs` と `race_index` を更新して全体生成で検証する。
status: active
---

# GateChecker Race Definition

## Trigger
- `GateCheckerに○○の関門データを設定して`
- `大会設定ファイルを作って`
- `大会名から race 定義を作って`

## Read first
- `apps/GateChecker/README.md`
- `apps/GateChecker/race_defs/race_index.yml`
- `apps/GateChecker/race_defs/races/20261101_toyama_marathon.yml`

## Default flow
1. 公式サイト、公式要項、公式コースページ、公式 PDF/JPG コースマップを優先して確認する。
2. `race_id`、大会名、開催日、タイムゾーン、コース一覧を整理する。
3. 各コースについて `course_id`、`course_name`、距離、関門、エイド、`race_code` の有無を整理する。
4. `apps/GateChecker/race_defs/races/<race_id>.yml` を作成または更新する。
5. `apps/GateChecker/race_defs/race_index.yml` に `race_id` と file entry を追加または更新する。
6. `race_code` が未確定なら `generate_race_code.py` を使って候補を作る。
7. `python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py` で全体生成と検証を行う。
8. 必要なら `apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm` で代表ビルドを確認する。

## Commands
```bash
python3 apps/GateChecker/scripts/generate_race_code.py \
  --race-id <race_id> \
  --course-id <course_id> \
  --year <year> \
  --race-abbr <abbr> \
  --course-label <label>
```

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py
```

```bash
apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm
```

## Validation
- `race_id` が `race_index.yml` と race file で一致していることを確認する。
- `race_code` が全コースで一意で、空でなく、重複していないことを確認する。
- `course_id` が同一 race 内で一意であることを確認する。
- `distance_km` と `distance_mi` が排他的であることを確認する。
- `gates` と `aids` が昇順であることを確認する。
- `GOAL` sentinel が最後に 1 回だけ出ることを確認する。
- `gates[].point` / `gates[].point_mi`、`aids[].km` / `aids[].mi` が混在していないことを確認する。
- 検証失敗時は推測で直さず、公式根拠とのズレを先に確認する。

## Output
- `race_key`（file stem）と `race_id`
- 追加または更新したコース一覧
- 各コースの `course_id` と `Race Code`
- 使用した取得元 URL 一覧
- 実行した検証コマンドと結果
- 推定で補完した項目があればその明示

## Do not
- 大会別アプリ生成を前提にしない。
- `generate_gatechecker_all_races.py` を飛ばして完了扱いにしない。
- 非公式まとめサイトだけを根拠に関門やエイドを確定しない。
