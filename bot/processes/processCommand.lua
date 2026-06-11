--- Command handler
--
local log = require('log')
local bot = require('bot')
local command_flags = require('bot.enums.command_flags')
local chat_type = require('bot.enums.chat_type')
local RateLimiter = require('bot.libs.rateLimiter')

-- Антифлуд: per (user_id, chat_id). У юзера свой бюджет в каждом чате,
-- юзеры друг друга не аффектят. TODO: вынести цифры в bot.cfg.
local antiflood = RateLimiter.new({ capacity = 2, refill_per_sec = 1 })

-- TODO: Callback press timeout handler?

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

    -- A resolved command is not guaranteed: callers pass bot.commands[name],
    -- which is nil for an unknown (or wrong-case) command addressed to the bot.
    if command == nil then
      return
    end

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
  if command:hasFlag(command_flags.PRIVATE) then
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

  -- Антифлуд per (user, chat)
  --
  local chat_id = ctx:getChatId()
  local key = ufrom.id..':'..chat_id
  local allowed, wait = antiflood:allow(key)

  if not allowed then
    log.warn('[processCommand] antiflood user=%s chat=%s wait=%.2fs',
      ufrom.id, chat_id, wait)

    if ctx.is_callback_query then
      -- luacheck: ignore
      if opts and opts.antiflood_answer and opts.antiflood_answer(ctx) then end
    end

    return
  end
  --

  -- Build commad arguments
  if command.arguments_schema then
    command.arguments = build_kv_arguments(ctx, command)
  end

  -- Pre call command event
  if bot.events.preCallCommand then
    local hasRun = bot.events.preCallCommand(ctx, command)
    if hasRun == false then
      return
    end
  end

  -- Execute the command
  command.call(ctx)

  -- Post call command event
  if bot.events.postCallCommand then
    bot.events.postCallCommand(ctx, command)
  end
end

return processCommand
