--- bot/utils/commandLoader.lua
--
local log = require('log')
local bot = require('bot')

local commandLoader = {
  path = ''
}

function commandLoader.setPath(path)
  commandLoader.path = path
end

local function command_require(path)
  local command = require(path)

  for i = 1, #command.commands do
    local commandName = command.commands[i]

    bot.commands[commandName] = command

    log.info('Command [%s] loaded', commandName)
  end
end

function commandLoader.loader(_, list)
  for commandType, commands in pairs(list) do
    local path = string.format('%s.%s', commandLoader.path, commandType)

    for command, params in pairs(commands) do
      local pathToCommand = string.format('%s.%s', path, command)

      -- First: Load callback command
      -- NOTE: Нужно для правильнной передачи callback-аргументов
      if params.callback_commands then
        for i = 1, #params.callback_commands do
          local callbackCommand = params.callback_commands[i]
          command_require(pathToCommand .. string.format('.%s', callbackCommand))
        end
      end

      -- Next: Load base command
      command_require(pathToCommand)
    end
  end
end

setmetatable(commandLoader, {
  __call = commandLoader.loader
})

return commandLoader
