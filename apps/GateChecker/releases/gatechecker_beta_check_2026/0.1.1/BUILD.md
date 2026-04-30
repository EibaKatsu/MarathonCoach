# Build Memo

- built_at: `2026-04-30 13:56:14 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `gatechecker_beta_check_2026`
- version: `0.1.1`
- branch: `codex/gatechecker-beta-package`
- source_commit: `dbf437af4d35e6c28392ce0c4fda90ce04a94106`
- app_id: `023ed61c-e951-4e8f-a228-7de069c931ea`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/gatechecker-gatechecker_beta_check_2026-0.1.1.iq`
- manifest: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/gatechecker_beta_check_2026.yml`
- generated_source: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/GateRaceConfig.mc`
- size: `1801774 bytes`
- sha256: `7985663a04147f95a4d129ace9e80518e44138f197ca5dd1dadf18a02d556f23`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh gatechecker_beta_check_2026 0.1.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
