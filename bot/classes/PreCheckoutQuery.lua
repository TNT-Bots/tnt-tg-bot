--- PreCheckoutQuery class wrapping a pre_checkout_query update.
local defineGetters = require('bot.libs.getter')

local PreCheckoutQuery = {}
PreCheckoutQuery.__index = PreCheckoutQuery

--- Create a new PreCheckoutQuery object.
-- @tparam table ctx update data with update_id and pre_checkout_query fields
-- @treturn table PreCheckoutQuery object
function PreCheckoutQuery:new(ctx)
  local obj = {}
  obj.update_id = ctx.update_id
  obj.pre_checkout_query = ctx.pre_checkout_query

  return setmetatable(obj, self)
end

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(PreCheckoutQuery, {
  getUpdateId        = 'update_id',
  getInvoicePayload  = 'pre_checkout_query.invoice_payload', -- bot-specified invoice payload
  getId              = 'pre_checkout_query.id',              -- unique query identifier
  getCurrency        = 'pre_checkout_query.currency',        -- ISO 4217 code, 'XTR' for Telegram Stars
  getUserFrom        = 'pre_checkout_query.from',            -- user who sent the query
  getTotalAmount     = 'pre_checkout_query.total_amount',    -- price in the smallest currency units
})

setmetatable(PreCheckoutQuery, {
  __call = PreCheckoutQuery.new
})

return PreCheckoutQuery
