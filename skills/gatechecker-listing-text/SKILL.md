---
name: gatechecker-listing-text
description: GateChecker の Connect IQ Store 向け listing text を作るスキル。ユーザーが「Connect IQ Listing Textを作って」「ストアタイトルと説明文を作って」「Listing文を作って」などと依頼したときに使う。`apps/GateChecker/race_defs` だけを入力ソースにして、日本語タイトル/説明文と英語タイトル/説明文を生成し、`apps/GateChecker/releases/<race_key>/CONNECT_IQ_LISTING.md` に保存する。
---

# GateChecker Listing Text

このスキルは、GateChecker の大会別 Connect IQ Store 文面を「race 特定 -> `race_defs` 読み取り -> 日英 listing 生成 -> release 配下へ保存」の順で作る。

## Quick Flow

1. ユーザーが指定した大会名または `race_key` から対象 race を特定する。
2. `apps/GateChecker/race_defs/race_index.yml` と `apps/GateChecker/race_defs/races/*.yml` を確認する。
3. `python3 apps/GateChecker/scripts/generate_gatechecker_listing_text.py <race_key>` を実行する。
4. `apps/GateChecker/releases/<race_key>/CONNECT_IQ_LISTING.md` の保存結果を確認する。
5. 最後に保存先の絶対パスをユーザーへ伝える。

## Source Rules

- 入力ソースは `apps/GateChecker/race_defs` だけを使う。
- 関門距離、関門時刻、AID 地点は推測で補わない。
- 大会名は `display_name.jpn` / `display_name.eng` を優先する。
- 英語名が未設定でも、無理に翻訳を増やさず既存値または `race_key` 解釈に留める。
- `GOAL` は最終関門ラベルとして維持し、単なる km 表記へ置き換えない。

## Output Rules

- 必ず次の 4 点を含める:
  - 日本語タイトル
  - 日本語説明文
  - 英語タイトル
  - 英語説明文
- 出力形式は Markdown 固定とする。
- 保存先は `apps/GateChecker/releases/<race_key>/CONNECT_IQ_LISTING.md` 固定とする。
- 文字数が長くなりすぎる場合でも、関門一覧、AID 一覧、注意書きを優先する。
- 「完走保証」「必ず間に合う」などの断定表現は入れない。

## Command

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_listing_text.py <race_key>
```

必要なら保存せず確認用に標準出力だけ見る:

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_listing_text.py <race_key> --stdout
```

## Race Resolution

- 入力が `race_key` ならそのまま使う。
- 大会名だけの指定なら `race_index.yml` と各 race 定義の `display_name.jpn` / `display_name.eng` から一致する race を探す。
- 候補が複数ある場合だけ、どの race を使うかユーザーへ確認する。

## Repo Pointers

- race index: `apps/GateChecker/race_defs/race_index.yml`
- race definitions: `apps/GateChecker/race_defs/races/`
- generator: `apps/GateChecker/scripts/generate_gatechecker_listing_text.py`
- output root: `apps/GateChecker/releases/`
