--- BotCommandScope type builder.
-- See: https://core.telegram.org/bots/api#botcommandscope
local bot_command_scope = require('bot.enums.bot_command_scope')

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
