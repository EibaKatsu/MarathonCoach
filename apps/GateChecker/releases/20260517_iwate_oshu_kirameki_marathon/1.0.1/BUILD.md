# Build Memo

- built_at: `2026-05-09 13:41:18 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260517_iwate_oshu_kirameki_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `e7edc6e6-be37-4774-8069-4a115ddc67bd`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/1.0.1/gatechecker-20260517_iwate_oshu_kirameki_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/1.0.1/20260517_iwate_oshu_kirameki_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/1.0.1/GateRaceConfig.mc`
- size: `2179716 bytes`
- sha256: `dffd87000df419e48fb6bc9084b9b6d70d599cd547f738c5e21d8fb0a8aacbb4`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260517_iwate_oshu_kirameki_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
