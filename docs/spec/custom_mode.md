# custom_mode

## 目的
通常版では扱わない個人差（補給・心拍管理・レース運び）を反映し、個別最適化する。

## MVP設定項目（7つ）
1. `fuelMode`（`off` / `time`）
2. `firstFuelAfterMin`（初回補給タイミング）
3. `fuelIntervalMin`（補給間隔）
4. `fuelAlertLeadMin`（補給予告の早さ）
5. `phaseAggressiveness`（走り方強度 0..20）
6. `hrCapBiasBpm`（心拍上限バイアス -8..+8）
7. `driftSensitivity`（ドリフト感度 0..7）

## 補給設定MVP方針
- `fuelMode=off`: 補給通知なし
- `fuelMode=time`: 時間ベース補給通知
  - `firstFuelAfterMin` で初回通知
  - 以降 `fuelIntervalMin` ごとに通知
  - 予定時刻の `fuelAlertLeadMin` 分前から予告

※ 距離ベース補給（`fuelMode=distance`）は将来拡張。MVP対象外。

## 設計方針
- ユーザーに見せる項目は7つに限定
- 内部の専門閾値は公開せず、抽象設定から展開する
- 通常版はシンプル維持、カスタムモードのみ個別最適化

## カスタムコード方針
- 7項目の設定値を短いカスタムコードへ符号化して受け渡す
- コードに含める要素:
  - バージョン情報
  - 設定本体
  - 誤入力検知用チェック値
- 目的は機密化ではなく、運用性/入力性/拡張性

## 初期実装で非公開の内部パラメタ（例）
- フェーズ境界の細かな進行率
- 心拍オーバー判定秒数/解除秒数/解除オフセット
- ペース押し上げ判定秒差
- push時の心拍余裕幅
- cardiac cost 関連比率
- 通知固定表示秒数
- 誤操作防止デバウンス秒数
