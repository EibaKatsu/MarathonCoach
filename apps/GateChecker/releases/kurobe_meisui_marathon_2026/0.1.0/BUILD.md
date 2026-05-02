# Build Memo

- built_at: `2026-05-02 20:35:20 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `kurobe_meisui_marathon_2026`
- version: `0.1.0`
- branch: `codex/gatechecker-mile-packaging`
- source_commit: `27a83a35c4104742bd48367e3ff0f017fda1f93c`
- app_id: `7d88321e-96e6-42ed-ac95-70baff556612`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/kurobe_meisui_marathon_2026/0.1.0/gatechecker-kurobe_meisui_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/kurobe_meisui_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/kurobe_meisui_marathon_2026/0.1.0/kurobe_meisui_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/kurobe_meisui_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `1925730 bytes`
- sha256: `f456faba5e9f8b3ddd6dc50fece3164e578283987045b9a3ac3abebef437c6df`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh kurobe_meisui_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
