# Build Memo

- built_at: `2026-05-07 23:31:52 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260516_ing_night_marathon_luxembourg`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `737184ed-a25a-4446-a4f9-ecfdc9fe4ff1`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260516_ing_night_marathon_luxembourg/0.1.0/gatechecker-20260516_ing_night_marathon_luxembourg-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260516_ing_night_marathon_luxembourg/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260516_ing_night_marathon_luxembourg/0.1.0/20260516_ing_night_marathon_luxembourg.yml`
- generated_source: `apps/GateChecker/releases/20260516_ing_night_marathon_luxembourg/0.1.0/GateRaceConfig.mc`
- size: `2122412 bytes`
- sha256: `782686b1f60ab244beb2bea91d2626e0e949b9649b3c45295c07642a3a633bb7`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260516_ing_night_marathon_luxembourg 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
