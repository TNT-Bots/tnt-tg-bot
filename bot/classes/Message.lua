--- Message module for handling message data
-- @module bot.classes.message

local SuccessfulPayment = require('bot.classes.SuccessfulPayment')
local defineGetters = require('bot.libs.getter')
local api = require('bot.api')

local message = {}
message.__index = message

--- Creates a new message object
-- @param ctx (table) The message data
--   - update_id (number): The update ID.
--   - message (table): The message data
-- @param opts (table)
--
-- @return (message) The message object
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

--- Gets the self data
-- @return (table) The self data
function message:getMessage()
  return self
end

--- Gets the arguments from the message text.
-- @param opts (table) Options table.
--   - separator (string, optional): The separator to split the text (default is ' ').
--   - count (number, optional): The maximum number of arguments to retrieve (default is 10).
--
-- @return (table) The arguments as a table
function message:getArguments(opts)
  if self.message and self.message.text then
    local separator = opts.separator or ' '
    local count = opts.count or 10
    return self.message.text:split(separator, count)
  end
end

defineGetters(message, {
  --- Gets the update ID
  -- @return (number) The update ID
  getUpdateId            = 'update_id',
  --- Get the chat information from the message object
  -- @return The chat information
  getChat                = 'message.chat',
  --- Gets the chat ID from the message data
  -- @return (number) The chat ID
  getChatId              = 'message.chat.id',
  --- Gets the chat type from the message data
  -- @return (string) The chat type
  getChatType            = 'message.chat.type',
  --- Gets the message ID from the message data
  -- @return (number) The message ID
  getMessageId           = 'message.message_id',
  --- Gets the text from the message data
  -- @return (string) The message text
  getText                = 'message.text',
  --- Gets the user data from the message data
  -- @return (table) The user data
  getUserFrom            = 'message.from',
  --- Gets the user ID from the message data
  -- @return (number) The user ID
  getUserFromId          = 'message.from.id',
  --- Gets the user who replied to the message
  -- @return (table) The user data of the reply
  getUserReply           = 'message.reply_to_message.from',
  --- message.external_reply.origin
  -- @return message.external_reply.origin
  getExternalReply       = 'message.external_reply.origin',
  --- message.reply_to_message.from.id
  -- @return (number)
  getUserReplyId         = 'message.reply_to_message.from.id',
  --- message.reply_to_message
  -- @return (table)
  getReplyToMessage      = 'message.reply_to_message',
  --- reply_to_message.message_id
  -- @return (number)
  getReplyToMessageId    = 'message.reply_to_message.message_id',
  --- Gets the entities from the message data
  -- @return (table) The message entities
  getEntities            = 'message.entities',
  --- message.dice
  -- @return (string)
  getDice                = 'message.dice',
  --- message.date
  -- @return (table)
  getDate                = 'message.date',
  --- message.sender_chat
  -- @return message.sender_chat
  getSenderChat          = 'message.sender_chat',
  --- message.sender_chat.id
  -- @return message.sender_chat.id
  getSenderChatId        = 'message.sender_chat.id',
  --- message.successful_payment
  -- @return (SuccessfulPayment)
  getSuccessfulPayment   = 'message.successful_payment',
})

-- START DEPRECATED BLOCK
--
-- left_chat_member and new_chat_member should be separate classes.
-- Kept for backward compatibility with older library versions.
--

defineGetters(message, {
  --- Gets the left chat member data from the message data
  -- @return (table) The left chat member data
  getLeftChatMember      = 'message.left_chat_member',
  --- Gets the new chat member data from the message data
  -- @return (table) The new chat member data
  getNewChatMember       = 'message.new_chat_member',
  --- Gets the new chat members data from the message data
  -- @return (table) The new chat members data
  getNewChatMembers      = 'message.new_chat_members',
})

--- Checks if the message sender is a new chat member
-- @return (boolean) True if the sender is a new chat member, false otherwise
function message:isNewChatMember()
  if self.message and self.message.new_chat_members then
    return self.message.new_chat_members[1].id == self.message.from.id
  end
end

--- Checks if the message sender added a new chat member
-- @return (boolean) True if the sender added a new chat member, false otherwise
function message:isAddNewChatMember()
  if self.message and self.message.new_chat_members then
    return self.message.new_chat_members[1].id ~= self.message.from.id
  end
end

--- Checks if the message sender is a left chat member
-- @return (boolean) True if the sender is a left chat member, false otherwise
function message:isLeftMember()
  if self.message and self.message.left_chat_member then
    return self.message.left_chat_member.id == self.message.from.id
  end
end

--- Checks if the message sender removed a chat member
-- @return (boolean) True if the sender removed a chat member, false otherwise
function message:isRemoveMember()
  if self.message and self.message.left_chat_member then
    return self.message.left_chat_member.id ~= self.message.from.id
  end
end
--
-- END DEPRECATED BLOCK

--- Trim Command
-- @return trimCommand
function message:trimCommand()
  if self.message and self.message.text and self.__command then
    local res, count = self.message.text:gsub(self.__command..' ', '', 1)
    return res, count
  end
end

--- Send a reply to the same chat
-- @param fields (string|table) Text string or fields table
-- @return (table) Response from the Telegram Bot API
-- @return (table) Error object
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

setmetatable(message, {
  __call = message.new
})

return message
