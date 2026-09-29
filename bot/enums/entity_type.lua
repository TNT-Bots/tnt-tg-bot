--- Message entity type enum.
-- See: https://core.telegram.org/bots/api#messageentity
--

--- Message entity types.
local entity_type = {
  MENTION = 'mention',                             -- @username
  HASHTAG = 'hashtag',                             -- #hashtag or #hashtag@chatusername
  CASHTAG = 'cashtag',                             -- $USD or $USD@chatusername
  BOT_COMMAND = 'bot_command',                     -- /start@jobs_bot
  URL = 'url',                                     -- https://telegram.org
  EMAIL = 'email',                                 -- do-not-reply@telegram.org
  PHONE_NUMBER = 'phone_number',                   -- +1-212-555-0123
  BOLD = 'bold',                                   -- bold text
  ITALIC = 'italic',                               -- italic text
  UNDERLINE = 'underline',                         -- underlined text
  STRIKETHROUGH = 'strikethrough',                 -- strikethrough text
  SPOILER = 'spoiler',                             -- spoiler message
  BLOCKQUOTE = 'blockquote',                       -- block quotation
  EXPANDABLE_BLOCKQUOTE = 'expandable_blockquote', -- collapsed-by-default block quotation
  CODE = 'code',                                   -- monowidth string
  PRE = 'pre',                                     -- monowidth block
  TEXT_LINK = 'text_link',                         -- clickable text URL
  TEXT_MENTION = 'text_mention',                   -- mention of a user without a username
  CUSTOM_EMOJI = 'custom_emoji',                   -- inline custom emoji sticker
  DATE_TIME = 'date_time',                         -- formatted date and time
}

return entity_type
