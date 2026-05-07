# Build Memo

- built_at: `2026-05-07 23:20:55 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260517_iwate_oshu_kirameki_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `e7edc6e6-be37-4774-8069-4a115ddc67bd`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/0.1.0/gatechecker-20260517_iwate_oshu_kirameki_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/0.1.0/20260517_iwate_oshu_kirameki_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260517_iwate_oshu_kirameki_marathon/0.1.0/GateRaceConfig.mc`
- size: `2126777 bytes`
- sha256: `9a8350a2bb8c536357a3500b1f2d0e950f802ba6f30976d0647ea804f285d2b6`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260517_iwate_oshu_kirameki_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
