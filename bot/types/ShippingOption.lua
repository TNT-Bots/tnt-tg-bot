--- ShippingOption type builder.
-- See: https://core.telegram.org/bots/api#shippingoption
--

--- Build a ShippingOption object.
-- @tparam table data
-- @tparam string data.id shipping option identifier
-- @tparam string data.title option title
-- @tparam table data.prices list of LabeledPrice portions
-- @treturn ?table ShippingOption, nil when required fields are missing
local function ShippingOption(data)
  if not data
    or data.id == nil
    or data.title == nil
    or type(data.prices) ~= 'table'
  then
    return nil
  end

  return {
    id = tostring(data.id),
    title = tostring(data.title),
    prices = data.prices
  }
end

return ShippingOption
