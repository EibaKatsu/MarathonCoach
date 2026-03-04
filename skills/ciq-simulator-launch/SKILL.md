---
name: ciq-simulator-launch
description: Connect IQ アプリのシミュレーター実行を自動化するスキル。ユーザーが「シミュレーション起動」「simulatorで起動」「run simulator」などを依頼したときに使う。`monkeyc` でビルドし、`connectiq` を起動し、`monkeydo` で指定デバイスへアプリを送る。
---

# CIQ Simulator Launch

このスキルは、MarathonCoach プロジェクトのシミュレーター実行を1コマンド化する。

## Default flow
1. `scripts/run_simulation.sh` を実行する。
2. デフォルトデバイスは `fr57042mm` を使う。
3. `connectiq` 実行後、シミュレーター起動待ちとして約10秒待ってから `monkeydo` を実行する。
4. 必要ならデバイスIDを引数で上書きする。

## Commands
```bash
./skills/ciq-simulator-launch/scripts/run_simulation.sh
./skills/ciq-simulator-launch/scripts/run_simulation.sh fr57042mm
```

## Notes
- 開発者キーは既定で `/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key` を使う。
- 別のキーを使う場合は `CIQ_DEV_KEY` 環境変数で上書きする。
- `monkeydo` 実行後は、シミュレーター稼働中にコマンドが待機状態になることがある。
- この待機状態に入った時点で、SKILL実行は完了扱いでよい。
