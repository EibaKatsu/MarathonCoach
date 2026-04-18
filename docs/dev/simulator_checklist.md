# simulator_checklist

通常 QA 全体の観点は `docs/dev/qa_checklist.md` を参照し、本ファイルではシミュレーターで先に潰せる項目に絞って確認する。

GateChecker の状態再現手順は `docs/dev/gatechecker_simulator_scenarios.md` を参照する。

## シミュレーション確認観点（STEP13時点）
1. タイマー基準は `Data Field Timer Controls` の `Start/Pause/Lap` を使う
2. `lthr_bpm` 指定時、device LTHR より優先して CAP が決まる
3. `lthr_bpm` に不正値を入れた場合、device LTHR / HRR / MaxHR へフォールバックする
4. カスタムコードの `S1〜S5` がすべて有効なとき、フェーズごとの CAP が直接使われる
5. カスタムコードが一部欠けているときは通常の CAP 算出へ戻る
6. 左上が `現在心拍 + CAP` 表示になり、取得不可時は `--` / `CAP --` へ安全側にフォールバックする
7. HR超過が継続秒数で遷移し、回復5秒継続で解除
8. ゾーン取得不可時はHR超過カードに遷移しない
9. `UP / FL / DN` の坂判定が中央カードの文言選択に反映される
10. `fr255 / fr57042mm / fr57047mm` でWatchdogクラッシュなし
11. `ja/en` 多言語表示と英語改行を確認
12. 独自距離通知カードが出ない
13. DRIFT固定表示が出ない
