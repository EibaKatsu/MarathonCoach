# Build Memo

- built_at: `2026-05-07 23:36:24 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20261018_sample_multi_course`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `8efe4e50-38b8-49c3-acad-3797de088084`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20261018_sample_multi_course/0.1.0/gatechecker-20261018_sample_multi_course-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20261018_sample_multi_course/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20261018_sample_multi_course/0.1.0/20261018_sample_multi_course.yml`
- generated_source: `apps/GateChecker/releases/20261018_sample_multi_course/0.1.0/GateRaceConfig.mc`
- size: `2179303 bytes`
- sha256: `319dbfc2f7fc9d042823c2f72f3551764b192e3e48e9a91c43d118b5758ab33a`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20261018_sample_multi_course 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
