--- Simple event emitter.
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
-- @tparam string event event name
-- @tparam function fn handler
function EventEmitter:on(event, fn)
  log.verbose('[EventEmitter] init event: %-40s | fn %s', event, fn)

  if not self.handlers[event] then
    self.handlers[event] = {}
  end

  table.insert(self.handlers[event], fn)
end

--- Emit an event to all subscribed handlers.
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
