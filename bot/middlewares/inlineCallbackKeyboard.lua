--- Inline callback keyboard middleware
--
-- @module bot.middlewares.inlineCallbackKeyboard
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

local function build_callback_data(item)
  local callback = item.callback
  local callback_data = string.format('%s ', callback.command)

  local arguments = {}
  for _, arg in pairs(callback.arguments) do
    table.insert(arguments, arg)
  end

  callback_data = callback_data .. table.concat(arguments, ' ')

  return callback_data
end

local function build_button(item)
  item.callback_data = build_callback_data(item)

  return item
end

local function inlineKeyoard(list)
  local keyboard = InlineKeyboardMarkup()

  for i = 1, #list do
    local item = list[i]

    if item[1] then
      local row = i

      for j = 1, #item do
        local rowButton = item[j]
        rowButton.row = row

        local button = rowButton
        InlineKeyboardButton(keyboard, build_button(button))
      end
    else
      local button = item
      InlineKeyboardButton(keyboard, build_button(button))
    end
  end

  return keyboard
end

return inlineKeyoard
