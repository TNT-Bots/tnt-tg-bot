--- Utility for declarative getter generation
-- @module bot.libs.getter

local function resolve(obj, path)
  local current = obj
  for segment in path:gmatch('[^.]+') do
    if current == nil then return nil end
    current = current[segment]
  end
  return current
end

--- Define getter methods on a class from a mapping table
-- @param class (table) Class table to add methods to
-- @param getters (table) { methodName = 'dot.separated.path', ... }
local function defineGetters(class, getters)
  for name, path in pairs(getters) do
    class[name] = function(self)
      return resolve(self, path)
    end
  end
end

return defineGetters
