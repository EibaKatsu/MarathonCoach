---
name: custom-code-generator
description: MarathonCoach のカスタムコード生成スキル。ユーザーが「カスタムコード」と依頼したら、1〜7項目の入力テンプレートを提示する。ユーザーがテンプレートに値を追記して返したら、それを読み取り、仕様に沿ってカスタムコードを生成して返す。
---

# Custom Code Generator

MarathonCoach のカスタムコードを、ユーザー入力（7項目）から生成する。

## Trigger
- ユーザーが `カスタムコード` と指示したとき

## Default flow
1. ユーザー入力に 7項目の値が未記入なら、次のテンプレートをそのまま返す。
2. ユーザーが値を記入して返したら、`scripts/generate_custom_code.py` でコードを生成する。
3. 生成結果のコード文字列のみを返す。入力エラー時は不足/不正項目を短く伝える。

## Template to show
```text
1. fuelMode(00=off, 01=time):
2. firstFuelAfterMin(1-99):
3. fuelIntervalMin(1-99):
4. fuelAlertLeadMin(0-5):
5. phaseAggressiveness(0-20):
6. hrCapBiasBpm(-8 to 8):
7. driftSensitivity(0-7):
```

## Command
```bash
python3 skills/custom-code-generator/scripts/generate_custom_code.py generate --text "<user_input>"
```

`--text` を使わない場合は標準入力を使う:
```bash
python3 skills/custom-code-generator/scripts/generate_custom_code.py generate
```

## Value rules
- `fuelMode`: `off` / `time`（`0`/`1` も可）
- `firstFuelAfterMin`: `1..99`
- `fuelIntervalMin`: `1..99`
- `fuelAlertLeadMin`: `0..5`
- `phaseAggressiveness`: `0..20`
- `hrCapBiasBpm`: `-8..8`
- `driftSensitivity`: `0..7`
