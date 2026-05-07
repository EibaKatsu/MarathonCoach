# Build Memo

- built_at: `2026-05-07 23:24:52 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260503_bmo_vancouver_marathon`
- version: `1.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `5435b1ff-486b-4355-9c14-542b631f266c`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260503_bmo_vancouver_marathon/1.1.0/gatechecker-20260503_bmo_vancouver_marathon-1.1.0.iq`
- manifest: `apps/GateChecker/releases/20260503_bmo_vancouver_marathon/1.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260503_bmo_vancouver_marathon/1.1.0/20260503_bmo_vancouver_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260503_bmo_vancouver_marathon/1.1.0/GateRaceConfig.mc`
- size: `2121999 bytes`
- sha256: `ee9955267c883027058acab1b4fdeb7bc7fd140b07332e6327ef868ed1faeb20`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260503_bmo_vancouver_marathon 1.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
