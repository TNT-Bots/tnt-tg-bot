--- Module SuccessfulPayment
-- @module bot.classes.SuccessfulPayment

local defineGetters = require('bot.libs.getter')

local SuccessfulPayment = {}
SuccessfulPayment.__index = SuccessfulPayment

--- Creates a new SuccessfulPayment object
-- @param successful_payment The data for initializing the object
-- @return The created SuccessfulPayment object
function SuccessfulPayment:new(successful_payment)
  return setmetatable(successful_payment, self)
end

--- Returns SuccessfulPayment object
-- @treturn (table)
function SuccessfulPayment:getSelf()
  return self.successful_payment
end

defineGetters(SuccessfulPayment, {
  --- Three-letter ISO 4217 currency code, or "XTR" for payments in Telegram Stars
  -- @treturn (string)
  getCurrency                   = 'currency',
  --- Get total amount
  -- @treturn (number)
  getTotalAmount                = 'total_amount',
  --- Bot-specified invoice payload
  -- @treturn (string)
  getInvoicePayload             = 'invoice_payload',
  --- Optional. Expiration date of the subscription, in Unix time; for recurring payments only
  -- @treturn (number)
  getSubscriptionExpirationDate = 'subscription_expiration_date',
  --- Optional. True, if the payment is a recurring payment for a subscription
  -- @treturn (True)
  isRecurring                   = 'is_recurring',
  --- Optional. True, if the payment is the first payment for a subscription
  -- @treturn (True)
  isFirstRecurring              = 'is_first_recurring',
  --- Optional. Identifier of the shipping option chosen by the user
  -- @return (string)
  getShippingOptionId           = 'shipping_option_id',
  --- Optional. Order information provided by the user
  -- @return (OrderInfo)
  getOrderInfo                  = 'order_info',
  --- Telegram payment identifier
  -- @return (string)
  getTelegramPaymentChargeId    = 'telegram_payment_charge_id',
  --- Provider payment identifier
  -- @return (string)
  getProviderPaymentChargeId    = 'provider_payment_charge_id',
})

setmetatable(SuccessfulPayment, {
  __call = SuccessfulPayment.new
})

return SuccessfulPayment
