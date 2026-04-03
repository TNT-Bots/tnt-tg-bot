--- Callback class for handling callback queries
-- @module bot.classes.callback

local Message = require('bot.classes.Message')
local defineGetters = require('bot.libs.getter')
local api = require('bot.api')

local callback = {}
callback.__index = callback

--- Creates a new callback object
-- @param ctx (table) The callback query data
--   - update_id (number): The update ID
--   - callback_query (table): The callback query data
-- @return (callback) The callback object
function callback:new(ctx)
  local obj = {}

  obj.update_id = ctx.update_id

  local t_message = Message(ctx.callback_query.message, { direct = true })

  obj.message = t_message.message
  obj.callback_query = ctx.callback_query
  obj.is_callback_query = true

  return setmetatable(obj, self)
end

-- START DEPRECATED BLOCK
--
-- Kept for backward compatibility with older library versions.
--
defineGetters(callback, {
  --- Gets the chat from the associated message
  -- @return (table) The chat
  getChat                = 'message.chat',
  --- Gets the chat ID from the associated message
  -- @return (number) The chat ID
  getChatId              = 'message.chat.id',
  --- Gets the chat type from the associated message
  -- @return (string) The chat type
  getChatType            = 'message.chat.type',
  --- Gets the text from the associated message
  -- @return (string) The message text
  getText                = 'message.text',
  --- Gets the message ID from the associated message
  -- @return (number) The message ID
  getMessageId           = 'message.message_id',
  --- Gets the user data from the associated message
  -- @return (table) The user data
  getUserMessageFrom     = 'message.from',
  --- Gets the user who replied to the associated message
  -- @return (table) The user data of the reply
  getUserReply           = 'message.reply_to_message.from',
  --- Get reply to message
  -- @return (table)
  getReplyToMessage      = 'message.reply_to_message',
  --- Gets the inline keyboard
  -- @return (table) inline keyboard object
  getInlineKeyboard      = 'message.reply_markup.inline_keyboard',
  --- Gets the sender chat
  -- @return (table) Sender chat object
  getSenderChat          = 'message.reply_to_message.sender_chat',
})

--- Checks if the callback query sender is the same as the message reply author
-- @return (boolean) True if it's the same user, false otherwise
function callback:isSameUser()
  if self.callback_query and self.callback_query.from and
    self.message and self.message.reply_to_message
  then
    return self.callback_query.from.id == self.message.reply_to_message.from.id
  end
end
--
-- END DEPRECATED BLOCK

defineGetters(callback, {
  --- Gets the update ID
  -- @return (number) The update ID
  getUpdateId            = 'update_id',
  --- Gets the callback query ID
  -- @return (string) The callback query ID
  getQueryId             = 'callback_query.id',
  --- Gets the user data from the callback query
  -- @return (table) The user data
  getUserFrom            = 'callback_query.from',
  --- Gets the user ID from the callback query
  -- @return (number) The user ID
  getUserFromId          = 'callback_query.from.id',
  --- Gets the callback query data
  -- @return (table) Callback query data
  getQueryData           = 'callback_query.data',
})

--- Gets the associated message
-- @return (table) The associated message
function callback:getMessage()
  return self.message
end

--- Gets the arguments from the callback query data
-- @param opts (table) Options table
--   - separator (string, optional): The separator to split the data (default is ' ')
--   - count (number, optional): The maximum number of arguments to retrieve (default is 10)
-- @return (table) The arguments as a table
function callback:getArguments(opts)
  if self.callback_query then
    local separator = opts.separator or ' '
    local count = opts.count or 10
    return self.callback_query.data:split(separator, count)
  end
end

--- Trim command
-- @return[1] Trimmed command
-- @return[2] count
function callback:trimCommand()
  if self.callback_query and self.callback_query.data and self.__command then
    local res, count = self.callback_query.data:gsub(self.__command..' ', '', 1)

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
function callback:reply(fields)
  if type(fields) == 'string' then
    fields = { text = fields }
  end

  if self.message and self.message.chat then
    fields.chat_id = fields.chat_id or self.message.chat.id
  end

  return api.call('sendMessage', fields)
end

--- Answer the callback query (shows notification to user)
-- @param fields (string|table) Text string or fields table
-- @return (table) Response from the Telegram Bot API
-- @return (table) Error object
-- @usage
-- ctx:answer('Done!')
-- ctx:answer({ text = 'Error!', show_alert = true })
function callback:answer(fields)
  if type(fields) == 'string' then
    fields = { text = fields }
  elseif fields == nil then
    fields = {}
  end

  fields.callback_query_id = fields.callback_query_id or self:getQueryId()

  return api.call('answerCallbackQuery', fields)
end

setmetatable(callback, {
  __call = callback.new
})

return callback
