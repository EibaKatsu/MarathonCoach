# Build Memo

- built_at: `2026-05-02 15:54:18 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `flying_pig_marathon_2026`
- version: `1.1.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `6b445b4aefb50020f4d5e35221a275bba4ef14da`
- app_id: `d6f3337a-6862-4ca4-a252-7e0af48ab0c4`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/flying_pig_marathon_2026/1.1.0/gatechecker-flying_pig_marathon_2026-1.1.0.iq`
- manifest: `apps/GateChecker/releases/flying_pig_marathon_2026/1.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/flying_pig_marathon_2026/1.1.0/flying_pig_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/flying_pig_marathon_2026/1.1.0/GateRaceConfig.mc`
- size: `1922639 bytes`
- sha256: `57a5d7385e57ed3c096b5ffb31f44402714c9320d944f24ef48a9e611e2fd6c1`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh flying_pig_marathon_2026 1.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
