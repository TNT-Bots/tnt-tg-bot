--- /bot/classes/Command.lua
--
local bit = require('bit')
local command_flags = require('bot.enums.command_flags')

local Command = {
  enum = command_flags
}
Command.__index = Command

local function build_flags(list)
  local mask = 0
  for _, flag in ipairs(list) do
    mask = bit.bor(mask, flag)
  end
  return mask
end

function Command:new(cfg)
  local command = {}

  command.commands = cfg.commands
  command.info = cfg.info
  command.flags = build_flags(cfg.flags)
  command.arguments_schema = cfg.arguments_schema

  return setmetatable(command, self)
end

function Command:hasFlag(flag)
  return bit.band(self.flags, flag) ~= 0
end

return Command
