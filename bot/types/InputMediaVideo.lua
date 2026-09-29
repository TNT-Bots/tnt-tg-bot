--- InputMediaVideo type builder.
-- See: https://core.telegram.org/bots/api#inputmediavideo
--

--- Build an InputMediaVideo object.
-- @tparam table data
-- @tparam string data.media file to send: a file_id, an HTTP URL or 'attach://name' for a file uploaded under that name
-- @tparam[opt] string|table data.thumbnail thumbnail of the file
-- @tparam[opt] string data.cover cover for the video in the message
-- @tparam[opt] number data.start_timestamp start timestamp for the video in the message, in seconds
-- @tparam[opt] string data.caption caption of the video, 0-1024 characters after entities parsing
-- @tparam[opt] string data.parse_mode mode for parsing entities in the caption
-- @tparam[opt] table data.caption_entities entities of the caption, instead of parse_mode
-- @tparam[opt] boolean data.show_caption_above_media show the caption above the media
-- @tparam[opt] number data.width video width
-- @tparam[opt] number data.height video height
-- @tparam[opt] number data.duration video duration in seconds
-- @tparam[opt] boolean data.supports_streaming the uploaded video is suitable for streaming
-- @tparam[opt] boolean data.has_spoiler cover the video with a spoiler animation
-- @treturn ?table InputMediaVideo, nil on invalid input
-- @usage
-- local InputMediaVideo = require('bot.types.InputMediaVideo')
--
-- bot:sendMediaGroup({
--   chat_id = ctx:getChatId(),
--   media = {
--     InputMediaVideo({ media = 'https://example.com/video.mp4', supports_streaming = true }),
--   },
-- })
local function InputMediaVideo(data)
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

  -- Type of the result, must be video
  jsonData.type = 'video'

  -- Optional. Thumbnail of the file sent;
  -- can be ignored if thumbnail generation for the file is supported server-side
  if data.thumbnail then
    if type(data.thumbnail) ~= 'string' and
      type(data.thumbnail) ~= 'table'
    then
      return nil
    end

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

  -- Optional. Caption of the video to be sent,
  -- 0-1024 characters after entities parsing
  if data.caption then
    jsonData.caption = tostring(data.caption)
  end

  -- Optional. Mode for parsing entities in the video caption.
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

  -- Optional. Pass True if the video needs to be covered with a spoiler animation
  if data.has_spoiler ~= nil then
    jsonData.has_spoiler = data.has_spoiler and true or false
  end

  return jsonData
end

return InputMediaVideo
