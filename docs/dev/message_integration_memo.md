# message_integration_memo

## 変更後の表示仕様メモ
- 2026-03-23 時点で、中央カードは Race Navi の既存画面骨格を維持したまま 2段表示へ変更した
- 1段目は小さい判定ラベル
  - `ちょい上げ / そのまま / ちょい落とし / 補給準備 / 補給NOW`
  - 英語時は `Push a bit / Hold pace / Ease down / Fuel prep / Fuel NOW`
- 2段目は MessageInGarmin 由来のメインメッセージ領域
  - ラベルより大きい文字で 1〜2 行表示
  - 同一状態では毎秒切り替えず、約24秒ごとにローテーション
  - 直前と同じ文をできるだけ避ける
- 他 UI の骨格は維持する
  - 左上: HR + CAP
  - 右上: FUEL リング
  - 右下: 10秒平均ペース
  - 下段: DIST / TIME

## メッセージ選択仕様
- 言語は `ja / en` のみ
- 端末ロケールが英語なら `en`、それ以外は `ja`
- カテゴリ構成は MessageInGarmin 準拠
  - `FIXED / FUNNY / SALT / ALCOHOL / TOXIC / PRAISE / DIST`
- 実表示では `DIST` を使わない
- 各カテゴリは以下を持つ
  - `normal`
  - `fuelPrep`
  - `fuelNow`
- `normal` のキーは `stateKey = slope × action`
  - `{UP|FL|DN}_{PUSH|HOLD|EASE}`
- `fuelState`
  - `NONE`: `normal[stateKey]`
  - `PREP`: `fuelPrep`
  - `NOW`: `fuelNow`

## 補給表示枠を復活させていない理由
- 補給タイマー専用の表示枠は復活させていない
- 補給ロジックそのものは維持している
- 補給判定は中央カードの入力へ移し替えた
  - `fuelState = PREP` なら 1段目ラベルを `補給準備 / Fuel prep`
  - `fuelState = NOW` なら 1段目ラベルを `補給NOW / Fuel NOW`
  - 2段目メッセージはカテゴリ内の `fuelPrep / fuelNow` から選ぶ
- これにより表示枠を増やさず、補給優先順位を明確に維持できる

## 削除した DRIFT / 距離トリガー関連
- DRIFT 判定
- DRIFT 固定表示 `水＋補給`
- DRIFT を ACTION 判定前提に使う条件
- 独自距離通知カード
- 1km ごとの距離イベント
- `HALF / FULL` などの距離割り込み表示
- 距離イベント用の状態管理、キュー、繰り越し表示
- MessageInGarmin 由来の `DIST` メッセージの実表示利用

## テスト観点の更新
- 中央カードが 2段表示で崩れない
- `FUEL NOW > FUEL PREP > EASE > HOLD/PUSH` の優先順位が守られる
- `stateKey = slope × action` で文言プールが切り替わる
- `ja / en` で文言プールが切り替わる
- 同一状態では毎秒ガチャガチャ切り替わらない
- 状態変化時は即時にラベル / メッセージが更新される
- 独自距離通知カードが出ない
- DRIFT 固定表示や DRIFT 判定への依存が出ない
