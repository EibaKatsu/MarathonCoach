# Build Memo

- built_at: `2026-05-21 08:58:24 +0900`
- release_type: `GATECHECKER_GLOBAL_PUBLIC`
- version: `1.0.1`
- branch: ``
- source_commit: `b5d30d9721f737889221e61e0aaa7b583d24bc9a`
- app_id: `1fb598f1-82d3-4540-857c-067977cb727b`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/global/1.0.1/gatechecker-global-1.0.1.iq`
- manifest: `apps/GateChecker/releases/global/1.0.1/manifest.xml`
- generated_source: `apps/GateChecker/releases/global/1.0.1/GateRaceConfig.mc`
- supported_races: `apps/GateChecker/releases/global/1.0.1/supported_races.json`
- race_index: `apps/GateChecker/releases/global/1.0.1/race_index.yml`
- size: `2444091 bytes`
- sha256: `fc9ef296fd5993f6f027a497813daacef0807e48ac82d094423df24219a5c021`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh 1.0.1
```

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
