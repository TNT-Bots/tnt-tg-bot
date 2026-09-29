--- Bot runtime configuration shared between modules.
-- bot:cfg() adds the token and username fields and overrides the defaults.

local parse_mode = require('bot.enums.parse_mode')

--- Default configuration values.
local config = {
  api_url = 'https://api.telegram.org/bot', -- Telegram Bot API base URL
  parse_mode = parse_mode.HTML, -- default parse mode
}

return config
