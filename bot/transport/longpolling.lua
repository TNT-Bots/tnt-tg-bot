--- Long polling transport.
local log = require('log')
local json = require('json')
local fiber = require('fiber')

local longpolling = {}

local DEFAULT_ALLOWED_UPDATES = {
  'message',
  'chat_member',
  'my_chat_member',
  'callback_query',
  'pre_checkout_query'
}

--- Start long polling.
-- Blocks the calling fiber in an endless getUpdates loop.
-- @tparam table bot bot object
-- @tparam[opt] table opts
-- @tparam[opt=-1] number opts.offset initial update offset
-- @tparam[opt=60] number opts.timeout getUpdates timeout, seconds
-- @tparam[opt] table opts.allowed_updates list of allowed update types
-- @tparam[opt=-1] number opts.max_connections http client connection limit
-- @tparam function switch update handler
function longpolling.start(bot, opts, switch)
  opts = opts or {}

  local offset = opts.offset or -1
  local timeout = opts.timeout or 60
  local allowed_updates = json.encode(opts.allowed_updates or DEFAULT_ALLOWED_UPDATES)

  local http = require('http.client')
  local client = http.new({
    max_connections = opts.max_connections or -1
  })

  log.info('[Long Polling] %s', 'Running | Updates: ' .. allowed_updates)

  while true do
    local url = {
      bot.api_url, bot.token,
      '/getUpdates?offset=', offset,
      '&timeout=', timeout,
      '&allowed_updates=', allowed_updates
    }

    local res = client:request('GET', table.concat(url))

    if res == nil or res.body == nil then
      log.verbose('[Long Polling] Empty body received | Status: %s | Reason: %s',
        res and res.status, res and res.reason)

      log.verbose('[Server] timeout')
      fiber.sleep(1)

      goto continue
    end

    -- Non-JSON body (e.g. an HTML error page from a proxy) must not kill the loop
    local decoded, body = pcall(json.decode, res.body)
    if not decoded then
      log.error('[Long Polling] Body decode failed: %s', body)
      fiber.sleep(1)

      goto continue
    end

    if body.ok == false then
      log.error(res)

      -- Pause before the retry, otherwise a persistent API error turns into a busy loop
      fiber.sleep(1)
    else
      if body.result then
        for i = 1, #body.result do
          local data = body.result[i]

          fiber.create(function ()
            switch(data)
          end)

          offset = data.update_id + 1
        end
      end
    end

    ::continue::
  end
end

return longpolling
