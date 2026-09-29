--- BotCommand type builder.
-- See: https://core.telegram.org/bots/api#botcommand
--

--- Build a BotCommand object.
-- @tparam table data named fields below, or positional { command, description }
-- @tparam string data.command text of the command, 1-32 characters: lowercase English letters, digits and underscores
-- @tparam[opt='command'] string data.description description of the command, 1-256 characters
-- @tparam[opt] boolean data.is_ephemeral the command sends an ephemeral message, visible to the sender and the bot only
-- @treturn ?table BotCommand, nil when data is missing
-- @usage
-- local BotCommand = require('bot.types.BotCommand')
--
-- bot:setMyCommands({
--   commands = {
--     BotCommand({ command = 'start', description = 'Start the bot' }),
--     BotCommand({ 'help', 'Show help' }),
--   },
-- })
local function BotCommand(data)
  if not data then
    return nil
  end

  return {
    command = data.command or data[1],
    description = data.description or data[2] or 'command',
    -- Optional. True, if the command sends an ephemeral message,
    -- which can be seen only by the sender of the message and the bot
    is_ephemeral = data.is_ephemeral
  }
end

return BotCommand
