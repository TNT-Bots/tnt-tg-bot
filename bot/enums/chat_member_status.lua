--- Chat member status enum.
-- See: https://core.telegram.org/bots/api#chatmember
--

--- Chat member statuses.
local chat_member_status = {
  CREATOR = 'creator',             -- owner of the chat
  ADMINISTRATOR = 'administrator', -- administrator of the chat
  MEMBER = 'member',               -- member of the chat without additional privileges or restrictions
  RESTRICTED = 'restricted',       -- member under restrictions, supergroups only
  LEFT = 'left',                   -- not a member of the chat, can join it
  KICKED = 'kicked',               -- banned in the chat, cannot return or view chat messages
  UNKNOWN = 'unknown',             -- not a Telegram status, a placeholder for an undefined status
}

return chat_member_status
