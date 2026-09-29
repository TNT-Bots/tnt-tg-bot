--- Command descriptor with behavior flags packed into a bitmask.
-- @pragma nostrip
local bit = require('bit')
local command_flags = require('bot.enums.command_flags')

--- Fields of the command object.
-- @table Command
-- @tfield table enum command flags, see enums.command_flags
-- @tfield table commands command names, e.g. { '/start' }
-- @tfield ?string info human-readable command description
-- @tfield number flags bitmask built from cfg.flags
-- @tfield ?table arguments_schema ordered callback argument names
-- @tfield function call command handler called as call(ctx), assigned by the user
-- @tfield ?table arguments deprecated, shared between fibers: use ctx.arguments
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
-- The handler is not a part of cfg, it is assigned to the call field afterwards.
-- @tparam table cfg
-- @tparam table cfg.commands command names, e.g. { '/start' }
-- @tparam[opt] string cfg.info human-readable command description
-- @tparam table cfg.flags list of bot.enums.command_flags values
-- @tparam[opt] table cfg.arguments_schema ordered callback argument names
-- @treturn table command object
-- @see enums.command_flags
-- @see processes.processCommand
-- @usage
-- local Command = require('bot.classes.Command')
--
-- local command = Command:new({
--   commands = { '/start' },
--   flags = { Command.enum.PRIVATE },
-- })
--
-- function command.call(ctx)
--   ctx:reply('Hello!')
-- end
--
-- return command
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
