--- LinkPreviewOptions type builder.
-- See: https://core.telegram.org/bots/api#linkpreviewoptions
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
