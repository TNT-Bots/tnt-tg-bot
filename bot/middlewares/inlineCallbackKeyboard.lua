--- Inline callback keyboard middleware.
-- Builds callback_data from { command, arguments } button descriptions.
local bot = require('bot')
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

local function build_callback_data(item)
  local callback = item.callback
  local arguments = { callback.command }

  -- Argument order is dictated by the command's arguments_schema
  local cmd = bot.commands[callback.command]
  local schema = cmd and cmd.arguments_schema

  if schema then
    for _, key in ipairs(schema) do
      table.insert(arguments, callback.arguments[key])
    end
  else
    -- Fallback: positional arguments (array without named keys)
    for _, arg in ipairs(callback.arguments) do
      table.insert(arguments, arg)
    end
  end

  return table.concat(arguments, ' ')
end

local function build_button(item)
  item.callback_data = build_callback_data(item)

  return item
end

--- Build an InlineKeyboardMarkup from callback button descriptions.
-- @tparam table list list where each item is a button or an array of buttons (a row)
-- @treturn table inline keyboard markup
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
