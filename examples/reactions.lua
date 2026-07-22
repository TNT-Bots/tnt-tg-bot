--- Example of message reactions.
-- The bot reacts with fire to messages containing "wow"
-- and with a thumbs up to everything else.
local log = require('log')
local bot = require('bot')
local ReactionType = require('bot.types.ReactionType')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

function bot.events.onGetUpdate(ctx)
  local text = ctx.message and ctx:getText()
  if not text then
    return
  end

  local reaction
  if text:lower():find('wow', 1, true) then
    reaction = ReactionType.emoji('🔥')
  else
    reaction = ReactionType.emoji('👍')
  end

  local _, err = bot:setMessageReaction({
    chat_id = ctx:getChatId(),
    message_id = ctx:getMessageId(),
    reaction = { reaction }
  })

  if err then
    log.error(err)
  end
end

bot:startLongPolling()
