# logic_drift

## 基準区間（Baseline）
- 開始条件: `20:00経過` かつ `3.0km到達`
- 上記達成後、連続10分で基準作成
  - `basePace`（平均ペース）
  - `baseHR`（平均心拍）

## 基準確定前UI
- ACTION判定前はウォームアップ文言を表示
- 文言ローテーション間隔: 15秒
- 基準確定後に通常ACTION文言へ切替

## 判定窓（Rolling）
- 直近10分の
  - `curPace`
  - `curHR`

## 安定条件
- `abs(curPace - basePace) <= 5秒/km` のときのみ判定

## ON/OFF
- ON: `curHR - baseHR >= +10 bpm`
- OFF: `curHR - baseHR <= +6 bpm` を60秒継続

## UI固定
- DRIFT ON時はコーチカードを「水＋補給」固定（トグル停止）
