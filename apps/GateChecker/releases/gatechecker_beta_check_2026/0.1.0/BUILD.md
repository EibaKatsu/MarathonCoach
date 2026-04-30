# Build Memo

- built_at: `2026-04-28 18:10:43 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `gatechecker_beta_check_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-beta-package`
- source_commit: `9c6550c1d6a562cbdd372dc7bad2743989966415`
- app_id: `023ed61c-e951-4e8f-a228-7de069c931ea`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.0/gatechecker-gatechecker_beta_check_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.0/gatechecker_beta_check_2026.yml`
- generated_source: `apps/GateChecker/releases/gatechecker_beta_check_2026/0.1.0/GateRaceConfig.mc`
- size: `1777550 bytes`
- sha256: `c4ccf8d4783c114f8697320e3e70dbee15388620556946f7b4bd3948fc634404`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh gatechecker_beta_check_2026 0.1.0
```

## Notes
- The package was built after resolving the race/version in a temporary workspace.
- Different versions for the same race can be output in parallel to separate directories.
