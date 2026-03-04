## Skills
A skill is a set of local instructions stored in a `SKILL.md` file.

### Available skills
- ciq-simulator-launch: Connect IQ のシミュレーション起動用。`シミュレーション起動` や `run simulator` の指示で、`monkeyc` ビルド -> `connectiq` 起動 -> `monkeydo` 実行を行う。 (file: /Users/eibakatsu/Documents/codex/MarathonCoach/skills/ciq-simulator-launch/SKILL.md)

### How to use skills
- Trigger rules: ユーザーがスキル名やトリガー文言を指定したらそのスキルを使う。
- Read policy: まず `SKILL.md` を開き、必要な参照ファイルだけ読む。
- Script policy: `scripts/` がある場合はスクリプト実行を優先する。
