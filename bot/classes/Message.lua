--- Message class wrapping an incoming Telegram message update.
local SuccessfulPayment = require('bot.classes.SuccessfulPayment')
local defineGetters = require('bot.libs.getter')
local api = require('bot.api')

local message = {}
message.__index = message

--- Create a new message object.
-- @tparam table ctx update data with update_id and message fields
-- @tparam[opt] table opts
-- @tparam[opt] boolean opts.direct treat ctx as the message itself, not an update
-- @treturn table message object
function message:new(ctx, opts)
  local obj = {}

  local update_id
  local refMessage

  if opts and opts.direct then
    refMessage = ctx
  else
    update_id = ctx.update_id
    refMessage = ctx.message
  end

  obj.update_id = update_id
  obj.message = refMessage

  if ctx.message then
    if ctx.message.successful_payment then
      obj.message.successful_payment = SuccessfulPayment(ctx.message.successful_payment)
    end
  end

  return setmetatable(obj, self)
end

--- Get the message object itself.
-- @treturn table message object
function message:getMessage()
  return self
end

--- Split the message text into arguments.
-- @tparam table opts
-- @tparam[opt=' '] string opts.separator separator used to split the text
-- @tparam[opt=10] number opts.count maximum number of arguments
-- @treturn table arguments list
function message:getArguments(opts)
  if self.message and self.message.text then
    local separator = opts.separator or ' '
    local count = opts.count or 10
    return self.message.text:split(separator, count)
  end
end

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(message, {
  getUpdateId            = 'update_id',
  getChat                = 'message.chat',
  getChatId              = 'message.chat.id',
  getChatType            = 'message.chat.type',
  getMessageId           = 'message.message_id',
  getText                = 'message.text',
  getUserFrom            = 'message.from',
  getUserFromId          = 'message.from.id',
  getUserReply           = 'message.reply_to_message.from',
  getExternalReply       = 'message.external_reply.origin',
  getUserReplyId         = 'message.reply_to_message.from.id',
  getReplyToMessage      = 'message.reply_to_message',
  getReplyToMessageId    = 'message.reply_to_message.message_id',
  getEntities            = 'message.entities',
  getDice                = 'message.dice',
  getDate                = 'message.date',
  getSenderChat          = 'message.sender_chat',
  getSenderChatId        = 'message.sender_chat.id',
  getSuccessfulPayment   = 'message.successful_payment',
})

-- START DEPRECATED BLOCK
--
-- left_chat_member and new_chat_member should be separate classes.
-- Kept for backward compatibility with older library versions.
--

defineGetters(message, {
  getLeftChatMember      = 'message.left_chat_member',
  getNewChatMember       = 'message.new_chat_member',
  getNewChatMembers      = 'message.new_chat_members',
})

--- Check whether the message sender is a new chat member.
-- @treturn boolean true if the sender is a new chat member, false otherwise
function message:isNewChatMember()
  if self.message and self.message.new_chat_members then
    return self.message.new_chat_members[1].id == self.message.from.id
  end
end

--- Check whether the message sender added a new chat member.
-- @treturn boolean true if the sender added a new chat member, false otherwise
function message:isAddNewChatMember()
  if self.message and self.message.new_chat_members then
    return self.message.new_chat_members[1].id ~= self.message.from.id
  end
end

--- Check whether the message sender is a left chat member.
-- @treturn boolean true if the sender is a left chat member, false otherwise
function message:isLeftMember()
  if self.message and self.message.left_chat_member then
    return self.message.left_chat_member.id == self.message.from.id
  end
end

--- Check whether the message sender removed a chat member.
-- @treturn boolean true if the sender removed a chat member, false otherwise
function message:isRemoveMember()
  if self.message and self.message.left_chat_member then
    return self.message.left_chat_member.id ~= self.message.from.id
  end
end
--
-- END DEPRECATED BLOCK

--- Strip the leading command from the message text.
-- @treturn string text without the command
-- @treturn number number of replacements made
function message:trimCommand()
  if self.message and self.message.text and self.__command then
    local res, count = self.message.text:gsub(self.__command..' ', '', 1)
    return res, count
  end
end

--- Send a reply to the same chat.
-- @tparam string|table fields text string or sendMessage fields
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @usage
-- ctx:reply('Hello!')
-- ctx:reply({ text = 'Hello!', reply_markup = ... })
function message:reply(fields)
  if type(fields) == 'string' then
    fields = { text = fields }
  end

  fields.chat_id = fields.chat_id or self:getChatId()

  return api.call('sendMessage', fields)
end

--- Send a reply referencing this message (reply_parameters).
-- @tparam string|table fields text string or sendMessage fields
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
function message:replyToMessage(fields)
  if type(fields) == 'string' then
    fields = {
      text = fields,
      reply_parameters = {
        message_id = self:getMessageId()
      }
    }
  end

  fields.chat_id = fields.chat_id or self:getChatId()
  fields.reply_parameters = {
      message_id = self:getMessageId()
  }

  return api.call('sendMessage', fields)
end

setmetatable(message, {
  __call = message.new
})

return message
