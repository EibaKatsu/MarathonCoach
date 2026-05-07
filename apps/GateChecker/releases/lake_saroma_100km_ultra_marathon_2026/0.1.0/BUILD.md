# Build Memo

- built_at: `2026-05-07 22:16:03 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `lake_saroma_100km_ultra_marathon_2026`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `932a5fab1984a70ea08555797efcecd9d87b28a0`
- app_id: `662bad21-6d5e-4b20-949a-e27b75c8e3b7`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/lake_saroma_100km_ultra_marathon_2026/0.1.0/gatechecker-lake_saroma_100km_ultra_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/lake_saroma_100km_ultra_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/lake_saroma_100km_ultra_marathon_2026/0.1.0/lake_saroma_100km_ultra_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/lake_saroma_100km_ultra_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `2129781 bytes`
- sha256: `26e2561e23c93726fb5d5ece343307a185a263f4b34dd729b2725b0e40739569`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh lake_saroma_100km_ultra_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
