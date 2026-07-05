---
--
local bot = require('bot')
local commandLoader = require('bot.utils.commandLoader')

bot:cfg {
  token = os.getenv('BOT_TOKEN')
}

bot.events.onGetUpdate = require('src.events.onGetUpdate')
bot.events.onGetEntities = require('src.events.onGetEntities')

commandLoader.setPath('src.commands')
commandLoader {
  private = {
    start = {},
    help = {},
  },
}

bot:startLongPolling()
