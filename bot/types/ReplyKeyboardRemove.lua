--- ReplyKeyboardRemove type builder.
-- See: https://core.telegram.org/bots/api#replykeyboardremove
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
