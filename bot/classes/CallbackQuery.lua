--- CallbackQuery class wrapping an incoming callback query update.
local Message = require('bot.classes.Message')
local defineGetters = require('bot.libs.getter')
local api = require('bot.api')

local callback = {}
callback.__index = callback

--- Create a new callback object.
-- @tparam table ctx update data with update_id and callback_query fields
-- @treturn table callback object
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
  getChat                = 'message.chat',
  getChatId              = 'message.chat.id',
  getChatType            = 'message.chat.type',
  getText                = 'message.text',
  getMessageId           = 'message.message_id',
  getUserMessageFrom     = 'message.from',
  getUserReply           = 'message.reply_to_message.from',
  getReplyToMessage      = 'message.reply_to_message',
  getInlineKeyboard      = 'message.reply_markup.inline_keyboard',
  getSenderChat          = 'message.reply_to_message.sender_chat',
})

--- Check whether the callback query sender is the message reply author.
-- @treturn boolean true if it is the same user, false otherwise
function callback:isSameUser()
  if self.callback_query and self.callback_query.from and
    self.message and self.message.reply_to_message
  then
    return self.callback_query.from.id == self.message.reply_to_message.from.id
  end
end
--
-- END DEPRECATED BLOCK

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(callback, {
  getUpdateId            = 'update_id',
  getQueryId             = 'callback_query.id',
  getUserFrom            = 'callback_query.from',
  getUserFromId          = 'callback_query.from.id',
  getQueryData           = 'callback_query.data',
})

--- Get the associated message.
-- @treturn table associated message
function callback:getMessage()
  return self.message
end

--- Split the callback query data into arguments.
-- @tparam[opt] table opts
-- @tparam[opt=' '] string opts.separator separator used to split the data
-- @tparam[opt=10] number opts.count maximum number of arguments
-- @treturn table arguments list
function callback:getArguments(opts)
  opts = opts or {}

  if self.callback_query then
    local separator = opts.separator or ' '
    local count = opts.count or 10
    return self.callback_query.data:split(separator, count)
  end
end

--- Strip the leading command from the callback query data.
-- @treturn string data without the command
-- @treturn number number of replacements made
function callback:trimCommand()
  if self.callback_query and self.callback_query.data and self.__command then
    local res, count = self.callback_query.data:gsub(self.__command..' ', '', 1)

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
function callback:reply(fields)
  if type(fields) == 'string' then
    fields = { text = fields }
  end

  if self.message and self.message.chat then
    fields.chat_id = fields.chat_id or self.message.chat.id
  end

  return api.call('sendMessage', fields)
end

--- Answer the callback query (shows a notification to the user).
-- @tparam[opt] string|table fields text string or answerCallbackQuery fields
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @usage
-- ctx:answer('Done!')
-- ctx:answer({ text = 'Error!', show_alert = true })
function callback:answer(fields)
  if type(fields) == 'string' then
    fields = {
      text = fields,
      show_alert = false,
    }
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
