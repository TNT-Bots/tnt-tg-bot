--- InlineKeyboardButton type builder.
-- See: https://core.telegram.org/bots/api#inlinekeyboardbutton
local log = require('log')

--- Build an InlineKeyboardButton and optionally attach it to a keyboard.
-- The button is appended to the keyboard row data.row. A new row is added
-- when data.row is omitted or the row does not exist. A callback_data longer than 64 bytes is reported to the log.
-- @tparam ?table keyboard InlineKeyboardMarkup to attach the button to
-- @tparam table data button fields
-- @tparam string data.text label text on the button
-- @tparam[opt] number data.row keyboard row to add the button to
-- @tparam[opt] string data.callback_data data sent in a callback query when the button is pressed, 1-64 bytes
-- @tparam[opt] string data.callback alias of callback_data
-- @tparam[opt] string data.url HTTP or tg:// URL opened when the button is pressed
-- @tparam[opt] string data.icon_custom_emoji_id custom emoji shown before the button text
-- @tparam[opt] string data.style button style: 'danger' (red), 'success' (green) or 'primary' (blue)
-- @tparam[opt] table data.web_app Web App launched when the button is pressed, see types.WebAppInfo
-- @tparam[opt] table data.login_url LoginUrl object: an HTTPS URL used to authorize the user
-- @tparam[opt] string data.switch_inline_query inline query inserted after the bot's username in a chat selected by the user
-- @tparam[opt] string data.switch_inline_query_current_chat inline query inserted after the bot's username in the current chat
-- @tparam[opt] table data.switch_inline_query_chosen_chat SwitchInlineQueryChosenChat object
-- @tparam[opt] table data.callback_game CallbackGame object: the game launched when the button is pressed
-- @tparam[opt] string|table data.copy_text text copied to the clipboard, or a CopyTextButton object
-- @tparam[opt] boolean data.pay true for a Pay button
-- @tparam[opt] boolean|table data.disabled true for a disabled button that does nothing,
-- or a DisabledButton object
-- @treturn ?table InlineKeyboardButton, nil on invalid input
-- @see types.InlineKeyboardMarkup
-- @see middlewares.inlineKeyboard
-- @usage
-- local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
-- local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')
--
-- local kb = InlineKeyboardMarkup()
-- InlineKeyboardButton(kb, { text = 'Yes', callback_data = 'yes', row = 1 })
-- InlineKeyboardButton(kb, { text = 'No', callback_data = 'no', row = 1 })
-- InlineKeyboardButton(kb, { text = 'Site', url = 'https://example.com', row = 2 })
--
-- ctx:reply({ text = 'Choose:', reply_markup = kb })
local function inlineKeyboardButton(keyboard, data)
  if type(data) ~= 'table' then
    return nil
  end

  if keyboard and type(keyboard) ~= 'table' then
    return nil
  end

  local button = {}

  -- Label text on the button
  if data.text then
    button.text = tostring(data.text)
  end

  -- Optional. Unique identifier of the custom emoji shown before the text of the button.
  -- Can only be used by bots that purchased additional usernames on Fragment
  -- or in the messages directly sent by the bot to private,
  -- group and supergroup chats if the owner of the bot has a Telegram Premium subscription.
  if data.icon_custom_emoji_id then
    button.icon_custom_emoji_id = tostring(data.icon_custom_emoji_id)
  end

  -- Optional. Style of the button.
  -- Must be one of:
  -- "danger" (red)
  -- "success" (green)
  -- "primary" (blue).
  -- If omitted, then an app-specific style is used.
  if data.style then
    button.style = tostring(data.style)
  end

  -- Optional. HTTP or tg:// URL to be opened when the button is pressed
  if data.url then
    button.url = tostring(data.url)
  end

  -- Optional. Data to be sent in a callback query to the bot when button is pressed, 1-64 bytes
  if data.callback_data then
    button.callback_data = tostring(data.callback_data)
  elseif data.callback then
    button.callback_data = tostring(data.callback)
  end

  if button.callback_data and string.len(button.callback_data) > 64 then
    log.error('Callback data > 64 bytes, data: %s', button.callback_data)
  end

  -- Optional. Description of the Web App that will be launched when the user presses the button
  if data.web_app then
    button.web_app = data.web_app
  end

  -- Optional. An HTTPS URL used to automatically authorize the user
  if data.login_url then
    button.login_url = data.login_url
  end

  -- Optional. If set, pressing the button will prompt the user to select one of their chats,
  -- open that chat and insert the bot's username and the specified inline query in the input field.
  -- May be empty, in which case just the bot's username will be inserted.
  if data.switch_inline_query then
    button.switch_inline_query = tostring(data.switch_inline_query)
  end

  -- Optional. If set, pressing the button will insert the bot's username and
  -- the specified inline query in the current chat's input field. May be empty,
  -- in which case only the bot's username will be inserted.
  if data.switch_inline_query_current_chat then
    button.switch_inline_query_current_chat = tostring(data.switch_inline_query_current_chat)
  end

  -- Optional. If set, pressing the button will insert the bot's username and
  -- the specified inline query in the current chat's input field. May be empty,
  -- in which case only the bot's username will be inserted.
  if data.switch_inline_query_chosen_chat then
    button.switch_inline_query_chosen_chat = data.switch_inline_query_chosen_chat
  end

  -- Optional. Description of the game that will be launched when the user presses the button
  if data.callback_game then
    button.callback_game = data.callback_game
  end

  -- Optional. Description of the button that copies the specified text to the clipboard.
  -- The API expects a CopyTextButton object; a plain string is wrapped into one.
  if type(data.copy_text) == 'table' then
    button.copy_text = data.copy_text
  elseif data.copy_text then
    button.copy_text = { text = tostring(data.copy_text) }
  end

  -- Optional. Specify True, to send a Pay button
  if data.pay then
    button.pay = data.pay
  end

  -- Optional. If set, then the button is disabled and does nothing.
  -- The API expects a DisabledButton object, which currently holds no information.
  -- An empty table is encoded as a JSON array by default, so it is marked as a map.
  if type(data.disabled) == 'table' and next(data.disabled) ~= nil then
    button.disabled = data.disabled
  elseif data.disabled then
    button.disabled = setmetatable({}, { __serialize = 'map' })
  end

  if keyboard then
    -- New row when data.row does not exist yet
    if not keyboard["inline_keyboard"][data.row] then
      table.insert(keyboard["inline_keyboard"], { button })

      return button
    end

    -- Button addition to an existing row
    table.insert(keyboard["inline_keyboard"][data.row or 1], button)

    return button
  end

  return button
end

return inlineKeyboardButton
