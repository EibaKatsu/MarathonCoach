# store_review_checklist

## 実施日
- 2026-03-14

## 対象
- リリース種別: `BETA`
- 申請バージョン: `0.0.1`
- app id: `12e1a6ba-4da8-47a1-b9ef-710f630f7c73`

## manifest 最終確認

| 項目 | 判定 | メモ |
| --- | --- | --- |
| アプリ名 | OK | `@Strings.AppName`。eng=`Race Navi` / jpn=`レースナビ`。 |
| app id | OK | `manifest.xml` の app id は `12e1a6ba-4da8-47a1-b9ef-710f630f7c73`。 |
| バージョン | OK | BETA 公開向けに `0.0.1` を設定。 |
| アプリ種別 | OK | `datafield`。`PRODUCT.md` の公開スコープと一致。 |
| 対応機種 | OK | `manifest.xml` に 42 機種を定義。`./scripts/run_manifest_smoke.sh --build-only` で全件ビルド成功。 |
| 言語 | OK | `eng` / `jpn` を定義。 |
| 権限 | OK | `UserProfile` のみ。 |
| BETA 運用整合 | OK | `docs/release/beta_test.md` の方針どおり通常公開 app id を継続利用。 |

## 審査前チェック

| 項目 | 判定 | 証跡 |
| --- | --- | --- |
| `.iq` 出力 | OK | `bin/releases/0.0.1/marathoncoach.iq` を生成。 |
| ユニットテスト | OK | `57` 件 PASS。`./scripts/run_unit_tests.sh run fr255` 実行。 |
| manifest 全機種ビルド | OK | `bin/releases/0.0.1/manifest_build_summary.tsv` に `42 PASS/SKIP/SKIP`。 |
| 初回設定導線 | OK | `tasks/03-1_store-assets/draft.md` の設定手順と `resources/properties.xml` が整合。通常版案内は `custom_mode_code` 空欄運用。 |
| BETA ストア表示整合 | OK | アプリ名 `レースナビ BETA`、サブタイトル `公開前の実機テスト版`、`cover_beta.png` を使用。 |
| サポート窓口 URL | 保留 | 公開 URL / フォーム URL をストアへ貼れる形で未確定。 |
| プライバシー / 利用規約 URL | 保留 | ローカル文書はあるが、公開 URL が未確定。 |
| ストア申請フォーム登録 | 保留 | 外部ログインを伴う手動作業。提出ログ準備済み。 |

## 注意メモ
- `.iq` のパッケージ化は `JAVA_TOOL_OPTIONS=-Djava.awt.headless=true` を付けると macOS 上の `Abort trap: 6` を回避できた。
- パッケージ化時に launcher icon の自動スケール警告が出るが、ビルドは成功した。
