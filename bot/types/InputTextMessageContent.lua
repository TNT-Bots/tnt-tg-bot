--- InputTextMessageContent type builder.
-- See: https://core.telegram.org/bots/api#inputtextmessagecontent
--

--- Build an InputTextMessageContent object.
-- @tparam string|table data message text, or a table with the fields below
-- @tparam string data.message_text text of the message, 1-4096 characters
-- @tparam[opt] string data.parse_mode parse mode for the text
-- @tparam[opt] table data.entities entities of the text, instead of parse_mode
-- @tparam[opt] table data.link_preview_options link preview generation options
-- @treturn ?table InputTextMessageContent, nil when message_text is missing
local function InputTextMessageContent(data)
  if not data then
    return nil
  end

  if type(data) ~= 'table' then
    return { message_text = tostring(data) }
  end

  if data.message_text == nil then
    return nil
  end

  return {
    message_text = tostring(data.message_text),
    parse_mode = data.parse_mode,
    entities = data.entities,
    link_preview_options = data.link_preview_options
  }
end

return InputTextMessageContent
