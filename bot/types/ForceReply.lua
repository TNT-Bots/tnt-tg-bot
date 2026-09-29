--- ForceReply type builder.
-- See: https://core.telegram.org/bots/api#forcereply
--

--- Build a ForceReply object.
-- @tparam[opt] table data
-- @tparam[opt] string data.input_field_placeholder placeholder shown in the input field, 1-64 characters
-- @tparam[opt] boolean data.selective force a reply from specific users only
-- @treturn table ForceReply
local function ForceReply(data)
  if not data then
    return {
      force_reply = true
    }
  end

  local obj = {
    force_reply = true,
    input_field_placeholder = data.input_field_placeholder,
    selective = data.selective
  }

  return obj
end

return ForceReply
