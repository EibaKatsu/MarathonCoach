# Build Memo

- built_at: `2026-05-26 23:28:03 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `20260614_hida_takayama_ultramarathon`
- version: `0.1.0`
- branch: `codex/hida-release-and-html`
- source_commit: `643c4600e1d8bed7e849be17d5940545a278baa3`
- app_id: `e9d0e8dc-eb37-4953-be8e-8547356ab5e9`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/0.1.0/gatechecker-20260614_hida_takayama_ultramarathon-0.1.0.iq`
- manifest: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/0.1.0/20260614_hida_takayama_ultramarathon.yml`
- generated_source: `apps/GateChecker/releases/20260614_hida_takayama_ultramarathon/0.1.0/GateRaceConfig.mc`
- size: `2326641 bytes`
- sha256: `9b4b0350b5a2813d636589a93b36d60b9f9b41e29b346df619b9e33f27f6221d`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh 20260614_hida_takayama_ultramarathon 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
