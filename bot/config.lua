--- Module config
--
local parse_mode = require('bot.enums.parse_mode')

local config = {
  api_url = 'https://api.telegram.org/bot',
  parse_mode = parse_mode.HTML
}

return config
