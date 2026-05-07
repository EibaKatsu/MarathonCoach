# Build Memo

- built_at: `2026-05-07 23:31:05 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260524_kurobe_meisui_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `7d88321e-96e6-42ed-ac95-70baff556612`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/0.1.0/gatechecker-20260524_kurobe_meisui_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/0.1.0/20260524_kurobe_meisui_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/0.1.0/GateRaceConfig.mc`
- size: `2125403 bytes`
- sha256: `81ab975e829a76005ea9e8f8d0939e0358ab974cbf5eab825d0cc4fbdf5ff4a4`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260524_kurobe_meisui_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
