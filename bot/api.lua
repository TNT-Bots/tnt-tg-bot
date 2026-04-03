--- API client module
-- @module bot.api
local request = require('bot.middlewares.request')
local inputFile = require('bot.libs.inputFile')
local methods = require('bot.enums.methods')

local api = {}

--- Executes a Telegram Bot API method.
--
-- @param method (string) TG API method to execute
-- @param fields (table) Method fields
-- @param opts (table) Options
-- @param[optchain] opts.request_param (table) { multipart_post = true }
--
-- @usage
-- bot.call("sendMessage", {
--  text = 'Hello!',
--  chat_id = 123456789,
-- })
--
-- @return (table) Response from the Telegram Bot API
-- @return (table) Error object
function api.call(method, fields, opts)
  if method == nil then
    error('bot.call method is nil')
  end

  local params = {
    method = method,
    fields = fields,
  }

  if opts and opts.multipart_post then
    params.is_multipart = true
  end

  return request.send(params)
end

--- A simplified version of the sendPhoto method
--
-- @param data (table) Method fields
-- @param data.filepath Path to image
-- @param data.url URL to image
function api.sendImage(data)
  if data.filepath then
    data.photo = inputFile(data.filepath)
    data.filepath = nil
  elseif data.url then
    data.photo = data.url
    data.url = nil
  end

  api.call(methods.sendPhoto, data, { multipart_post = true })
end

--- Wraps all Telegram API methods onto the bot object
--
-- @param bot (table) Bot object
function api.wrapMethods(bot)
  for method, _ in pairs(methods) do
    bot[method] = function (_, fields, opts)
      return api.call(method, fields, opts)
    end
  end
end

return api
