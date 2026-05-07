# Build Memo

- built_at: `2026-05-07 08:33:27 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `sample_multi_course`
- version: `0.1.0`
- branch: `codex/gatechecker-course-settings-logfix-20260507`
- source_commit: `f96d3347c150beb767a37e58c4fe1df29afa3bea`
- app_id: `8efe4e50-38b8-49c3-acad-3797de088084`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/sample_multi_course/0.1.0/gatechecker-sample_multi_course-0.1.0.iq`
- manifest: `apps/GateChecker/releases/sample_multi_course/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/sample_multi_course/0.1.0/sample_multi_course.yml`
- generated_source: `apps/GateChecker/releases/sample_multi_course/0.1.0/GateRaceConfig.mc`
- size: `2178361 bytes`
- sha256: `fc792f3e1ecb913968e04d2542645cbffc90ef088385e6ca93650b7b349e80a3`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh sample_multi_course 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
