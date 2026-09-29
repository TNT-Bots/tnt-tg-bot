--- InlineKeyboardMarkup type builder.
-- See: https://core.telegram.org/bots/api#inlinekeyboardmarkup
local json = require('json')

--- Build an InlineKeyboardMarkup object.
-- With a ready data.inline_keyboard table returns its JSON encoding,
-- otherwise returns an empty markup with a toJson method.
-- @tparam[opt] table data
-- @tparam[opt] table data.inline_keyboard array of button rows { { button, ... }, ... }
-- @treturn ?table|string markup object with the inline_keyboard field and the toJson() method,
-- JSON string for a ready data.inline_keyboard, nil when data is not a table
-- @see types.InlineKeyboardButton
-- @usage
-- local InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup')
--
-- local kb = InlineKeyboardMarkup()
-- kb:toJson() -- '{"inline_keyboard":[]}'
local function InlineKeyboardMarkup(data)
  if data and type(data) ~= 'table' then
    return nil
  end

  local obj = {}

  -- inline_keyboard is an array of button rows,
  -- each represented by an array of InlineKeyboardButton objects
  if data then
    -- A ready inline_keyboard table is encoded as-is
    if type(data.inline_keyboard) == 'table' then
      return json.encode(data)
    end
  else
    obj.inline_keyboard = {}
  end

  local keyboard = {}
  keyboard.__index = keyboard

  -- JSON encoding of the markup
  function keyboard:toJson()
    return json.encode(self)
  end

  setmetatable(obj, keyboard)

  return obj
end

return InlineKeyboardMarkup
