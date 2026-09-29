--- Bot command scope enum.
-- See: https://core.telegram.org/bots/api#botcommandscope
--

--- Bot command scopes.
local bot_command_scope = {
  DEFAULT = 'default',                                 -- default scope, used when no narrower scope is set
  ALL_PRIVATE_CHATS = 'all_private_chats',             -- all private chats
  ALL_GROUP_CHATS = 'all_group_chats',                 -- all group and supergroup chats
  ALL_CHAT_ADMINISTRATORS = 'all_chat_administrators', -- all group and supergroup chat administrators
  CHAT = 'chat',                                       -- a specific chat, requires chat_id
  CHAT_ADMINISTRATORS = 'chat_administrators',         -- all administrators of a specific chat, requires chat_id
  CHAT_MEMBER = 'chat_member',                         -- a specific member of a chat, requires chat_id and user_id
}

return bot_command_scope
