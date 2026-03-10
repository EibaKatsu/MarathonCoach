# ui

## UI方針（コーチカード風 / B案）
- 画面中央のコーチカードを主役にする
- 数値は補助情報として扱う
- 右下に10秒平均ペース（`/km` は小表示）

## 画面要素（1画面）
- 中央: コーチカード
- 左上: HR/ZONE（取得不可時 `HR / --`）
- 右上: FUELリング + 残り時間
- 右下: いまのぺーす（10秒平均）
- 下段: DIST / TIME
- 補助: PACE Δ（狭小時は縮退対象）

## UI文言
### ペース系
- ちょい上げ
- ちょい落とし
- そのまま

### 補給系
- 補給しよ
- いま 補給

### ドリフト固定文言
- 水＋補給

### 英語対応
- Push a bit
- Ease down
- Hold pace
- Fuel now
- Fuel overdue
- Water + fuel

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
3. HR/ZONE
4. FUEL残り
5. DIST/TIME
6. PACE Δ

### デバッグ
- `layoutDebugOverlay` で枠線・基準線を可視化

## UIアセット参照
- `assets/UI_Image.png`
- `assets/step3_layout_fr255_4block_mockup.png`
- `assets/ui/mockups/ui_b_v1.png`
- `assets/ui/mockups/ui_b_v2_pace_unit_small.png`
- `assets/ui/mockups/ui_b_v3_pace_centered.png`
