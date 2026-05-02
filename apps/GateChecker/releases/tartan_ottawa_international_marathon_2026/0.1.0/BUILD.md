# Build Memo

- built_at: `2026-05-02 20:32:59 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `tartan_ottawa_international_marathon_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-mile-packaging`
- source_commit: `27a83a35c4104742bd48367e3ff0f017fda1f93c`
- app_id: `bc7e02d5-9778-4e03-8ed8-d6b986d8dfc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/tartan_ottawa_international_marathon_2026/0.1.0/gatechecker-tartan_ottawa_international_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/tartan_ottawa_international_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/tartan_ottawa_international_marathon_2026/0.1.0/tartan_ottawa_international_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/tartan_ottawa_international_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `1926086 bytes`
- sha256: `1b9b2162c961589b79244c324c58d2c5b9e52f5ca716275a011c9456cacc9d0c`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh tartan_ottawa_international_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
