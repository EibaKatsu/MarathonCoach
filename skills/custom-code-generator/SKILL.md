---
name: custom-code-generator
description: MarathonCoach のカスタムコード生成スキル。ユーザーが「カスタムコード」と依頼したら、S1〜S5 の CAP 心拍を埋める 5項目テンプレートを提示する。ユーザーがテンプレートに値を追記して返したら、それを読み取り、仕様に沿ってカスタムコードを生成して返す。
---

# Custom Code Generator

MarathonCoach のカスタムコードを、ユーザー入力（5項目）から生成する。

## Trigger
- ユーザーが `カスタムコード` と指示したとき

## Default flow
1. ユーザー入力に 7項目の値が未記入なら、次のテンプレートをそのまま返す。
2. ユーザーが値を記入して返したら、`scripts/generate_custom_code.py` でコードを生成する。
3. 生成結果のコード文字列のみを返す。入力エラー時は不足/不正項目を短く伝える。

## Template to show
```text
1. customCapS1(30-260):
2. customCapS2(30-260):
3. customCapS3(30-260):
4. customCapS4(30-260):
5. customCapS5(30-260):
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
- `customCapS1`: `30..260`
- `customCapS2`: `30..260`
- `customCapS3`: `30..260`
- `customCapS4`: `30..260`
- `customCapS5`: `30..260`
