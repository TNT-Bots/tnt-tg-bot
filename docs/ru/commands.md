[English](../en/commands.md) | [Russian](../ru/commands.md)

# Команды

Команда — это небольшой модуль: объект `Command` (его метаданные) плюс обработчик
`call`. Команды регистрируются в `bot.commands` (таблица `имя → команда`) и
диспетчеризуются через [`processCommand`](../../bot/processes/processCommand.lua).

## Определение команды

```lua
local Command = require('bot.classes.Command')

local command = Command:new {
  commands = { '/mute', 'мут' },          -- триггеры (слэш-команда и/или текстовый алиас)
  info     = 'Ограничить пользователя',   -- опционально, произвольное описание
  flags    = { Command.enum.IN_CHAT, Command.enum.MODERATION },
}

-- Обработчик навешивается отдельно (Command:new его не принимает):
function command.call(ctx)
  ctx:replyToMessage('muted')
end

return command
```

`Command:new(cfg)` хранит `commands`, `info`, `arguments_schema` и упаковывает
`flags` в битовую маску. `command:hasFlag(flag)` проверяет флаг. Функция `call` —
обычное поле, которое ты присваиваешь сам.

## Флаги

[`bot/enums/command_flags`](../../bot/enums/command_flags.lua) (используются как `Command.enum.*`):

| Флаг | Бит |
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

> **Важно:** сам `processCommand` enforce-ит **только `PRIVATE`** (команда работает
> лишь в личке). Ещё он отбивает других ботов и отправителей от лица канала
> (`sender_chat`) и применяет антифлуд. **Все остальные флаги — конвенции**: они
> ничего не значат, пока их не трактует *твой* хук `preCallCommand` (например,
> сопоставляя `MODERATION`/`ADMINISTRATIVE` с проверками ролей). Флаги — просто
> типизированная битовая маска, которую либа носит за тебя.

## Регистрация команд

Либо напрямую:

```lua
bot.commands['/start'] = require('src.commands.private.start')
```

…либо через [`commandLoader`](../../bot/utils/commandLoader.lua), который грузит
модули команд по соглашению `<base>.<group>.<command>`:

```lua
local commandLoader = require('bot.utils.commandLoader')

commandLoader.setPath('src.commands')
commandLoader {
  private = {
    start = {},
    help  = {},
  },
  moderation = {
    -- Команда с inline-callback обработчиками (грузятся первыми):
    settings = { callback_commands = { 'cb_settings', 'cb_set_setting' } },
    mute     = {},
  },
}
```

Для `settings` выше загрузчик потребует
`src.commands.moderation.settings.cb_settings`,
`src.commands.moderation.settings.cb_set_setting`, затем
`src.commands.moderation.settings` — и зарегистрирует каждую строку из поля
`commands` каждого модуля в `bot.commands`.

## Диспетчеризация

[`processCommand(ctx, opts)`](../../bot/processes/processCommand.lua) — это рантайм. Зови его из своих обработчиков апдейтов (например, из `onGetEntities` / `onGetMessageText`). Он:

1. Находит команду — по callback-данным, по первому токену текста или из `opts.command`, если задан `opts.is_text_command`.
2. Enforce-ит `PRIVATE`; отбивает ботов и отправителей-каналы.
3. Применяет **антифлуд** на `(user_id, chat_id)` — токен-бакет (`capacity = 2`, `refill = 1/сек`). На callback зовётся `opts.antiflood_answer(ctx)`, если передан.
4. Для команд с `arguments_schema` заполняет `command.arguments` (см. ниже).
5. Зовёт `bot.events.preCallCommand(ctx, command)` — **если он вернул `false`, команда отменяется.**
6. Выполняет `command.call(ctx)`.
7. Зовёт `bot.events.postCallCommand(ctx, command)`.

`preCallCommand` — место для авторизации, проверок ролей (по флагам), синка стафа и т.п. `bot.command(ctx)` / `bot.callbackCommand(ctx)` — низкоуровневые резолверы, просто возвращают команду по имени.

## Callback-команды

Команда может обрабатывать и нажатия inline-кнопок. Объяви `arguments_schema` —
и позиционная `callback_data` разберётся обратно в именованный `command.arguments`:

```lua
local command = Command:new {
  commands = { 'cb_settings' },
  flags    = { Command.enum.CALLBACK, Command.enum.ADMINISTRATIVE },
  arguments_schema = { 'page', 'action' },
}

function command.call(ctx)
  ctx:answer()                       -- подтвердить нажатие
  local page   = command.arguments.page
  local action = command.arguments.action
  -- ...
end
```

`callback_data` — строка через пробел `cb_settings <page> <action>`. Схема
сопоставляет позиции именам. Строй такие кнопки через
[`inlineCallbackKeyboard`](keyboards.md) — он сам кодирует `callback_data` из
`arguments_schema` команды.

См. также: [Контекст и события](context.md), [Клавиатуры](keyboards.md).
