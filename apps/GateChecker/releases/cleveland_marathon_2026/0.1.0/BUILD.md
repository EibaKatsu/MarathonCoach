# Build Memo

- built_at: `2026-05-02 20:34:35 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `cleveland_marathon_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-mile-packaging`
- source_commit: `27a83a35c4104742bd48367e3ff0f017fda1f93c`
- app_id: `396c147b-b3d1-45ad-9969-1d8d5652afc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/cleveland_marathon_2026/0.1.0/gatechecker-cleveland_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/cleveland_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/cleveland_marathon_2026/0.1.0/cleveland_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/cleveland_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `1921994 bytes`
- sha256: `20f70fb29469ffefa1f8b931da6d0a1dce1d1d55ffbfd4f4cd1438e3547f156d`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh cleveland_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
