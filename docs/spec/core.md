# core

## 通常版（Core）
目的: レース中に一瞬で読めるダッシュボードを安定提供しつつ、目標達成ペースと心拍上限の両方を崩さないことを支援する。

## 含まれる機能
- 常時表示ダッシュボード
  - 上段左: 心拍アーク / CAP心拍 / 現在心拍
  - 上段右: 予測ゴール時刻 / 目標差分
  - 中央: 現在ペース / ゴールランナーゲージ
  - 下段: 距離 / 経過時間
- 目標ゴール予測
  - 現在の表示ペースと残距離から予測ゴール時刻を算出する
  - 目標時刻との差分を分単位のコンパクト表記で出す
  - レース距離超過後は `Over` と `+x.xxkm` 表示へ切り替える
- 心拍管理
  - `LTHR -> HRR -> MaxHR` の優先順位で CAP 心拍を決める
  - レース進行率と距離プロファイルから、その時点の許容心拍上限を決める
  - 心拍アーク色と CAP ティックで上限接近 / 超過を伝える
- ペース / ゴール差ゲージ
  - 現在ペースを中央主役で表示する
  - 目標との差をゴールランナーゲージの左右位置でも示す
- ビープ通知
  - 心拍上限超過
- `ja` / `en` の2言語対応

## 現在の通常版で画面に出さないもの
- コーチカード
- 中央メッセージ切り替え表示
- ACTION ラベルの常時表示
- 独自距離通知カード
- DRIFT の常時表示

## モード方針
- 2モードを維持する
  - 通常版
  - カスタムモード
- 通常版はシンプルな設定で使えることを優先する
- カスタムモードの詳細仕様は [custom_mode.md](/Users/eibakatsu/Documents/codex/MarathonCoach/docs/spec/custom_mode.md) を正とする

## 設定
- 端末設定画面で扱う項目は次の4つ
  1. `race_distance_km`
  2. `target_time_hour`
  3. `target_time_minute`
  4. `custom_mode_code`
- `race_distance_km` はプリセット選択を使う
  - `42.195km`
  - `21.0975km`
  - `10km`
- `target_time_hour` は `0..8`
- `target_time_minute` は `00..59`
- `custom_mode_code` は任意入力の英数字文字列とする

## カスタムモードとの関係
- `custom_mode_code` が有効な場合、走り方強度と心拍上限バイアスなどを上書きできる
- `hrCapBiasBpm` はアンカー由来の CAP 心拍へ最後に加算する
- 通常版の画面構成はカスタムモードでも同じダッシュボードを維持する
- 補給関連の旧コード領域は後方互換のため予約のまま残してよいが、現行通常版では使用しない
- カスタムモードは公開版から排除しないが、詳細パラメタの直接編集UIは持たない

## 公開版で含めない機能
- FIT 自動取り込み
- レース後の詳細分析やレポート出力
- 公開版UIでの詳細パラメタ編集
  - 心拍上限バイアスの直接指定
  - フェーズ別ペース帯の直接指定
- 後半レース専用の別モード

## 実装メモ
- 予測表示は `distance >= 0.05km` から有効にする
- 予測差の compact text は `+Nm / -Nm / 0m / --m` を使う
- 上段左右は共通2行グリッドで縦位置を揃える
- 予測差の数字フォントは、同フレームで解決した心拍フォントを超えてはならない
- `SHORT` は `10km` 想定とし、`5km` 専用モードは持たない

## 参照
- UI: [ui.md](/Users/eibakatsu/Documents/codex/MarathonCoach/docs/spec/ui.md)
- HR/CAP ロジック: [logic_hr_zone.md](/Users/eibakatsu/Documents/codex/MarathonCoach/docs/spec/logic_hr_zone.md)
- ACTION: [logic_action.md](/Users/eibakatsu/Documents/codex/MarathonCoach/docs/spec/logic_action.md)
