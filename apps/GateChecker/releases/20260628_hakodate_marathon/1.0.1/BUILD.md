# Build Memo

- built_at: `2026-05-09 13:45:54 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260628_hakodate_marathon`
- version: `1.0.1`
- branch: `codex/main-sync-20260507`
- source_commit: `b94def4068d767aab13184bbb9cd73504746a17d`
- app_id: `e19ff169-f77f-44f1-a9ac-7c5ca2aa53f8`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260628_hakodate_marathon/1.0.1/gatechecker-20260628_hakodate_marathon-1.0.1.iq`
- manifest: `apps/GateChecker/releases/20260628_hakodate_marathon/1.0.1/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260628_hakodate_marathon/1.0.1/20260628_hakodate_marathon.yml`
- generated_source: `apps/GateChecker/releases/20260628_hakodate_marathon/1.0.1/GateRaceConfig.mc`
- size: `2175527 bytes`
- sha256: `4d5df1eb3bcbb0aebdcc8a033cded24693a163aaa59abcdbcb1aab286c39037b`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260628_hakodate_marathon 1.0.1
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
