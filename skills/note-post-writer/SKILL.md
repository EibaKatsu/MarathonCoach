---
name: note-post-writer
description: RaceNavi の note 記事作成支援スキル。既存記事確認、テーマ提案、ヒアリング、構成案、本文作成、再校正、保存までを一貫して行う。
status: active
---

# RaceNavi Note Post Writer

## Trigger
- `note投稿文を作って`
- `note記事の下書きを作って`
- `既存のnoteの流れを見て次の記事案を出して`

## Read first
- `references/racenavi-note-editor-profile.md`
- 必要なら `PRODUCT.md`

## Default flow
1. `references/racenavi-note-editor-profile.md` を読む。
2. `https://note.com/ebasan` の既存記事を確認し、テーマ、トーン、重複リスクを整理する。
3. 次テーマ案を 3〜5 個出し、おすすめ 1 本を選ぶ理由を添える。
4. 選択テーマに対して 3〜6 問ヒアリングする。
5. 回答に応じて 3〜5 問の深掘りを 1〜2 回行う。
6. 本文前に `狙い / 想定読者 / タイトル3案 / 流れ / 画像挿入位置 / 着地案` を提示する。
7. note 向け Markdown で本文を作成し、再校正する。
8. 保存が必要なときは `scripts/save_note_post.sh` を使って `content/` に保存する。

## Commands
```bash
skills/note-post-writer/scripts/save_note_post.sh <markdown-file>
```

## Output
- 初回は `既存記事の確認結果 / 次テーマ案 / おすすめ案 / 質問`
- 素材収集後は `構成案`
- 最終的に `見出し付き Markdown 本文`

## Notes
- 技術説明より、体験・課題・気づき・作った理由を優先する。
- 売り込みは強くしすぎず、読み物として自然な流れを優先する。
- 保存ファイル名は `YYYY-MM-DD.md`、同日複数稿は `YYYY-MM-DD-2.md` 形式にする。

## Do not
- 推測で体験談を盛らない。
- 既存記事未確認でテーマを決めない。
- 機能一覧だけの記事にしない。
- いきなり長文完成稿を出さない。
