# Build Memo

- built_at: `2026-05-07 23:29:29 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260530_stockholm_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `ebe0b2bf-a312-4e3f-b0c5-b6483a1f940f`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260530_stockholm_marathon/0.1.0/gatechecker-20260530_stockholm_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260530_stockholm_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260530_stockholm_marathon/0.1.0/20260530_stockholm_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260530_stockholm_marathon/0.1.0/GateRaceConfig.mc`
- size: `2122670 bytes`
- sha256: `7f4e58b6bd629ce516a5da035c75430b3ca1b244665c285c11870152122987ee`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260530_stockholm_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
