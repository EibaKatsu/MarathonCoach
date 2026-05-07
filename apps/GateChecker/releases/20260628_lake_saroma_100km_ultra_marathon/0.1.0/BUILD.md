# Build Memo

- built_at: `2026-05-07 23:35:37 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260628_lake_saroma_100km_ultra_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `662bad21-6d5e-4b20-949a-e27b75c8e3b7`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/0.1.0/gatechecker-20260628_lake_saroma_100km_ultra_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/0.1.0/20260628_lake_saroma_100km_ultra_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260628_lake_saroma_100km_ultra_marathon/0.1.0/GateRaceConfig.mc`
- size: `2129603 bytes`
- sha256: `234389e2e2f393575340723737cb68474aa909b128a6e255d25da8f29e8fd502`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260628_lake_saroma_100km_ultra_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
