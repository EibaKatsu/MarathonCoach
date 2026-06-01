# RaceNavi X Context

## Canonical product position

- このリポジトリの通常版プロダクトは `MarathonCoach / RaceNavi Core`。
- 通常版の正は `docs/spec/core.md`。
- GateChecker は別プロダクトで、現行方針は `apps/GateChecker/README.md` の単一アプリ + Race Code。

## Product value

- RaceNavi Core は Garmin 向けのマラソン支援 Data Field。
- 中心価値は `レース中の迷いを減らす` `失速リスクを下げる` `心拍上限を守りやすくする` `ゴール予測を見ながら判断しやすくする`。
- 表示量より、1画面で早く判断できることを重視する。
- 主対象は PB 5:00 前後の市民ランナー。完走〜サブ4 前後とも相性がよい。
- `補給通知` は現在の通常版の主訴求ではない。X 投稿でも中心メッセージとしては使いすぎない。

## GateChecker note

- GateChecker は `1つのアプリ + Race Code` で大会とコースを切り替える。
- 大会別アプリ生成は legacy 扱い。
- GateChecker を話題にする場合は `Race Code` と `単一アプリ` の説明を優先する。

## Account voice

- 運用方針は `公式アカウントを中の人が運営している` 温度感。
- 冷たすぎる広報文は避ける。
- ただし個人雑談アカウントにはしない。
- `中の人より。` という書き出しは使わない。
- 必要なら `レースナビです。`、または主語なしで自然に始める。
- 募集だけでなく、改善ログや実走確認も混ぜる。

## Promotion restraint

- 宣伝臭を強くしすぎない。
- 実走、検証、改善の具体がある投稿を優先する。
- URL は原則 1 個まで。なくてもよい。
- 実績や効果を過大に断定しない。

## Main paths

- Web: `https://racenavi.jpn.org/`
- X: `@racenavi_run`
- note: `https://note.com/ebasan`
- Connect IQ: インストール導線として案内するが、最新 URL は live 情報またはサイト側の導線を優先する。

## Verified X snapshot

- Checked on 2026-03-19 JST.
- Handle: `@racenavi_run`
- Display name: `Race Navi | Garminレース支援`
- Bio: `Garmin向けマラソン支援「レースナビ」のアカウントです。レース中の迷いを減らす表示と通知を磨いています。実機テスター募集中。`
- Visible `statuses_count` from profile lookup: `2`

### Retrieval limitation

- このファイルは fallback 用のキャッシュであり、毎回の live history 確認の代替ではない。
- 履歴取得が不完全な場合は、直近投稿を把握したふりをしない。

## Useful repo files

- `PRODUCT.md`
- `TASKS.md`
- `site/racenavi/README.md`
