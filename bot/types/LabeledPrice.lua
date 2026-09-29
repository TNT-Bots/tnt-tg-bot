--- LabeledPrice type builder.
-- See: https://core.telegram.org/bots/api#labeledprice
--

--- Build a LabeledPrice object.
-- @tparam table data { label = ..., amount = ... } or positional { label, amount }
-- @tparam string data.label portion label
-- @tparam number data.amount price in the smallest units of the currency (integer, not float)
-- @treturn ?table LabeledPrice, nil when required fields are missing
-- @usage
-- local LabeledPrice = require('bot.types.LabeledPrice')
--
-- bot:sendInvoice({
--   chat_id = ctx:getChatId(),
--   title = 'Coffee',
--   description = 'A cup of coffee',
--   payload = 'coffee',
--   currency = 'XTR',
--   prices = { LabeledPrice({ label = 'Coffee', amount = 10 }) },
-- })
local function LabeledPrice(data)
  if not data then
    return nil
  end

  local label = data.label or data[1]
  local amount = data.amount or data[2]

  if label == nil or amount == nil then
    return nil
  end

  return {
    label = tostring(label),
    amount = tonumber(amount)
  }
end

return LabeledPrice
