[English](../en/transport.md) | [Russian](../ru/transport.md)

# Transport

A transport receives raw updates and feeds each one (in its own fiber) to the
internal `switch`, i.e. `bot.events.onGetUpdate(processMessage(update))`.

## Long polling

[`bot/transport/longpolling.lua`](../../bot/transport/longpolling.lua).

```lua
bot:startLongPolling({
  offset  = -1,
  timeout = 60,                              -- getUpdates long-poll timeout, seconds
  allowed_updates = {                        -- optional; see default below
    bot.enums.allowed_updates.MESSAGE,
    bot.enums.allowed_updates.CALLBACK_QUERY,
    bot.enums.allowed_updates.CHAT_MEMBER,
  },
})
```

Default `allowed_updates` if you omit it: `message`, `chat_member`,
`my_chat_member`, `callback_query`, `pre_checkout_query`.

> Note: to receive **`chat_member`** (status changes of *other* users) the bot
> must be an **administrator** in the chat *and* `chat_member` must be in
> `allowed_updates`. Without admin rights Telegram simply won't send them.

## Webhook

[`bot/transport/webhook.lua`](../../bot/transport/webhook.lua). Starts an HTTP
server and registers the webhook:

```lua
bot:startWebHook({
  bot_url = 'https://example.com/webhook',   -- passed to setWebhook
  host = '0.0.0.0',
  port = 9091,
  path = '/webhook',                         -- default '/'
  drop_pending_updates = false,
  allowed_updates = { ... },
  certificate = '/path/cert.pem',            -- optional self-signed cert
  routes = {                                 -- optional extra HTTP routes
    { path = '/health', method = 'GET', callback = function(req) return { status = 200 } end },
  },
})
```

`bot:sendCertificate(opts)` re-sends a self-signed certificate to Telegram on its
own.

## Debug server

[`bot/transport/debug.lua`](../../bot/transport/debug.lua). Spin up an HTTP server
with custom routes **while running long polling** — handy for WebApp routes or
local testing without switching to webhook:

```lua
bot:debugRoutes({
  host = '0.0.0.0',
  port = 9091,
  routes = {
    { path = '/twa', method = 'POST', callback = handler },
  },
})
bot:startLongPolling()
```

## Selecting updates

[`bot/enums/allowed_updates`](../../bot/enums/allowed_updates.lua) lists every
update type (`MESSAGE`, `CALLBACK_QUERY`, `CHAT_MEMBER`, `MY_CHAT_MEMBER`,
`PRE_CHECKOUT_QUERY`, `INLINE_QUERY`, `POLL`, …). Pass the ones you handle to the
transport's `allowed_updates`.

## Payments (Telegram Stars)

Two updates are involved; enable `pre_checkout_query` (it's in the long-polling
default):

```lua
function bot.events.onGetUpdate(ctx)
  -- 1. Confirm the pre-checkout (must answer within seconds)
  if ctx.pre_checkout_query then
    bot:answerPreCheckoutQuery({ pre_checkout_query_id = ctx:getId(), ok = true })
    return
  end

  -- 2. Payment completed — arrives as a field on a message
  if ctx.message and ctx.message.successful_payment then
    local sp = ctx:getSuccessfulPayment()
    -- sp:getTotalAmount(), sp:getCurrency(), sp:getInvoicePayload(),
    -- sp:getTelegramPaymentChargeId()
    return
  end
end
```

Related wrapped methods: `bot:sendInvoice`, `bot:createInvoiceLink`,
`bot:refundStarPayment{ user_id, telegram_payment_charge_id }`,
`bot:getStarTransactions`.

See also: [Context & events](context.md), [Overview](overview.md).
