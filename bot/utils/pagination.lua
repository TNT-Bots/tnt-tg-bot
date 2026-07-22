--- Keyboard pagination utility.
-- Navigation relies on the project convention: { command, arguments } +
-- inlineCallbackKeyboard (callback_data is built from the command's arguments_schema).
local inlineCallbackKeyboard = require('bot.middlewares.inlineCallbackKeyboard')

--- Build a paginated inline keyboard.
-- @tparam table opts
-- @tparam number opts.total total number of items
-- @tparam number opts.page current page (1-based)
-- @tparam[opt=5] number opts.per_page items per page
-- @tparam string opts.command navigation callback command (e.g. 'cb_top')
-- @tparam[opt] table opts.arguments base arguments, page is substituted on the buttons
-- @tparam[opt='page'] string opts.page_key page argument name
-- @tparam[opt] table opts.items items (required only when make_button is set)
-- @tparam[opt] function opts.make_button function(item, index) -> { text, callback = { command, arguments } }
-- @tparam[opt] table opts.footer extra button rows after navigation (e.g. a back button)
-- @treturn table inline keyboard markup ready for reply_markup
-- @usage
-- local kb = pagination({
--   total = 100,
--   page = 1,
--   per_page = 10,
--   command = 'cb_top',
--   arguments = { which = 'donat' },
--   footer = { { { text = '🔙 Back', callback = { command = 'cb_top', arguments = { which = 'menu', page = 1 } } } } },
-- })
local function pagination(opts)
  local page = opts.page or 1
  local per_page = opts.per_page or 5
  local page_key = opts.page_key or 'page'

  local total_pages = math.ceil(opts.total / per_page)
  if total_pages < 1 then total_pages = 1 end

  if page < 1 then page = 1 end
  if page > total_pages then page = total_pages end

  -- Navigation button: base arguments plus the target page.
  local function navButton(text, targetPage)
    local arguments = {}

    for key, value in pairs(opts.arguments or {}) do
      arguments[key] = value
    end

    arguments[page_key] = targetPage

    return { text = text, callback = { command = opts.command, arguments = arguments } }
  end

  local buttons = {}

  -- Item buttons (one per row) when make_button is set.
  if opts.make_button then
    local start_idx = (page - 1) * per_page + 1
    local end_idx = math.min(start_idx + per_page - 1, opts.total)

    for i = start_idx, end_idx do
      table.insert(buttons, opts.make_button(opts.items[i], i))
    end
  end

  -- Navigation row.
  if total_pages > 1 then
    local nav = {}

    if page > 1 then
      table.insert(nav, navButton('◀️ '..(page - 1), page - 1))
    end

    if page < total_pages then
      table.insert(nav, navButton((page + 1)..' ▶️', page + 1))
    end

    table.insert(buttons, nav)
  end

  -- Extra rows (e.g. a back button).
  if opts.footer then
    for _, row in ipairs(opts.footer) do
      table.insert(buttons, row)
    end
  end

  return inlineCallbackKeyboard(buttons)
end

return pagination
