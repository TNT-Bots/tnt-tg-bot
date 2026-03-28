--- bot/ext/commandLoader.lua
--
local bot = require('bot')
local log = require('bot.libs.logger')

local function commandLoader(list)
  for i = 1, #list do
    local command = list[i]

    local objCommand = require(command)
    for j = 1, #objCommand.commands do
      local commandName = objCommand.commands[j]

      bot.commands[commandName] = objCommand

      log.info('Command [%s] loaded', commandName)
    end
  end
end

return commandLoader
