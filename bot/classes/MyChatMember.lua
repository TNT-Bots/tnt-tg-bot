--- MyChatMember class wrapping a my_chat_member update.
local defineGetters = require('bot.libs.getter')

local myChatMember = {}
myChatMember.__index = myChatMember

--- Create a new myChatMember object.
-- @tparam table ctx update data with update_id and my_chat_member fields
-- @treturn table myChatMember object
function myChatMember:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.my_chat_member = ctx.my_chat_member

  return setmetatable(obj, self)
end

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(myChatMember, {
  getUpdateId              = 'update_id',
  getChat                  = 'my_chat_member.chat',
  getChatId                = 'my_chat_member.chat.id',
  getChatType              = 'my_chat_member.chat.type',
  getUserFrom              = 'my_chat_member.from',
  getUserFromId            = 'my_chat_member.from.id',
  getDate                  = 'my_chat_member.date',
  getOldChatMember         = 'my_chat_member.old_chat_member',
  getNewChatMember         = 'my_chat_member.new_chat_member',
  getNewChatMemberStatus   = 'my_chat_member.new_chat_member.status',
  getOldChatMemberStatus   = 'my_chat_member.old_chat_member.status',
})

setmetatable(myChatMember, {
  __call = myChatMember.new
})

return myChatMember
