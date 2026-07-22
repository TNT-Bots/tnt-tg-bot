--- KeyboardButton type builder.
-- See: https://core.telegram.org/bots/api#keyboardbutton
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

  -- Optional. If specified, pressing the button will open a list of suitable users.
  -- Tapping on any user will send their identifier to the bot in a "user_shared" service message.
  -- Available in private chats only
  if data.request_user then
    button.request_user = data.request_user
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
