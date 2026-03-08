## Skills
A skill is a set of local instructions stored in a `SKILL.md` file.

### Available skills
- ciq-simulator-launch: Connect IQ のシミュレーション起動用。`シミュレーション起動` や `run simulator` の指示で、`monkeyc` ビルド -> `connectiq` 起動 -> `monkeydo` 実行を行う。 (file: /Users/eibakatsu/Documents/codex/MarathonCoach/skills/ciq-simulator-launch/SKILL.md)

### How to use skills
- Trigger rules: ユーザーがスキル名やトリガー文言を指定したらそのスキルを使う。
- Read policy: まず `SKILL.md` を開き、必要な参照ファイルだけ読む。
- Script policy: `scripts/` がある場合はスクリプト実行を優先する。

## Product Value (Runner-Centric)
このアプリは、レース中の意思決定を減らし、完走・目標達成確率を上げる「リアルタイム伴走」を提供する。

### Core runner value
- ペース迷子を防ぐ: 目標との差分と Push/Hold/Ease で、次の一手を即時に示す。
- 失速リスクを下げる: 心拍ゾーン超過を早期検知し、オーバーペース修正を促す。
- 補給忘れを防ぐ: 補給タイマーと警告で後半のガス欠リスクを抑える。
- 崩れの兆候に先回りする: ドリフト兆候に対して水分/補給などの対処を促す。
- メンタル負荷を下げる: 短いメッセージで焦りを抑え、リズム維持に集中させる。

### Guidance for future feature proposals
- 単なるデータ表示より「次の行動提案」に変換できる機能を優先する。
- 走行中に迷わないことを最優先し、表示は短く、判断は即時にする。
- 後半失速を防ぐ観点 (ペース/心拍/補給/ドリフト) への寄与を明示する。
- 新機能は「完走確率向上」または「目標達成確率向上」のどちらに効くかを説明する。
