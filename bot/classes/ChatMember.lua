--- ChatMember module for handling chat member data
-- @module bot.classes.chatMember

local defineGetters = require('bot.libs.getter')

local chatMember = {}
chatMember.__index = chatMember

--- Creates a new chatMember object
-- @param ctx (table) The chat member data
--   - update_id (number): The update ID.
--   - chat_member (table): The chat member data
-- @return (chatMember) The chatMember object
function chatMember:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.chat_member = ctx.chat_member

  return setmetatable(obj, self)
end

defineGetters(chatMember, {
  --- Gets the update ID
  -- @return (number) The update ID
  getUpdateId              = 'update_id',
  --- Gets the associated chat
  -- @return (table) The associated chat data
  getChat                  = 'chat_member.chat',
  --- Gets the chat ID from the associated chat data
  -- @return (number) The chat ID
  getChatId                = 'chat_member.chat.id',
  --- Gets the chat type from the associated chat data
  -- @return (string) The chat type
  getChatType              = 'chat_member.chat.type',
  --- Gets the user data from the chat member data
  -- @return (table) The user data
  getUserFrom              = 'chat_member.from',
  --- Gets the user ID from the chat member data
  -- @return (number) The user ID
  getUserFromId            = 'chat_member.from.id',
  --- Gets the date from the chat member data
  -- @return (number) The date
  getDate                  = 'chat_member.date',
  --- Gets the new chat member data
  -- @return (table) The new chat member data
  getNewChatMember         = 'chat_member.new_chat_member',
  --- Gets the old chat member data
  -- @return (table) The old chat member data
  getOldChatMember         = 'chat_member.old_chat_member',
  --- Gets the status of the old chat member
  -- @return (string) The status of the old chat member
  getOldChatMemberStatus   = 'chat_member.old_chat_member.status',
  --- Gets the status of the new chat member
  -- @return (string) The status of the new chat member
  getNewChatMemberStatus   = 'chat_member.new_chat_member.status',
})

setmetatable(chatMember, {
  __call = chatMember.new
})

return chatMember
