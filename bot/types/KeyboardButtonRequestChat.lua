--- KeyboardButtonRequestChat type builder.
-- See: https://core.telegram.org/bots/api#keyboardbuttonrequestchat
--

--- Build a KeyboardButtonRequestChat object.
-- @tparam table data
-- @tparam number data.request_id signed 32-bit request identifier, returned in the chat_shared message
-- @tparam boolean data.chat_is_channel request a channel (true) or a group/supergroup (false)
-- @tparam[opt] boolean data.chat_is_forum request a forum (true) or non-forum (false) chat
-- @tparam[opt] boolean data.chat_has_username request a chat with (true) or without (false) a username
-- @tparam[opt] boolean data.chat_is_created request a chat owned by the user
-- @tparam[opt] table data.user_administrator_rights required administrator rights of the user in the chat
-- @tparam[opt] table data.bot_administrator_rights required administrator rights of the bot in the chat
-- @tparam[opt] boolean data.bot_is_member request a chat with the bot as a member
-- @tparam[opt] boolean data.request_title request the chat's title
-- @tparam[opt] boolean data.request_username request the chat's username
-- @tparam[opt] boolean data.request_photo request the chat's photo
-- @treturn ?table KeyboardButtonRequestChat, nil when required fields are missing
local function KeyboardButtonRequestChat(data)
  if not data or data.request_id == nil or data.chat_is_channel == nil then
    return nil
  end

  return {
    request_id = tonumber(data.request_id),
    chat_is_channel = data.chat_is_channel and true or false,
    chat_is_forum = data.chat_is_forum,
    chat_has_username = data.chat_has_username,
    chat_is_created = data.chat_is_created,
    user_administrator_rights = data.user_administrator_rights,
    bot_administrator_rights = data.bot_administrator_rights,
    bot_is_member = data.bot_is_member,
    request_title = data.request_title,
    request_username = data.request_username,
    request_photo = data.request_photo
  }
end

return KeyboardButtonRequestChat
