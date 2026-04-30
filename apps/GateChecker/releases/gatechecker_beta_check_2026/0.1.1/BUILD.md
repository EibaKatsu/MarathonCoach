# Build Memo

- built_at: `2026-04-30 13:53:47 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `gatechecker_beta_check_2026`
- version: `0.1.1`
- branch: `codex/gatechecker-beta-package`
- source_commit: `56c299504cd8775c0758b531916daa9ff028ee5a`
- app_id: `023ed61c-e951-4e8f-a228-7de069c931ea`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/gatechecker-gatechecker_beta_check_2026-0.1.1.iq`
- manifest: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/gatechecker_beta_check_2026.yml`
- generated_source: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.1/GateRaceConfig.mc`
- size: `1817319 bytes`
- sha256: `cd6ae3e23eec02331bf71dfcf1193b24fe1d1a91d070bf93c1ba664709a71ebb`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh gatechecker_beta_check_2026 0.1.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
