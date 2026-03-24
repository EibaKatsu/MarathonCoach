# logic_action

## 概要
MarathonCoach 現行のレース距離プロファイル × フェーズ別 ACTION 判定を source of truth とする。
MessageInGarmin の `Z1..Z5` は使わず、出力だけを `PUSH / HOLD / EASE` に正規化して中央カードへ渡す。

## 前提
- フェーズ定義は `docs/spec/logic_hr_zone.md` の `S1..S5`
- 距離プロファイルは `FULL / HALF / SHORT`
- 判定に使う主入力
  - `paceNowSecPerKm`
  - `targetPaceSecPerKm`
  - `allowedMaxHeartRate`
  - `currentHeartRate`
  - レース距離から求めるフェーズ情報

## 発火前提（1つでも欠けると発火しない）
- FUEL期限超過でない
- HR超過状態でない
- `paceNowSecPerKm` / `targetPaceSecPerKm` / `allowedMaxHeartRate` / `currentHeartRate` が有効

## ちょい上げ閾値（`paceDelta >=` かつ `headroom >=`）
| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | `+12s, 8bpm` | `+8s, 6bpm` | `+6s, 4bpm` | `+4s, 3bpm` | `+3s, 2bpm` |
| HALF | `+10s, 7bpm` | `+6s, 5bpm` | `+4s, 3bpm` | `+3s, 2bpm` | `+2s, 1bpm` |
| SHORT | `+8s, 6bpm` | `+5s, 4bpm` | `+3s, 2bpm` | `+2s, 1bpm` | `+1s, 0bpm` |

## ヒステリシス
- ON: 条件成立が6秒継続
- OFF: 次のいずれかが5秒継続
  - `paceDelta < (閾値 -2秒)`
  - `headroom < (閾値 -1bpm)`

## ちょい落とし（Ease）
- `paceDelta <= -8秒/km`
- または `headroom <= 閾値`

## カード連携
- `ちょい上げ` は `PUSH`
- `そのまま` は `HOLD`
- `ちょい落とし` は `EASE`
- さらに坂判定 `UP / FL / DN` を組み合わせて `stateKey` を作る
