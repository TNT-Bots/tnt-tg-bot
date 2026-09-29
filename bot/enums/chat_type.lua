--- Chat type enum.
-- See: https://core.telegram.org/bots/api#chat
--

--- Chat types.
local chat_type = {
  SENDER = 'sender',         -- private chat with the inline query sender, inline queries only
  PRIVATE = 'private',       -- private chat with a user
  GROUP = 'group',           -- group chat
  SUPERGROUP = 'supergroup', -- supergroup chat
  CHANNEL = 'channel',       -- channel
}

return chat_type
