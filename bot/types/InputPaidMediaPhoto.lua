--- InputPaidMediaPhoto type builder.
-- See: https://core.telegram.org/bots/api#inputpaidmediaphoto
--

--- Build an InputPaidMediaPhoto object.
-- @tparam table data InputPaidMediaPhoto fields, data.media required
-- @treturn ?table InputPaidMediaPhoto, nil on invalid input
local function InputPaidMediaPhoto(data)
  if not data or type(data.media) ~= 'string' then
    return nil
  end

  return {
    type = 'photo',
    media = data.media
  }
end

return InputPaidMediaPhoto
