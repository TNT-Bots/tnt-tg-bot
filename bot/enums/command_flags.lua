--- bot/enums/command_flags.lua
--
local flags = {}

flags.PRIVATE      = 1   -- 0b000001
flags.PUBLIC       = 2   -- 0b000010
flags.CALLBACK     = 4   -- 0b000100
flags.REPLY        = 8   -- 0b001000
flags.NO_REPLY     = 16  -- 0b010000
flags.MAINTENANCE  = 32  -- 0b100000

return flags
