--- Inline keyboard middleware.
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

--- Build an InlineKeyboardMarkup from a list of buttons and button rows.
-- @tparam table data list where each item is a button or an array of buttons (a row)
-- @treturn table inline keyboard markup
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
