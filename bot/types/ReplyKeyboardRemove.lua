--- ReplyKeyboardRemove type builder.
-- See: https://core.telegram.org/bots/api#replykeyboardremove
--

--- Build a ReplyKeyboardRemove object.
-- Without data the keyboard is removed for all users (API default).
-- @tparam[opt] table data { selective = ... }
-- @treturn table ReplyKeyboardRemove
local function ReplyKeyboardRemove(data)
  if not data then
    return {
      remove_keyboard = true
    }
  end

  local obj = {
    remove_keyboard = true,
    selective = data.selective
  }

  return obj
end

return ReplyKeyboardRemove
