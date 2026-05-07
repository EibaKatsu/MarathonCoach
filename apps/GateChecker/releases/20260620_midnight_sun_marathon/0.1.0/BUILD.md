# Build Memo

- built_at: `2026-05-07 23:34:06 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260620_midnight_sun_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `469d958f-0b5e-4f47-b017-9b2bc5319832`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260620_midnight_sun_marathon/0.1.0/gatechecker-20260620_midnight_sun_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260620_midnight_sun_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260620_midnight_sun_marathon/0.1.0/20260620_midnight_sun_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260620_midnight_sun_marathon/0.1.0/GateRaceConfig.mc`
- size: `2120087 bytes`
- sha256: `798eb0de0bccc1a741d7da5697cf2415f0012e0404197b4dfc1c6af2cfd3bcb4`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260620_midnight_sun_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
