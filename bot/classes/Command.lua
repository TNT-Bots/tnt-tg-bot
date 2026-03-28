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
  local _command = {}

  _command.commands = cfg.commands
  _command.info = cfg.info
  _command.flags = build_flags(cfg.flags)

  return setmetatable(_command, self)
end

function Command:has_flag(flag)
  return bit.band(self.flags, flag) ~= 0
end

return Command
