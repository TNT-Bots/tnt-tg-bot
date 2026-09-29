--- ReplyParameters type builder.
-- See: https://core.telegram.org/bots/api#replyparameters
--

--- Build a ReplyParameters object.
-- @tparam table data
-- @tparam[opt] number data.message_id id of the message to reply to
-- @tparam[opt] number data.ephemeral_message_id id of the incoming ephemeral message to reply to
-- @tparam[opt] number|string data.chat_id chat of the original message, if different
-- @tparam[opt] boolean data.allow_sending_without_reply send even if the message is not found
-- @tparam[opt] string data.quote quoted part of the message, 0-1024 characters
-- @tparam[opt] string data.quote_parse_mode parse mode for the quote
-- @tparam[opt] table data.quote_entities entities of the quote
-- @tparam[opt] number data.quote_position position of the quote in UTF-16 code units
-- @tparam[opt] number data.checklist_task_id id of the checklist task to reply to
-- @tparam[opt] string data.poll_option_id id of the poll option to reply to
-- @treturn ?table ReplyParameters, nil when data is missing
-- @usage
-- local ReplyParameters = require('bot.types.ReplyParameters')
--
-- ctx:reply({
--   text = 'Hello!',
--   reply_parameters = ReplyParameters({
--     message_id = ctx:getMessageId(),
--     allow_sending_without_reply = true,
--   }),
-- })
local function ReplyParameters(data)
  if not data then
    return nil
  end

  return {
    message_id = data.message_id,
    chat_id = data.chat_id,
    ephemeral_message_id = data.ephemeral_message_id,
    allow_sending_without_reply = data.allow_sending_without_reply,
    quote = data.quote,
    quote_parse_mode = data.quote_parse_mode,
    quote_entities = data.quote_entities,
    quote_position = data.quote_position,
    checklist_task_id = data.checklist_task_id,
    poll_option_id = data.poll_option_id
  }
end

return ReplyParameters
