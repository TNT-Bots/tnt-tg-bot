--- EventEmitter
--
local log = require('log')

local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter:new()
  local obj = { handlers = {} }

  setmetatable(obj, self)
  return obj
end

function EventEmitter:on(event, fn)
  log.verbose('[EventEmitter] init event: %-40s | fn %s', event, fn)

  if not self.handlers[event] then
    self.handlers[event] = {}
  end

  table.insert(self.handlers[event], fn)
end

function EventEmitter:emit(event, ctx)
  local fns = self.handlers[event]
  if fns then
    for _, fn in ipairs(fns) do
      fn(ctx)
    end
  end
end

return EventEmitter
