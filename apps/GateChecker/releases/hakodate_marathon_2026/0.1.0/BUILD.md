# Build Memo

- built_at: `2026-05-07 22:16:00 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `hakodate_marathon_2026`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `932a5fab1984a70ea08555797efcecd9d87b28a0`
- app_id: `e19ff169-f77f-44f1-a9ac-7c5ca2aa53f8`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/hakodate_marathon_2026/0.1.0/gatechecker-hakodate_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/hakodate_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/hakodate_marathon_2026/0.1.0/hakodate_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/hakodate_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `2121242 bytes`
- sha256: `25df794dae0e78e7f16fb861ccbf826929afa736a325f87bafecfb131bd14dc1`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh hakodate_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
