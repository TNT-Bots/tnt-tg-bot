--- InputPollOption type builder.
-- See: https://core.telegram.org/bots/api#inputpolloption
--

--- Build an InputPollOption object.
-- @tparam string|table data option text, or a table with the fields below
-- @tparam string data.text option text, 1-100 characters
-- @tparam[opt] string data.text_parse_mode parse mode for the text
-- @tparam[opt] table data.text_entities entities of the text, instead of text_parse_mode
-- @tparam[opt] table data.media media added to the poll option
-- @treturn ?table InputPollOption, nil when text is missing
local function InputPollOption(data)
  if not data then
    return nil
  end

  if type(data) ~= 'table' then
    return { text = tostring(data) }
  end

  if data.text == nil then
    return nil
  end

  return {
    text = tostring(data.text),
    text_parse_mode = data.text_parse_mode,
    text_entities = data.text_entities,
    media = data.media
  }
end

return InputPollOption
