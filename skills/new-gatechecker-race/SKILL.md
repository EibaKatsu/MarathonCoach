---
name: new-gatechecker-race
description: 新しい GateChecker 対応レースを単一アプリ + Race Code 方針で追加するスキル。公式情報の確認から race_defs 更新、生成検証、サイト更新、テストまでを通す。
status: active
---

# New GateChecker Race

表示名: 新規関門ガイド大会追加

## Trigger
- `新規関門ガイド大会追加`
- `GateChecker に新しい大会を追加して`
- `Race Code 対応レースを追加して`

## Read first
- `apps/GateChecker/README.md`
- `skills/gatechecker-race-definition/SKILL.md`

## Default flow
1. 未取り込みレース候補を調査する。
2. 公式情報から関門、エイド、制限時間、コースを確認する。
3. `apps/GateChecker/race_defs/races/*.yml` を作成または更新する。
4. `apps/GateChecker/race_defs/race_index.yml` に登録する。
5. `Race Code` を設定または生成する。
6. `python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py` で検証する。
7. `apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm` で代表ビルド確認を行う。
8. 必要なら `apps/GateChecker/scripts/run_gatechecker_global_sim.sh --device fr57042mm` で確認し、対象 `Race Code` は app settings へ手入力して試す。
9. `python3 site/racenavi/scripts/generate_race_pages.py` で対応大会ページを更新する。
10. `./scripts/run_unit_tests.sh` を実行する。
11. PR 作成、独立レビュー、main マージまで進める。

## Commands
```bash
python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py
```

```bash
apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm
```

```bash
apps/GateChecker/scripts/run_gatechecker_global_sim.sh --device fr57042mm
```

```bash
python3 site/racenavi/scripts/generate_race_pages.py
```

```bash
./scripts/run_unit_tests.sh
```

## Output
- `race_id`
- 追加または更新したコース一覧
- 各コースの `Race Code`
- 取得元 URL
- 生成、ビルド、テスト結果

## Do not
- `build_gatechecker_global_release_package.sh` を通常フローに混ぜない。
- 大会別アプリ生成を前提にしない。
- 公式根拠が弱いまま race definition を確定しない。
