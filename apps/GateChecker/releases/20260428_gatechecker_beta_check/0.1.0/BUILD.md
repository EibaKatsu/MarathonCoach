# Build Memo

- built_at: `2026-05-07 23:21:44 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260428_gatechecker_beta_check`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `023ed61c-e951-4e8f-a228-7de069c931ea`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.0/gatechecker-20260428_gatechecker_beta_check-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.0/20260428_gatechecker_beta_check.yml`
- generated_source: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.0/GateRaceConfig.mc`
- size: `2119031 bytes`
- sha256: `84e053baa75777ba8de24f844fd3f76116638edda308bd7234aa187a61ca62d7`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260428_gatechecker_beta_check 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
