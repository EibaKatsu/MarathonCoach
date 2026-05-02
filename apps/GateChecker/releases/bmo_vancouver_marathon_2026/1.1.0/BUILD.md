# Build Memo

- built_at: `2026-05-02 15:53:31 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `bmo_vancouver_marathon_2026`
- version: `1.1.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `6b445b4aefb50020f4d5e35221a275bba4ef14da`
- app_id: `5435b1ff-486b-4355-9c14-542b631f266c`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.1.0/gatechecker-bmo_vancouver_marathon_2026-1.1.0.iq`
- manifest: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.1.0/bmo_vancouver_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/bmo_vancouver_marathon_2026/1.1.0/GateRaceConfig.mc`
- size: `1922389 bytes`
- sha256: `ccfa7eff27aa582b609d05416c8a6fc676f0c49bcf273749546a399ce08707b2`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh bmo_vancouver_marathon_2026 1.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
