[English](../en/getting-started.md) | [Russian](../ru/getting-started.md)

# Getting started

## Requirements

- [Tarantool](https://www.tarantool.io/en/download/os-installation)
- `git`, `curl`, `lua 5.1`, `luarocks`
- (optional, WebApp only) OpenSSL + Lua 5.1 dev headers, for the `luaossl` rock

## Install

The fastest path is the bundled installer:

```bash
bash tnt-tg-bot.pre-build.sh
```

Or install the rocks manually:

```bash
# HTTP client/server (required)
luarocks install --local --tree=$PWD/.rocks --server=https://rocks.tarantool.org/ http
# Multipart POST (required)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 lua-multipart-post 1.0-0
# OpenSSL binding (optional, WebApp only)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 luaossl
```

See the [README](../../README.md#installation) for OpenSSL header details.

## Your first bot

```lua
local log = require('log')
local bot = require('bot')

-- 1. Configure once. parse_mode defaults to HTML.
bot:cfg({ token = os.getenv('BOT_TOKEN') })

-- 2. The runtime calls exactly one event: onGetUpdate.
function bot.events.onGetUpdate(ctx)
  local text = ctx:getText()
  if not text then return end

  local _, err = ctx:reply(text)   -- ctx:reply is a shortcut for sendMessage to this chat
  if err then
    log.error(err)
  end
end

-- 3. Run it.
bot:startLongPolling()
```

`ctx` is a typed context object (here a `Message`). It exposes getters like
`ctx:getText()` / `ctx:getChatId()` and helpers like `ctx:reply(...)`. See
[Context & events](context.md).

## Running

```bash
BOT_TOKEN="1348551682:AAFK..." tarantool examples/echo-bot.lua
```

Any file under [`examples/`](../../examples) runs the same way.

## Structuring a larger bot

For anything beyond a toy, split the bot into modules and route updates from
`onGetUpdate` into your own named events. The recommended layout:

```
┌─ app.lua                     - Entry point: bot:cfg, wire events, load commands, start transport
├── bot                        - The tnt-tg-bot library
├── conf                       - Configs
├── bin                        - Scripts (run, lint, …)
├── src                        - Your bot source
│   ├── enums                  - Enums
│   ├── events                 - Handlers for onGetUpdate (dispatch by update type)
│   ├── commands               - Commands, grouped by kind
│   │   ├── private            - Private-chat-only commands
│   │   ├── public             - Public (groups, supergroups)
│   │   └── maint              - Maintenance commands
│   ├── models                 - Storage models / validators
│   ├── services               - CRUD services over spaces
│   ├── spaces                 - Space schemas
│   └── utils                  - Helpers
└── var                        - Tarantool runtime (logs, snapshots, xlogs)
```

A minimal wired entry point:

```lua
local bot = require('bot')
local commandLoader = require('bot.utils.commandLoader')

bot:cfg { token = os.getenv('BOT_TOKEN') }

-- Route updates: define onGetUpdate, hand off entities to a command processor, etc.
bot.events.onGetUpdate = require('src.events.onGetUpdate')
bot.events.onGetEntities = require('src.events.onGetEntities')

-- Load command modules into bot.commands.
-- A module resolves to <base>.<group>.<command>, e.g. src/commands/private/start/init.lua
commandLoader.setPath('src.commands')
commandLoader {
  private = {
    start = {},
    help = {},
  },
  -- A command that also has inline-callback handlers:
  -- settings = { callback_commands = { 'cb_settings' } },
}

bot:startLongPolling()
```

See [Commands](commands.md) for the `commandLoader` format and callback commands.

> Tip: enable strict mode to catch accidental globals — `require('strict').on()`.

## Next steps

- [Overview](overview.md) — the update lifecycle and full subsystem map.
- [Commands](commands.md) — the `Command` class, flags, the loader, callbacks.
- [Context & events](context.md) — context objects and building your own dispatch.
- [Keyboards](keyboards.md) — inline and reply keyboards.
