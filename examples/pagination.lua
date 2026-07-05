-- Example: paginated inline keyboard with nested detail pages.
--
-- Uses bot.utils.pagination, which builds navigation through the project's
-- callback convention: a registered command plus its arguments_schema. The
-- keyboard encodes { command, arguments } into callback_data, and
-- processCommand parses it back into command.arguments on each press.
--
local bot = require('bot')
local Command = require('bot.classes.Command')
local pagination = require('bot.utils.pagination')
local processCommand = require('bot.processes.processCommand')
local inlineCallbackKeyboard = require('bot.middlewares.inlineCallbackKeyboard')

bot:cfg({
  token = os.getenv('BOT_TOKEN'),
})

local PER_PAGE = 5

-- Sample data
local fruits = {
  { name = 'Apple',      desc = 'A sweet red fruit, rich in fiber and vitamin C.'           },
  { name = 'Banana',     desc = 'A yellow tropical fruit, high in potassium.'               },
  { name = 'Cherry',     desc = 'A small red stone fruit with a sweet-tart flavor.'         },
  { name = 'Date',       desc = 'A sweet dried fruit from the date palm tree.'              },
  { name = 'Elderberry', desc = 'A dark purple berry used in syrups and jams.'              },
  { name = 'Fig',        desc = 'A soft pear-shaped fruit with sweet flesh.'                },
  { name = 'Grape',      desc = 'A small round fruit growing in clusters on vines.'         },
  { name = 'Honeydew',   desc = 'A large melon with pale green sweet flesh.'                },
  { name = 'Kiwi',       desc = 'A brown fuzzy fruit with bright green flesh.'              },
  { name = 'Lemon',      desc = 'A sour yellow citrus fruit rich in vitamin C.'             },
  { name = 'Mango',      desc = 'A tropical stone fruit with juicy orange flesh.'           },
  { name = 'Nectarine',  desc = 'A smooth-skinned variety of peach.'                        },
  { name = 'Orange',     desc = 'A round citrus fruit with a bright orange rind.'           },
  { name = 'Papaya',     desc = 'A tropical fruit with soft orange flesh and black seeds.'  },
  { name = 'Quince',     desc = 'A hard aromatic fruit used in preserves and jellies.'      },
  { name = 'Raspberry',  desc = 'A soft red berry with a delicate sweet flavor.'            },
  { name = 'Strawberry', desc = 'A juicy red fruit covered with tiny seeds.'                },
  { name = 'Tangerine',  desc = 'A small sweet citrus fruit, easy to peel.'                 },
  { name = 'Watermelon', desc = 'A large fruit with juicy red flesh and green rind.'        },
  { name = 'Blueberry',  desc = 'A small dark blue berry rich in antioxidants.'             },
}

-- The list keyboard: item buttons open a detail page, nav buttons flip pages.
local function listKeyboard(page)
  return pagination({
    items = fruits,
    total = #fruits,
    page = page,
    per_page = PER_PAGE,
    command = 'cb_fruits',
    -- nav buttons inherit this; page is set per button
    arguments = { action = 'page' },

    make_button = function(item, index)
      return {
        text = item.name,
        callback = {
          command = 'cb_fruits',
          arguments = { action = 'open', page = page, index = index },
        },
      }
    end,
  })
end

-- Render the list: reply on first show, edit in place on navigation.
local function showList(ctx, page, edit)
  local view = {
    text = 'Pick a fruit:',
    reply_markup = listKeyboard(page),
  }

  if edit then
    view.chat_id = ctx:getChatId()
    view.message_id = ctx:getMessageId()
    bot:editMessageText(view)
  else
    ctx:reply(view)
  end
end

-- Render one fruit with a back button to the originating page.
local function showDetail(ctx, index, backPage)
  local fruit = fruits[index]

  local keyboard = inlineCallbackKeyboard({
    {
      text = '🔙 Back',
      callback = { command = 'cb_fruits', arguments = { action = 'back', page = backPage } },
    },
  })

  bot:editMessageText({
    chat_id = ctx:getChatId(),
    message_id = ctx:getMessageId(),
    text = '<b>'..fruit.name..'</b>\n\n'..fruit.desc,
    reply_markup = keyboard,
  })
end

-- Callback command: arguments_schema turns "cb_fruits open 2 3" into named args.
local cbFruits = Command:new({
  commands = { 'cb_fruits' },
  flags = { Command.enum.CALLBACK },
  arguments_schema = { 'action', 'page', 'index' },
})

function cbFruits.call(ctx)
  local args = cbFruits.arguments
  local page = tonumber(args.page)

  if args.action == 'open' then
    showDetail(ctx, tonumber(args.index), page)
  else
    -- 'page' (navigation) and 'back' both land on the list.
    showList(ctx, page, true)
  end

  ctx:answer()
end

bot.commands['cb_fruits'] = cbFruits

function bot.events.onGetUpdate(ctx)
  if ctx.is_callback_query then
    processCommand(ctx)
    return
  end

  if ctx:getText() == '/list' then
    showList(ctx, 1, false)
  end
end

bot:startLongPolling()
