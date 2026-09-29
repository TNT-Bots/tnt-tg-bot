--- Simple event emitter.
-- @pragma nostrip
-- @usage
-- local EventEmitter = require('bot.interfaces.EventEmitter')
--
-- local emitter = EventEmitter:new()
--
-- emitter:on('member_kicked', function(ctx)
--   ctx:reply('Bye!')
-- end)
--
-- emitter:emit('member_kicked', ctx)
local log = require('log')

local EventEmitter = {}
EventEmitter.__index = EventEmitter

--- Create an emitter.
-- @treturn table emitter object
function EventEmitter:new()
  local obj = { handlers = {} }

  setmetatable(obj, self)
  return obj
end

--- Subscribe a handler to an event.
-- Several handlers of one event are called in the subscription order.
-- @tparam string event event name
-- @tparam function fn handler called as fn(ctx)
function EventEmitter:on(event, fn)
  log.verbose('[EventEmitter] init event: %-40s | fn %s', event, fn)

  if not self.handlers[event] then
    self.handlers[event] = {}
  end

  table.insert(self.handlers[event], fn)
end

--- Emit an event to all subscribed handlers.
-- An event without handlers is ignored.
-- @tparam string event event name
-- @tparam any ctx argument passed to handlers
function EventEmitter:emit(event, ctx)
  local fns = self.handlers[event]
  if fns then
    for _, fn in ipairs(fns) do
      fn(ctx)
    end
  end
end

return EventEmitter
