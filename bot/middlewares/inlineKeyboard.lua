--- Inline keyboard middleware.
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

--- Build an InlineKeyboardMarkup from a list of buttons and button rows.
-- The row field is set on the buttons of a row, the passed tables are modified.
-- @tparam table data list where each item is a button or an array of buttons (a row),
-- a button is a table of types.InlineKeyboardButton fields
-- @treturn table inline keyboard markup
-- @see types.InlineKeyboardButton
-- @usage
-- local inlineKeyboard = require('bot.middlewares.inlineKeyboard')
--
-- local kb = inlineKeyboard({
--   { text = 'Open', url = 'https://example.com' }, -- row 1
--   {                                               -- row 2, two buttons
--     { text = 'Yes', callback_data = 'yes' },
--     { text = 'No', callback_data = 'no' },
--   },
-- })
--
-- ctx:reply({ text = 'Choose:', reply_markup = kb })
local function inlineKeyboard(data)
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

return inlineKeyboard
