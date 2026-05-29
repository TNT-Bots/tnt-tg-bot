[English](../en/transport.md) | [Russian](../ru/transport.md)

# Транспорт

Транспорт получает сырые апдейты и передаёт каждый (в своём fiber) во внутренний
`switch`, то есть `bot.events.onGetUpdate(processMessage(update))`.

## Long polling

[`bot/transport/longpolling.lua`](../../bot/transport/longpolling.lua).

```lua
bot:startLongPolling({
  offset  = -1,
  timeout = 60,                              -- таймаут long-poll getUpdates, секунды
  allowed_updates = {                        -- опционально; дефолт ниже
    bot.enums.allowed_updates.MESSAGE,
    bot.enums.allowed_updates.CALLBACK_QUERY,
    bot.enums.allowed_updates.CHAT_MEMBER,
  },
})
```

Дефолтный `allowed_updates`, если не задан: `message`, `chat_member`,
`my_chat_member`, `callback_query`, `pre_checkout_query`.

> Заметка: чтобы получать **`chat_member`** (смену статуса *других* участников),
> бот должен быть **администратором** чата *и* `chat_member` должен быть в
> `allowed_updates`. Без админ-прав Telegram их просто не пришлёт.

## Webhook

[`bot/transport/webhook.lua`](../../bot/transport/webhook.lua). Поднимает
HTTP-сервер и регистрирует webhook:

```lua
bot:startWebHook({
  bot_url = 'https://example.com/webhook',   -- уходит в setWebhook
  host = '0.0.0.0',
  port = 9091,
  path = '/webhook',                         -- по умолчанию '/'
  drop_pending_updates = false,
  allowed_updates = { ... },
  certificate = '/path/cert.pem',            -- опционально, самоподписанный серт
  routes = {                                 -- опционально, доп. HTTP-ручки
    { path = '/health', method = 'GET', callback = function(req) return { status = 200 } end },
  },
})
```

`bot:sendCertificate(opts)` отдельно перешлёт самоподписанный сертификат в Telegram.

## Отладочный сервер

[`bot/transport/debug.lua`](../../bot/transport/debug.lua). Поднимает HTTP-сервер
с произвольными ручками **во время long polling** — удобно для ручек WebApp или
локальных тестов без перехода на webhook:

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

## Выбор апдейтов

[`bot/enums/allowed_updates`](../../bot/enums/allowed_updates.lua) перечисляет все
типы апдейтов (`MESSAGE`, `CALLBACK_QUERY`, `CHAT_MEMBER`, `MY_CHAT_MEMBER`,
`PRE_CHECKOUT_QUERY`, `INLINE_QUERY`, `POLL`, …). Передавай в `allowed_updates`
транспорта те, что обрабатываешь.

## Платежи (Telegram Stars)

Участвуют два апдейта; включи `pre_checkout_query` (он есть в дефолте long polling):

```lua
function bot.events.onGetUpdate(ctx)
  -- 1. Подтвердить pre-checkout (ответить нужно за секунды)
  if ctx.pre_checkout_query then
    bot:answerPreCheckoutQuery({ pre_checkout_query_id = ctx:getId(), ok = true })
    return
  end

  -- 2. Платёж завершён — приходит полем в сообщении
  if ctx.message and ctx.message.successful_payment then
    local sp = ctx:getSuccessfulPayment()
    -- sp:getTotalAmount(), sp:getCurrency(), sp:getInvoicePayload(),
    -- sp:getTelegramPaymentChargeId()
    return
  end
end
```

Связанные обёрнутые методы: `bot:sendInvoice`, `bot:createInvoiceLink`,
`bot:refundStarPayment{ user_id, telegram_payment_charge_id }`,
`bot:getStarTransactions`.

См. также: [Контекст и события](context.md), [Обзор](overview.md).
