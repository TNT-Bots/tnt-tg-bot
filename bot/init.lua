-- ----------------------------- --
-- Tarantool Telegram Bot API    --
-- By uriid1                     --
-- Licence MIT                   --
-- ----------------------------- --
--- @module bot
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

--- Initializes the bot with opts
--
-- @param opts (table) opts
  -- @param[opt] opts.token (string) Bot token
  -- @param[opt] opts.parse_mode (string) Parse mode. HTML by default
  -- @param[opt] opts.api_url (string)
-- @usage
-- bot:cfg {
--  token = '1234567:AABBccDDFF...',
--  parse_mode = 'HTML' -- Default: 'HTML'
-- }
--
-- @return bot object
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

  --- Wrap methods
  --
  api.wrapMethods(self)

  return self
end

--- Helper for require
-- @param deep (number)
-- @param (path|any)
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
--- Helper for get bot id
function bot:getBotId()
  if not botId then
    botId = tonumber((self.token or ''):match('^%d+'))
  end

  return botId
end

-- Commands
function bot.Command(ctx)
  return cmds.Command(bot, ctx)
end

function bot.CallbackCommand(ctx)
  return cmds.CallbackCommand(bot, ctx)
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
