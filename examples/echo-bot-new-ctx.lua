--- Example of an echo bot using the ctx object.
local bot = require('bot')

bot:cfg({ token = os.getenv('BOT_TOKEN') })

function bot.events.onGetUpdate(ctx)
  ctx:reply(ctx:getText())
end

bot:startLongPolling()
