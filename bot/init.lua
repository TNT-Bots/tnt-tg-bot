--- Telegram Bot API framework for Tarantool.
-- Licence: MIT
-- (C) 2026 uriid1 <github.com/uriid1>
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

local switch = function (ctx)
  if bot.events.onGetUpdate then
    bot.events.onGetUpdate(processMessage(ctx))
  end
end

--- Initialize the bot with options.
-- @tparam table opts
-- @tparam[opt] string opts.token bot token
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

-- API
bot.call = api.call
bot.sendImage = api.sendImage

local botId

--- Get the numeric bot id derived from the token.
-- @treturn number bot id
function bot:getBotId()
  if not botId then
    botId = tonumber((self.token or ''):match('^%d+'))
  end

  return botId
end

-- Commands
function bot.command(ctx)
  return cmds.command(bot, ctx)
end

function bot.callbackCommand(ctx)
  return cmds.callbackCommand(bot, ctx)
end

-- Transport
function bot:debugRoutes(opts)
  return debugTransport.start(self, opts)
end

function bot:startWebHook(opts)
  return webhook.start(self, opts, switch)
end

function bot:sendCertificate(opts)
  return webhook.sendCertificate(self, opts)
end

function bot:startLongPolling(opts)
  return longpolling.start(self, opts, switch)
end

return bot
