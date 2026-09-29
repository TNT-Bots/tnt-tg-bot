--- Command flag bits enum.
-- Values are combined into a bitmask in Command.flags, also available as Command.enum.
--
-- Only PRIVATE is interpreted by the library, see processes.processCommand.
-- Any other flag is a convention: it has no effect until the user's
-- bot.events.preCallCommand handler checks it with command:hasFlag(flag).
-- @see classes.Command
-- @usage
-- function bot.events.preCallCommand(ctx, command)
--   if command:hasFlag(Command.enum.ADMINISTRATIVE) and not isAdmin(ctx) then
--     return false
--   end
-- end

--- Command behavior flags.
local flags = {
  PRIVATE        = 1,   -- 1, the command runs in private chats only
  PUBLIC         = 2,   -- 2, convention
  IN_CHAT        = 4,   -- 4, convention
  REPLY          = 8,   -- 8, convention
  NO_REPLY       = 16,  -- 16, convention
  CALLBACK       = 32,  -- 32, convention
  MAINTENANCE    = 64,  -- 64, convention
  MODERATION     = 128, -- 128, convention
  ADMINISTRATIVE = 256, -- 256, convention
  MULTI_USER     = 512, -- 512, convention
}

return flags
