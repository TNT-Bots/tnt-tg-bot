--- InputMediaAudio type builder.
-- See: https://core.telegram.org/bots/api#inputmediaaudio
local function InputMediaAudio(data)
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

  -- Type of the result, must be audio
  jsonData.type = 'audio'

  -- Optional. Thumbnail of the file sent;
  -- can be ignored if thumbnail generation for the file is supported server-side
  if data.thumbnail then
    if type(data.thumbnail) ~= 'string' or
      type(data.thumbnail) ~= 'table'
    then
      return nil
    end
  end

  -- Optional. Caption of the audio to be sent,
  -- 0-1024 characters after entities parsing
  if data.caption then
    jsonData.caption = tostring(data.caption)
  end

  -- Optional. Mode for parsing entities in the audio caption.
  if data.parse_mode then
    jsonData.parse_mode = data.parse_mode
  end

  -- Optional. List of special entities that appear in the caption,
  -- which can be specified instead of parse_mode
  if data.caption_entities and type(data.caption_entities) == 'table' then
    jsonData.caption_entities = data.caption_entities
  end

  -- Optional. Audio duration in seconds
  if data.duration then
    jsonData.duration = tonumber(data.duration)
  end

  -- Optional. Performer of the audio
  if data.performer then
    jsonData.performer = tostring(data.performer)
  end

  -- Optional. Title of the audio
  if data.title then
    jsonData.title = tostring(data.title)
  end

  return jsonData
end

return InputMediaAudio
