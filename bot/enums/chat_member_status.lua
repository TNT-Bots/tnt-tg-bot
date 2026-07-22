--- Chat member status enum.
-- See: https://core.telegram.org/bots/api#chatmember
--

--- Chat member statuses.
local chat_member_status = {
  CREATOR = 'creator',
  ADMINISTRATOR = 'administrator',
  MEMBER = 'member',
  RESTRICTED = 'restricted',
  LEFT = 'left',
  KICKED = 'kicked',
  UNKNOWN = 'unknown',
}

return chat_member_status
