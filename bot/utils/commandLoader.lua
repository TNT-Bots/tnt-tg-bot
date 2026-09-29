--- Command module loader registering commands in bot.commands.
-- The module is callable: commandLoader(list) is a shortcut for commandLoader.loader(_, list).
-- @pragma nostrip
-- @usage
-- local commandLoader = require('bot.utils.commandLoader')
--
-- commandLoader.setPath('src.commands')
-- commandLoader({
--   private = {
--     start = {},
--     help = {},
--   },
--   moderation = {
--     -- requires src.commands.moderation.settings.cb_settings,
--     -- then src.commands.moderation.settings
--     settings = { callback_commands = { 'cb_settings' } },
--   },
-- })
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

-- Module require and registration of every name from its commands field
local function command_require(path)
  local command = require(path)

  for i = 1, #command.commands do
    local commandName = command.commands[i]

    bot.commands[commandName] = command

    log.info('Command [%s] loaded', commandName)
  end
end

--- Load command modules and register them in bot.commands.
-- A module is required as path.command_type.command_name and registered
-- under every name from its commands field.
--
-- params.callback_commands is an optional list of callback command modules,
-- required before the command itself as path.command_type.command_name.callback_name.
-- @tparam any _ unused (self when called via __call)
-- @tparam table list { [command_type] = { [command_name] = params } }
-- @raise if a module is not found
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
