# Build Memo

- built_at: `2026-05-27 07:11:36 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260614_hida_takayama_ultramarathon`
- version: `1.0.2`
- branch: `codex/hida-release-1-0-2`
- source_commit: `1a324b12ea5b122a899a3b6c1df0605aeeee4512`
- app_id: `e9d0e8dc-eb37-4953-be8e-8547356ab5e9`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/1.0.2/gatechecker-20260614_hida_takayama_ultramarathon-1.0.2.iq`
- manifest: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/1.0.2/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/1.0.2/20260614_hida_takayama_ultramarathon.yml`
- generated_source: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/1.0.2/GateRaceConfig.mc`
- size: `2327006 bytes`
- sha256: `8f7875e8924625901c620196f9d563472b82b32e5edb10634e7fd967d3ccd2cb`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260614_hida_takayama_ultramarathon 1.0.2
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
