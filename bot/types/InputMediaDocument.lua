--- InputMediaDocument type builder.
-- See: https://core.telegram.org/bots/api#inputmediadocument
--

--- Build an InputMediaDocument object.
-- @tparam table data InputMediaDocument fields, data.media required
-- @treturn ?table InputMediaDocument, nil on invalid input
local function InputMediaDocument(data)
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

  -- Type of the result, must be document
  jsonData.type = 'document'

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

  -- Optional. Caption of the document to be sent,
  -- 0-1024 characters after entities parsing
  if data.caption then
    jsonData.caption = tostring(data.caption)
  end

  -- Optional. Mode for parsing entities in the document caption.
  if data.parse_mode then
    jsonData.parse_mode = data.parse_mode
  end

  -- Optional. List of special entities that appear in the caption,
  -- which can be specified instead of parse_mode
  if data.caption_entities and type(data.caption_entities) == 'table' then
    jsonData.caption_entities = data.caption_entities
  end

  -- Optional. Disables automatic server-side content type detection for files uploaded using multipart/form-data.
  -- Always True, if the document is sent as part of an album
  if data.disable_content_type_detection ~= nil then
    jsonData.disable_content_type_detection = data.disable_content_type_detection and true or false
  end

  return jsonData
end

return InputMediaDocument
