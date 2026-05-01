# Build Memo

- built_at: `2026-05-01 22:16:17 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `flying_pig_marathon_2026`
- version: `1.0.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `56262bb23e13c8e8376af307ea93f9d7ee50a82e`
- app_id: `d6f3337a-6862-4ca4-a252-7e0af48ab0c4`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/flying_pig_marathon_2026/1.0.0/gatechecker-flying_pig_marathon_2026-1.0.0.iq`
- manifest: `apps/GateChecker/releases/flying_pig_marathon_2026/1.0.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/flying_pig_marathon_2026/1.0.0/flying_pig_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/flying_pig_marathon_2026/1.0.0/GateRaceConfig.mc`
- size: `1859498 bytes`
- sha256: `78d27804892294f4a790cb377a75e0109c805f3b80a6fd82d272209fc827893e`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh flying_pig_marathon_2026 1.0.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
