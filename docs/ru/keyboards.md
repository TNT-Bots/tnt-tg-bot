[English](../en/keyboards.md) | [Russian](../ru/keyboards.md)

# Клавиатуры

Собери объект разметки и передай его как `reply_markup`.

## Inline-клавиатура

[`bot.middlewares.inlineKeyboard`](../../bot/middlewares/inlineKeyboard.lua)
принимает массив. Обычная кнопка становится отдельной строкой; массив кнопок -
одной строкой:

```lua
local inlineKeyboard = require('bot.middlewares.inlineKeyboard')

local kb = inlineKeyboard({
  { text = 'Open', url = 'https://example.com' },       -- строка 1
  { text = 'Ping', callback_data = 'ping' },            -- строка 2
  {                                                     -- строка 3 (две кнопки)
    { text = 'Yes', callback_data = 'yes' },
    { text = 'No',  callback_data = 'no' },
  },
})

ctx:reply({ text = 'Choose:', reply_markup = kb })
```

Поля кнопки (см. [`InlineKeyboardButton`](../../bot/types/InlineKeyboardButton.lua)):
`text`, `callback_data`, `url`, `web_app`, `login_url`, `switch_inline_query`,
`switch_inline_query_current_chat`, `copy_text`, `pay`, `style`. `callback_data`
должна быть ≤ 64 байт (иначе сборщик пишет error в лог).

## Callback-клавиатура (типизированная callback_data)

[`bot.middlewares.inlineCallbackKeyboard`](../../bot/middlewares/inlineCallbackKeyboard.lua)
- та же форма, но кнопка нацелена на **зарегистрированную callback-команду**, и
`callback_data` кодируется из `arguments_schema` этой команды:

```lua
local inlineCallbackKeyboard = require('bot.middlewares.inlineCallbackKeyboard')

-- bot.commands['cb_settings'].arguments_schema == { 'page', 'action' }
local kb = inlineCallbackKeyboard({
  {
    text = '⚙️ Settings',
    callback = { command = 'cb_settings', arguments = { page = 'settings', action = 'show' } },
  },
})
-- кодирует callback_data: "cb_settings settings show"
```

Так данные кнопки и [callback-команда](commands.md) держатся синхронно: аргументы
пишутся в порядке `arguments_schema` и разбираются обратно в `command.arguments`
при нажатии.

## Reply-клавиатура

[`ReplyKeyboardMarkup`](../../bot/types/ReplyKeyboardMarkup.lua) оборачивает
`keyboard` (строки из таблиц [`KeyboardButton`](../../bot/types/KeyboardButton.lua)):

```lua
local ReplyKeyboardMarkup = require('bot.types.ReplyKeyboardMarkup')

local kb = ReplyKeyboardMarkup({
  keyboard = {
    { { text = 'Yes' }, { text = 'No' } },
    { { text = 'Cancel' } },
  },
  resize_keyboard   = true,
  one_time_keyboard = true,
  input_field_placeholder = 'Pick one',
})

ctx:reply({ text = 'Answer:', reply_markup = kb })
```

Reply-кнопки могут и запрашивать данные: `request_user`, `request_chat`,
`request_contact`, `request_location`, `request_poll`, `web_app` (только в личке).

## Прочие типы разметки

В [`bot/types/`](../../bot/types) есть также сборщики `ForceReply`,
`ReplyKeyboardRemove`, `LinkPreviewOptions` и семейство `InputMedia*` для
`sendMediaGroup`. Каждый зеркалит соответствующий объект Telegram.

## Пагинация

Для длинных списков [`bot.utils.pagination`](../../bot/utils/pagination.lua)
строит постраничную inline-клавиатуру с кнопками навигации - см.
[Библиотеки](libs.md) и пример [`pagination.lua`](../../examples/pagination.lua).

См. также: [Команды](commands.md), [Контекст и события](context.md).
