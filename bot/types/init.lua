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
  InputMediaAnimation = require('bot.types.InputMediaAnimation'),
  InputMediaAudio = require('bot.types.InputMediaAudio'),
  InputMediaDocument = require('bot.types.InputMediaDocument'),
  InputMedia = require('bot.types.InputMedia'),
  InputMediaPhoto = require('bot.types.InputMediaPhoto'),
  InputMediaVideo = require('bot.types.InputMediaVideo'),
  KeyboardButton = require('bot.types.KeyboardButton'),
  LinkPreviewOptions = require('bot.types.LinkPreviewOptions'),
  ReplyKeyboardMarkup = require('bot.types.ReplyKeyboardMarkup'),
  ReplyKeyboardRemove = require('bot.types.ReplyKeyboardRemove'),
}

return types
