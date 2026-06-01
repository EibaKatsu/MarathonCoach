---
name: custom-code-generator
description: MarathonCoach / RaceNavi Core のカスタムコード生成スキル。5項目テンプレートを提示し、`customCapS1`〜`customCapS5` を受け取ってコード文字列だけを返す。
status: active
---

# Custom Code Generator

## Trigger
- `カスタムコード`

## Read first
- `docs/spec/custom_code.md`

## Default flow
1. ユーザー入力に 5項目の値が未記入なら、5項目テンプレートを返す。
2. 値が揃ったら `skills/custom-code-generator/scripts/generate_custom_code.py` でコードを生成する。
3. 正常時はコード文字列のみを返す。入力エラー時は不足または不正項目だけを短く返す。

## Commands
```bash
python3 skills/custom-code-generator/scripts/generate_custom_code.py template
```

```bash
python3 skills/custom-code-generator/scripts/generate_custom_code.py generate --text "<user_input>"
```

`--text` を使わない場合は標準入力を使う:
```bash
python3 skills/custom-code-generator/scripts/generate_custom_code.py generate
```

## Template
```text
1. customCapS1(30-260):
2. customCapS2(30-260):
3. customCapS3(30-260):
4. customCapS4(30-260):
5. customCapS5(30-260):
```

## Output
- 正常時: コード文字列のみ
- 異常時: 不足または不正な項目名のみを簡潔に返す

## Do not
- 5項目以外を要求しない。
- 前置きや説明文を付けてコードを返さない。
