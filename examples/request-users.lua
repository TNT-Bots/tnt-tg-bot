--- Example of a reply keyboard that asks the user to share other users.
-- /pick shows the keyboard; the selection comes back
-- as a "users_shared" service message.
local log = require('log')
local bot = require('bot')
local types = require('bot.types')

bot:cfg({
  token = os.getenv('BOT_TOKEN')
})

-- Request identifier returned back in the users_shared message
local PICK_REQUEST_ID = 1

function bot.events.onGetUpdate(ctx)
  if not ctx.message then
    return
  end

  -- Selection result
  local shared = ctx.message.users_shared
  if shared and shared.request_id == PICK_REQUEST_ID then
    local ids = {}
    for _, user in ipairs(shared.users) do
      table.insert(ids, user.user_id)
    end

    ctx:reply('Shared user ids: '..table.concat(ids, ', '))

    return
  end

  if ctx:getText() ~= '/pick' then
    return
  end

  local keyboard = types.ReplyKeyboardMarkup({
    keyboard = {
      {
        types.KeyboardButton(nil, {
          text = 'Pick users',
          request_users = types.KeyboardButtonRequestUsers({
            request_id = PICK_REQUEST_ID,
            max_quantity = 3,
            request_name = true
          })
        })
      }
    },
    resize_keyboard = true,
    one_time_keyboard = true
  })

  local _, err = ctx:reply({
    text = 'Press the button to pick up to three users.',
    reply_markup = keyboard
  })

  if err then
    log.error(err)
  end
end

bot:startLongPolling()
