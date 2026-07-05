[English](../en/commands.md) | [Russian](../ru/commands.md)

# Commands

A command is a small module: a `Command` object (its metadata) plus a `call`
handler. Commands are registered in `bot.commands` (a `name -> command` table)
and dispatched by [`processCommand`](../../bot/processes/processCommand.lua).

## Defining a command

```lua
local Command = require('bot.classes.Command')

local command = Command:new {
  commands = { '/mute', 'мут' },          -- trigger strings (slash command and/or text alias)
  info     = 'Restrict a user',           -- optional, free-form description
  flags    = { Command.enum.IN_CHAT, Command.enum.MODERATION },
}

-- The handler is attached separately (Command:new does not take it):
function command.call(ctx)
  ctx:replyToMessage('muted')
end

return command
```

`Command:new(cfg)` keeps `commands`, `info`, `arguments_schema`, and packs
`flags` into a bitmask. `command:hasFlag(flag)` tests a flag. The `call`
function is a plain field you assign yourself.

## Flags

[`bot/enums/command_flags`](../../bot/enums/command_flags.lua) (used as `Command.enum.*`):

| Flag | Bit |
|------|-----|
| `PRIVATE` | 1 |
| `PUBLIC` | 2 |
| `IN_CHAT` | 4 |
| `REPLY` | 8 |
| `NO_REPLY` | 16 |
| `CALLBACK` | 32 |
| `MAINTENANCE` | 64 |
| `MODERATION` | 128 |
| `ADMINISTRATIVE` | 256 |

> **Important:** `processCommand` itself enforces **only `PRIVATE`** (the command
> runs only in private chats). It also denies other bots and channel (`sender_chat`)
> senders, and applies antiflood. **All other flags are conventions** - they mean
> nothing until *your* `preCallCommand` hook interprets them (e.g. mapping
> `MODERATION`/`ADMINISTRATIVE` to role checks). The flags are just a typed bitmask
> the library carries for you.

## Registering commands

Either assign directly:

```lua
bot.commands['/start'] = require('src.commands.private.start')
```

…or use [`commandLoader`](../../bot/utils/commandLoader.lua), which requires
command modules by convention `<base>.<group>.<command>`:

```lua
local commandLoader = require('bot.utils.commandLoader')

commandLoader.setPath('src.commands')
commandLoader {
  private = {
    start = {},
    help  = {},
  },
  moderation = {
    -- A command that also has inline-callback handlers (loaded first):
    settings = { callback_commands = { 'cb_settings', 'cb_set_setting' } },
    mute     = {},
  },
}
```

For `settings` above, the loader requires
`src.commands.moderation.settings.cb_settings`,
`src.commands.moderation.settings.cb_set_setting`, then
`src.commands.moderation.settings` - and registers every string in each module's
`commands` field into `bot.commands`.

## Dispatching

[`processCommand(ctx, opts)`](../../bot/processes/processCommand.lua) is the runtime. Call it from your update handlers (e.g. from `onGetEntities` / `onGetMessageText`). It:

1. Resolves the command - by callback data, by the first text token, or from `opts.command` when `opts.is_text_command` is set.
2. Enforces `PRIVATE`; denies bots and channel senders.
3. Applies **antiflood** per `(user_id, chat_id)` - a token bucket (`capacity = 2`, `refill = 1/s`). On a callback, `opts.antiflood_answer(ctx)` is called if provided.
4. For commands with an `arguments_schema`, fills `command.arguments` (see below).
5. Calls `bot.events.preCallCommand(ctx, command)` - **if it returns `false`, the command is aborted.**
6. Runs `command.call(ctx)`.
7. Calls `bot.events.postCallCommand(ctx, command)`.

`preCallCommand` is where you put auth, role checks (using the flags), staff sync, etc. `bot.command(ctx)` / `bot.callbackCommand(ctx)` are lower-level resolvers that just return the matching command by name.

## Callback commands

A command can also handle inline-button presses. Declare an `arguments_schema`
and the positional `callback_data` is parsed back into a named `command.arguments`:

```lua
local command = Command:new {
  commands = { 'cb_settings' },
  flags    = { Command.enum.CALLBACK, Command.enum.ADMINISTRATIVE },
  arguments_schema = { 'page', 'action' },
}

function command.call(ctx)
  ctx:answer()                       -- acknowledge the press
  local page   = command.arguments.page
  local action = command.arguments.action
  -- ...
end
```

`callback_data` is a space-separated string `cb_settings <page> <action>`. The
schema maps positions to names. Build such buttons with
[`inlineCallbackKeyboard`](keyboards.md), which encodes `callback_data` from the
command's `arguments_schema` for you.

See also: [Context & events](context.md), [Keyboards](keyboards.md).
