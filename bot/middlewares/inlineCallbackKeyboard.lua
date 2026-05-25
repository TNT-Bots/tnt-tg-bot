--- Inline callback keyboard middleware
--
-- @module bot.middlewares.inlineCallbackKeyboard
local bot = require('bot')
local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
local InlineKeyboardButton = require('bot.types.InlineKeyboardButton')

local function build_callback_data(item)
  local callback = item.callback
  local arguments = { callback.command }

  -- Порядок аргументов диктует arguments_schema команды
  local cmd = bot.commands[callback.command]
  local schema = cmd and cmd.arguments_schema

  if schema then
    for _, key in ipairs(schema) do
      table.insert(arguments, callback.arguments[key])
    end
  else
    -- Fallback: позиционные аргументы (массив без именованных ключей)
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
