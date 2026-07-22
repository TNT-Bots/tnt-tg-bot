--- ReplyKeyboardMarkup type builder.
-- See: https://core.telegram.org/bots/api#replykeyboardmarkup
local function ReplyKeyboardMarkup(data)
  if not data then
    return { keyboard = {} }
  end

  local obj = {}

  -- Array of button rows, each represented by an Array of KeyboardButton objects
  if data.keyboard and type(data.keyboard) == 'table' then
    obj.keyboard = data.keyboard
  else
    obj.keyboard = {}
  end

  -- Optional. Requests clients to always show the keyboard when the regular keyboard is hidden.
  -- Defaults to false,
  -- in which case the custom keyboard can be hidden and opened with a keyboard icon.
  if data.is_persistent ~= nil then
    obj.is_persistent = data.is_persistent and true or false
  end

  -- Optional. Requests clients to resize the keyboard vertically for optimal fit
  -- (e.g., make the keyboard smaller if there are just two rows of buttons)
  if data.resize_keyboard ~= nil then
    obj.resize_keyboard = data.resize_keyboard and true or false
  end

  -- Optional. Requests clients to hide the keyboard as soon as it's been used
  if data.one_time_keyboard ~= nil then
    obj.one_time_keyboard = data.one_time_keyboard and true or false
  end

  -- Optional. The placeholder to be shown in the input field when the keyboard is active,
  -- 1-64 characters
  if data.input_field_placeholder then
    obj.input_field_placeholder = tostring(data.input_field_placeholder):sub(1, 64)
  end

  -- Optional. Use this parameter if you want to show the keyboard to specific users only.
  -- Targets:
  -- 1) users that are @mentioned in the text of the Message object;
  -- 2) if the bot's message is a reply (has reply_to_message_id),
  -- sender of the original message.
  if data.selective ~= nil then
    obj.selective = data.selective and true or false
  end

  return obj
end

return ReplyKeyboardMarkup
