--- InlineQueryResultArticle type builder.
-- See: https://core.telegram.org/bots/api#inlinequeryresultarticle
--

--- Build an InlineQueryResultArticle object.
-- @tparam table data
-- @tparam string data.id unique identifier for this result, 1-64 bytes
-- @tparam string data.title title of the result
-- @tparam table data.input_message_content content of the message to be sent (e.g. InputTextMessageContent)
-- @tparam[opt] table data.reply_markup inline keyboard attached to the message
-- @tparam[opt] string data.url URL of the result
-- @tparam[opt] string data.description short description of the result
-- @tparam[opt] string data.thumbnail_url URL of the result thumbnail
-- @tparam[opt] number data.thumbnail_width thumbnail width
-- @tparam[opt] number data.thumbnail_height thumbnail height
-- @treturn ?table InlineQueryResultArticle, nil when required fields are missing
local function InlineQueryResultArticle(data)
  if not data
    or data.id == nil
    or data.title == nil
    or data.input_message_content == nil
  then
    return nil
  end

  return {
    type = 'article',
    id = tostring(data.id),
    title = tostring(data.title),
    input_message_content = data.input_message_content,
    reply_markup = data.reply_markup,
    url = data.url,
    description = data.description,
    thumbnail_url = data.thumbnail_url,
    thumbnail_width = data.thumbnail_width,
    thumbnail_height = data.thumbnail_height
  }
end

return InlineQueryResultArticle
