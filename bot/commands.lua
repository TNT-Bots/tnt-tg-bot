--- Command parsing module
-- @module bot.commands
local log = require('log')

local commands = {}

--- Handles a command via text (ctx.message.text)
--
-- @param bot (table) Bot object
-- @param ctx (table) Message object
--
-- @return Command func
-- @return Bot username
function commands.Command(bot, ctx)
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

--- Handles a callback query
--
-- @param bot (table) Bot object
-- @param ctx (table) Callback query object
--
-- @return Command func
function commands.CallbackCommand(bot, ctx)
  local command = ctx:getArguments({ count = 1 })[1]
  if not bot.commands[command] then
    return
  end

  ctx.__command = command

  log.info('[Callback] %s', command)

  return bot.commands[command]
end

return commands
