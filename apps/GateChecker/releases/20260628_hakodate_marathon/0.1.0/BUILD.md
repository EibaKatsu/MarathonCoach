# Build Memo

- built_at: `2026-05-07 23:34:52 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260628_hakodate_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `e19ff169-f77f-44f1-a9ac-7c5ca2aa53f8`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260628_hakodate_marathon/0.1.0/gatechecker-20260628_hakodate_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260628_hakodate_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260628_hakodate_marathon/0.1.0/20260628_hakodate_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260628_hakodate_marathon/0.1.0/GateRaceConfig.mc`
- size: `2122430 bytes`
- sha256: `9e23c67d77fdea79ed5260b182743ff4e81aa81218dea650327063cb3ef1fd97`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260628_hakodate_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
