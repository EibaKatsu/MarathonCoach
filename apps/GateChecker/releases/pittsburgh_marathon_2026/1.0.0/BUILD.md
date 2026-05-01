# Build Memo

- built_at: `2026-05-01 22:16:15 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `pittsburgh_marathon_2026`
- version: `1.0.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `56262bb23e13c8e8376af307ea93f9d7ee50a82e`
- app_id: `bef26e98-9cdd-4201-ab4a-89fc6ce2e5f9`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.0.0/gatechecker-pittsburgh_marathon_2026-1.0.0.iq`
- manifest: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.0.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.0.0/pittsburgh_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.0.0/GateRaceConfig.mc`
- size: `1858380 bytes`
- sha256: `11f1b1118713b6f20e669c6e14d16fc72ee6e002b88c5239cfc1c4338521da39`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh pittsburgh_marathon_2026 1.0.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
