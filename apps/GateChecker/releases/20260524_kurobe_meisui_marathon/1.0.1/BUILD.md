# Build Memo

- built_at: `2026-05-09 13:43:11 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260524_kurobe_meisui_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `7d88321e-96e6-42ed-ac95-70baff556612`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/1.0.1/gatechecker-20260524_kurobe_meisui_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/1.0.1/20260524_kurobe_meisui_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260524_kurobe_meisui_marathon/1.0.1/GateRaceConfig.mc`
- size: `2177193 bytes`
- sha256: `664b3059d4a27d6e743c3d2eb55d8560e60d98f28e63d8c0c75bd945f991464c`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260524_kurobe_meisui_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
