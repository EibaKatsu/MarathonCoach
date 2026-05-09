# Build Memo

- built_at: `2026-05-09 13:47:50 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20261101_toyama_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `214f6dbb-0476-4778-a81b-eb9c7afc901d`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20261101_toyama_marathon/1.0.1/gatechecker-20261101_toyama_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20261101_toyama_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20261101_toyama_marathon/1.0.1/20261101_toyama_marathon.yml`
- generated_source: `apps/GateChecker/releases/20261101_toyama_marathon/1.0.1/GateRaceConfig.mc`
- size: `2176892 bytes`
- sha256: `81fa16bb7a0d2f2c3b0f6d36af9c9696e514a8fa7cd01bc52dc193174ab54e78`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20261101_toyama_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
