local bot = require('bot')
local Command = require('bot.classes.Command')

local command = Command:new {
  commands = { '/start' },
  flags = { Command.enum.PRIVATE }
}

function command.call(ctx)
  bot:sendMessage {
    text = 'Hello! I\'m a bot!',
    chat_id = ctx:getChatId()
  }
end

return command
