# ui

## UI方針（Race Navi土台 + MessageInGarmin風カード）
- 画面中央のコーチカードを主役にする
- 数値は補助情報として扱う
- 右下に10秒平均ペース（`/km` は小表示）
- Race Navi の既存骨格は維持し、中央カードだけ MessageInGarmin 寄りに再設計する

## 画面要素（1画面）
- 上段左: HR + CAP
- 上段右: いまのぺーす（10秒平均）
- 中央: 横長コーチカード
- 下段: DIST / TIME
- 最下段: ゴール予測時刻 / 差分
- FUELリングは表示せず、補給はカード文言で通知する
- レース距離を超過した後は、ゴール予測時刻 / 差分の代わりに `Over +0.12km` 形式で超過距離を表示する

## UI文言
### 1段目ラベル
- ちょい上げ
- そのまま
- ちょい落とし
- 少し戻す（`EASE` がペース理由のみのとき）
- ラストスパート
- 補給準備
- 補給NOW

### 英語ラベル
- Push a bit
- Hold pace
- Ease down
- Ease pace（pace-only）
- Final push
- Fuel prep
- Fuel NOW

### 2段目メッセージ
- MessageInGarmin 由来の短文を表示する
- カテゴリ構成は `FIXED / FUNNY / SALT / ALCOHOL / TOXIC / PRAISE / DIST`
- 今回の表示対象は `DIST` を除く
- 表示時は `FIXED / FUNNY / SALT / ALCOHOL / TOXIC / PRAISE` を等確率で抽選する
- 各カテゴリは `normal / fuelPrep / fuelNow` を持つ
- `normal` は `UP_PUSH / UP_HOLD / UP_EASE / FL_* / DN_*` を持つ
- 文字はラベルより大きく、1〜2行までを許容する
- 長い文は短縮または省略で収める

### 表示優先順位
1. 残り距離が「全体の5%」または `1km` の小さい方以下になったら `ラストスパート / Final push`
2. `FUEL NOW`
3. `FUEL PREP`
4. `EASE`
5. `HOLD / PUSH`

距離イベント割り込みと DRIFT 由来割り込みは行わない。

## 多言語
- `ja` / `en` の2言語対応
- 端末言語が `Japanese` のときだけ `ja`
- それ以外は `en`
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
- 残り距離が「全体の5%」または `1km` の小さい方以下になったら、補給・心拍・ペース判定を表示上は無視して `ラストスパート / Final push` を固定表示する
- 2段目はメインメッセージ。ラストスパート条件未満では `fuelState` が `NOW` のときは `fuelNow`、`PREP` のときは `fuelPrep`、それ以外は `normal[stateKey]` から選ぶ
- `stateKey` は `slope × action` を基本とする
- `EASE` は理由別に `PACE / HR / BOTH` を持ち、`{UP|FL|DN}_EASE_{PACE|HR|BOTH}` を使い分ける
- 理由不明や後方互換時は従来どおり `{UP|FL|DN}_EASE` を使う
- 同一状態では毎秒切り替えず、20〜30秒程度の間隔で差し替える
- 同じ文が連続しすぎないよう、直前と同じ文はできるだけ避ける

## 心拍表示仕様
- 左上は「現在心拍を大きく + その上または横に小さく `cap` + 状態テキスト」の構成とする
- `cap` はその時点の許容最大心拍を表す
- 現在心拍取得可 / cap取得不可時は `cap --` を表示する
- 心拍取得不可時は大表示を `--` とし、`cap` 表示は保持できる場合のみ出す
- 左上の心拍エリアでは、心拍ゲージやハートアイコンは使わない

### 状態色
- `安全`: `HR <= CAP - 3`
- `危険`: `CAP - 2 <= HR <= CAP`
- `オーバー`: `HR >= CAP + 1`
- 状態テキストは `安全=緑 / 危険=オレンジ / オーバー=赤` とする
- `安全/危険/オーバー` は表示用の即時状態であり、`HR OVER` カードやビープの継続秒判定とは分けて扱う

### サイズクラス別
- `small`: 心拍を最優先。`cap` は `cap152` のように詰めて表示する
- `medium`: 基本形。大きい心拍数の上に `cap 152`、左側に `SAFE / CAUTION / OVER` を置く
- `large`: `medium` を踏襲しつつ、数値とラベルの余白を広めに取る

### デバッグ
- `layoutDebugOverlay` で枠線・基準線を可視化

## UIアセット参照
- `assets/UI_Image.png`
- `assets/step3_layout_fr255_4block_mockup.png`
- `assets/ui/mockups/ui_b_v1.png`
- `assets/ui/mockups/ui_b_v2_pace_unit_small.png`
- `assets/ui/mockups/ui_b_v3_pace_centered.png`
