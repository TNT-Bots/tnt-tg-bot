-- Example of inline keyboard with ctx:answer() and ctx:reply()
--
local log = require('log')
local bot = require('bot')
local inlineKeyboard = require('bot.middlewares.inlineKeyboard')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

function bot.events.onGetUpdate(ctx)
  -- Handle callback queries
  if ctx.is_callback_query then
    local data = ctx:getQueryData()

    if data == 'greet' then
      ctx:answer('Button pressed!')
      ctx:reply('You pressed the greet button.')
    elseif data == 'alert' then
      ctx:answer({ text = 'This is an alert!', show_alert = true })
    end

    return
  end

  -- Handle /start command
  local text = ctx:getText()
  if not text or text ~= '/start' then return end

  local keyboard = inlineKeyboard({
    { text = 'Greet', callback_data = 'greet' },
    { text = 'Alert', callback_data = 'alert' }
  })

  local _, err = ctx:reply({
    text = 'Press a button:',
    reply_markup = keyboard
  })

  if err then
    log.error(err)
  end
end

bot:startLongPolling()
