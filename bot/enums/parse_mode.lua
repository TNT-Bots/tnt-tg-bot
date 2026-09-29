--- Parse mode enum.
-- See: https://core.telegram.org/bots/api#formatting-options
--

--- Parse modes.
local parse_mode = {
  HTML = 'HTML',              -- HTML style, the default of the library
  MARKDOWN = 'Markdown',      -- legacy Markdown style
  MARKDOWN_V2 = 'MarkdownV2', -- MarkdownV2 style
}

return parse_mode
