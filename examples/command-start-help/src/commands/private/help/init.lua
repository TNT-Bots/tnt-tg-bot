--- The /help command.
local Command = require('bot.classes.Command')

local command = Command:new({
  commands = { '/help' },
  flags = { Command.enum.PRIVATE }
})

function command.call(ctx)
  ctx:reply('This is "help message"')
end

return command
