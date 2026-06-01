---
name: gatechecker-release-package
description: GateChecker の署名付き release package を作る legacy スキル。通常フローでは使わず、明示的に `.iq` パッケージが必要なときだけ使う。
status: legacy
---

# GateChecker Release Package

## Trigger
- `GateChecker の release package を作って`
- `署名付き .iq を作って`

## Read first
- `apps/GateChecker/README.md`
- `skills/gatechecker-global-build/SKILL.md`

## Default flow
1. このスキルは legacy 扱いであることを明示する。
2. 通常の Race Code 追加や定義更新では使わず、必要時だけ `.iq` 生成に進む。
3. `apps/GateChecker/scripts/build_gatechecker_global_release_package.sh <version> [output_dir]` を実行する。
4. 出力された `.iq`、`BUILD.md`、race snapshot を確認する。

## Commands
```bash
apps/GateChecker/scripts/build_gatechecker_global_release_package.sh <version> [output_dir]
```

## Output
- version
- 出力された `.iq` のパス
- `BUILD.md` の有無
- 通常フローではないことの注記

## Notes
- 通常は使わない。単一アプリ + Race Code 方式の日常作業では `gatechecker-global-build` を使う。
- 旧来の「大会別 .iq」発想の代わりに、現行コマンドは単一グローバルアプリの signed package を作る。

## Do not
- Race Code 追加や race definition 修正の通常フローにこのスキルを混ぜない。
- 鍵ファイルの探索、表示、編集をしない。
