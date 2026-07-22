--- Webhook transport.
local log = require('log')
local fio = require('fio')
local json = require('json')
local fiber = require('fiber')

local webhook = {}

--- Register the webhook, optionally with a self-signed certificate.
-- @tparam table bot bot object
-- @tparam table opts
-- @tparam string opts.url webhook URL (opts.bot_url is accepted as an alias)
-- @tparam[opt] string opts.certificate path to the certificate file
-- @tparam[opt=false] boolean opts.drop_pending_updates drop pending updates
-- @tparam[opt] table opts.allowed_updates list of allowed update types
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
function webhook.sendCertificate(bot, opts)
  if type(opts) ~= 'table' or
    type(opts.bot_url or opts.url) ~= 'string'
  then
    log.error('[WebHook] %s', 'Invalid opts')

    return
  end

  -- Certificate read
  local data
  if opts.certificate then
    if not fio.path.exists(opts.certificate) then
      log.error('[WebHook] %s', 'Certificate not found: '..opts.certificate)

      return
    end

    local cert = fio.open(opts.certificate, 'O_RDONLY')

    data = {
      filename = opts.certificate:match('[^/]*.$'),
      data = cert:read()
    }

    cert:close()
  end

  if type(opts.allowed_updates) == 'table' then
    opts.allowed_updates = json.encode(opts.allowed_updates)
  end

  -- Webhook registration
  return bot.call('setWebhook', {
    url = opts.bot_url or opts.url,
    certificate = data,
    drop_pending_updates = opts.drop_pending_updates or false,
    allowed_updates = opts.allowed_updates
  }, { multipart_post = true })
end

--- Start the webhook HTTP server and register the webhook.
-- @tparam table bot bot object
-- @tparam table opts
-- @tparam[opt='0.0.0.0'] string opts.host host to bind to
-- @tparam[opt=9091] number opts.port port to listen on
-- @tparam[opt='/'] string opts.path route for incoming updates
-- @tparam string opts.url webhook URL (opts.bot_url is accepted as an alias)
-- @tparam[opt] string opts.certificate path to the certificate file
-- @tparam[opt] table opts.routes extra routes { path, method, callback }
-- @tparam function switch update handler
-- @treturn[1] table response from the Telegram Bot API
-- @treturn[2] table err
function webhook.start(bot, opts, switch)
  local http_server = require('http.server')
  local host = opts.host or '0.0.0.0'
  local port = opts.port or 9091
  local httpd = http_server.new(host, port)

  bot.maintenance = not not opts.maintenance

  -- Bot update route setup
  --
  local function default_callback(req)
    fiber.create(function ()
      switch(req:json())
    end)

    return {
      status = 200
    }
  end

  httpd:route({
    path = opts.path or '/',
    method = 'POST',
  }, default_callback)
  --

  -- Custom route declaration
  if opts.routes then
    for i = 1, #opts.routes do
      local route = opts.routes[i]

      httpd:route({
        path = route.path,
        method = route.method
      }, route.callback)
    end
  end

  httpd:start()

  log.info('[HTTP Server] Listening | Host: %s | Port: %d', host, port)

  if opts.certificate then
    return webhook.sendCertificate(bot, opts)
  else
    return bot.call('setWebhook', {
      url = opts.bot_url or opts.url,
      drop_pending_updates = opts.drop_pending_updates or false,
      allowed_updates = opts.allowed_updates
    })
  end
end

return webhook
