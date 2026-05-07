# Build Memo

- built_at: `2026-05-07 23:33:21 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260620_grandmas_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `62c9a871-54d0-4afa-99a7-7ad0ae965e64`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260620_grandmas_marathon/0.1.0/gatechecker-20260620_grandmas_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260620_grandmas_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260620_grandmas_marathon/0.1.0/20260620_grandmas_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260620_grandmas_marathon/0.1.0/GateRaceConfig.mc`
- size: `2120392 bytes`
- sha256: `e283410f210def0d31accabc283f842671b5a15011e9cb0bf409774278fc3727`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260620_grandmas_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
