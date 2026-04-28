---
name: gatechecker-release-package
description: GateChecker の大会別公開配布用 `.iq` を作るスキル。ユーザーが「大会名とリリースバージョンでiqファイルを作って」「公開配布用iqを作って」「GateCheckerのリリースパッケージを作って」などと依頼したときに使う。大会名から `race_key` を特定し、必要なら version を指定して、`apps/GateChecker/scripts/build_gatechecker_release_package.sh` で公開配布用 `.iq` を生成し、出力先と使用した race/version を表示する。
---

# GateChecker Release Package

このスキルは、GateChecker の大会別リリースパッケージを「race 特定 -> version 確定 -> `.iq` 生成 -> 出力結果提示」の順で作る。

## Quick Flow

1. ユーザーが指定した大会名から `race_key` を特定する。
2. version 指定があればその値を使い、なければ `race_index.yml` の登録 version を使う。
3. `apps/GateChecker/scripts/build_gatechecker_release_package.sh <race_key> [version]` を実行する。
4. 生成された `.iq`、`BUILD.md`、関連スナップショットの出力先を確認する。
5. 最後に race 名、version、出力ファイルの絶対パスをユーザーへ伝える。

## Inputs

- ユーザーが大会名だけを言ったら、対応する `race_key` を `apps/GateChecker/race_defs/race_index.yml` と `apps/GateChecker/race_defs/races/` から特定する。
- ユーザーが release version も指定したら、その値を build 引数へ渡す。
- version が未指定なら、`race_index.yml` の登録値をそのまま使う。

## Command

```bash
apps/GateChecker/scripts/build_gatechecker_release_package.sh <race_key>
apps/GateChecker/scripts/build_gatechecker_release_package.sh <race_key> <version>
```

## Output Rules

- まず `.iq` 生成の成否を 1 行で伝える。
- 次に `race_key`、`version`、出力先ディレクトリを短く示す。
- 生成された主要ファイルとして少なくとも次を示す:
  - `.iq`
  - `BUILD.md`
  - `manifest.xml`
  - race YAML snapshot
- 失敗した場合は、どのステップで止まったかを短く伝える。

## Notes

- 配布用は `.prg` ではなく `.iq` を使う。
- 実体の build は `apps/GateChecker/scripts/build_gatechecker_release_package.sh` が担う。
- このスクリプトは一時ワークスペースを使うので、作業中の `apps/GateChecker` を直接汚さない。
- 署名鍵は既定で公開用キーを使う。必要なら `CIQ_RELEASE_KEY` を使う。
- 大会定義自体が未作成なら、このスキル単独で無理に進めず、先に `gatechecker-race-definition` を使う。

## Repo Pointers

- release build: `apps/GateChecker/scripts/build_gatechecker_release_package.sh`
- race index: `apps/GateChecker/race_defs/race_index.yml`
- race definitions: `apps/GateChecker/race_defs/races/`
- usage doc: `apps/GateChecker/README.md`
