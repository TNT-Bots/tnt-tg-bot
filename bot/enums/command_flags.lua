--- bot/enums/command_flags.lua
--
local flags = {}

flags.PRIVATE      = 0b000001  -- 1
flags.PUBLIC       = 0b000010  -- 2
flags.CALLBACK     = 0b000100  -- 4
flags.REPLY        = 0b001000  -- 8
flags.NO_REPLY     = 0b010000  -- 16
flags.MAINTENANCE  = 0b100000  -- 32

return flags
