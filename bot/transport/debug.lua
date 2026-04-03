--- Debug HTTP server
-- @module bot.transport.debug
local log = require('bot.libs.logger')

local debug = {}

--- Debug routes while Long Polling is running
-- @param bot (table) Bot object
-- @param opts (table) Options table
  -- @param opts.host (string) Host to bind to (default is '0.0.0.0')
  -- @param opts.port (number) Port to listen on (default is 9091)
  -- @param opts.routes (table) Routes table
function debug.start(bot, opts)
  local http_server = require('http.server')
  local host = opts.host or '0.0.0.0'
  local port = opts.port or 9091
  local httpd = http_server.new(host, port)

  -- Declaration custom routes
  if opts.routes then
    for i = 1, #opts.routes do
      local route = opts.routes[i]

      httpd:route(
        {
          path = route.path,
          method = route.method
        },
        route.callback
      )
    end
  end

  httpd:start()

  if not bot.debug then
    bot.debug =  {}
  end

  bot.debug = {
    host = host,
    port = port
  }

  log.info('[HTTP Server] %s', 'listening', host..':'..port)
end

return debug
