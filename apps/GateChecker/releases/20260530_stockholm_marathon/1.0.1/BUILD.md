# Build Memo

- built_at: `2026-05-09 13:44:57 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260530_stockholm_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `ebe0b2bf-a312-4e3f-b0c5-b6483a1f940f`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260530_stockholm_marathon/1.0.1/gatechecker-20260530_stockholm_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260530_stockholm_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260530_stockholm_marathon/1.0.1/20260530_stockholm_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260530_stockholm_marathon/1.0.1/GateRaceConfig.mc`
- size: `2177353 bytes`
- sha256: `5652810234bb193dfd8c7fbe8d07dd4a47be46b933f0903b39f8b84c49ca31b1`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260530_stockholm_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
