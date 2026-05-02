# Build Memo

- built_at: `2026-05-02 20:33:45 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `stockholm_marathon_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-mile-packaging`
- source_commit: `27a83a35c4104742bd48367e3ff0f017fda1f93c`
- app_id: `ebe0b2bf-a312-4e3f-b0c5-b6483a1f940f`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/stockholm_marathon_2026/0.1.0/gatechecker-stockholm_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/stockholm_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/stockholm_marathon_2026/0.1.0/stockholm_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/stockholm_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `1923807 bytes`
- sha256: `3b6d7fb9066ad30cd047ddbc2cbc621d580c21420a498ea2eb6499a2ebea40ce`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh stockholm_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
