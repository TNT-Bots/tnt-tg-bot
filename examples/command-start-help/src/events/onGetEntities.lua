local processCommand = require('bot.processes.processCommand')

local function onGetEntities(ctx)
  local entities = ctx:getEntities()

  local entity = entities[1]
  if entity.type ~= 'bot_command' then
    return
  end

  processCommand(ctx)
end

return onGetEntities
