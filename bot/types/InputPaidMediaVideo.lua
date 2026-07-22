--- InputPaidMediaVideo type builder.
-- See: https://core.telegram.org/bots/api#inputpaidmediavideo
--

--- Build an InputPaidMediaVideo object.
-- @tparam table data InputPaidMediaVideo fields, data.media required
-- @treturn ?table InputPaidMediaVideo, nil on invalid input
local function InputPaidMediaVideo(data)
  if not data or type(data.media) ~= 'string' then
    return nil
  end

  local jsonData = {}

  jsonData.type = 'video'
  jsonData.media = data.media

  -- Optional. Thumbnail of the file sent;
  -- can be ignored if thumbnail generation for the file is supported server-side
  if data.thumbnail then
    jsonData.thumbnail = data.thumbnail
  end

  -- Optional. Cover for the video in the message
  if data.cover then
    jsonData.cover = tostring(data.cover)
  end

  -- Optional. Start timestamp for the video in the message, in seconds
  if data.start_timestamp then
    jsonData.start_timestamp = tonumber(data.start_timestamp)
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

  -- Optional. Pass True if the uploaded video is suitable for streaming
  if data.supports_streaming ~= nil then
    jsonData.supports_streaming = data.supports_streaming and true or false
  end

  return jsonData
end

return InputPaidMediaVideo
