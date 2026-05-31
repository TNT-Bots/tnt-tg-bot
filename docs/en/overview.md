[English](../en/overview.md) | [Russian](../ru/overview.md)

# Overview

This page explains **what tnt-tg-bot includes** and **how an update flows through it**. Once you have this mental model, the rest of the docs are just details of each subsystem.

## What it is

tnt-tg-bot is a thin, explicit layer over the Telegram Bot API for Tarantool:

- It turns raw Telegram updates into **typed context objects** (`Message`, `CallbackQuery`, …).
- It exposes **every Bot API method** on the `bot` object (`bot:sendMessage{…}`).
- It gives you the building blocks for **commands**, **keyboards**, **payments** and **WebApp**, but leaves the routing/architecture to you.

It is deliberately unopinionated: the only event the runtime calls is `bot.events.onGetUpdate(ctx)`. Everything else - how you dispatch by update type, how you structure commands and events - is yours to design.

## Update lifecycle

```
Telegram
   │  raw update (JSON)
   ▼
transport            bot/transport/{longpolling,webhook}.lua
   │  one fiber per update → switch(update)
   ▼
processMessage       bot/processes/processMessage.lua
   │  wraps raw update into a typed context object
   ▼
bot.events.onGetUpdate(ctx)        ← the single built-in entry point (you define it)
   │  you route by update type / content
   ▼
your handlers        commands, keyboards, your own events (EventEmitter), …
```

1. **Transport** (`longpolling` or `webhook`) receives raw updates and runs each one in its own Tarantool fiber, calling the internal `switch`.
2. **`switch`** does exactly one thing: `bot.events.onGetUpdate(processMessage(update))`.
3. **`processMessage`** inspects the update and returns the matching context object: `Message` (`message`), `CallbackQuery` (`callback_query`), `ChatMember` (`chat_member`), `MyChatMember` (`my_chat_member`), `PreCheckoutQuery` (`pre_checkout_query`). Anything else is passed through as-is.
4. **`bot.events.onGetUpdate(ctx)`** is yours. A typical implementation branches on the update type and forwards to your own named events / command processor.

> Undefined events are safe to reference: `bot.events.someEvent` returns a no-op that logs at `verbose` level. So you can call `bot.events.onChatMessage(ctx)` even before you define it.

## The `bot` object

Configured once via `bot:cfg{…}`. Key surface:

| Member | Purpose |
|--------|---------|
| `bot:cfg(opts)` | Init: `token`, `parse_mode` (default `HTML`), `api_url`, `username`. Creates `bot.commands`, `bot.events`, wraps API methods. |
| `bot.call(method, fields, opts)` | Raw Bot API call. |
| `bot:<method>{…}` | Auto-generated wrappers for every method in `enums/methods` (e.g. `bot:sendMessage`, `bot:banChatMember`). |
| `bot.sendImage(data)` | Shortcut for `sendPhoto` from a file path or URL. |
| `bot.events` | Table of your event handlers; the runtime only calls `onGetUpdate`. |
| `bot.command(ctx)` / `bot.callbackCommand(ctx)` | Resolve a registered command/callback from the update by name. |
| `bot.commands` | Registry: `name → command`. Populated manually or via `commandLoader`. |
| `bot:getBotId()` | Numeric bot id, parsed from the token. |
| `bot.subdir(deep, ...)` | `require`-path helper for module-relative requires. |
| `bot:startLongPolling(opts)` | Run via long polling. |
| `bot:startWebHook(opts)` / `bot:sendCertificate(opts)` | Run via webhook. |
| `bot:debugRoutes(opts)` | Spin up an HTTP server with custom routes while long polling. |

## Subsystem map

| Directory | What's inside |
|-----------|---------------|
| [`bot/init.lua`](../../bot/init.lua) | Entry point. Builds the `bot` object, wires the lifecycle (`switch`), exposes config, transports, command resolvers and wrapped methods. |
| [`bot/api.lua`](../../bot/api.lua) | API client: `call`, `wrapMethods` (generates `bot:<method>`), `sendImage`. |
| [`bot/commands.lua`](../../bot/commands.lua) | Resolve a text command or callback from a context by its first token (and `/cmd@username`). |
| [`bot/config.lua`](../../bot/config.lua) | Library defaults: `api_url`, `parse_mode`, `token`. |
| [`bot/classes/`](../../bot/classes) | Typed update contexts with getters and helpers: `Message`, `CallbackQuery`, `ChatMember`, `MyChatMember`, `PreCheckoutQuery`, `SuccessfulPayment`. See [Context & events](context.md). |
| [`bot/enums/`](../../bot/enums) | Telegram constants: `methods`, `chat_type`, `chat_member_status`, `chat_permissions`, `command_flags`, `entity_type`, `parse_mode`, `allowed_updates`, `bot_command_scope`, `message_effect`, `errors`. |
| [`bot/interfaces/`](../../bot/interfaces) | `EventEmitter` (`on`/`emit`) - the observer primitive for building your own event dispatch. |
| [`bot/libs/`](../../bot/libs) | Helpers: `hdec` (HTML formatting), `sql` (Tarantool 3 SQL/NoSQL wrapper), `rateLimiter` (token bucket), `sendQueue` (per-chat outgoing queue), `parseInitData` (WebApp initData validation), `inputFile`, `getter`. See [Libraries](libs.md). |
| [`bot/middlewares/`](../../bot/middlewares) | `request` (HTTP transport to the API, retries, parse-mode injection), `inlineKeyboard` and `inlineCallbackKeyboard` (keyboard builders). See [Keyboards](keyboards.md). |
| [`bot/processes/`](../../bot/processes) | `processMessage` (raw update → typed ctx) and `processCommand` (command runtime: argument parsing, pre/post hooks, rate limiting). |
| [`bot/transport/`](../../bot/transport) | `longpolling`, `webhook`, `debug`. See [Transport](transport.md). |
| [`bot/types/`](../../bot/types) | Telegram payload builders/validators: inline & reply keyboards, buttons, `ForceReply`, `LinkPreviewOptions`, `InputMedia*` (media groups). |
| [`bot/utils/`](../../bot/utils) | `commandLoader` (load command modules into `bot.commands`), `fstring` (`string.f` templating), `pagination`, `colors`. |

## Where to go next

- [Getting started](getting-started.md) - install and run a minimal bot.
- [Commands](commands.md) - the `Command` class, flags, the loader, and callbacks.
- [Context & events](context.md) - context objects, getters, and building your own event dispatch.
- [Keyboards](keyboards.md) - inline and reply keyboards.
- [Libraries](libs.md) - the helpers in `bot/libs` and `bot/utils`.
- [Transport](transport.md) - long polling, webhook, and the debug server.
