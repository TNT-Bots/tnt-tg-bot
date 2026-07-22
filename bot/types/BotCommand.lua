--- BotCommand type builder.
-- See: https://core.telegram.org/bots/api#botcommand
--

--- Build a BotCommand object.
-- @tparam table data { command = ..., description = ... } or positional { command, description }
-- @treturn ?table BotCommand, nil when data is missing
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
