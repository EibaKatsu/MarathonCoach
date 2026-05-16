# Build Memo

- built_at: `2026-05-16 21:33:17 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `0.1.0`
- branch: `codex/gatechecker-global-release-0.1.0`
- source_commit: `cf65c90132055761c8764c1d3ade071d60eb5fbc`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/global/0.1.0/gatechecker-global-0.1.0.iq`
- manifest: `apps/GateChecker/releases/global/0.1.0/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/0.1.0/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/0.1.0/supported_races.json`
- race_index: `apps/GateChecker/releases/global/0.1.0/race_index.yml`
- size: `2419542 bytes`
- sha256: `a0c2e39ff5a38d75f504a1171143f57d57cd4fc106e6c5a6acfb75325f56d0b3`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 0.1.0
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
