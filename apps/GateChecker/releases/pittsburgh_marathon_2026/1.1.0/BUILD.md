# Build Memo

- built_at: `2026-05-02 15:55:08 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `pittsburgh_marathon_2026`
- version: `1.1.0`
- branch: `codex/gatechecker-aid-label-clearance`
- source_commit: `6b445b4aefb50020f4d5e35221a275bba4ef14da`
- app_id: `bef26e98-9cdd-4201-ab4a-89fc6ce2e5f9`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.1.0/gatechecker-pittsburgh_marathon_2026-1.1.0.iq`
- manifest: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.1.0/pittsburgh_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/pittsburgh_marathon_2026/1.1.0/GateRaceConfig.mc`
- size: `1923663 bytes`
- sha256: `48bd83842ea948473eb5a2edd44839586caacf52368fdae7d77c384fd621c40f`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh pittsburgh_marathon_2026 1.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
