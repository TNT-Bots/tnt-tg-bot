--- HTML formatting helpers for Telegram messages.
local utf8 = require('utf8')

local M = {}

local html_escape_map = {
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ["&"] = "&amp;",
  ['"'] = "&quot;",
  ["'"] = "&#039;",
}

M.sep = "<code>··············</code>"

--- Escape HTML-unsafe characters as HTML entities.
-- @tparam string text
-- @treturn string escaped text
function M.escape(text)
  text = tostring(text)
  return string.gsub(text, "[<>&\"']", html_escape_map)
end

--- Wrap text in b tags for bold formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.bold(text)
  return "<b>"..M.escape(text).."</b>"
end

--- Wrap text in i tags for italic formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.italic(text)
  return "<i>"..M.escape(text).."</i>"
end

--- Wrap text in b and i tags for bold-italic formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.bi(text)
  return "<b><i>"..M.escape(text).."</i></b>"
end

--- Join up to two strings into a bold-italic title.
-- Unlike bi, the text is NOT escaped.
-- @tparam string text_1
-- @tparam[opt] string text_2 appended after a space
-- @treturn string wrapped text
function M.title(text_1, text_2)
  if text_2 then
    text_1 = text_1..' '..text_2
  end

  return "<b><i>"..text_1.."</i></b>"
end

--- Wrap text in code tags for monospaced formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.monospaced(text)
  return "<code>"..M.escape(text).."</code>"
end

--- Alias of monospaced.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.mono(text)
  return "<code>"..M.escape(text).."</code>"
end

--- Wrap text in strike tags for strike-through formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.strike(text)
  return "<strike>"..M.escape(text).."</strike>"
end

--- Wrap text in u tags for underline formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.underline(text)
  return "<u>"..M.escape(text).."</u>"
end

--- Generate a pre code block with a specified language.
-- The code text is NOT escaped.
-- @tparam string lang programming language
-- @tparam string text code text
-- @treturn string formatted code block
function M.code(lang, text)
  return ('<pre language="%s">%s</pre>'):format(lang, text)
end

--- Generate an HTML hyperlink.
-- @tparam string url URL
-- @tparam string name link text
-- @treturn string formatted hyperlink
function M.url(url, name)
  return ('<a href="%s">%s</a>'):format(url, M.escape(name))
end

--- Generate a Telegram user mention link.
-- @tparam number id user id
-- @tparam string link_name link text
-- @treturn string formatted user mention link
function M.user_url(id, link_name)
  return ('<a href="tg://user?id=%s">%s</a>'):format(id, M.escape(link_name))
end

-- Display name truncation limit for M.user
local MAX_USERNAME_LENGTH = 25

--- Convert a Telegram User object to a mention link.
-- @tparam table user User object
-- @tparam[opt] table opts
-- @tparam[opt=25] number opts.len display name truncation limit
-- @tparam[opt] boolean opts.no_link return the escaped name without a link
-- @treturn string formatted user mention link
function M.user(user, opts)
  if not user then
    return 'nil'
  end

  local name = user.first_name or user.username or 'Аноним'
  name = utf8.sub(name, 1, opts and opts.len or MAX_USERNAME_LENGTH)

  if opts then
    if opts.no_link then
      return M.escape(name)
    end
  end

  return ('<a href="tg://user?id=%s">%s</a>'):format(user.id, M.escape(name))
end

-- Title truncation limit for M.chat
local MAX_CHAT_TITLE_LENGTH = 32

--- Convert a Telegram Chat object to a mention link.
-- @tparam table Chat Chat object
-- @tparam[opt] table opts
-- @tparam[opt=32] number opts.len title truncation limit
-- @tparam[opt] boolean opts.no_link return the escaped title without a link
-- @treturn string formatted chat mention link
function M.chat(Chat, opts)
  if not Chat or not Chat.id or not Chat.title then
    return 'Nil'
  end

  local title = utf8.sub(Chat.title, 1, opts and opts.len or MAX_CHAT_TITLE_LENGTH)

  if opts and opts.no_link then
    return M.escape(title)
  end

  if Chat.username then
    return ('<a href="https://t.me/%s">%s</a>'):format(Chat.username, M.escape(title))
  end

  return M.mono(title)
end

--- Generate a Telegram message URL.
-- @tparam string username username of the user or chat
-- @tparam number id message id
-- @tparam string link_name link text
-- @treturn string formatted message URL
function M.message_url(username, id, link_name)
  return ('<a href="https://t.me/%s/%s">%s</a>'):format(username, id, M.escape(link_name))
end

--- Wrap text in tg-spoiler tags for spoiler formatting.
-- @tparam string text
-- @treturn string escaped and wrapped text
function M.spoiler(text)
  return ("<tg-spoiler>%s</tg-spoiler>"):format(M.escape(text))
end

return M
