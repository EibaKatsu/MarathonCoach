# Build Memo

- built_at: `2026-04-28 17:19:55 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `iwate_oshu_kirameki_marathon_2026`
- version: `0.1.0`
- branch: `codex/update-store-assets`
- source_commit: `70b8c17c503645a37fa933e1e373d11f21d9af5f`
- app_id: `e7edc6e6-be37-4774-8069-4a115ddc67bd`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/iwate_oshu_kirameki_marathon_2026/0.1.0/gatechecker-iwate_oshu_kirameki_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/iwate_oshu_kirameki_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/iwate_oshu_kirameki_marathon_2026/0.1.0/iwate_oshu_kirameki_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/iwate_oshu_kirameki_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `1782533 bytes`
- sha256: `bdcadc495bd571373fb548347ba38597563be7ddbd6e14b986e52c61cba2691e`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh iwate_oshu_kirameki_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
