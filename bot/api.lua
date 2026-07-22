--- Telegram Bot API client.
local request = require('bot.middlewares.request')
local inputFile = require('bot.libs.inputFile')
local methods = require('bot.enums.methods')

local api = {}

--- Execute a Telegram Bot API method.
-- @tparam string method API method to execute
-- @tparam table fields method fields
-- @tparam[opt] table opts options
-- @tparam[opt] boolean opts.multipart_post send fields as multipart/form-data
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
-- @usage
-- bot.call('sendMessage', {
--   text = 'Hello!',
--   chat_id = 123456789,
-- })
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

--- Simplified wrapper over the sendPhoto method.
-- @tparam table data sendPhoto fields
-- @tparam[opt] string data.filepath path to a local image file
-- @tparam[opt] string data.url image URL
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

--- Wrap all Telegram API methods onto the bot object.
-- After the call every method is available as bot:<method>(fields, opts).
-- @tparam table bot bot object
function api.wrapMethods(bot)
  for method, _ in pairs(methods) do
    bot[method] = function (_, fields, opts)
      return api.call(method, fields, opts)
    end
  end
end

return api
