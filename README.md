English | [Russian](docs/ru/README.md)</br>

![banner](banner.jpg)

[![luacheck](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml/badge.svg?branch=master)](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

## Description
**tnt-tg-bot** is a Lua library for the [Tarantool](https://www.tarantool.io/) platform that provides an interface to the [Telegram Bot API](https://core.telegram.org/bots/api). Current version: `2.0`.

> [!WARNING]
> The `master` branch may receive force pushes, hard resets.

## Features
- Simple, explicit interfaces
- Asynchronous update handling — one Tarantool fiber per update
- All Telegram Bot API methods auto-wrapped onto the bot object (`bot:sendMessage{...}`)
- Built-in command and callback-command handling
- You name your own events — only `bot.events.onGetUpdate(ctx)` is provided out of the box
- Long polling and webhook transports
- Telegram Stars payments
- WebApp (TWA): [initData validation](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app) via [`bot/libs/parseInitData.lua`](bot/libs/parseInitData.lua) and HTTP routes
- LDoc annotations
- Runnable examples

## Documentation
Detailed docs live in [`docs/en/`](docs/en) (на русском — [`docs/ru/`](docs/ru)):

| Topic | Description |
|-------|-------------|
| [Overview](docs/en/overview.md) | What the library includes: update lifecycle and subsystem map |
| [Getting started](docs/en/getting-started.md) | Install, a minimal bot, running |
| [Commands](docs/en/commands.md) | `Command` class, flags, `commandLoader`, callbacks |
| [Context & events](docs/en/context.md) | `bot.events`, `onGetUpdate`, context objects and getters |
| [Keyboards](docs/en/keyboards.md) | Inline and reply keyboards |
| [Libraries](docs/en/libs.md) | `hdec`, `sql`, `fstring`, `rateLimiter`, `sendQueue`, … |
| [Transport](docs/en/transport.md) | Long polling, webhook, debug server |

The LDoc API reference is generated with `bash bin/ldoc` (output in `doc/`).

## Quick start
```lua
local bot = require('bot')

bot:cfg({ token = os.getenv('BOT_TOKEN') })

function bot.events.onGetUpdate(ctx)
  local text = ctx:getText()
  if text then
    ctx:reply(text)
  end
end

bot:startLongPolling()
```
```bash
BOT_TOKEN="1348551682:AAFK..." tarantool examples/echo-bot.lua
```

## Installation

### Automatic
1. Install `git`, `curl`, `lua 5.1` and `luarocks`.
2. Install [Tarantool](https://www.tarantool.io/en/download/os-installation).
3. (Optional, for WebApp) install OpenSSL and Lua 5.1 dev headers — needed to build the `luaossl` rock.
4. Run the dependency installer:
```bash
bash tnt-tg-bot.pre-build.sh
```
5. If it fails, fall back to the manual steps.

> [!NOTE]
> `luaossl` (OpenSSL binding) needs OpenSSL and Lua 5.1 headers. On Ubuntu:
> `sudo apt install libssl-dev liblua5.1-0-dev`. It is required only by
> [`bot/libs/parseInitData.lua`](bot/libs/parseInitData.lua) for WebApp initData validation.

### Manual
1. Install `git`, `curl`, `lua 5.1`, `luarocks`, and [Tarantool](https://www.tarantool.io/en/download/os-installation).
2. Install the rocks:
```bash
# HTTP client/server (required)
luarocks install --local --tree=$PWD/.rocks --server=https://rocks.tarantool.org/ http
# Multipart POST (required)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 lua-multipart-post 1.0-0
# OpenSSL binding (optional, WebApp only)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 luaossl
```

## Examples

### Run with Docker (recommended)

The only requirement is Docker. [`bin/tarantool`](bin/tarantool) builds the
`tnt-tg-bot` image — which installs the rocks **inside** the container (no host
setup, and the native rock ABI matches the runtime) — then runs the example in it:

```bash
env BOT_TOKEN="BOT_TOKEN_HERE" ./bin/tarantool examples/echo-bot-new-ctx.lua
```

The first run builds the image; later runs use the cache. `bot/` and `examples/`
are mounted live, so you can edit them without rebuilding. The image **skips
`luaossl`** (WebApp/initData) by default — to enable it, add `libssl-dev` and
`liblua5.1-0-dev` to the [`Dockerfile`](Dockerfile) and uncomment luaossl in
[`tnt-tg-bot.pre-build.sh`](tnt-tg-bot.pre-build.sh).


| Example | What it shows |
|---------|---------------|
| [echo-bot.lua](examples/echo-bot.lua) | Echo replies via `bot:sendMessage` |
| [reply-bot.lua](examples/reply-bot.lua) | Echo via the `ctx:reply()` shortcut |
| [callback-answer.lua](examples/callback-answer.lua) | Inline keyboard + callback handling (`ctx:answer`, `ctx:getQueryData`) |
| [pagination.lua](examples/pagination.lua) | Paginated inline keyboard with detail pages (`bot.utils.pagination`) |
| [command-start-help/](examples/command-start-help) | Structured project: `commandLoader` + `/start`, `/help` modules |

## Library structure
```
bot/
├── init.lua        Entry point: bot object, cfg, transports, command resolvers, wrapped API methods
├── api.lua         API client: call, wrapMethods (generates bot:<method>), sendImage
├── commands.lua    Resolve a command / callback from the update by name
├── config.lua      Defaults (api_url, parse_mode, token)
├── classes/        Typed update contexts: Message, CallbackQuery, ChatMember, MyChatMember, PreCheckoutQuery, SuccessfulPayment
├── enums/          Telegram constants (methods, chat_type, command_flags, parse_mode, …)
├── interfaces/     EventEmitter (observer) for building your own event dispatch
├── libs/           Helpers: hdec, sql, rateLimiter, sendQueue, parseInitData, inputFile, getter
├── middlewares/    request (HTTP transport) + inline/callback keyboard builders
├── processes/      processMessage (raw → typed ctx), processCommand (command runtime)
├── transport/      longpolling, webhook, debug
├── types/          Telegram payload builders: keyboards, buttons, input media
└── utils/          commandLoader, fstring (string.f), pagination, colors
```
See [docs/en/overview.md](docs/en/overview.md) for the full subsystem map and the update lifecycle.

## Documentation generation
```bash
bash bin/ldoc
```

## Contributing
Fork the repository and open a Pull Request.

## License
[MIT](LICENSE)
