# Build Memo

- built_at: `2026-05-07 23:32:36 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260524_edinburgh_marathon`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `25a6b0eb9ca64a53d7a4f5b405abe46de83e43f2`
- app_id: `9fa5a8f6-1602-4f29-b220-c41634fba5bf`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260524_edinburgh_marathon/0.1.0/gatechecker-20260524_edinburgh_marathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260524_edinburgh_marathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260524_edinburgh_marathon/0.1.0/20260524_edinburgh_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260524_edinburgh_marathon/0.1.0/GateRaceConfig.mc`
- size: `2119515 bytes`
- sha256: `afbd159e388868441d00b0b24af6713f252288e60cfe491c9db7502b80863468`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260524_edinburgh_marathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
