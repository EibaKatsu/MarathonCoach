# X Direct Posting Research

Checked on 2026-03-19 JST.

## Conclusion

- `skills/x-post-writer` から X へ直接投稿することは技術的には可能。
- いちばん現実的な初期実装は `テキスト投稿 / 返信投稿` に限定し、`POST /2/tweets` を使う形。
- 認証は `OAuth 2.0 Authorization Code Flow with PKCE` を第一候補にする。
- 画像付き投稿は後回しが安全。公式 docs 内で media upload 周りの説明が揺れているため。

## Recommended architecture

### Phase 1

- スキルはまず投稿文を作る。
- その後、ローカルスクリプトを呼び出して X API に投稿する。
- 初期対応は次の 2 種類だけに絞る:
  - 通常投稿
  - 既存投稿への返信

### Why PKCE first

- 公式 docs で v2 の投稿系に使える認証として `OAuth 2.0 Authorization Code with PKCE` が明示されている。
- `tweet.write` などの scope を細かく絞れる。
- `offline.access` を付ければ refresh token を保持でき、毎回ログインし直さずに済む。
- OAuth 1.0a User Context でも可能だが、署名処理が面倒で実装・保守の難度が上がる。

## Required X-side setup

- X Developer account
- Project
- App
- App の認証設定で OAuth 2.0 を有効化
- Callback URL / Redirect URI を設定
- 必要 scope を設定

### Minimum scopes

- `tweet.read`
- `tweet.write`
- `users.read`
- `offline.access`

### Optional scope

- `media.write`
  - 画像投稿までやるときだけ

## Endpoint plan

### Create post

- Endpoint: `POST https://api.x.com/2/tweets`
- 用途:
  - 通常投稿
  - 返信
  - 引用

### Example bodies

通常投稿:

```json
{
  "text": "Hello from Race Navi"
}
```

返信:

```json
{
  "text": "返信テキスト",
  "reply": {
    "in_reply_to_tweet_id": "1234567890123456789"
  }
}
```

## Local secret storage plan

既存の `.deploy/racenavi.env` 運用に合わせて、X 用もローカル env ファイルに寄せるのが自然。

候補:

- `.deploy/x.env`
- `.deploy/x.env.example`

想定キー:

```text
X_CLIENT_ID=
X_CLIENT_SECRET=
X_REDIRECT_URI=
X_ACCESS_TOKEN=
X_REFRESH_TOKEN=
X_USER_ID=
```

### Notes

- PKCE の public client なら `X_CLIENT_SECRET` は不要な場合がある。
- confidential client にするなら `X_CLIENT_SECRET` も保持する。
- アクセストークンは短命なので、実運用は refresh token 前提にする。

## Script plan

将来追加するスクリプト候補:

- 認可 URL 生成と token 交換を行う補助スクリプト（未作成）
- 投稿実行と refresh を行う補助スクリプト（未作成）

### CLI shape draft

```bash
python3 <future_publish_script> post --text "本文"
python3 <future_publish_script> reply --text "返信本文" --in-reply-to 1234567890123456789
```

## Safety rules for implementation

- デフォルトでは即投稿しない。
- 最初の実装は `--execute` を付けたときだけ投稿する。
- 何も付けないと dry-run にして、送信予定 payload を表示する。
- 投稿前に次をチェックする:
  - 280 文字超過
  - 空文
  - 直近投稿との重複疑い
  - reply 先 ID の未指定

## Known uncertainties

### Media upload docs are inconsistent

- `Manage Posts` の integration guide では「v2 だけでは完全な media upload はまだできない」と読める。
- 一方で最新の rate limit docs には `/2/media/upload` 系の endpoint が載っている。
- このため、初期実装は text-only にしておき、画像投稿は実装時に Developer Console と最新 docs を再確認する。

### Pricing docs are in transition

- `docs.x.com` では pay-per-usage pricing が案内されている。
- `developer.x.com` 側には legacy な Free / Basic / Pro 説明がまだ残っている。
- 実際の課金・利用可否は Developer Console の current plan を正に確認する必要がある。

### Rate limit docs are not perfectly aligned

- integration guide には `POST /2/tweets` が `200 requests / 15 minutes` と読める記述がある。
- 最新 rate limit docs では `POST /2/tweets` が `100 / 15min per user`, `10,000 / 24hrs per app`。
- 実装時はレスポンスヘッダと Developer Console 表示を正とする。

## Recommendation for actual implementation

- まずは text-only の direct posting を実装する。
- 認証は PKCE + refresh token にする。
- スキルからは毎回いきなり投稿せず、以下の 2 段階にする:
  1. 投稿文作成と重複チェック
  2. `投稿して` と明示されたときだけスクリプト実行

## Official sources

- Create or Edit Post: https://docs.x.com/x-api/posts/create-or-edit-post
- Manage Posts introduction: https://docs.x.com/x-api/posts/manage-tweets/introduction
- Manage Posts integration guide: https://docs.x.com/x-api/posts/manage-tweets/integrate
- OAuth 2.0 Authorization Code with PKCE: https://docs.x.com/fundamentals/authentication/oauth-2-0/authorization-code
- OAuth 2.0 user access token guide: https://docs.x.com/fundamentals/authentication/oauth-2-0/user-access-token
- v2 authentication mapping: https://docs.x.com/fundamentals/authentication/guides/v2-authentication-mapping
- Rate limits: https://docs.x.com/x-api/fundamentals/rate-limits
- Pricing: https://docs.x.com/x-api/getting-started/pricing
