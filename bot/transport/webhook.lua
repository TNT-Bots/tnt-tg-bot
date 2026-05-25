--- Webhook transport
-- @module bot.transport.webhook
local log = require('log')
local fio = require('fio')
local json = require('json')
local fiber = require('fiber')

local webhook = {}

--- Sends a certificate for webhook setup
--
-- @param bot (table) Bot object
-- @param opts (table) Options table
  -- @param opts.url (string) URL for the webhook
  -- @param opts.certificate (string) Path to the certificate file
  -- @param opts.drop_pending_updates (boolean) Whether to drop pending updates (false by default)
  -- @param opts.allowed_updates (table) List of allowed updates (nil by default)
--
-- @return (table) Response data
function webhook.sendCertificate(bot, opts)
  if type(opts) ~= 'table' or
    type(opts.bot_url) ~= 'string'
  then
    log.error('[WebHook] %s', 'Invalid opts')

    return
  end

  -- Read certificate
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

  -- Set webhook
  return bot.call('setWebhook', {
    url = opts.bot_url,
    certificate = data,
    drop_pending_updates = opts.drop_pending_updates or false,
    allowed_updates = opts.allowed_updates
  }, { multipart_post = true })
end

--- Start the webhook
--
-- @param bot (table) Bot object
-- @param opts (table) Options table
-- @param switch (function) Update handler
function webhook.start(bot, opts, switch)
  local http_server = require('http.server')
  local host = opts.host or '0.0.0.0'
  local port = opts.port or 9091
  local httpd = http_server.new(host, port)

  bot.maintenance = not not opts.maintenance

  -- Bot route setup
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

  -- Declaration custom routes
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
      url = opts.bot_url,
      drop_pending_updates = opts.drop_pending_updates or false,
      allowed_updates = opts.allowed_updates
    })
  end
end

return webhook
