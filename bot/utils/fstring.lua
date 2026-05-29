--- Lua format string
-- @module bot.ext.fstring
-- @param text (string)
-- @param args (table)
-- @usage
  -- string.f = require('bot.ext.fstring')
  -- local str = '${name}, hello!'
  -- print(
  --   str:f({ name = 'uriid1' })
  -- )
local function fstring(text, args)
  local res, _ = string.gsub(text, '%${([%w_]+)}', args)

  return res
end

return fstring
