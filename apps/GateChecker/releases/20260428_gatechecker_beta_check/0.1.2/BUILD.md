# Build Memo

- built_at: `2026-05-07 23:23:17 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260428_gatechecker_beta_check`
- version: `0.1.2`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `023ed61c-e951-4e8f-a228-7de069c931ea`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.2/gatechecker-20260428_gatechecker_beta_check-0.1.2.iq`
- manifest: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.2/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.2/20260428_gatechecker_beta_check.yml`
- generated_source: `apps/GateChecker/releases/20260428_gatechecker_beta_check/0.1.2/GateRaceConfig.mc`
- size: `2117690 bytes`
- sha256: `a3632b351477bdbe7a267eccd752aada436789a4a9b57049627f5576ca16d050`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260428_gatechecker_beta_check 0.1.2
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
