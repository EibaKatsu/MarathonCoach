# Build Memo

- built_at: `2026-05-02 20:36:04 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `ing_night_marathon_luxembourg_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-mile-packaging`
- source_commit: `27a83a35c4104742bd48367e3ff0f017fda1f93c`
- app_id: `737184ed-a25a-4446-a4f9-ecfdc9fe4ff1`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/ing_night_marathon_luxembourg_2026/0.1.0/gatechecker-ing_night_marathon_luxembourg_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/ing_night_marathon_luxembourg_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/ing_night_marathon_luxembourg_2026/0.1.0/ing_night_marathon_luxembourg_2026.yml`
- generated_source: `apps/GateChecker/releases/ing_night_marathon_luxembourg_2026/0.1.0/GateRaceConfig.mc`
- size: `1922893 bytes`
- sha256: `5b5908017ff7535989175574c0a73c4ab6fda2f009e4c57e5f508c87fa8248e8`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh ing_night_marathon_luxembourg_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
