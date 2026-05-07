# Build Memo

- built_at: `2026-05-07 23:26:25 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260503_flying_pig_marathon`
- version: `1.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `d6f3337a-6862-4ca4-a252-7e0af48ab0c4`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260503_flying_pig_marathon/1.1.0/gatechecker-20260503_flying_pig_marathon-1.1.0.iq`
- manifest: `apps/GateChecker/releases/20260503_flying_pig_marathon/1.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260503_flying_pig_marathon/1.1.0/20260503_flying_pig_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260503_flying_pig_marathon/1.1.0/GateRaceConfig.mc`
- size: `2122451 bytes`
- sha256: `991616ba02d9a36f8230089ee66f6fe7b9074a93b24eee9582b42a95820ee96e`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260503_flying_pig_marathon 1.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
