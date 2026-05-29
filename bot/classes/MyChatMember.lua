--- Module myChatMember
-- @module bot.classes.myChatMember

local defineGetters = require('bot.libs.getter')

local myChatMember = {}
myChatMember.__index = myChatMember

--- Creates a new myChatMember object
-- @param ctx The data for initializing the object
-- @return The created myChatMember object
function myChatMember:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.my_chat_member = ctx.my_chat_member

  return setmetatable(obj, self)
end

defineGetters(myChatMember, {
  --- Get the update ID
  -- @return The update ID
  getUpdateId              = 'update_id',
  --- Get the chat information
  -- @return The chat information
  getChat                  = 'my_chat_member.chat',
  --- Get the chat ID
  -- @return The chat ID
  getChatId                = 'my_chat_member.chat.id',
  --- Get the chat type
  -- @return The chat type
  getChatType              = 'my_chat_member.chat.type',
  --- Get the user information
  -- @return The user information
  getUserFrom              = 'my_chat_member.from',
  --- Get the user ID
  -- @return The user ID
  getUserFromId            = 'my_chat_member.from.id',
  --- Get the date
  -- @return The date
  getDate                  = 'my_chat_member.date',
  --- Get the old chat member information
  -- @return The old chat member information
  getOldChatMember         = 'my_chat_member.old_chat_member',
  --- Get the new chat member information
  -- @return The new chat member information
  getNewChatMember         = 'my_chat_member.new_chat_member',
  --- Get the status of the new chat member
  -- @return The status of the new chat member
  getNewChatMemberStatus   = 'my_chat_member.new_chat_member.status',
  --- Get the status of the old chat member
  -- @return The status of the old chat member
  getOldChatMemberStatus   = 'my_chat_member.old_chat_member.status',
})

setmetatable(myChatMember, {
  __call = myChatMember.new
})

return myChatMember
