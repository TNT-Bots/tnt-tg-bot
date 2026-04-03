--- Inline keyboard middleware
--
-- @module bot.middlewares.inlineKeyoard
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

local function inlineKeyoard(data)
  local keyboard = InlineKeyboardMarkup()

  for i = 1, #data do
    local button = data[i]

    if button[1] then
      local row = i

      for j = 1, #button do
        local rowButton = button[j]

        rowButton.row = row
        InlineKeyboardButton(keyboard, rowButton)
      end
    else
      InlineKeyboardButton(keyboard, button)
    end
  end

  return keyboard
end

return inlineKeyoard
