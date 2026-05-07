# Build Memo

- built_at: `2026-05-07 22:16:04 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `edinburgh_marathon_2026`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `932a5fab1984a70ea08555797efcecd9d87b28a0`
- app_id: `9fa5a8f6-1602-4f29-b220-c41634fba5bf`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/edinburgh_marathon_2026/0.1.0/gatechecker-edinburgh_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/edinburgh_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/edinburgh_marathon_2026/0.1.0/edinburgh_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/edinburgh_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `2118539 bytes`
- sha256: `d485c16f38851dd5a2ca9df6c81e3ee3fcee3e00c66339995cb7763c908af11f`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh edinburgh_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
