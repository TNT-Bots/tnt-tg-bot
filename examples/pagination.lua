-- Example of paginated inline keyboard with nested detail pages
--
local bot = require('bot')
local pagination = require('bot.ext.pagination')
local inlineKeyboard = require('bot.middlewares.inlineKeyboard')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

-- Sample data
local fruits = {
  { name = 'Apple',      desc = 'A sweet red fruit, rich in fiber and vitamin C.' },
  { name = 'Banana',     desc = 'A yellow tropical fruit, high in potassium.' },
  { name = 'Cherry',     desc = 'A small red stone fruit with a sweet-tart flavor.' },
  { name = 'Date',       desc = 'A sweet dried fruit from the date palm tree.' },
  { name = 'Elderberry', desc = 'A dark purple berry used in syrups and jams.' },
  { name = 'Fig',        desc = 'A soft pear-shaped fruit with sweet flesh.' },
  { name = 'Grape',      desc = 'A small round fruit growing in clusters on vines.' },
  { name = 'Honeydew',   desc = 'A large melon with pale green sweet flesh.' },
  { name = 'Kiwi',       desc = 'A brown fuzzy fruit with bright green flesh.' },
  { name = 'Lemon',      desc = 'A sour yellow citrus fruit rich in vitamin C.' },
  { name = 'Mango',      desc = 'A tropical stone fruit with juicy orange flesh.' },
  { name = 'Nectarine',  desc = 'A smooth-skinned variety of peach.' },
  { name = 'Orange',     desc = 'A round citrus fruit with a bright orange rind.' },
  { name = 'Papaya',     desc = 'A tropical fruit with soft orange flesh and black seeds.' },
  { name = 'Quince',     desc = 'A hard aromatic fruit used in preserves and jellies.' },
  { name = 'Raspberry',  desc = 'A soft red berry with a delicate sweet flavor.' },
  { name = 'Strawberry', desc = 'A juicy red fruit covered with tiny seeds.' },
  { name = 'Tangerine',  desc = 'A small sweet citrus fruit, easy to peel.' },
  { name = 'Watermelon', desc = 'A large fruit with juicy red flesh and green rind.' },
  { name = 'Blueberry',  desc = 'A small dark blue berry rich in antioxidants.' },
}

-- Show the fruit list page
local function show_list(ctx, page, edit)
  local keyboard = pagination({
    items = fruits,
    total = #fruits,
    page = page,
    per_page = 5,
    prefix = 'fruits',
    make_button = function(item, i)
      return { text = item.name, callback_data = 'fruit ' .. i .. ' ' .. page }
    end,
  })

  if edit then
    bot:editMessageText({
      chat_id = ctx:getChatId(),
      message_id = ctx:getMessageId(),
      text = 'Pick a fruit:',
      reply_markup = keyboard,
    })
  else
    ctx:reply({
      text = 'Pick a fruit:',
      reply_markup = keyboard,
    })
  end
end

-- Show the fruit detail page
local function show_detail(ctx, index, back_page)
  local fruit = fruits[index]

  local keyboard = inlineKeyboard({
    { text = '🔄 Back', callback_data = 'back ' .. back_page },
  })

  bot:editMessageText({
    chat_id = ctx:getChatId(),
    message_id = ctx:getMessageId(),
    text = '<b>' .. fruit.name .. '</b>\n\n' .. fruit.desc,
    reply_markup = keyboard,
  })
end

function bot.events.onGetUpdate(ctx)
  if ctx.is_callback_query then
    local args = ctx:getArguments({ separator = ' ', count = 4 })
    local action = args[1]

    -- Pagination: "fruits page N"
    if action == 'fruits' and args[2] == 'page' then
      show_list(ctx, tonumber(args[3]), true)
      ctx:answer()

    -- Fruit detail: "fruit INDEX BACK_PAGE"
    elseif action == 'fruit' then
      show_detail(ctx, tonumber(args[2]), tonumber(args[3]))
      ctx:answer()

    -- Back to list: "back PAGE"
    elseif action == 'back' then
      show_list(ctx, tonumber(args[2]), true)
      ctx:answer()
    end

    return
  end

  local text = ctx:getText()
  if text == '/list' then
    show_list(ctx, 1, false)
  end
end

bot:startLongPolling()
