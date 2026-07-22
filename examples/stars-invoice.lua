--- Example of a Telegram Stars (XTR) payment flow.
-- /buy sends an invoice, the pre-checkout query is confirmed,
-- and the successful payment is acknowledged.
local log = require('log')
local bot = require('bot')
local types = require('bot.types')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

function bot.events.onGetUpdate(ctx)
  -- Pre-checkout confirmation: must be answered within 10 seconds,
  -- otherwise Telegram cancels the payment
  if ctx.pre_checkout_query then
    local _, err = bot:answerPreCheckoutQuery({
      pre_checkout_query_id = ctx:getId(),
      ok = true
    })

    if err then
      log.error(err)
    end

    return
  end

  if not ctx.message then
    return
  end

  -- Successful payment notification arrives as a service message
  local payment = ctx:getSuccessfulPayment()
  if payment then
    ctx:reply(('Thank you! Received %d %s.'):format(
      payment:getTotalAmount(), payment:getCurrency()))

    return
  end

  if ctx:getText() ~= '/buy' then
    return
  end

  -- Invoice in Telegram Stars: currency XTR, exactly one price,
  -- provider_token is not needed
  local _, err = bot:sendInvoice({
    chat_id = ctx:getChatId(),
    title = 'Magic potion',
    description = 'A small vial of pure magic',
    payload = 'potion-001',
    currency = 'XTR',
    prices = { types.LabeledPrice({ 'Potion', 1 }) }
  })

  if err then
    log.error(err)
  end
end

bot:startLongPolling()
