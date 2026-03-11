# core

## 通常版（Core）
目的: 信頼できる土台を提供し、レース中の判定バタつきを抑える。

### 含まれる機能
- コーチカード（ちょい上げ/ちょい落とし/そのまま/補給系）
- 距離通知カード（1kmごと + 種目別の節目/ゴール）
- 右下: いまのぺーす（10秒平均、`/km` 小表示）
- 距離/経過時間
- 心拍ZONE上限（Garmin心拍ゾーン基準、フェーズ別）
- ドリフト検知（基準20:00〜30:00 + 10分窓）
- 補給タイマー（LAPリセット、通常版は35分固定）
- ACTION/FUELトグル（3秒）

### モード方針
- 2モードのみ: 通常版 / カスタムモード
- 後半レースモードは実装しない

### 設定
- ユーザーが変更できる設定は2つのみ
  1. `raceDistanceKm`（km）
  2. `targetTimeSec`（HH:MM:SS）
- 補給は距離別の固定仕様（設定項目なし）
  - フル（上記以外）: 35分ごとに通知
  - ハーフ（`20.8-21.4km`）: 35分通知を1回のみ
  - 10K（`9.5-10.5km`）/5K（`4.5-5.5km`）: 通知なし
- 心拍ゾーンは Garmin 端末設定を取得する（設定項目なし）

### 参照
- UI: `docs/spec/ui.md`
- HR/ZONE: `docs/spec/logic_hr_zone.md`
- ACTION: `docs/spec/logic_action.md`
- DRIFT: `docs/spec/logic_drift.md`
- FUEL: `docs/spec/logic_fuel.md`
- 距離通知: `docs/spec/distance_cards.md`
