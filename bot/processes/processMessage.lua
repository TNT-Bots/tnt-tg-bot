--- Process incoming data and create corresponding objects
-- @module bot.middlewares.processMessage

local Message = require('bot.classes.Message')
local CallbackQuery = require('bot.classes.CallbackQuery')
local ChatMember = require('bot.classes.ChatMember')
local MyChatMember = require('bot.classes.MyChatMember')
local PreCheckoutQuery = require('bot.classes.PreCheckoutQuery')

local function processMessage(data)
  if data.message then
    return Message(data)
  elseif data.callback_query then
    return CallbackQuery(data)
  elseif data.chat_member then
    return ChatMember(data)
  elseif data.my_chat_member then
    return MyChatMember(data)
  elseif data.pre_checkout_query then
    return PreCheckoutQuery(data)
  end

  return data
end

return processMessage
