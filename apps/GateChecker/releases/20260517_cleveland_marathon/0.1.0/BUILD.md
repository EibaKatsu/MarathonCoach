# Build Memo

- built_at: `2026-05-07 23:30:16 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260517_cleveland_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `396c147b-b3d1-45ad-9969-1d8d5652afc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260517_cleveland_marathon/0.1.0/gatechecker-20260517_cleveland_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260517_cleveland_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260517_cleveland_marathon/0.1.0/20260517_cleveland_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260517_cleveland_marathon/0.1.0/GateRaceConfig.mc`
- size: `2120959 bytes`
- sha256: `06a1954ade02aac93fe720ef36ce544ab44a30c8ac6834cc13d9ea15de506b05`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260517_cleveland_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
