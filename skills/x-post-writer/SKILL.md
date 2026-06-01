---
name: x-post-writer
description: RaceNavi 公式アカウント `@racenavi_run` 向けの X 投稿文を作るスキル。直近投稿の確認、重複リスク判定、文案作成を順に行う。
status: active
---

# X Post Writer

## Trigger
- `X投稿文を作って`
- `次の投稿を考えて`
- `ポスト文を考えて`

## Read first
- `references/racenavi-context.md`
- 直接投稿の実装や調査が必要なときだけ `references/x-direct-posting-research.md`

## Default flow
1. `references/racenavi-context.md` を読む。
2. `@racenavi_run` の直近 1〜3 件の投稿本文と投稿日時を確認する。
3. 依頼内容と直近投稿を比較し、連投や重複のリスクを判定する。
4. 問題なければ推奨案を 1 本作る。微妙なら理由を短く示し、保守的な代替案を添える。

## Commands
- 固定のローカルコマンドはない。公開情報の live 確認を優先し、取得できない場合だけ `references/racenavi-context.md` を fallback として使う。

## Notes
- 可能なら絶対日付で直近投稿を確認する。
- 履歴取得が不完全な場合は、そのことを明示したうえで保守的な文案にする。
- 価値訴求は `レース中の迷いを減らす` `見やすさ` `心拍CAP` `ゴール予測` `実走での改善` を軸にする。
- 会社広報調にしすぎず、ただし個人雑談にも寄せすぎない。
- ハッシュタグは通常 0〜2 個、多くても 3 個までにする。

## Output
- 1 行目に `投稿可 / 注意 / 今は非推奨`
- 次に推奨案 1 本
- 必要なら代替案 1〜2 本
- 注意や非推奨なら理由 1 文

## Do not
- 直近履歴を確認せずに断定的な連投案を出さない。
- 新情報なしの連続募集を勧めない。
- URL やハッシュタグを詰め込みすぎない。
- 実体験や検証なしに大きな効果を断定しない。
