--- Command descriptor with behavior flags packed into a bitmask.
local bit = require('bit')
local command_flags = require('bot.enums.command_flags')

local Command = {
  enum = command_flags
}
Command.__index = Command

-- OR-combination of a flag list into a single bitmask
local function build_flags(list)
  local mask = 0
  for _, flag in ipairs(list) do
    mask = bit.bor(mask, flag)
  end
  return mask
end

--- Create a command descriptor.
-- @tparam table cfg
-- @tparam table cfg.commands command names, e.g. { '/start' }
-- @tparam[opt] string cfg.info human-readable command description
-- @tparam table cfg.flags list of bot.enums.command_flags values
-- @tparam[opt] table cfg.arguments_schema ordered callback argument names
-- @treturn table command object
function Command:new(cfg)
  local command = {}

  command.commands = cfg.commands
  command.info = cfg.info
  command.flags = build_flags(cfg.flags)
  command.arguments_schema = cfg.arguments_schema

  return setmetatable(command, self)
end

--- Check whether the command has a flag.
-- @tparam number flag value from bot.enums.command_flags
-- @treturn boolean true if the flag is set
function Command:hasFlag(flag)
  return bit.band(self.flags, flag) ~= 0
end

return Command
