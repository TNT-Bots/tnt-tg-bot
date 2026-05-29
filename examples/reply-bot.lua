-- Example of echo bot using ctx:reply() shortcut
--
local log = require('log')
local bot = require('bot')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

function bot.events.onGetUpdate(ctx)
  local text = ctx:getText()
  if not text then
    return
  end

  local _, err = ctx:reply(text)

  if err then
    log.error(err)
  end
end

bot:startLongPolling()
