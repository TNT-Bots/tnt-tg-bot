--- The /start command.
local Command = require('bot.classes.Command')

local command = Command:new({
  commands = { '/start' },
  flags = { Command.enum.PRIVATE }
})

function command.call(ctx)
  ctx:reply('Hello! I\'m a bot!')
end

return command
