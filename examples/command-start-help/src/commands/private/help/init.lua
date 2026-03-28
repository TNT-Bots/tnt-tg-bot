local bot = require('bot')
local Command = require('bot.classes.Command')

local command = Command:new {
  commands = { '/help' },
  flags = { Command.enum.PRIVATE }
}

function command.call(ctx)
  bot:sendMessage {
    text = '...HELP MESSAGE...',
    chat_id = ctx:getChatId()
  }
end

return command
