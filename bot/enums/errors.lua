--- Telegram API error codes enum.
-- Values of the error_code field of an API error.
-- See: https://core.telegram.org/api/errors
-- @usage
-- local errors = require('bot.enums.errors')
--
-- local _, err = ctx:reply('Hello!')
-- if err and err.error_code == errors.FORBIDDEN then
--   -- the bot was blocked by the user
-- end

--- Error codes.
local errors = {
  SEE_OTHER = 303,         -- 303, the request must be repeated to a different data center
  BAD_REQUEST = 400,       -- 400, the request contains errors
  UNAUTHORIZED = 401,      -- 401, unauthorized use of the functionality
  FORBIDDEN = 403,         -- 403, privacy violation, the action is not allowed
  NOT_FOUND = 404,         -- 404, an object or a method is not found
  NOT_ACCEPTABLE = 406,    -- 406, the error must not be shown to the user
  FLOOD = 420,             -- 420, the maximum allowed number of attempts is exceeded
  TOO_MANY_REQUESTS = 429, -- 429, too many requests, err.parameters.retry_after holds the pause in seconds
  INTERNAL = 500,          -- 500, internal server error
}

return errors
