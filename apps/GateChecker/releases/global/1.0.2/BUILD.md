# Build Memo

- built_at: `2026-05-27 15:32:53 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `1.0.2`
- branch: `codex/remove-legacy-race-app-support`
- source_commit: `9ddb6d9f04c1c23c16f2ca88ef3eca83c1217347`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/global/1.0.2/gatechecker-global-1.0.2.iq`
- manifest: `apps/GateChecker/releases/global/1.0.2/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/1.0.2/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/1.0.2/supported_races.json`
- race_index: `apps/GateChecker/releases/global/1.0.2/race_index.yml`
- size: `2464741 bytes`
- sha256: `38dee96764ea3168b6f769549af22c03e25528c91c8c1421caa185435afac71a`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 1.0.2
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
