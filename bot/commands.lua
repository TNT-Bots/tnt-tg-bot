--- Command resolution for text and callback updates.
local log = require('log')

local commands = {}

--- Resolve a command from message text (ctx.message.text).
-- @tparam table bot bot object
-- @tparam table ctx message object
-- @treturn function command handler, nil if the command is unknown
-- @treturn string bot username from the '/cmd@username' form, if present
function commands.command(bot, ctx)
  local command = ctx:getArguments({ count = 1 })[1]

  local username
  if command:find('@') then
    command, username = command:match("(/.+)@(.+)")
  end

  if not bot.commands[command] then
    return nil, nil
  end

  ctx.__command = command

  log.verbose('[Command] %s', command)

  return bot.commands[command], username
end

--- Resolve a command from callback query data.
-- @tparam table bot bot object
-- @tparam table ctx callback query object
-- @treturn function command handler, nil if the command is unknown
function commands.callbackCommand(bot, ctx)
  local command = ctx:getArguments({ count = 1 })[1]
  if not bot.commands[command] then
    return
  end

  ctx.__command = command

  log.info('[Callback] %s', command)

  return bot.commands[command]
end

return commands
