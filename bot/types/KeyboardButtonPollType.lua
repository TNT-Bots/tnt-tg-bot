--- KeyboardButtonPollType type builder.
-- See: https://core.telegram.org/bots/api#keyboardbuttonpolltype
--

--- Build a KeyboardButtonPollType object.
-- With 'quiz' the user can create only quizzes, with 'regular' only regular polls.
-- Without data any poll type is allowed.
-- @tparam[opt] string|table data poll type string, or { type = ... }
-- @treturn table KeyboardButtonPollType
local function KeyboardButtonPollType(data)
  if not data then
    return {}
  end

  if type(data) == 'table' then
    return { type = data.type }
  end

  return { type = tostring(data) }
end

return KeyboardButtonPollType
