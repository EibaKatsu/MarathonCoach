---
name: ciq-simulator-launch
description: MarathonCoach の Connect IQ シミュレーター起動スキル。ビルド、Simulator 起動、`monkeydo` 転送、settings JSON 再送までを既存スクリプトで行う。
status: active
---

# CIQ Simulator Launch

## Trigger
- `シミュレーション起動`
- `simulatorで起動`
- `run simulator`

## Read first
- `docs/dev/simulator_checklist.md`

## Default flow
1. `skills/ciq-simulator-launch/scripts/run_simulation.sh` を実行する。
2. デフォルトデバイスは `fr57042mm` を使う。
3. 必要ならデバイス ID を引数で上書きする。
4. 自動生成された settings JSON があれば Simulator へ再送する。
5. 設定を固定したいときは `CIQ_SETTINGS_JSON` で明示する。

## Commands
```bash
./skills/ciq-simulator-launch/scripts/run_simulation.sh
```

```bash
./skills/ciq-simulator-launch/scripts/run_simulation.sh fr57042mm
```

## Output
- 使用デバイス
- PRG 転送結果
- settings JSON を送ったかどうか
- 手動で必要な Simulator 操作があればその案内

## Notes
- `monkeydo` 実行後に待機状態に入っても、アプリ転送まで完了していればこのスキルは完了扱いでよい。
- Data Field は `monkeydo` だけでは activity recording が始まらないことがある。
- `CIQ_DEV_KEY` や既存の repo 設定を使う前提とし、鍵の中身表示や再生成はこのスキルの対象外とする。

## Do not
- 鍵ファイルを編集、移動、再生成しない。
- 実在しない独自起動コマンドを案内しない。
