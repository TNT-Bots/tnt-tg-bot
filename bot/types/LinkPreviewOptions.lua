--- LinkPreviewOptions type builder.
-- See: https://core.telegram.org/bots/api#linkpreviewoptions
--

--- Build a LinkPreviewOptions object.
-- @tparam table data
-- @tparam[opt] boolean data.is_disabled disable the link preview
-- @tparam[opt] string data.url URL to use for the link preview, the first URL of the message text by default
-- @tparam[opt] boolean data.prefer_small_media shrink the media in the link preview
-- @tparam[opt] boolean data.prefer_large_media enlarge the media in the link preview
-- @tparam[opt] boolean data.show_above_text show the link preview above the message text
-- @treturn ?table LinkPreviewOptions, nil when data is missing
-- @usage
-- local LinkPreviewOptions = require('bot.types.LinkPreviewOptions')
--
-- ctx:reply({
--   text = 'https://example.com',
--   link_preview_options = LinkPreviewOptions({ is_disabled = true }),
-- })
local function LinkPreviewOptions(data)
  if not data then
    return nil
  end

  return {
    is_disabled = data.is_disabled,
    url = data.url,
    prefer_small_media = data.prefer_small_media,
    prefer_large_media = data.prefer_large_media,
    show_above_text = data.show_above_text
  }
end

return LinkPreviewOptions
