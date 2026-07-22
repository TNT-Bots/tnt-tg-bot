--- ReplyKeyboardRemove type builder.
-- See: https://core.telegram.org/bots/api#replykeyboardremove
--

--- Build a ReplyKeyboardRemove object.
-- @tparam[opt] table data { selective = ... }, selective defaults to true without data
-- @treturn table ReplyKeyboardRemove
local function ReplyKeyboardRemove(data)
  if not data then
    return {
      remove_keyboard = true,
      selective = true
    }
  end

  local obj = {
    remove_keyboard = true,
    selective = data.selective
  }

  return obj
end

return ReplyKeyboardRemove
