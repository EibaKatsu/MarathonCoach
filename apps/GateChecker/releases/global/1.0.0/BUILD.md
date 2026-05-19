# Build Memo

- built_at: `2026-05-18 18:49:49 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `1.0.0`
- branch: `codex/gatechecker-global-release-0.1.0`
- source_commit: `c389b37c2dd76c397df010ccf5df1ec999d77335`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/global/1.0.0/gatechecker-global-1.0.0.iq`
- manifest: `apps/GateChecker/releases/global/1.0.0/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/1.0.0/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/1.0.0/supported_races.json`
- race_index: `apps/GateChecker/releases/global/1.0.0/race_index.yml`
- size: `2433313 bytes`
- sha256: `582ae7b026c3c3d74a94165849bae8416118f81aeb1ca3ed0d97e8ca84b12176`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 1.0.0
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
