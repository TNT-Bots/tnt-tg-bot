--- Command flag bits enum.
-- Values are combined into a bitmask in Command.flags.
--

--- Command behavior flags.
local flags = {
  PRIVATE        = 1,
  PUBLIC         = 2,
  IN_CHAT        = 4,
  REPLY          = 8,
  NO_REPLY       = 16,
  CALLBACK       = 32,
  MAINTENANCE    = 64,
  MODERATION     = 128,
  ADMINISTRATIVE = 256,
  MULTI_USER     = 512,
}

return flags
