--- KeyboardButton type builder.
-- See: https://core.telegram.org/bots/api#keyboardbutton
--

--- Build a KeyboardButton and optionally attach it to a keyboard.
-- The button is appended to the keyboard row data.row. A new row is added
-- when data.row is omitted or the row does not exist.
-- @tparam ?table keyboard ReplyKeyboardMarkup to attach the button to
-- @tparam table data button fields
-- @tparam string data.text text of the button, sent as a message when the button is pressed
-- @tparam[opt] number data.row keyboard row to add the button to
-- @tparam[opt] string data.icon_custom_emoji_id custom emoji shown before the button text
-- @tparam[opt] string data.style button style: 'danger' (red), 'success' (green) or 'primary' (blue)
-- @tparam[opt] table data.request_users request to select users, see types.KeyboardButtonRequestUsers
-- @tparam[opt] table data.request_user deprecated, replaced by request_users in Bot API 7.0
-- @tparam[opt] table data.request_managed_bot KeyboardButtonRequestManagedBot object
-- @tparam[opt] table data.request_chat request to select a chat, see types.KeyboardButtonRequestChat
-- @tparam[opt] boolean data.request_contact send the user's phone number as a contact
-- @tparam[opt] boolean data.request_location send the user's current location
-- @tparam[opt] table data.request_poll ask the user to create a poll, see types.KeyboardButtonPollType
-- @tparam[opt] table data.web_app Web App launched when the button is pressed, see types.WebAppInfo
-- @treturn ?table KeyboardButton, nil on invalid input
-- @see types.ReplyKeyboardMarkup
-- @usage
-- local ReplyKeyboardMarkup = require('bot.types.ReplyKeyboardMarkup')
-- local KeyboardButton = require('bot.types.KeyboardButton')
--
-- local kb = ReplyKeyboardMarkup({ resize_keyboard = true })
-- KeyboardButton(kb, { text = 'Share contact', request_contact = true, row = 1 })
-- KeyboardButton(kb, { text = 'Cancel', row = 2 })
--
-- ctx:reply({ text = 'Choose:', reply_markup = kb })
local function KeyboardButton(keyboard, data)
  if keyboard and type(keyboard) ~= 'table' then
    return nil
  end

  if data and type(data) ~= 'table' then
    return nil
  end

  local button = {}

  -- Text of the button
  if data.text then
    button.text = tostring(data.text)
  end

  -- Optional. Unique identifier of the custom emoji shown before the text of the button
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

  -- Optional. If specified, pressing the button will open a list of suitable users (KeyboardButtonRequestUsers).
  -- Identifiers of the selected users will be sent to the bot in a "users_shared" service message.
  -- Available in private chats only
  if data.request_users then
    button.request_users = data.request_users
  end

  -- Deprecated: replaced by request_users in Bot API 7.0.
  -- Kept as a passthrough for backward compatibility.
  if data.request_user then
    button.request_user = data.request_user
  end

  -- Optional. If specified, pressing the button will suggest creating a managed bot
  -- (KeyboardButtonRequestManagedBot)
  if data.request_managed_bot then
    button.request_managed_bot = data.request_managed_bot
  end

  -- Optional. If specified, pressing the button will open a list of suitable chats.
  -- Tapping on a chat will send its identifier to the bot in a "chat_shared" service message.
  -- Available in private chats only.
  if data.request_chat then
    button.request_chat = data.request_chat
  end

  -- Optional. If True, the user's phone number will be sent as a contact when the button is pressed.
  -- Available in private chats only
  if data.request_contact then
    button.request_contact = data.request_contact and true or false
  end

  -- Optional. If True, the user's current location will be sent when the button is pressed.
  -- Available in private chats only.
  if data.request_location then
    button.request_location = data.request_location and true or false
  end

  -- Optional. If specified, the user will be asked to create a poll and send it to the bot when the button is pressed.
  -- Available in private chats only.
  if data.request_poll then
    button.request_poll = data.request_poll
  end

  -- Optional. If specified, the described Web App will be launched when the button is pressed
  if data.web_app then
    button.web_app = data.web_app
  end

  if keyboard then
    -- New row when data.row does not exist yet
    if not keyboard["keyboard"][data.row] then
      table.insert(keyboard["keyboard"], { button })

      return button
    end

    -- Button addition to an existing row
    table.insert(keyboard["keyboard"][data.row or 1], button)

    return button
  end

  return button
end

return KeyboardButton
