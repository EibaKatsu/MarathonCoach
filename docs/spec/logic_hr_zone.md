# logic_hr_zone

## レースプロファイル判定
- `SHORT`: `raceDistanceKm <= 10.5`
- `HALF`: `abs(raceDistanceKm - 21.0975) <= 0.25`
- `FULL`: 上記以外

## フェーズ分割
`progress = elapsedDistance / raceDistanceKm`

- `S1`: `< 24%`
- `S2`: `24%〜59%`
- `S3`: `59%〜83%`
- `S4`: `83%〜95%`
- `S5`: `95%〜Finish`

## 許容ゾーンとオフセット
| Profile | S1 | S2 | S3 | S4 | S5 |
| --- | --- | --- | --- | --- | --- |
| FULL | Z2 +0 | Z3 +0 | Z3 +2 | Z4 +0 | Z4 +3 |
| HALF | Z3 +0 | Z4 -2 | Z4 +0 | Z4 +2 | Z4 +4 |
| SHORT | Z4 +0 | Z5 +2 | Z5 +3 | Z5 +4 | Z5 +5 |

## HR超過判定
判定条件: `HR > allowed + 1bpm`

- Over開始継続秒数
  - `S1/S2/S3`: 12秒
  - `S4`: 10秒
  - `S5`: 20秒
- Over解除
  - 回復継続 5秒
  - 解除閾値
    - `S4`: `allowed -1bpm`
    - その他: `allowed -2bpm`
