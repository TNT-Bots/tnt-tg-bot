--- InputMediaAnimation type builder.
-- See: https://core.telegram.org/bots/api#inputmediaanimation
--

--- Build an InputMediaAnimation object.
-- @tparam table data InputMediaAnimation fields, data.media required
-- @treturn ?table InputMediaAnimation, nil on invalid input
local function InputMediaAnimation(data)
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

  -- Type of the result, must be animation
  jsonData.type = 'animation'

  -- Optional. Thumbnail of the file sent;
  -- can be ignored if thumbnail generation for the file is supported server-side
  if data.thumbnail then
    if type(data.thumbnail) ~= 'string' or
      type(data.thumbnail) ~= 'table'
    then
      return nil
    end
  end

  -- Optional. Caption of the animation to be sent,
  -- 0-1024 characters after entities parsing
  if data.caption then
    jsonData.caption = tostring(data.caption)
  end

  -- Optional. Mode for parsing entities in the animation caption.
  if data.parse_mode then
    jsonData.parse_mode = data.parse_mode
  end

  -- Optional. List of special entities that appear in the caption,
  -- which can be specified instead of parse_mode
  if data.caption_entities and type(data.caption_entities) == 'table' then
    jsonData.caption_entities = data.caption_entities
  end

  -- Optional. Video width
  if data.width then
    jsonData.width = tonumber(data.width)
  end

  -- Optional. Video height
  if data.height then
    jsonData.height = tonumber(data.height)
  end

  -- Optional. Video duration in seconds
  if data.duration then
    jsonData.duration = tonumber(data.duration)
  end

  -- Optional. Pass True if the animation needs to be covered with a spoiler animation
  if data.has_spoiler ~= nil then
    jsonData.has_spoiler = data.has_spoiler and true or false
  end

  return jsonData
end

return InputMediaAnimation
