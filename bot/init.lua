-- ----------------------------- --
-- Tarantool Telegram Bot API    --
-- By uriid1                     --
-- Licence MIT                   --
-- ----------------------------- --
--- @module bot
local bot = { _version = '2.0' }

package.path = package.path .. ';.rocks/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';.rocks/lib/lua/5.1/?.so'

local config = require('bot.config')
local processMessage = require('bot.processes.processMessage')
local log = require('bot.libs.logger')
local methods = require('bot.enums.methods')
local api = require('bot.api')
local cmds = require('bot.commands')
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
  self.logger = opts.logger or log
  self.commands = {}

  config.token = opts.token
  config.api_url = opts.api_url or config.api_url
  config.parse_mode = opts.parse_mode or config.parse_mode
  config.username = opts.username

  -- Log calls to undefined events
  self.events = setmetatable({}, {
    __index = function(_, key)
      return function ()
        log.warn(string.format('[Event] "%s" is not defined', key))
      end
    end
  })

  --- Wrap methods
  --
  api.wrapMethods(self)

  return self
end

-- API
bot.call = api.call
bot.sendImage = api.sendImage

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

function bot:startLongPolling(opts)
  return longpolling.start(self, opts, switch)
end

return bot
