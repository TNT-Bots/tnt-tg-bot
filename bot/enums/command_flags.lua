--- Command flag bits enum.
-- Values are combined into a bitmask in Command.flags.
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
flags.MULTI_USER     = 512

return flags
