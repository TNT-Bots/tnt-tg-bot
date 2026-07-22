--- InputMediaPhoto type builder.
-- See: https://core.telegram.org/bots/api#inputmediaphoto
--

--- Build an InputMediaPhoto object.
-- @tparam table data InputMediaPhoto fields, data.media required
-- @treturn ?table InputMediaPhoto, nil on invalid input
local function InputMediaPhoto(data)
  if not data then
    return nil
  end

  local jsonData = {}

  -- File to send
  if type(data.media) ~= 'string' then
    return nil
  else
    jsonData.media = data.media
  end

  -- Type of the result, must be photo
  jsonData.type = 'photo'

  -- Optional. Caption of the photo to be sent,
  -- 0-1024 characters after entities parsing
  if data.caption then
    jsonData.caption = tostring(data.caption)
  end

  -- Optional. Mode for parsing entities in the photo caption.
  if data.parse_mode then
    jsonData.parse_mode = data.parse_mode
  end

  -- Optional. List of special entities that appear in the caption,
  -- which can be specified instead of parse_mode
  if data.caption_entities and type(data.caption_entities) == 'table' then
    jsonData.caption_entities = data.caption_entities
  end

  -- Optional. Pass True if the caption must be shown above the message media
  if data.show_caption_above_media ~= nil then
    jsonData.show_caption_above_media = data.show_caption_above_media and true or false
  end

  -- Optional. Pass True if the photo needs to be covered with a spoiler animation
  if data.has_spoiler ~= nil then
    jsonData.has_spoiler = data.has_spoiler and true or false
  end

  return jsonData
end

return InputMediaPhoto
