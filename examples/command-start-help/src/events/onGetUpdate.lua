---
--
local bot = require('bot')

local function onGetUpdate(ctx)
  if ctx.message then
    if ctx.message.entities then
      return bot.events.onGetEntities(ctx)
    end
  end
end

return onGetUpdate
