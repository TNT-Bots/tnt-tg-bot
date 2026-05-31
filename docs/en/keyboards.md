[English](../en/keyboards.md) | [Russian](../ru/keyboards.md)

# Keyboards

Build a markup object and pass it as `reply_markup`.

## Inline keyboard

[`bot.middlewares.inlineKeyboard`](../../bot/middlewares/inlineKeyboard.lua)
takes an array. A plain button becomes its own row; an array of buttons becomes
one row:

```lua
local inlineKeyboard = require('bot.middlewares.inlineKeyboard')

local kb = inlineKeyboard({
  { text = 'Open', url = 'https://example.com' },       -- row 1
  { text = 'Ping', callback_data = 'ping' },            -- row 2
  {                                                     -- row 3 (two buttons)
    { text = 'Yes', callback_data = 'yes' },
    { text = 'No',  callback_data = 'no' },
  },
})

ctx:reply({ text = 'Choose:', reply_markup = kb })
```

Button fields (see [`InlineKeyboardButton`](../../bot/types/InlineKeyboardButton.lua))
include `text`, `callback_data`, `url`, `web_app`, `login_url`,
`switch_inline_query`, `switch_inline_query_current_chat`, `copy_text`, `pay`,
`style`. `callback_data` must be ≤ 64 bytes (the builder logs an error otherwise).

## Callback keyboard (typed callback_data)

[`bot.middlewares.inlineCallbackKeyboard`](../../bot/middlewares/inlineCallbackKeyboard.lua)
is the same shape, but a button targets a **registered callback command** and the
`callback_data` is encoded from that command's `arguments_schema`:

```lua
local inlineCallbackKeyboard = require('bot.middlewares.inlineCallbackKeyboard')

-- bot.commands['cb_settings'].arguments_schema == { 'page', 'action' }
local kb = inlineCallbackKeyboard({
  {
    text = '⚙️ Settings',
    callback = { command = 'cb_settings', arguments = { page = 'settings', action = 'show' } },
  },
})
-- encodes callback_data: "cb_settings settings show"
```

This keeps button data and the [callback command](commands.md) in sync: arguments
are written in `arguments_schema` order, and parsed back into `command.arguments`
when the button is pressed.

## Reply keyboard

[`ReplyKeyboardMarkup`](../../bot/types/ReplyKeyboardMarkup.lua) wraps a
`keyboard` (rows of [`KeyboardButton`](../../bot/types/KeyboardButton.lua) tables):

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

Reply buttons can also request data: `request_user`, `request_chat`,
`request_contact`, `request_location`, `request_poll`, `web_app` (private chats).

## Other markup types

[`bot/types/`](../../bot/types) also provides builders for `ForceReply`,
`ReplyKeyboardRemove`, `LinkPreviewOptions`, and the `InputMedia*` family used by
`sendMediaGroup`. Each mirrors the corresponding Telegram object.

## Pagination

For long lists, [`bot.utils.pagination`](../../bot/utils/pagination.lua) builds a
paginated inline keyboard with navigation buttons - see [Libraries](libs.md) and
the [`pagination.lua`](../../examples/pagination.lua) example.

See also: [Commands](commands.md), [Context & events](context.md).
