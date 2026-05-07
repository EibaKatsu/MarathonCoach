---
name: gatechecker-race-definition
description: GateChecker 向けの大会定義を作るスキル。ユーザーが「GateCheckerに○○の関門データを設定して」「大会設定ファイルを作って」「大会名から race 定義を作って」などと依頼したときに使う。大会名を受けたら公式情報を優先して検索し、関門情報とエイド情報を取得し、`apps/GateChecker/race_defs/races/*.yml` と `apps/GateChecker/race_defs/race_index.yml` を更新し、最後に取得元URLを表示する。
---

# GateChecker Race Definition

このスキルは、GateChecker の大会別 race 定義を「公式情報確認 -> YAML 作成 -> index 登録 -> 検証 -> 出典提示」の順で作る。

## Quick Flow

1. 大会名から公式サイト、公式要項、公式コースページ、公式 PDF/JPG コースマップを優先して探す。
2. 関門距離・関門時刻・スタート時刻・制限時間・エイド距離を確認する。
3. `apps/GateChecker/race_defs/races/<race_key>.yml` を作成または更新する。
4. `apps/GateChecker/race_defs/race_index.yml` に race を登録する。
5. 生成スクリプトで定義を検証する。
6. 最後に、使った取得元 URL をユーザーへ表示する。

## Source Rules

- 公式情報を最優先する。
- 優先順は `公式要項 > 公式コースページ > 公式コースマップ画像/PDF > 公式ニュース`。
- 公式情報で不足する場合だけ、RUNNET など大会公式が参照している準公式ページを補助的に使う。
- 関門やエイドの距離・時刻は、非公式まとめサイトだけを根拠に確定しない。
- 画像や PDF から読んだ値は、その URL を必ず最終報告に含める。
- 推定が入る場合は、推定だと明示する。例: `GOAL cutoff は公式のスタート時刻 + 制限時間から補完`。

## File Rules

- race 定義ファイルは `apps/GateChecker/race_defs/races/<race_key>.yml` に置く。
- `race_key` は `YYYYMMDD_<race_name>` 形式にする。例: `20260517_iwate_oshu_kirameki_marathon`
- `display_name.jpn` は大会名のみを入れる。`関門チェッカー` は付けない。
- `display_name.eng` も大会名のみを基本にする。`Gate Checker` は付けない。公式英語名がなければ過度に凝らず一貫したローマ字/英訳にする。
- `race.timezone` は日本国内大会なら通常 `Asia/Tokyo`
- 最終関門は距離ではなく `GOAL` を使う。
- `gates` と `aids` は厳密に昇順、`0.1km` 単位に揃える。

## race_index Rules

- `apps/GateChecker/race_defs/race_index.yml` に該当 race がなければ追加する。
- 既存 entry があれば `app_id` を壊さず維持する。
- 新規 entry の既定 version は `0.1.0`。
- `app_id` が未確定なら `null` でもよい。生成スクリプトが採番する構成を尊重する。

## Validation

- まず定義ファイル単体を見直し、距離・時刻・日付書式を確認する。
- 検証は `python3 apps/GateChecker/scripts/generate_gatechecker_race.py <race_key>` を使う。
- 生成検証で作業ツリーを不要に汚したくない場合は、`apps/GateChecker` を一時ディレクトリへコピーしてそこで検証する。
- 検証失敗時は、推測で直さず `どの値が公式根拠とズレているか` を先に確認する。

## Output

- 何を作成/更新したかを短く伝える。
- 関門と AID の取得根拠を 1 文で要約する。
- 取得元 URL をフラットな箇条書きで並べる。
- 推定が混じる場合は、その項目だけを分けて明示する。

## Repo Pointers

- 形式確認: `apps/GateChecker/README.md`
- index: `apps/GateChecker/race_defs/race_index.yml`
- 既存例: `apps/GateChecker/race_defs/races/20261101_toyama_marathon.yml`
- 生成検証: `apps/GateChecker/scripts/generate_gatechecker_race.py`
