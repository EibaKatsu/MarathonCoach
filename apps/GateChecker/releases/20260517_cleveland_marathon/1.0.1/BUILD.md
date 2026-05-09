# Build Memo

- built_at: `2026-05-09 13:42:12 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260517_cleveland_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `396c147b-b3d1-45ad-9969-1d8d5652afc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260517_cleveland_marathon/1.0.1/gatechecker-20260517_cleveland_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260517_cleveland_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260517_cleveland_marathon/1.0.1/20260517_cleveland_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260517_cleveland_marathon/1.0.1/GateRaceConfig.mc`
- size: `2172795 bytes`
- sha256: `d613e4f25f0c323226c66375700678557e2611796f7bb4b43760401a7d56e2f9`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260517_cleveland_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
