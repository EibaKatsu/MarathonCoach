# gatechecker_simulator_scenarios

GateChecker の `NORMAL / PACE N/A / OVER / ALL PASSED` を simulator で再現するための固定手順をまとめる。

通常の simulator QA 観点は `docs/dev/simulator_checklist.md` を参照し、本ファイルでは GateChecker 専用の状態再現に絞る。

## 基本方針

- 時刻依存の `NORMAL / OVER` は固定コードを長期保存せず、その場の現在時刻基準で毎回生成する
- 距離依存の `ALL PASSED` は同じコードを使い、現在距離だけを進めて再現する
- `PACE N/A` は「次関門あり + 残距離 0 + 残時間あり」で出るので、先頭関門を `0.0km` にした専用コードを使う
- 判定の最終確認は画面だけでなく `[GATE_CODE_DIAG] displayState=...` でも行う

## 補助スクリプト

リポジトリ root で実行する。

```bash
python3 scripts/generate_gatechecker_scenarios.py
```

時刻を固定したい場合:

```bash
python3 scripts/generate_gatechecker_scenarios.py --base-time 22:00
```

出力される scenario 名:

- `normal`
- `pace_na`
- `over`
- `all_passed`

## 共通準備

1. GateChecker を build して simulator にロードする
2. App Settings Editor を開き、使いたい scenario の `gate_code` を貼り付けて save する
3. simulator で `Simulation > FIT Data > Simulate` と `Data Fields > Timer > Start Activity` を使う
4. ログ確認時は `[GATE_CODE_DIAG] displayState=...` を探す

## NORMAL

目的:
- 4 段構成の通常表示を確認する

使う code:
- `python3 scripts/generate_gatechecker_scenarios.py` の `normal`

手順:
1. `normal` の `gate_code` を save する
2. activity を開始する
3. 現在距離が `0.3km` 未満の間に画面を見る

期待表示:
- line1: `0.3km / HH:MM`
- line2: `残距離 / 残り時間`
- line3: `必要ペース | 現在ペース`
- line4: `現在距離 / 現在時刻`

期待ログ:
- `displayState=normal`

## PACE N/A

目的:
- `line2` を維持したまま、`line3` 左側だけ `PACE N/A` に切り替わることを確認する

使う code:
- `python3 scripts/generate_gatechecker_scenarios.py` の `pace_na`

手順:
1. `pace_na` の `gate_code` を save する
2. 先に `Data Fields > Timer > Start Activity` を実行する
3. distance が `0.00km` のまま見えている間に画面を見る
4. その後に `Simulation > FIT Data > Simulate` を開始する

期待表示:
- line1: `0.0km / HH:MM`
- line2: `0.0km / 残り時間`
- line3: `PACE N/A | 現在ペース`
- line4: `0.00km / 現在時刻`

期待ログ:
- `displayState=pace_na`

補足:
- `PACE N/A` は current distance が先頭 `0.0km` gate と一致している短いタイミングで出る
- すぐに distance が進んで `NORMAL` へ移る場合は、activity を止めて同じ手順をやり直す

## OVER

目的:
- `OVER` 時に必要ペースが消え、`LATE` 表示が優先されることを確認する

使う code:
- `python3 scripts/generate_gatechecker_scenarios.py` の `over`

手順:
1. `over` の `gate_code` を save する
2. activity を開始する
3. 現在距離を `0.3km` 未満に保ったまま画面を見る

期待表示:
- line1: `0.3km / 過去時刻`
- line2: `残距離 / LATE h:mm`
- line3: `OVER | 現在ペース`
- line4: `現在距離 / 現在時刻`

期待ログ:
- `displayState=over`

## ALL PASSED

目的:
- 全関門通過後に不要な pace 数値が残らないことを確認する

使う code:
- `python3 scripts/generate_gatechecker_scenarios.py` の `all_passed`

手順:
1. `all_passed` の `gate_code` を save する
2. activity を開始する
3. current distance を `1.2km` より先まで進める

期待表示:
- line1: `LAST / HH:MM`
- line2: `ALL PASSED`
- line3: blank
- line4: `現在距離 / 現在時刻`

期待ログ:
- `displayState=all_passed`

## 運用メモ

- scenario の close time は現在時刻ベースで作るので、作成後は同じセッションのうちに使う
- `NORMAL` と `OVER` は時刻依存なので、翌日や数時間後に同じ code を再利用しない
- `ALL PASSED` は時刻より距離で確認する
- `PACE N/A` は現在仕様上もっとも短時間の状態なので、ログ確認を併用する
