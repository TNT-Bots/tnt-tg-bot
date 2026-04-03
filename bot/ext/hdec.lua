--- HTML formatting functions
-- @module bot.ext.hdec
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

--- Format HTML-unsafe characters as HTML entities
-- @param text (string) text
-- @return (string) Formatted text
function M.format(text)
  text = tostring(text)
  return string.gsub(text, "[<>&\"']", html_escape_map)
end

--- Wrap the input text in <b> tags for bold formatting.</b>
-- @param text (string) text
-- @return (string) Formatted text
function M.bold(text)
  return "<b>"..M.format(text).."</b>"
end

--- Wrap the input text in <i> tags for italic formatting.</i>
-- @param text (string) text
-- @return (string) Formatted text
function M.italic(text)
  return "<i>"..M.format(text).."</i>"
end

--- Wrap like <b><i>Text</i></b>
-- @param text (string) text
-- @return (string) Formatted text
function M.bi(text)
  return "<b><i>"..M.format(text).."</i></b>"
end

--- TODO
-- @param text_1 (string) text
-- @param text_2 (string) text
-- @return (string) Formatted text
function M.title(text_1, text_2)
  if text_2 then
    text_1 = text_1..' '..text_2
  end

  return "<b><i>"..text_1.."</i></b>"
end

--- Wrap the input text in "code" tags for monospaced formatting
-- @param text (string) text
-- @return (string) Formatted text
function M.monospaced(text)
  return "<code>"..M.format(text).."</code>"
end

function M.mono(text)
  return "<code>"..M.format(text).."</code>"
end

--- Wrap the input text in <strike> tags for strike-through formatting.</strike>
-- @param text (string) text
-- @return (string) Formatted text
function M.strike(text)
  return "<strike>"..M.format(text).."</strike>"
end

--- Wrap the input text in <u> tags for underline formatting.</u>
-- @param text (string) text
-- @return (string) Formatted text
function M.underline(text)
  return "<u>"..M.format(text).."</u>"
end

--- Generate a "pre" code block with a specified language for code formatting.
-- @param lang (string) Programming language
-- @param text (string) Code text
-- @return (string) Formatted code block
function M.code(lang, text)
  return ('<pre language="%s">%s</pre>'):format(lang, text)
end

--- Generate an HTML hyperlink
-- @param url (string) URL
-- @param name   (string) Link text
-- @return (string) Formatted hyperlink
function M.url(url, name)
  return ('<a href="%s">%s</a>'):format(url, M.format(name))
end

--- Generate a Telegram user mention link
-- @param id        (number) User ID
-- @param link_name (string) Link text
-- @return (string) Formatted user mention link
function M.user_url(id, link_name)
  return ('<a href="tg://user?id=%s">%s</a>'):format(id, M.format(link_name))
end

--- Convert a Telegram User object to a mention link
-- @param user (table) User object
-- @return (string) Formatted user mention link
local MAX_USERNAME_LENGTH = 25

function M.user(user, opts)
  if not user then
    return 'nil'
  end

  local name = user.first_name or user.username or 'Аноним'
  name = utf8.sub(name, 1, opts and opts.len or MAX_USERNAME_LENGTH)

  if opts then
    if opts.no_link then
      return M.format(name)
    end
  end

  return ('<a href="tg://user?id=%s">%s</a>'):format(user.id, M.format(name))
end

--- Convert a Telegram Chat object to a mention link
-- @param Chat (table) Chat object
-- @return (string) Formatted chat mention link
local MAX_CHAT_TITLE_LENGTH = 32

function M.chat(Chat, opts)
  if not Chat or not Chat.id or not Chat.title then
    return 'Nil'
  end

  local title = utf8.sub(Chat.title, 1, opts and opts.len or MAX_CHAT_TITLE_LENGTH)

  if opts and opts.no_link then
    return M.format(title)
  end

  if Chat.username then
    return ('<a href="https://t.me/%s">%s</a>'):format(Chat.username, M.format(title))
  end

  return M.mono(title)
end

--- Generate a Telegram message URL
-- @param username  (string) Username of the user or chat
-- @param id        (number) Message ID
-- @param link_name (string) Link text
-- @return (string) Formatted message URL
function M.message_url(username, id, link_name)
  return ('<a href="https://t.me/%s/%s">%s</a>'):format(username, id, M.format(link_name))
end

--- Wrap the input text in "tg-spoiler" tags for spoiler formatting
-- @param text (string) text
-- @return (string) Formatted text
function M.spoiler(text)
  return ("<tg-spoiler>%s</tg-spoiler>"):format(M.format(text))
end

return M
