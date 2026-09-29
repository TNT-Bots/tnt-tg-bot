--- BotCommandScope type builder.
-- See: https://core.telegram.org/bots/api#botcommandscope
local bot_command_scope = require('bot.enums.bot_command_scope')

--- Build a BotCommandScope object.
-- @tparam[opt='default'] string scope value from enums.bot_command_scope
-- @tparam[opt] table data fields of the chat-specific scopes
-- @tparam[opt] number|string data.chat_id chat identifier for the chat, chat_administrators and chat_member scopes
-- @tparam[opt] number data.user_id user identifier for the chat_member scope
-- @treturn table BotCommandScope
-- @see enums.bot_command_scope
-- @usage
-- local BotCommandScope = require('bot.types.BotCommandScope')
-- local scope = require('bot.enums.bot_command_scope')
--
-- bot:setMyCommands({
--   commands = commands,
--   scope = BotCommandScope(scope.CHAT, { chat_id = chat_id }),
-- })
local function BotCommandScope(scope, data)
  if not scope then
    return { type = bot_command_scope.DEFAULT }
  end

  return {
    type = scope,
    chat_id = data and data.chat_id,
    user_id = data and data.user_id
  }
end

return BotCommandScope
