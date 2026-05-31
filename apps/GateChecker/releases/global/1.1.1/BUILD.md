# Build Memo

- built_at: `2026-06-01 08:35:40 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `1.1.1`
- branch: `codex/remove-legacy-race-app-support`
- source_commit: `f4930834d8121194f319934dc5226c00fa0c17c1`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/.secure/racenavi/connectiq/developer_key`
- output: `apps/GateChecker/releases/global/1.1.1/gatechecker-global-1.1.1.iq`
- manifest: `apps/GateChecker/releases/global/1.1.1/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/1.1.1/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/1.1.1/supported_races.json`
- race_index: `apps/GateChecker/releases/global/1.1.1/race_index.yml`
- size: `2751260 bytes`
- sha256: `aa12b8d6497d2284049734d07101b1e27b97e213d089eb2d111afa744542be94`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/.secure/racenavi/connectiq/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 1.1.1
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
