# logic_hr_zone

## レースプロファイル判定
- `SHORT`: `raceDistanceKm <= 10.5`
- `HALF`: `abs(raceDistanceKm - 21.0975) <= 0.25`
- `FULL`: 上記以外

- `SHORT` は現行仕様では `10km` 想定とする
- `5km` 専用の分岐は持たない

## フェーズ分割
`progress = elapsedDistance / raceDistanceKm`

- `S1`: `< 24%`
- `S2`: `24%〜59%`
- `S3`: `59%〜83%`
- `S4`: `83%〜95%`
- `S5`: `95%〜Finish`

## CAP HR 算出優先順位
1. `custom code direct CAP`
2. `property LTHR`
3. `device LTHR`
4. `HRR = MaxHR - RestingHR`
5. `MaxHR`

- Garmin のゾーン番号は CAP の主ロジックに使わない
- `custom code direct CAP` は `S1〜S5` の5値がすべて有効な場合のみ使う
- `property LTHR` が無効または未指定なら `device LTHR` へフォールバックする
- direct CAP 使用時は後段バイアスを加えない

## LTHR ベース係数
| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | 0.95 | 0.96 | 0.97 | 0.98 | 0.99 |
| HALF | 0.97 | 0.98 | 0.99 | 1.00 | 1.01 |
| SHORT | 0.99 | 1.00 | 1.01 | 1.02 | 1.03 |

## HRR ベース係数
`CAP HR = RestingHR + (MaxHR - RestingHR) * ratio`

| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | 0.78 | 0.80 | 0.82 | 0.84 | 0.86 |
| HALF | 0.83 | 0.85 | 0.87 | 0.89 | 0.90 |
| SHORT | 0.88 | 0.89 | 0.90 | 0.91 | 0.92 |

## MaxHR ベース係数
`CAP HR = MaxHR * ratio`

| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | 0.84 | 0.85 | 0.86 | 0.87 | 0.88 |
| HALF | 0.88 | 0.89 | 0.90 | 0.91 | 0.92 |
| SHORT | 0.90 | 0.91 | 0.92 | 0.93 | 0.94 |

## 安全クリップ
- `FULL`
  - `LTHR` がある場合: `capHr <= min(LTHR + 1, MaxHR - 3)` を優先
  - `LTHR` がない場合: `capHr <= MaxHR - 3`
- `HALF`
  - `LTHR` がある場合: `capHr <= min(LTHR + 3, MaxHR - 2)` を優先
  - `LTHR` がない場合: `capHr <= MaxHR - 2`
- `SHORT`
  - `capHr <= MaxHR - 1`

- 最終 CAP HR は bpm の整数へ丸める
- 下限は `RestingHR` を下回りにくい安全側クリップを入れてよい
- `custom code direct CAP` は最終値として扱い、LTHR/HRR/MaxHR の係数計算を通さない

## Source 識別
- `CAP_SOURCE_CUSTOM_CODE`
- `CAP_SOURCE_LTHR_PROPERTY`
- `CAP_SOURCE_LTHR_DEVICE`
- `CAP_SOURCE_HRR`
- `CAP_SOURCE_MAXHR`

## HR超過判定
- 表示用心拍とは別に、判定専用の `judgeHr` を EMA で持つ
- `judgeHr >= capHr + 2` が `8秒` 継続で Over
- `judgeHr >= capHr + 4` が `3秒` 継続で即 Over
- `judgeHr <= capHr - 2` が `5秒` 継続で解除
- フェーズ依存の秒数・解除閾値は持たない
