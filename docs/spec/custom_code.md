# custom_code

## 目的
通常版の自動 CAP 算出では足りない個別調整を、心拍CAPに限定して明示的に反映する。

## 現在有効な調整項目
1. `customCapS1`（S1 の CAP bpm）
2. `customCapS2`（S2 の CAP bpm）
3. `customCapS3`（S3 の CAP bpm）
4. `customCapS4`（S4 の CAP bpm）
5. `customCapS5`（S5 の CAP bpm）

- 各値は整数 bpm として扱う
- `30..260` を有効値とする
- `S1〜S5` がすべて有効な場合のみ direct CAP として有効化する
- 1つでも欠ける、または無効値を含む場合は通常の CAP 算出へフォールバックする

## 通常計算との関係
- direct CAP は `custom code direct CAP -> property LTHR -> device LTHR -> HRR -> MaxHR` の最上位に置く
- direct CAP 使用時は `LTHR / HRR / MaxHR` の係数計算を行わない
- direct CAP 使用時は後段 bias を加えない
- `LTHR` を明示したいだけなら、カスタムコードではなく `lthr_bpm` プロパティを使う

## コード形式
- 接頭辞: `C2`
- 本体: `S1〜S5` の5値を base36 2桁ずつで保持
- 末尾: 誤入力検知用チェックサム 2桁

## 互換方針
- 旧来の方針ベースコードは廃止する
- 旧 `C1` 系コードは新仕様の direct CAP としては解釈しない
- 設定キー名 `custom_mode_code` は内部互換のため残すが、UI表示名は `Custom Code` に統一する
