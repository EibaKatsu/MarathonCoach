# Build Memo

- built_at: `2026-05-07 23:28:41 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260524_tartan_ottawa_international_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `bc7e02d5-9778-4e03-8ed8-d6b986d8dfc6`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/0.1.0/gatechecker-20260524_tartan_ottawa_international_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/0.1.0/20260524_tartan_ottawa_international_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260524_tartan_ottawa_international_marathon/0.1.0/GateRaceConfig.mc`
- size: `2123226 bytes`
- sha256: `ecc213d01a1f639466af89aed83590d9e4c045ef609472ba04091351a306d54b`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260524_tartan_ottawa_international_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
