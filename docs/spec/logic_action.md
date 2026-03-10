# logic_action

## 概要
「ちょい上げ」は、遅れがあり、心拍余裕があり、Cardiac Costが悪化していない場合のみ発火する。

## 前提
- フェーズ定義は `docs/spec/logic_hr_zone.md` の `S1..S5`
- `ccRatio = (curHR * curPace) / (baseHR * basePace)`
- `ccRatio` 有効条件
  - ドリフト基準確定済み
  - rollingサンプル数 `>= 30`
  - `abs(curPace - basePace) <= 5秒/km`

## 発火前提（1つでも欠けると発火しない）
- FUEL期限超過でない
- HR超過状態でない
- DRIFT ONでない
- `paceNowSecPerKm` / `targetPaceSecPerKm` / `allowedMaxHeartRate` / `currentHeartRate` が有効

## ちょい上げ閾値（`paceDelta >=` かつ `headroom >=`）
| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | `+12s, 8bpm` | `+8s, 6bpm` | `+6s, 4bpm` | `+4s, 3bpm` | `+3s, 2bpm` |
| HALF | `+10s, 7bpm` | `+6s, 5bpm` | `+4s, 3bpm` | `+3s, 2bpm` | `+2s, 1bpm` |
| SHORT | `+8s, 6bpm` | `+5s, 4bpm` | `+3s, 2bpm` | `+2s, 1bpm` | `+1s, 0bpm` |

## Cardiac Costゲート（ちょい上げ時）
- FULL: `ccRatio <= 1.06`
- HALF: `ccRatio <= 1.08`
- SHORT: `ccRatio <= 1.10`
- `ccRatio == null` はゲート未適用

## ヒステリシス
- ON: 条件成立が6秒継続
- OFF: 次のいずれかが5秒継続
  - `paceDelta < (閾値 -2秒)`
  - `headroom < (閾値 -1bpm)`
  - Cardiac Costゲート不成立

## ちょい落とし（Ease）
- `paceDelta <= -8秒/km`
- または `headroom <= 閾値`
- または `baselineHrDelta >= 閾値`
- または `ccRatio >= 閾値`

`ccRatio` 閾値:
- FULL 1.10
- HALF 1.12
- SHORT 1.15
