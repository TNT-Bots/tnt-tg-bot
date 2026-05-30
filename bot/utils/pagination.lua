--- Keyboard pagination utility
-- @module bot.utils.pagination
--
-- Навигация строится через convention проекта: { command, arguments } +
-- inlineCallbackKeyboard (callback_data собирается по arguments_schema команды).
--
local inlineCallbackKeyboard = require('bot.middlewares.inlineCallbackKeyboard')

--- Build a paginated inline keyboard
-- @param opts (table)
--   - total (number): всего элементов
--   - page (number): текущая страница (с 1)
--   - per_page (number, optional): на страницу (по умолчанию 5)
--   - command (string): callback-команда навигации (напр. 'cb_top')
--   - arguments (table, optional): базовые аргументы; page подставляется на кнопках
--   - page_key (string, optional): имя аргумента страницы (по умолчанию 'page')
--   - items (table, optional): элементы (нужны только если задан make_button)
--   - make_button (function, optional): function(item, index) -> { text, callback = { command, arguments } }
--   - footer (table, optional): доп. ряды кнопок после навигации (напр. «назад»)
--
-- @return Inline keyboard markup ready for reply_markup
--
-- @usage
-- local kb = pagination({
--   total = 100,
--   page = 1,
--   per_page = 10,
--   command = 'cb_top',
--   arguments = { which = 'donat' },
--   footer = { { { text = '🔙 Назад', callback = { command = 'cb_top', arguments = { which = 'menu', page = 1 } } } } },
-- })
local function pagination(opts)
  local page = opts.page or 1
  local per_page = opts.per_page or 5
  local page_key = opts.page_key or 'page'

  local total_pages = math.ceil(opts.total / per_page)
  if total_pages < 1 then total_pages = 1 end

  if page < 1 then page = 1 end
  if page > total_pages then page = total_pages end

  -- Кнопка навигации: базовые аргументы + нужная страница.
  local function navButton(text, targetPage)
    local arguments = {}

    for key, value in pairs(opts.arguments or {}) do
      arguments[key] = value
    end

    arguments[page_key] = targetPage

    return { text = text, callback = { command = opts.command, arguments = arguments } }
  end

  local buttons = {}

  -- Кнопки элементов (по одной в ряд), если задан make_button.
  if opts.make_button then
    local start_idx = (page - 1) * per_page + 1
    local end_idx = math.min(start_idx + per_page - 1, opts.total)

    for i = start_idx, end_idx do
      table.insert(buttons, opts.make_button(opts.items[i], i))
    end
  end

  -- Ряд навигации.
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

  -- Доп. ряды (напр. «назад»).
  if opts.footer then
    for _, row in ipairs(opts.footer) do
      table.insert(buttons, row)
    end
  end

  return inlineCallbackKeyboard(buttons)
end

return pagination
