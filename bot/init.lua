--- Telegram Bot API framework for Tarantool.
-- Licence: MIT
-- (C) 2026 uriid1 <github.com/uriid1>
-- @module bot
-- @pragma nostrip

--- Fields of the bot object.
-- Everything except _version is available after bot:cfg().
-- @table bot
-- @tfield string _version library version
-- @tfield string token bot token
-- @tfield string api_url Telegram Bot API base URL
-- @tfield string parse_mode default parse mode
-- @tfield ?string username bot username
-- @tfield table commands registered commands { [name] = command }, see utils.commandLoader
-- @tfield table events user-defined event handlers, see the Events section
-- @tfield table methods API method names, see enums.methods
-- @tfield table enums { allowed_updates = enums.allowed_updates }
-- @tfield ?table debug { host, port } of the debug server, set by bot:debugRoutes()
-- @tfield ?boolean maintenance opts.maintenance flag, set by bot:startWebHook()
local bot = { _version = '2.0' }

package.path = package.path .. ';.rocks/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ";.rocks/lib/tarantool/?.so;.rocks/lib/lua/5.1/?.so"

local log = require('log')
local api = require('bot.api')
local config = require('bot.config')
local methods = require('bot.enums.methods')
local cmds = require('bot.commands')
local processMessage = require('bot.processes.processMessage')
local allowed_updates = require('bot.enums.allowed_updates')
local longpolling = require('bot.transport.longpolling')
local webhook = require('bot.transport.webhook')
local debugTransport = require('bot.transport.debug')

-- Update handler passed to transports: wraps the raw update
-- into a typed object and calls bot.events.onGetUpdate
local switch = function (ctx)
  if bot.events.onGetUpdate then
    bot.events.onGetUpdate(processMessage(ctx))
  end
end

--- Initialize the bot with options.
-- Sets the bot object fields, resets bot.commands and bot.events
-- and exposes every Telegram Bot API method as bot:method(fields, opts).
-- @tparam table opts
-- @tparam string opts.token bot token
-- @tparam[opt] string opts.parse_mode parse mode, 'HTML' by default
-- @tparam[opt] string opts.api_url Telegram Bot API base URL
-- @tparam[opt] string opts.username bot username
-- @treturn table bot object
-- @usage
-- bot:cfg({
--   token = '1234567:AABBccDDFF...',
--   parse_mode = 'HTML',
-- })
function bot:cfg(opts)
  self.token = opts.token
  self.api_url = opts.api_url or config.api_url
  self.parse_mode = opts.parse_mode or config.parse_mode
  self.username = opts.username
  self.methods = methods
  self.commands = {}

  self.enums = {
    allowed_updates = allowed_updates
  }

  config.token = opts.token
  config.api_url = opts.api_url or config.api_url
  config.parse_mode = opts.parse_mode or config.parse_mode
  config.username = opts.username

  -- Log calls to undefined events
  self.events = setmetatable({}, {
    __index = function(_, key)
      return function ()
        log.verbose(string.format('[Event] "%s" is not defined', key))
      end
    end
  })

  -- Exposure of all Telegram API methods as bot:<method>()
  api.wrapMethods(self)

  return self
end

--- Strip trailing segments from a module or filesystem path.
-- Helper for building require paths relative to the caller.
-- @tparam number deep number of trailing segments to strip
-- @tparam string path module path ('a.b.c') or filesystem path
-- @treturn string path without the stripped segments
function bot.subdir(deep, ...)
  local sep
  local path = tostring(select(1, ...))

  if string.find(path, '/') then
    sep = '/'
  elseif string.find(path, '\\') then
    sep = '\\'
  else
    sep = '%.'
  end

  -- ^(.-)%.[%w%d_]+%.?$
  local re = "^(.-)"..sep..('[%w%d_]+'..sep):rep(deep).."?$"

  return path:match(re)
end

--- Execute a Telegram Bot API method, alias of api.call.
-- @function bot.call
-- @tparam string method API method to execute
-- @tparam[opt] table fields method fields
-- @tparam[opt] table opts options
-- @tparam[opt] boolean opts.multipart_post send fields as multipart/form-data
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @raise if method is nil
-- @see api.call
bot.call = api.call

--- Simplified wrapper over the sendPhoto method, alias of api.sendImage.
-- @function bot.sendImage
-- @tparam table data sendPhoto fields
-- @tparam[opt] string data.filepath path to a local image file
-- @tparam[opt] string data.url image URL
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @see api.sendImage
bot.sendImage = api.sendImage

local botId

--- Get the numeric bot id derived from the token.
-- @treturn ?number bot id, nil when the token is not set
function bot:getBotId()
  if not botId then
    botId = tonumber((self.token or ''):match('^%d+'))
  end

  return botId
end

--- Commands.
-- Low-level command resolvers, processes.processCommand is the full pipeline.
-- @section commands

--- Resolve a command from the message text.
-- @tparam table ctx message object
-- @treturn ?table command object from bot.commands, nil if the command is unknown
-- @treturn ?string bot username from the '/cmd@username' form, if present
-- @see commands.command
function bot.command(ctx)
  return cmds.command(bot, ctx)
end

--- Resolve a command from the callback query data.
-- @tparam table ctx callback query object
-- @treturn ?table command object from bot.commands, nil if the command is unknown
-- @see commands.callbackCommand
function bot.callbackCommand(ctx)
  return cmds.callbackCommand(bot, ctx)
end

--- Transport.
-- Every update is handled in its own fiber: the raw update is wrapped by
-- processes.processMessage and passed to bot.events.onGetUpdate.
-- @section transport

--- Start an HTTP server with custom routes while long polling is running.
-- @tparam table opts
-- @tparam[opt='0.0.0.0'] string opts.host host to bind to
-- @tparam[opt=9091] number opts.port port to listen on
-- @tparam[opt] table opts.routes routes { { path, method, callback }, ... }
-- @see transport.debug
-- @usage
-- bot:debugRoutes({
--   port = 9091,
--   routes = {
--     { path = '/twa', method = 'POST', callback = handler },
--   },
-- })
-- bot:startLongPolling()
function bot:debugRoutes(opts)
  return debugTransport.start(self, opts)
end

--- Start the webhook HTTP server and register the webhook.
-- @tparam table opts
-- @tparam string opts.url webhook URL (opts.bot_url is accepted as an alias)
-- @tparam[opt='0.0.0.0'] string opts.host host to bind to
-- @tparam[opt=9091] number opts.port port to listen on
-- @tparam[opt='/'] string opts.path route for incoming updates
-- @tparam[opt] string opts.certificate path to the self-signed certificate file
-- @tparam[opt=false] boolean opts.drop_pending_updates drop pending updates
-- @tparam[opt] table opts.allowed_updates list of allowed update types
-- @tparam[opt] table opts.routes extra routes { { path, method, callback }, ... }
-- @tparam[opt=false] boolean opts.maintenance value stored in bot.maintenance
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @see transport.webhook
-- @usage
-- bot:startWebHook({
--   url = 'https://example.com/webhook',
--   port = 9091,
--   path = '/webhook',
-- })
function bot:startWebHook(opts)
  return webhook.start(self, opts, switch)
end

--- Register the webhook, optionally with a self-signed certificate.
-- Returns nothing when opts are invalid or the certificate cannot be opened,
-- the reason is written to the log.
-- @tparam table opts
-- @tparam string opts.url webhook URL (opts.bot_url is accepted as an alias)
-- @tparam[opt] string opts.certificate path to the certificate file
-- @tparam[opt=false] boolean opts.drop_pending_updates drop pending updates
-- @tparam[opt] table opts.allowed_updates list of allowed update types
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @see transport.webhook
function bot:sendCertificate(opts)
  return webhook.sendCertificate(self, opts)
end

--- Start long polling.
-- Blocks the calling fiber in an endless getUpdates loop.
-- @tparam[opt] table opts
-- @tparam[opt=-1] number opts.offset initial update offset
-- @tparam[opt=60] number opts.timeout getUpdates timeout, seconds
-- @tparam[opt] table opts.allowed_updates list of allowed update types,
-- by default message, chat_member, my_chat_member, callback_query, pre_checkout_query
-- @tparam[opt=-1] number opts.max_connections http client connection limit
-- @see transport.longpolling
-- @see enums.allowed_updates
-- @usage
-- bot:startLongPolling({
--   allowed_updates = {
--     bot.enums.allowed_updates.MESSAGE,
--     bot.enums.allowed_updates.CALLBACK_QUERY,
--   },
-- })
function bot:startLongPolling(opts)
  return longpolling.start(self, opts, switch)
end

--- Events.
-- Handlers defined by the user on bot.events. A call to an undefined event
-- is safe: it returns a stub that writes to the log at the verbose level.
-- @section events

--- Called for every incoming update.
-- The only event the transport calls by itself, any other event
-- is defined and called by the user.
-- @function bot.events.onGetUpdate
-- @tparam table ctx typed update object: classes.Message, classes.CallbackQuery,
-- classes.ChatMember, classes.MyChatMember or classes.PreCheckoutQuery,
-- the raw update table for any other update type
-- @see processes.processMessage
-- @usage
-- function bot.events.onGetUpdate(ctx)
--   if ctx.callback_query then
--     return bot.events.onCallbackQuery(ctx)
--   elseif ctx.message then
--     return bot.events.onGetMessage(ctx)
--   end
-- end

--- Called by processes.processCommand before the command handler.
-- @function bot.events.preCallCommand
-- @tparam table ctx typed update object
-- @tparam table command command object, see classes.Command
-- @treturn ?boolean false cancels the command
-- @see processes.processCommand

--- Called by processes.processCommand after the command handler.
-- @function bot.events.postCallCommand
-- @tparam table ctx typed update object
-- @tparam table command command object, see classes.Command
-- @see processes.processCommand

--- API methods.
-- bot:cfg() exposes every method of enums.methods as bot:method(fields, opts),
-- a shortcut for api.call('method', fields, opts). The fields are the method
-- parameters from https://core.telegram.org/bots/api. On success the response is
-- returned, its result fields are reachable directly (res.message_id).
-- On failure nil and err are returned. The most used methods are listed below.
-- @section api_methods

--- Get basic information about the bot.
-- See https://core.telegram.org/bots/api#getme
-- @function bot:getMe
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Send a text message.
-- @function bot:sendMessage
-- @tparam table fields see https://core.telegram.org/bots/api#sendmessage
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Send a photo.
-- A local file is passed as libs.inputFile(path) with opts.multipart_post = true.
-- @function bot:sendPhoto
-- @tparam table fields see https://core.telegram.org/bots/api#sendphoto
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Send a general file.
-- A local file is passed as libs.inputFile(path) with opts.multipart_post = true.
-- @function bot:sendDocument
-- @tparam table fields see https://core.telegram.org/bots/api#senddocument
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Send a group of photos, videos, documents or audios as an album.
-- @function bot:sendMediaGroup
-- @tparam table fields see https://core.telegram.org/bots/api#sendmediagroup
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Show a chat action (typing, upload_photo, ...) to the user.
-- @function bot:sendChatAction
-- @tparam table fields see https://core.telegram.org/bots/api#sendchataction
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Edit the text of a message.
-- @function bot:editMessageText
-- @tparam table fields see https://core.telegram.org/bots/api#editmessagetext
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Edit only the reply markup of a message.
-- @function bot:editMessageReplyMarkup
-- @tparam table fields see https://core.telegram.org/bots/api#editmessagereplymarkup
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Delete a message.
-- @function bot:deleteMessage
-- @tparam table fields see https://core.telegram.org/bots/api#deletemessage
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Answer a callback query sent from an inline keyboard.
-- @function bot:answerCallbackQuery
-- @tparam table fields see https://core.telegram.org/bots/api#answercallbackquery
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Change the reactions on a message.
-- @function bot:setMessageReaction
-- @tparam table fields see https://core.telegram.org/bots/api#setmessagereaction
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Get up-to-date information about a chat.
-- @function bot:getChat
-- @tparam table fields see https://core.telegram.org/bots/api#getchat
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Get information about a member of a chat.
-- @function bot:getChatMember
-- @tparam table fields see https://core.telegram.org/bots/api#getchatmember
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Ban a user in a group, a supergroup or a channel.
-- @function bot:banChatMember
-- @tparam table fields see https://core.telegram.org/bots/api#banchatmember
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Restrict a user in a supergroup.
-- @function bot:restrictChatMember
-- @tparam table fields see https://core.telegram.org/bots/api#restrictchatmember
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Change the list of the bot commands.
-- @function bot:setMyCommands
-- @tparam table fields see https://core.telegram.org/bots/api#setmycommands
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Send an invoice.
-- @function bot:sendInvoice
-- @tparam table fields see https://core.telegram.org/bots/api#sendinvoice
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Respond to a pre-checkout query.
-- @function bot:answerPreCheckoutQuery
-- @tparam table fields see https://core.telegram.org/bots/api#answerprecheckoutquery
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

--- Refund a successful payment in Telegram Stars.
-- @function bot:refundStarPayment
-- @tparam table fields see https://core.telegram.org/bots/api#refundstarpayment
-- @tparam[opt] table opts see api.call
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err

return bot
