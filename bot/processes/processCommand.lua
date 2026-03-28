--- Обработчик команд
--
local bot = require('bot')
local command_flags = require('bot.enums.command_flags')
local chat_type = require('bot.enums.chat_type')

-- TODO: Обработчик таймаута нажатий на callback
-- TODO: Антифлуддер

local function processCommand(ctx, opts)
  local commandName
  local command

  if opts and opts.is_text_command then
    command = opts.command

    goto text_command
  end

  -- Нажали на callback кнопку
  if ctx.is_callback_query then
    commandName = ctx:getArguments({ count = 1 })[1]
  else
    -- Выполняем команды бота
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

  -- Пользователь выполнивший
  local ufrom = ctx:getUserFrom()

  -- Определение типа команд
  --
  if command:has_flag(command_flags.PRIVATE) then
    if ctx:getChatType() ~= chat_type.PRIVATE then
      return
    end
  end

  -- (По-умолчанию) Запрещаем сторонним ботам выполнять команды
  --
  if ufrom.is_bot then
    return
  end

  -- (По-умолчанию) Не разрешать каналам использовать команды
  --
  local senderChat = ctx:getSenderChat()
  if senderChat then
    return
  end

  -- Выполнение команды
  command.call(ctx)
end

return processCommand
