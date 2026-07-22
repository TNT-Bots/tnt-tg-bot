--- Debug HTTP server.
local log = require('log')

local _debug = {}

--- Start an HTTP server with debug routes while long polling is running.
-- @tparam table bot bot object
-- @tparam table opts
-- @tparam[opt='0.0.0.0'] string opts.host host to bind to
-- @tparam[opt=9091] number opts.port port to listen on
-- @tparam[opt] table opts.routes routes { path, method, callback }
function _debug.start(bot, opts)
  local http_server = require('http.server')
  local host = opts.host or '0.0.0.0'
  local port = opts.port or 9091
  local httpd = http_server.new(host, port)

  -- Custom route declaration
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

  bot.debug = {
    host = host,
    port = port
  }

  log.info('[HTTP Server] %s %s', 'listening', host..':'..port)
end

return _debug
