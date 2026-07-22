--- ChatMember class wrapping a chat_member update.
local defineGetters = require('bot.libs.getter')

local chatMember = {}
chatMember.__index = chatMember

--- Create a new chatMember object.
-- @tparam table ctx update data with update_id and chat_member fields
-- @treturn table chatMember object
function chatMember:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.chat_member = ctx.chat_member

  return setmetatable(obj, self)
end

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(chatMember, {
  getUpdateId              = 'update_id',
  getChat                  = 'chat_member.chat',
  getChatId                = 'chat_member.chat.id',
  getChatType              = 'chat_member.chat.type',
  getUserFrom              = 'chat_member.from',
  getUserFromId            = 'chat_member.from.id',
  getDate                  = 'chat_member.date',
  getNewChatMember         = 'chat_member.new_chat_member',
  getOldChatMember         = 'chat_member.old_chat_member',
  getOldChatMemberStatus   = 'chat_member.old_chat_member.status',
  getNewChatMemberStatus   = 'chat_member.new_chat_member.status',
})

setmetatable(chatMember, {
  __call = chatMember.new
})

return chatMember
