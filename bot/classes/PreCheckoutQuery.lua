--- Module PreCheckoutQuery
-- @module bot.classes.PreCheckoutQuery

local defineGetters = require('bot.libs.getter')

local PreCheckoutQuery = {}
PreCheckoutQuery.__index = PreCheckoutQuery

--- Creates a new PreCheckoutQuery object
-- @param ctx The data for initializing the object
-- @return The created PreCheckoutQuery object
function PreCheckoutQuery:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.pre_checkout_query = ctx.pre_checkout_query

  return setmetatable(obj, self)
end

defineGetters(PreCheckoutQuery, {
  --- Gets the update ID
  -- @return (number) The update ID
  getUpdateId        = 'update_id',
  --- Bot-specified invoice payload
  -- @return (string)
  getInvoicePayload  = 'pre_checkout_query.invoice_payload',
  --- Unique query identifier
  -- @return (string)
  getId              = 'pre_checkout_query.id',
  --- Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars
  -- @return (string)
  getCurrency        = 'pre_checkout_query.currency',
  --- User who sent the query
  -- @return (User)
  getUserFrom        = 'pre_checkout_query.from',
  --- Price in the smallest units of the currency (integer, not float/double)
  -- @return (Integer)
  getTotalAmount     = 'pre_checkout_query.total_amount',
})

setmetatable(PreCheckoutQuery, {
  __call = PreCheckoutQuery.new
})

return PreCheckoutQuery
