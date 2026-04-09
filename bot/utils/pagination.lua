--- Keyboard pagination utility
-- @module bot.ext.pagination
local inlineKeyboard = require('bot.middlewares.inlineKeyboard')

--- Build a paginated inline keyboard
-- @param opts (table) Options table
--   - items (table): Array of items to paginate
--   - total (number): Total items
--   - page (number): Current page number (starting from 1)
--   - per_page (number, optional): Items per page (default 5)
--   - prefix (string): Callback data prefix for navigation buttons
--   - make_button (function): function(item, index) -> { text, callback_data }
--
-- @return Inline keyboard markup ready for reply_markup
--
-- @usage
-- local kb = pagination({
--   items = items,
--   total = 100
--   page = 1,
--   per_page = 5,
--   prefix = 'list',
--   make_button = function(item, i)
--     return { text = item, callback_data = 'item ' .. i }
--   end,
-- })
local function pagination(opts)
  local items = opts.items
  local total = opts.total
  local page = opts.page or 1
  local per_page = opts.per_page or 5
  local prefix = opts.prefix or 'page'
  local make_button = opts.make_button

  local total_pages = math.ceil(total / per_page)

  if page < 1 then page = 1 end
  if page > total_pages then page = total_pages end

  local start_idx = (page - 1) * per_page + 1
  local end_idx = math.min(start_idx + per_page - 1, total)

  -- Item buttons (one per row)
  local buttons = {}
  for i = start_idx, end_idx do
    table.insert(buttons, make_button(items[i], i))
  end

  -- Navigation row
  if total_pages > 1 then
    local nav = {}

    if page > 1 then
      table.insert(nav, {
        text = '◀️ '..(page - 1),
        callback_data = prefix .. ' page ' .. (page - 1)
      })
    end

    if page < total_pages then
      table.insert(nav, {
        text = (page + 1)..' ▶️',
        callback_data = prefix .. ' page ' .. (page + 1)
      })
    end

    table.insert(buttons, nav)
  end

  return inlineKeyboard(buttons)
end

return pagination
