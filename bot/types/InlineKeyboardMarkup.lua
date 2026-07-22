--- InlineKeyboardMarkup type builder.
-- See: https://core.telegram.org/bots/api#inlinekeyboardmarkup
local json = require('json')

--- Build an InlineKeyboardMarkup object.
-- With a ready data.inline_keyboard table returns its JSON encoding,
-- otherwise returns an empty markup with a toJson method.
-- @tparam[opt] table data { inline_keyboard = { { button, ... }, ... } }
-- @treturn table|string markup object or JSON string
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

  function keyboard:toJson()
    return json.encode(self)
  end

  setmetatable(obj, keyboard)

  return obj
end

return InlineKeyboardMarkup
