# Build Memo

- built_at: `2026-06-01 08:34:10 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `1.1.0`
- branch: `codex/remove-legacy-race-app-support`
- source_commit: `f4930834d8121194f319934dc5226c00fa0c17c1`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/.secure/racenavi/connectiq/developer_key`
- output: `apps/GateChecker/releases/global/1.1.0/gatechecker-global-1.1.0.iq`
- manifest: `apps/GateChecker/releases/global/1.1.0/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/1.1.0/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/1.1.0/supported_races.json`
- race_index: `apps/GateChecker/releases/global/1.1.0/race_index.yml`
- size: `2750370 bytes`
- sha256: `c2bb64db334d4d612d10c8a72f6f3a1493603c9fe7a599ed969b94b012fa0782`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/.secure/racenavi/connectiq/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 1.1.0
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
