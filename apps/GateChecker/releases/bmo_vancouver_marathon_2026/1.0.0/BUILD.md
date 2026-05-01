# Build Memo

- built_at: `2026-05-01 22:15:01 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `bmo_vancouver_marathon_2026`
- version: `1.0.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `56262bb23e13c8e8376af307ea93f9d7ee50a82e`
- app_id: `5435b1ff-486b-4355-9c14-542b631f266c`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.0.0/gatechecker-bmo_vancouver_marathon_2026-1.0.0.iq`
- manifest: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.0.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.0.0/bmo_vancouver_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.0.0/GateRaceConfig.mc`
- size: `1858680 bytes`
- sha256: `65c8829187dc16c34a0d226339b55d6b0744ea3acce892a1fce7ddd9cbaabe9e`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh bmo_vancouver_marathon_2026 1.0.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
