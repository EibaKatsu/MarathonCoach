# Build Memo

- built_at: `2026-05-09 13:46:55 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260628_lake_saroma_100km_ultra_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `662bad21-6d5e-4b20-949a-e27b75c8e3b7`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/1.0.1/gatechecker-20260628_lake_saroma_100km_ultra_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/1.0.1/20260628_lake_saroma_100km_ultra_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/1.0.1/GateRaceConfig.mc`
- size: `2183570 bytes`
- sha256: `2b84b358f446c3e614328ccd5b6df464343c2ded7cbadf9bb83ca83512e87f92`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260628_lake_saroma_100km_ultra_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
