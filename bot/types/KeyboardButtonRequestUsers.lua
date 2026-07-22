--- KeyboardButtonRequestUsers type builder.
-- See: https://core.telegram.org/bots/api#keyboardbuttonrequestusers
--

--- Build a KeyboardButtonRequestUsers object.
-- @tparam table data
-- @tparam number data.request_id signed 32-bit request identifier, returned in the users_shared message
-- @tparam[opt] boolean data.user_is_bot request bots (true) or regular users (false)
-- @tparam[opt] boolean data.user_is_premium request premium (true) or non-premium (false) users
-- @tparam[opt=1] number data.max_quantity maximum number of users to be selected, 1-10
-- @tparam[opt] boolean data.request_name request the users' first and last names
-- @tparam[opt] boolean data.request_username request the users' usernames
-- @tparam[opt] boolean data.request_photo request the users' photos
-- @treturn ?table KeyboardButtonRequestUsers, nil when request_id is missing
local function KeyboardButtonRequestUsers(data)
  if not data or data.request_id == nil then
    return nil
  end

  return {
    request_id = tonumber(data.request_id),
    user_is_bot = data.user_is_bot,
    user_is_premium = data.user_is_premium,
    max_quantity = data.max_quantity,
    request_name = data.request_name,
    request_username = data.request_username,
    request_photo = data.request_photo
  }
end

return KeyboardButtonRequestUsers
