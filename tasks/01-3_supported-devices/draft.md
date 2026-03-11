# 1-3. 対応機種整理

- Source: `TASKS.md`

## T01 [P0] 正式対応機種リストを決める

- タスク内容:
  - 正式対応機種リストを決める
- 目的:
  - 公開初期のサポート範囲を現実的な検証済み機種に限定するため。
- 草案:
  - 層定義:
    - `P0` 売れ筋ランナー中心: `fr255 fr255s fr265 fr965 fr57042mm fr57047mm fr970 venu3 vivoactive5`
    - `P1` 画面形状・クラス差分カバー: `fr55 venux1 fenix7 enduro3 instinct3solar45mm instinct3amoled45mm`
    - `P2` 実利用のボリューム拡張枠（16）: `fr165 fr165m fr245 fr245m fr255m fr255sm fr265s fr745 fr945 fr945lte fr955 venu3s venusq2 venusq2m vivoactive4 vivoactive4s`
    - `P3` ハイエンド差分検証枠（26）: `enduro epix2 epix2pro42mm epix2pro47mm epix2pro51mm fenix6 fenix6pro fenix6s fenix6spro fenix6xpro fenix7s fenix7x fenix7pro fenix7spro fenix7xpro fenix7pronowifi fenix7xpronowifi fenix843mm fenix847mm fenixe fenix8solar47mm fenix8solar51mm fenix8pro47mm venu441mm venu445mm vivoactive6`
    - `P4` ロングテール互換枠（28）: `fenix5plus fenix5splus fenix5xplus fr645 fr645m instinct3amoled50mm instinctcrossover instinctcrossoveramoled instincte40mm instincte45mm marq2 marq2aviator marqadventurer marqathlete marqaviator marqcaptain marqcommander marqdriver marqexpedition marqgolfer venu venu2 venu2plus venu2s venusq venusqm vivoactive3m vivoactive3mlte`
  - 初期対応範囲: `P0/P1/P2/P3` のうち build-pass 機種（42機種）を正式対応とする。
  - 除外（動作保証外・manifest未掲載）: `fr55 instinct3solar45mm fr245 fr245m fr745 fr945 fr945lte vivoactive4 vivoactive4s enduro fenix6 fenix6pro fenix6s fenix6spro fenix6xpro`。
  - 後続対応方針: `P4` は対応最大化のロングテール枠として段階追加する。
  - 対応条件: 実機または同等シミュレーションでP0チェックを完了した機種のみ掲載。
  - 公開文面: `初期対応はP0〜P3。P4は検証完了次第で段階追加。` を明記する。
  - 注意点: 機種数を広げるより、確認済み品質を優先する。
- 結果:
  - `初期対応はP0/P1/P2/P3のbuild-pass機種（42機種）とし、build-fail機種は動作保証外としてmanifestから除外する。P4はロングテール互換の段階追加枠として運用する。`

## T02 [P0] manifest の対応機種定義を見直す

- タスク内容:
  - manifest の対応機種定義を見直す
- 目的:
  - Store掲載機種と実際のサポート方針を一致させるため。
- 草案:
  - manifest方針: 正式対応機種のみを残し、未確認機種エントリは削除またはコメント化。
  - 確認観点: 画面サイズ、メモリ制約、ビープ通知対応、言語リソース。
  - 成果物: `manifest.xml` の対応機種セクション差分と理由メモ。
  - 信頼訴求: `掲載機種 = 検証済み` を崩さないことで、レビュー時の安心感を作る。
  - 注意点: 「動く可能性がある」機種を入れない。検証済みのみ登録する。
- 結果:
  - `manifest掲載と実サポートを完全一致させ、掲載機種の信頼性を担保する。`

## T03 [P1] 非対応機種ポリシーを決める

- タスク内容:
  - 非対応機種ポリシーを決める
- 目的:
  - 問い合わせ時の回答を統一し、期待値ギャップを防ぐため。
- 草案:
  - 分類: `正式対応` / `未確認` / `非対応` の3区分。
  - 案内文: `未確認機種は動作保証なし。報告が集まり次第、対応可否を更新。`
  - 非対応条件: 画面情報量不足、通知制約、処理性能不足で価値提供できない機種。
  - 追加導線: 未確認機種ユーザー向けに「検証協力フォーム」を提示し、次回対応候補を可視化。
  - 注意点: 断定できない場合は「未確認」と記載し、誤案内を避ける。
- 結果:
  - `3区分ポリシーを固定し、未確認機種には検証協力導線を用意してサポートの透明性を高める。`

## 【斬新案】

- `機種別アンバサダー制度`:
  - 各シリーズの検証協力者を「公式アンバサダー」として紹介し、対応拡大をコミュニティ企画化する。
- `30秒互換性チェック診断`:
  - ストア外ランディングで機種名を選ぶだけで「正式対応/未確認/非対応」と代替案を即表示する。
