# message_integration_memo

## 現在の扱い
- 中央カード系の整理メモとして残す
- 補給ロジックと補給表示は削除済みのため、本ファイルでは扱わない

## 中央カード入力
- `actionState`
  - `PUSH`
  - `HOLD`
  - `EASE`
- `slopeState`
- `hrWarning`

## 画面配置
- 左上: HR + CAP
- 右上: 予測ゴール
- 中央: ペース + ゴールランナーゲージ
- 下段: 距離 / 経過時間

## メモ
- 心拍上限表示は左上の HR/CAP に集約する
- CAP 算出元は `custom code / property LTHR / device LTHR / HRR / MaxHR` を内部で区別する
