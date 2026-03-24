# ui

## UI方針（Race Navi土台 + MessageInGarmin風カード）
- 画面中央のコーチカードを主役にする
- 数値は補助情報として扱う
- 右下に10秒平均ペース（`/km` は小表示）
- Race Navi の既存骨格は維持し、中央カードだけ MessageInGarmin 寄りに再設計する

## 画面要素（1画面）
- 中央: コーチカード
- 左上: HR + CAP
- 右上: FUELリング + 残り時間
- 右下: いまのぺーす（10秒平均）
- 下段: DIST / TIME
- 補助: PACE Δ（狭小時は縮退対象）

## UI文言
### 1段目ラベル
- ちょい上げ
- そのまま
- ちょい落とし
- 補給準備
- 補給NOW

### 英語ラベル
- Push a bit
- Hold pace
- Ease down
- Fuel prep
- Fuel NOW

### 2段目メッセージ
- MessageInGarmin 由来の短文を表示する
- カテゴリ構成は `FIXED / FUNNY / SALT / ALCOHOL / TOXIC / PRAISE / DIST`
- 今回の表示対象は `DIST` を除く
- 各カテゴリは `normal / fuelPrep / fuelNow` を持つ
- `normal` は `UP_PUSH / UP_HOLD / UP_EASE / FL_* / DN_*` を持つ
- 文字はラベルより大きく、1〜2行までを許容する
- 長い文は短縮または省略で収める

### 表示優先順位
1. `FUEL NOW`
2. `FUEL PREP`
3. `EASE`
4. `HOLD / PUSH`

距離イベント割り込みと DRIFT 由来割り込みは行わない。

## 多言語
- `ja` / `en` の2言語対応
- デフォルト `ja`、端末ロケール英語なら `en`
- 設定画面ラベルは英語固定

## ペース表示仕様
- 5秒ごとサンプルを保持し、直近10〜15秒相当で平均
- GPS不安定時は更新抑制
- 計算不能時は `--:--`

## STEP3レイアウト方針
### サイズクラス
- `small`: `min(width, height) <= 218`
- `medium`: `219..260`（fr255）
- `large`: `>= 261`

### モデル
- 中央割 + 縦4分割（計8セル）
- 参照: `assets/step3_layout_fr255_4block_mockup.png`

### 狭小時の表示優先
1. コーチカード
2. 現在ペース
3. HR + CAP
4. FUEL残り
5. DIST/TIME
6. PACE Δ

## コーチカード構成
- 1段目は小さい判定ラベル。状態変化時に即更新する
- 2段目はメインメッセージ。`fuelState` が `NOW` のときは `fuelNow`、`PREP` のときは `fuelPrep`、それ以外は `normal[stateKey]` から選ぶ
- `stateKey` は `slope × action` で、`{UP|FL|DN}_{PUSH|HOLD|EASE}` を使う
- 同一状態では毎秒切り替えず、20〜30秒程度の間隔で差し替える
- 同じ文が連続しすぎないよう、直前と同じ文はできるだけ避ける

## 心拍表示仕様
- 左上は「現在心拍を大きく + その下に小さく `cap` + 右側に状態ハート」の構成とする
- `cap` はその時点の許容最大心拍を表す
- 現在心拍取得可 / cap取得不可時は `cap --` を表示する
- 心拍取得不可時は大表示を `--` とし、`cap` 表示は保持できる場合のみ出す
- 左上の心拍エリアでは、心拍ゲージや位置マーカーは使わない

### 状態色
- `安全`: `HR <= CAP - 3`
- `危険`: `CAP - 2 <= HR <= CAP`
- `オーバー`: `HR >= CAP + 1`
- 状態ハートは `安全=緑 / 危険=オレンジ / オーバー=赤` とする
- `安全/危険/オーバー` は表示用の即時状態であり、`HR OVER` カードやビープの継続秒判定とは分けて扱う

### サイズクラス別
- `small`: 心拍を最優先。`cap` は `cap152` のように詰めて表示する
- `medium`: 基本形。大きい心拍数の下に `cap 152` を置き、右側に状態ハートを置く
- `large`: `medium` を踏襲しつつ、数値とハートの間隔を少し広めに取る

### デバッグ
- `layoutDebugOverlay` で枠線・基準線を可視化

## UIアセット参照
- `assets/UI_Image.png`
- `assets/step3_layout_fr255_4block_mockup.png`
- `assets/ui/mockups/ui_b_v1.png`
- `assets/ui/mockups/ui_b_v2_pace_unit_small.png`
- `assets/ui/mockups/ui_b_v3_pace_centered.png`
