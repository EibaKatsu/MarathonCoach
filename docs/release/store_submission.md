# store_submission

## 申請素材（P0中心）
- アプリ名
- サブタイトル
- ストア説明文（短文/詳細）
- カバー画像
- 対応機種説明
- 設定方法説明
- スクリーンショット 3〜5枚

## ストア表示ルール
### 共通素材
- スクリーンショットは通常版とベータ版で共通運用する
- アイコンは通常版とベータ版で共通運用する
- 共通素材の差し替えで `BETA` を表現しない

### 通常版
- アプリ名: `レースナビ`
- サブタイトル: `目標達成をサポートするペース&心拍ガイド`
- 説明文: `tasks/03-1_store-assets/draft.md` で確定した通常版文面を使う
- カバー画像: `assets/store_shots/cover_normal.png`

### ベータ期間版
- アプリ名: `レースナビ BETA`
- サブタイトル: `公開前の実機テスト版`
- 説明文冒頭: `公開前の実機テスト運用中 / 不具合の可能性あり / 安定版ではありません`
- カバー画像: `assets/store_shots/cover_beta.png`
- 注意書き: 安定版希望ユーザーには非推奨であること、機種差分確認が目的であることを明記する

## 期待値調整で必ず入れる要点
- 公開版はレース中の判断支援に特化する
- FIT分析やレース後の深掘りは含めない
- 高度な個別設定は公開版では提供しない
- 個別最適化は `LTHR` 指定またはカスタムコードで案内する

## スクリーンショット構成案
1. アプリの価値
2. レース中の表示
3. 心拍CAPと予測ゴールのイメージ
4. 設定画面
5. 通常版の使い方

## パッケージ作成と申請
- `manifest.xml` 最終確認
- `./scripts/build_release_package.sh` で `.iq` を生成
- `.iq` ファイル出力
- ストア申請フォーム登録
- 審査前チェックリスト実施
- チェック記録: `docs/release/store_review_checklist.md`
- 提出ログ: `docs/release/store_submission_log.md`
- 差し戻し対応: `docs/release/store_rejection_flow.md`

## 署名鍵ルール
- Store 提出用 `.iq` は、過去公開版と同じ旧署名鍵で署名する
- 既定の公開鍵パスは `/Users/eibakatsu/Downloads/grow/.vscode/developer_key`
- 鍵の保管場所が変わった場合だけ `CIQ_RELEASE_KEY=/path/to/developer_key` で上書きする
- `CIQ_DEV_KEY` や `./.vscode/developer_key` は開発用として扱い、Store 提出用パッケージには使わない

## 推奨手順
1. `CIQ_DEV_KEY=.vscode/developer_key ./scripts/run_unit_tests.sh run fr255`
2. `CIQ_DEV_KEY=.vscode/developer_key ./scripts/run_manifest_smoke.sh --build-only`
3. `./scripts/build_release_package.sh`

## 補足
- `./scripts/build_release_package.sh` は `manifest.xml` の version を読み、`bin/releases/<version>/` に `.iq` と `BUILD.md` を出力する
- Store にアップロードするファイルは、このスクリプトで生成した `.iq` を使う

## 素材ファイル
- 通常版カバー画像: `assets/store_shots/cover_normal.png`
- ベータ版カバー画像: `assets/store_shots/cover_beta.png`
- 共通スクリーンショット: `assets/store_shots/shot01_value.jpg` / `assets/store_shots/shot02_one_screen.jpg` / `assets/store_shots/shot03_hr_cap.jpg` / `assets/store_shots/shot04_three_settings.jpg`
- 共通アイコン: `assets/icon_output/launcher_icon_512.png`

## 参照
- 全体タスク: `TASKS.md`
- 公開判定: `RELEASE.md`
