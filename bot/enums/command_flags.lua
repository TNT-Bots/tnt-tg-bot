--- bot/enums/command_flags.lua
--
local flags = {}

flags.PRIVATE        = 1
flags.PUBLIC         = 2
flags.IN_CHAT        = 4
flags.REPLY          = 8
flags.NO_REPLY       = 16
flags.CALLBACK       = 32
flags.MAINTENANCE    = 64
flags.MODERATION     = 128
flags.ADMINISTRATIVE = 256

return flags
