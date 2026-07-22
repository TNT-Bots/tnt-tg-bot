--- Command module loader registering commands in bot.commands.
local log = require('log')
local bot = require('bot')

local commandLoader = {
  path = ''
}

--- Set the base require path for command modules.
-- @tparam string path base path, e.g. 'src.commands'
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

--- Load command modules and register them in bot.commands.
-- @tparam any _ unused (self when called via __call)
-- @tparam table list { [command_type] = { [command_name] = params } }
function commandLoader.loader(_, list)
  for commandType, commands in pairs(list) do
    local path = string.format('%s.%s', commandLoader.path, commandType)

    for command, params in pairs(commands) do
      local pathToCommand = string.format('%s.%s', path, command)

      -- Callback commands load first.
      -- NOTE: required for correct callback argument passing.
      if params.callback_commands then
        for i = 1, #params.callback_commands do
          local callbackCommand = params.callback_commands[i]
          command_require(pathToCommand .. string.format('.%s', callbackCommand))
        end
      end

      -- Base command load
      command_require(pathToCommand)
    end
  end
end

setmetatable(commandLoader, {
  __call = commandLoader.loader
})

return commandLoader
