# Build Memo

- built_at: `2026-05-07 22:16:04 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `midnight_sun_marathon_2026`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `932a5fab1984a70ea08555797efcecd9d87b28a0`
- app_id: `469d958f-0b5e-4f47-b017-9b2bc5319832`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/midnight_sun_marathon_2026/0.1.0/gatechecker-midnight_sun_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/midnight_sun_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/midnight_sun_marathon_2026/0.1.0/midnight_sun_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/midnight_sun_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `2118524 bytes`
- sha256: `93d1d91b833aa9ec48beadc8406e6bebac9e9fce3a5c14dffd47e477b2ac99ab`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh midnight_sun_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
