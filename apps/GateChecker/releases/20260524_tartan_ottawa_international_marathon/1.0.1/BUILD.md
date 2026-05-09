# Build Memo

- built_at: `2026-05-09 13:44:01 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260524_tartan_ottawa_international_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `bc7e02d5-9778-4e03-8ed8-d6b986d8dfc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/1.0.1/gatechecker-20260524_tartan_ottawa_international_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/1.0.1/20260524_tartan_ottawa_international_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/1.0.1/GateRaceConfig.mc`
- size: `2176890 bytes`
- sha256: `7f4997b7ee0c2b44163c8aaff37f1f5b7176a8188f34fdc64b47b48494161849`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260524_tartan_ottawa_international_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
