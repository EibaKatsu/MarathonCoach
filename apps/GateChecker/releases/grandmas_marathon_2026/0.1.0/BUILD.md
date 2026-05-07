# Build Memo

- built_at: `2026-05-07 22:16:06 +0900`
- release_type: `GATECHECKER_PUBLIC`
- race_key: `grandmas_marathon_2026`
- version: `0.1.0`
- branch: `codex/main-sync-20260507`
- source_commit: `932a5fab1984a70ea08555797efcecd9d87b28a0`
- app_id: `62c9a871-54d0-4afa-99a7-7ad0ae965e64`
- signing_key: `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- output: `apps/GateChecker/releases/grandmas_marathon_2026/0.1.0/gatechecker-grandmas_marathon_2026-0.1.0.iq`
- manifest: `apps/GateChecker/releases/grandmas_marathon_2026/0.1.0/manifest.xml`
- race_definition: `apps/GateChecker/releases/grandmas_marathon_2026/0.1.0/grandmas_marathon_2026.yml`
- generated_source: `apps/GateChecker/releases/grandmas_marathon_2026/0.1.0/GateRaceConfig.mc`
- size: `2119516 bytes`
- sha256: `7a77588b5c9cef4085e0bad4abecf779bc60d12e859f69d51709f84c947d90fb`

## Build Command

```sh
CIQ_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key" apps/GateChecker/scripts/build_gatechecker_release_package.sh grandmas_marathon_2026 0.1.0
```

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
