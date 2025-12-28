Russian | [English](README_EN.md)</br>

[![luacheck](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml/badge.svg?branch=master)](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

## Description
tnt-tg-bot is a Lua library for the Tarantool platform.
It provides interfaces for working with the Telegram Bot API.

> [!NOTE]
> For production, use the latest stable branch or the latest release.
>
> The `master` branch may contain API changes or be partially incompatible with release versions.

## Features
- Simple and clear interfaces
- Asynchronous request processing
- Built-in support for Telegram Stars payments
- Built-in methods for command handling, including callbacks
- You define event names yourself; only `bot.events.onGetUpdate(ctx)` is provided by default
- Simple WebApp integration
- [[TWA](https://core.telegram.org/bots/webapps)] initData validation using the module  
  [bot/libs/parseInitData.lua](bot/libs/parseInitData.lua)
- [[TWA](https://core.telegram.org/bots/webapps)] Route (handlers) support
- LDoc annotations support
- Large number of examples

----
## Table of Contents

1. [Showcase](#showcase)
2. [Installation](#install)
3. [Examples](#examples)
4. [Project Structure](#project-structure)
5. [Interfaces](#interfaces)
6. [Guidelines](#guideline)
7. [Documentation Generation](#gen-doc)
----

## <a name='showcase'>Showcase</a>
- [Niko Bot](https://t.me/Niko_rp_bot) — Bot with mini-games, many commands, pets, and group moderation
  <details>
    <summary>Open screenshot</summary>
    <img src="examples/img/screen.jpg" alt="screenshot" class="screenshot" loading="lazy">
  </details>
- [Talking Hooligan](https://t.me/talking_piska_bot) — Popular chat bot that sends funny and silly messages

## <a name='install'>Installation</a>

### Automatic
1. Install `git`, `curl`, `lua 5.1`, and `luarocks`.
2. (Optional) If WebApp support is required:</br>
   Install the `luaossl` rock.</br>
   You also need Lua 5.1 and OpenSSL development headers.
3. Install [tarantool](https://www.tarantool.io/en/download/os-installation)
4. Run the automatic dependency installation script:
```bash
bash tnt-tg-bot.pre-build.sh
```
5. If problems occur, switch to manual installation.

> [!NOTE]
> To build `luaossl` (OpenSSL bindings), OpenSSL and Lua 5.1 headers are required.
> On Ubuntu:
> `sudo apt install libssl-dev liblua5.1-0-dev`
>
> `luaossl` is required for the `bot/libs/parseInitData.lua` module.
> This module is used to process Telegram Web Mini App data.
> https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app

### Manual
1. Install `git`, `curl`, `lua 5.1`, and `luarocks`.
2. Install [tarantool](https://www.tarantool.io/en/download/os-installation)
3. (Optional) If WebApp support is required:</br>
   Install the `luaossl` rock and Lua 5.1 / OpenSSL headers.
4. Install required packages using `luarocks`:
  - **HTTP client/server (required)**
    ```bash
    luarocks install --local --tree=$PWD/.rocks --server=https://rocks.tarantool.org/ http
    ```
  - **Multipart POST handler (required)**
    ```bash
    luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 lua-multipart-post 1.0-0
    ```
  - **OpenSSL bindings (optional)**
    ```bash
    luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 luaossl
    ```

## <a name='examples'>Examples</a>
- [Observer pattern](examples/pattern-observer) — Observer pattern example. Event dispatching. Well structured and suitable as a base
- [Mini Shop](examples/mini-shop) — Minimal shop example showing project structure
- [Star payments](examples/stars-payment) — Telegram Stars payment handling (purchase, refund)
- [examples/echo-bot-webhook.lua](examples/echo-bot-webhook.lua) — Echo bot via WebHook
- [examples/echo-bot-old.lua](examples/echo-bot-old.lua) — Echo bot (old API)
- [examples/echo-bot.lua](examples/echo-bot.lua) — Echo bot (new API)
- [examples/ping-pong.lua](examples/ping-pong.lua) — `/ping` command handler
- [examples/send-animation.lua](examples/send-animation.lua) — Send GIF via `/get_animation`
- [examples/send-document.lua](examples/send-document.lua) — Send document via `/get_document`
- [examples/send-image.lua](examples/send-image.lua) — Send image via `/get_image`
- [examples/send-image-2.lua](examples/send-image-2.lua) — Simplified image sending via `bot.sendImage`
- [examples/send-media-group.lua](examples/send-media-group.lua) — Send media group
- [examples/simple-callback-old.lua](examples/simple-callback-old.lua) — Callback handling example (old API)
- [examples/simple-callback.lua](examples/simple-callback.lua) — Simplified callback handling (new API)
- [examples/simple-process-commands.lua](examples/simple-process-commands.lua) — Simple command processing
- [examples/routes-example/init.lua](examples/routes-example/init.lua) — Route handlers example

> [!NOTE]
> It is recommended to use only the new API.

### Running an example
`BOT_TOKEN` — your bot token
```bash
BOT_TOKEN="YOUR_BOT_TOKEN" tarantool examples/echo-bot.lua
```

## <a name='project-structure'>Project Structure</a>
- [bot/init.lua](bot/init.lua) — Entry point
- [bot/libs](bot/libs) — Helper libraries
- [bot/enums](bot/enums) — Enums
- [bot/classes](bot/classes) — Telegram object classes
- [bot/middlewares](bot/middlewares) — Middlewares
- [bot/processes](bot/processes) — Processes (runtime logic)
- [bot/types](bot/types) — Telegram models and validators
- [bot/ext](bot/ext) — Built-in extensions (addons)
- [bot/interfaces](bot/interfaces) — Interfaces (observer pattern)

## <a name='interfaces'>Interfaces</a>
| Method | Description | Usage Example |
|------|------------|---------------|
| bot:cfg | Initialize configuration | `bot:cfg { token = "123:token", username = "bot_name" }` |
| bot.call | Call Telegram API | `bot.call('sendMessage', { chat_id = 123, text = 'Hello!' })` |
| bot.events | User-defined events table | `function bot.events.onPoll(ctx) ... end` |
| bot.events.onGetUpdate | Telegram update processing event | `function bot.events.onGetUpdate(ctx) ... end` |
| bot.sendImage | Simplified image sending | `examples/send-image-2.lua` |
| bot.Command | Minimal command handler | `bot.Command(ctx)` |
| bot.CallbackCommand | Minimal callback handler | `bot.CallbackCommand(ctx)` |
| bot:startWebHook | Run bot on remote server | `examples/echo-bot-webhook.lua` |
| bot:startLongPolling | Run bot in long polling mode | Any example in `examples/*` |
| bot:debugRoutes | Debug routes in long polling mode | |

For argument details, see LDoc: `doc/index.html`

## <a name='guideline'>Guidelines</a>
- Use a single style guide, for example:  
  https://github.com/Olivine-Labs/lua-style-guide
- Enable strict mode:
```lua
-- Prevent usage of undeclared global variables
require('strict').on()
```
- Use a consistent project structure:

```
┌─ app.lua                       - Entry point
├── bot                          - tnt-tg-bot library
├── pre-build.sh                 - Dependency installation script
├── conf                         - Configs
├── scripts                      - Scripts (run, lint, etc.)
├── src                          - Main bot source directory
│   ├── classes                  - Classes
│   ├── enums                    - Enums
│   ├── events                   - onGetUpdate events
│   ├── commands                 - Command handlers
│   │   ├── maintenance          - Maintenance mode commands
│   │   ├── private              - Private chat only commands
│   │   ├── public               - Public commands (groups, chats)
│   │   └── commandLoader.lua    - Command loader
│   ├── models                   - Storage models
│   ├── processes                - Processes and runtimes
│   │   └── processCommand.lua   - Command processor
│   ├── routes                   - API routes
│   ├── services                 - CRUD services
│   ├── spaces                   - Space schemas
│   └── utils                    - Utilities
└── var                          - System directory
    ├── log                      - Bot logs
    └── storage                  - Storage directory
        ├── snap
        └── xlog
```

## <a name='gen-doc'>Documentation Generation</a>
```bash
bash scripts/ldoc
```

## Contributing
Fork the repository and open a Pull Request.
