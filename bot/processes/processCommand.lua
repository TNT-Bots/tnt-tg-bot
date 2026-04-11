--- Command handler
--
local bot = require('bot')
local command_flags = require('bot.enums.command_flags')
local chat_type = require('bot.enums.chat_type')

-- TODO: Callback press timeout handler
-- TODO: Anti-flood

local function build_kv_arguments(ctx, command)
  local arguments = {}
  local schema = command.arguments_schema

  if ctx.is_callback_query then
    local arrArgs = ctx:getArguments({ count = 64 })

    for i = 1, #schema do
      arguments[schema[i]] = arrArgs[i + 1]
    end
  end

  return arguments
end

local function processCommand(ctx, opts)
  local commandName
  local command

  if opts and opts.is_text_command then
    command = opts.command

    goto text_command
  end

  -- Callback button pressed
  if ctx.is_callback_query then
    commandName = ctx:getArguments({ count = 1 })[1]
  else
    -- Execute bot commands
    local entities = ctx:getEntities()
    if entities then
      commandName = ctx.message.text:split(' ', 1)[1]
    end
  end

  command = bot.commands[commandName]
  if command == nil then
    return
  end

  ::text_command::

  -- User who triggered the command
  local ufrom = ctx:getUserFrom()

  -- Check command type flags
  --
  if command:has_flag(command_flags.PRIVATE) then
    if ctx:getChatType() ~= chat_type.PRIVATE then
      return
    end
  end

  -- (Default) Deny other bots from executing commands
  --
  if ufrom.is_bot then
    return
  end

  -- (Default) Deny channels from using commands
  --
  local senderChat = ctx:getSenderChat()
  if senderChat then
    return
  end

  -- Build commad arguments
  if command.arguments_schema then
    command.arguments = build_kv_arguments(ctx, command)
  end

  -- Pre call command event
  if bot.events.preCallCommand then
    bot.events.preCallCommand(ctx, command)
  end

  -- Execute the command
  command.call(ctx)

  -- Post call command event
  if bot.events.postCallCommand then
    bot.events.postCallCommand(ctx, command)
  end
end

return processCommand
