--- Aggregation of all Telegram type builders.
--

--- Telegram type builders.
-- @table types
local types = {
  BotCommand = require('bot.types.BotCommand'),
  BotCommandScope = require('bot.types.BotCommandScope'),
  ForceReply = require('bot.types.ForceReply'),
  InlineKeyboardButton = require('bot.types.InlineKeyboardButton'),
  InlineKeyboardMarkup = require('bot.types.InlineKeyboardMarkup'),
  InlineQueryResultArticle = require('bot.types.InlineQueryResultArticle'),
  InputMediaAnimation = require('bot.types.InputMediaAnimation'),
  InputMediaAudio = require('bot.types.InputMediaAudio'),
  InputMediaDocument = require('bot.types.InputMediaDocument'),
  InputMedia = require('bot.types.InputMedia'),
  InputMediaPhoto = require('bot.types.InputMediaPhoto'),
  InputMediaVideo = require('bot.types.InputMediaVideo'),
  InputPaidMediaPhoto = require('bot.types.InputPaidMediaPhoto'),
  InputPaidMediaVideo = require('bot.types.InputPaidMediaVideo'),
  InputPollOption = require('bot.types.InputPollOption'),
  InputTextMessageContent = require('bot.types.InputTextMessageContent'),
  KeyboardButton = require('bot.types.KeyboardButton'),
  KeyboardButtonPollType = require('bot.types.KeyboardButtonPollType'),
  KeyboardButtonRequestChat = require('bot.types.KeyboardButtonRequestChat'),
  KeyboardButtonRequestUsers = require('bot.types.KeyboardButtonRequestUsers'),
  LabeledPrice = require('bot.types.LabeledPrice'),
  LinkPreviewOptions = require('bot.types.LinkPreviewOptions'),
  ReactionType = require('bot.types.ReactionType'),
  ReplyKeyboardMarkup = require('bot.types.ReplyKeyboardMarkup'),
  ReplyKeyboardRemove = require('bot.types.ReplyKeyboardRemove'),
  ReplyParameters = require('bot.types.ReplyParameters'),
  ShippingOption = require('bot.types.ShippingOption'),
  WebAppInfo = require('bot.types.WebAppInfo'),
}

return types
