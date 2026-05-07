---
name: 新規関門ガイドアプリ作成
description: 未取り込みのフルマラソンやウルトラマラソンを参加規模付きで選定し、GateChecker の race 定義、Connect IQ Listing、公開用 .iq、テスト、PR、独立レビュー、main マージまで一気通しで進めるスキル。ユーザーが「新規関門ガイドアプリ作成」「未取り込みレースを探して関門ガイドアプリを作って」「大会を選んで取り込みから公開iq作成までやって」などと依頼したときに使う。
---

# 新規関門ガイドアプリ作成

このスキルは、GateChecker 向けの新規レース追加を「候補選定 -> race 定義 -> Listing -> 公開 `.iq` -> 対応大会 HTML -> テスト -> PR -> 独立レビュー -> main マージ -> サイト公開」の順で進める。

## Quick Flow

1. 対象期間、地域、対象種別（フル/ウルトラ）を確認する。
2. 未取り込みレースを公式情報から探し、参加規模の大きい順に候補化する。
3. 各候補について、公式の関門、制限時間、エイド情報が十分に取れるか確認する。
4. 採用レースの `apps/GateChecker/race_defs/races/*.yml` と `apps/GateChecker/race_defs/race_index.yml` を更新する。
5. `python3 apps/GateChecker/scripts/generate_gatechecker_race.py <race_key>` で検証する。
6. `python3 apps/GateChecker/scripts/generate_gatechecker_listing_text.py <race_key>` で Listing を生成する。
7. `apps/GateChecker/scripts/build_gatechecker_release_package.sh <race_key> [version]` で公開用 `.iq` を生成する。
8. `python3 site/racenavi/scripts/generate_race_pages.py` で対応大会一覧と大会詳細 HTML を更新する。
9. `./scripts/run_unit_tests.sh` を実行する。
10. PR 作成、独立レビュー結果の記録、main マージまで実施する。
11. `./scripts/racenavi_deploy.sh check` で公開先接続を確認し、問題なければ `./scripts/racenavi_deploy.sh upload` でサイト公開まで実施する。

## Selection Rules

- 既存レースは `apps/GateChecker/race_defs/race_index.yml` で判定する。
- 参加規模は、公式の参加者数、定員、完走者数、または公式の規模表現を優先する。
- 比較指標の粒度が揃わない場合は、その旨を最終報告で明示する。
- 関門とエイドの公式根拠が弱い大会は、参加規模が大きくても採用を見送る。

## Source Rules

- 関門とエイドは公式情報を最優先する。
- 優先順は `公式要項 > 公式コースページ > 公式PDF/画像 > 公式FAQ/ニュース`。
- 公式が mile 表記なら、race 定義も mile 表記のまま作る。
- 公式が近似表現しか出していない場合は、その近似に沿って定義し、最終報告で明示する。
- 前年版の公式資料を使う場合は、当年版が未公開であることを確認し、暫定利用だと明示する。

## HTML / Publish Rules

- 対応大会 HTML は `site/racenavi/gatechecker/races/` と `site/racenavi/en/gatechecker/races/` の一覧・詳細ページまで更新対象に含める。
- HTML 生成は `site/racenavi/scripts/generate_race_pages.py` を使い、race 定義から再生成する。
- `site/racenavi/index.html` や `site/racenavi/styles.css` に unrelated な未コミット変更がある場合は、作業ツリーを壊さないよう一時ディレクトリで生成し、必要な HTML だけを戻す。
- 公開前に `./scripts/racenavi_deploy.sh check` を実行し、FTPS 接続と deploy 設定を確認する。
- main マージ後に `./scripts/racenavi_deploy.sh upload` を実行し、HTML 公開まで完了させる。

## Output Rules

- 最終報告では次を必ず含める。
  - 採用した大会一覧
  - 参加規模の根拠
  - 生成した `.iq` と Listing の保存先
  - 更新した対応大会 HTML
  - テスト結果
  - `PR URL`
  - `独立レビュー結果`
  - `マージコミット`
  - 公開結果

## Repo Pointers

- race index: `apps/GateChecker/race_defs/race_index.yml`
- race definitions: `apps/GateChecker/race_defs/races/`
- listing generator: `apps/GateChecker/scripts/generate_gatechecker_listing_text.py`
- release builder: `apps/GateChecker/scripts/build_gatechecker_release_package.sh`
- HTML generator: `site/racenavi/scripts/generate_race_pages.py`
- site deploy: `scripts/racenavi_deploy.sh`
- process: `PROCESS.md`
