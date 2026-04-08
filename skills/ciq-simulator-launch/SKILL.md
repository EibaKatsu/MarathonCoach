---
name: ciq-simulator-launch
description: Connect IQ アプリのシミュレーター実行を自動化するスキル。ユーザーが「シミュレーション起動」「simulatorで起動」「run simulator」などを依頼したときに使う。`monkeyc` でビルドし、Connect IQ Simulator を起動し、`monkeydo` で指定デバイスへアプリを送る。
---

# CIQ Simulator Launch

このスキルは、MarathonCoach プロジェクトのシミュレーター実行を1コマンド化する。

## Default flow
1. `scripts/run_simulation.sh` を実行する。
2. デフォルトデバイスは `fr57042mm` を使う。
3. `ConnectIQ.app` を起動し、待受ポートが開くまで待ってから `monkeydo` を実行する。
4. 必要ならデバイスIDを引数で上書きする。
5. 設定JSONが自動生成されていれば、それを `monkeydo` で `GARMIN/Settings/` へ送る。
6. 設定を固定再現したいときは `CIQ_SETTINGS_JSON=/path/to/settings.json` で上書きする。

## Commands
```bash
./skills/ciq-simulator-launch/scripts/run_simulation.sh
./skills/ciq-simulator-launch/scripts/run_simulation.sh fr57042mm
```

## Notes
- 開発者キーは既定で `./.vscode/developer_key` を優先し、なければ旧 `/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key` を使う。
- 別のキーを使う場合は `CIQ_DEV_KEY` 環境変数で上書きする。
- 開発者キーは `4096-bit RSA` を使う。`2048-bit` のままだと simulator で青い三角のままになり、`CIQ_LOG.YML` に `Signature check failed on file` が出ることがある。
- `monkeydo` 実行後は、シミュレーター稼働中にコマンドが待機状態になることがある。
- この待機状態に入った時点で、SKILL実行は完了扱いでよい。
- `bin/<app>-settings.json` が生成される構成では、これを送ることで Simulator の App Settings Editor から設定UIを開ける。
- App Settings Editor が `No settings file found for this app` を出したら、再送後に Editor を閉じて開き直す。古い app/settings の組み合わせを見ていることがある。
- Data Field は `monkeydo` だけでは activity recording が始まらない。青い三角の待機画面のままなら、Simulator で `Simulation > FIT Data > Simulate` と `Data Fields > Timer > Start Activity` を実行する。
- 起動スクリプトは `"$TMPDIR"/com.garmin.connectiq` 配下を見て、settings 配置と `GARMIN/Activities/FILE.FIT` の有無をログで確認する。

## Troubleshooting
- simulator 再起動後は settings が `"$TMPDIR"/com.garmin.connectiq/GARMIN/Settings/` 配下から消えるので、App Settings Editor を使う前に必ず `run_simulation.sh` で再送する。
- `CIQ_LOG.YML` に `Signature check failed on file` が出たら、まず公式 sample でも同じか確認し、そのうえで `4096-bit RSA` の `developer_key` を再生成する。
- App Settings Editor の `App` 名は `manifest.xml` の `name="@Strings.AppName"` から表示される。MarathonCoach では現在 `Race Navi` という表示名でも settings 定義元はこのリポジトリである。
