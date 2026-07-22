--- SuccessfulPayment class wrapping a successful_payment message field.
local defineGetters = require('bot.libs.getter')

local SuccessfulPayment = {}
SuccessfulPayment.__index = SuccessfulPayment

--- Create a new SuccessfulPayment object.
-- @tparam table successful_payment raw successful_payment data
-- @treturn table SuccessfulPayment object
function SuccessfulPayment:new(successful_payment)
  return setmetatable(successful_payment, self)
end

--- Get the SuccessfulPayment object itself.
-- @treturn table SuccessfulPayment object
function SuccessfulPayment:getSelf()
  return self.successful_payment
end

-- Getters are generated from the mapping below.
-- Each method returns the value at the dot-separated path inside the object.
defineGetters(SuccessfulPayment, {
  getCurrency                   = 'currency',                     -- ISO 4217 code, 'XTR' for Telegram Stars
  getTotalAmount                = 'total_amount',                 -- price in the smallest currency units
  getInvoicePayload             = 'invoice_payload',              -- bot-specified invoice payload
  getSubscriptionExpirationDate = 'subscription_expiration_date', -- Unix time, recurring payments only
  isRecurring                   = 'is_recurring',                 -- true for a recurring payment
  isFirstRecurring              = 'is_first_recurring',           -- true for the first recurring payment
  getShippingOptionId           = 'shipping_option_id',           -- shipping option chosen by the user
  getOrderInfo                  = 'order_info',                   -- order info provided by the user
  getTelegramPaymentChargeId    = 'telegram_payment_charge_id',   -- Telegram payment identifier
  getProviderPaymentChargeId    = 'provider_payment_charge_id',   -- provider payment identifier
})

setmetatable(SuccessfulPayment, {
  __call = SuccessfulPayment.new
})

return SuccessfulPayment
