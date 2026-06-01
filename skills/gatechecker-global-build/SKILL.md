---
name: gatechecker-global-build
description: GateChecker の単一アプリ + Race Code 方式で、全 race 生成、代表デバイスビルド、必要時の Simulator 確認を行うスキル。
status: active
---

# GateChecker Global Build

## Trigger
- `GateChecker をビルドして`
- `GateChecker global build`
- `GateChecker の生成結果を確認して`

## Read first
- `apps/GateChecker/README.md`

## Default flow
1. `python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py` を実行する。
2. 必要な生成ファイルが更新されたことを確認する。
3. `apps/GateChecker/scripts/build_gatechecker_global.sh <device_id>` で代表ビルドを行う。
4. Simulator 確認が必要なら `apps/GateChecker/scripts/run_gatechecker_global_sim.sh --device <device_id>` を使う。
5. Race Code の確認は、起動後に Garmin Connect 設定へ対象コードを入力して行う。

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

## Output
- `GateRaceConfig.mc` 生成結果
- `supported_races.json` 生成結果
- 生成または更新された PRG パス
- 実行した検証コマンドと結果

## Notes
- 現在の Simulator スクリプトは `--race-code` 引数を受け取らない。
- Race Code の確認は、起動後に実際の app settings で行う。

## Do not
- 大会別アプリ生成を前提にしない。
- 生成検証なしでビルドだけ通して完了扱いにしない。
