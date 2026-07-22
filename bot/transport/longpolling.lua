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

    if res and res.body == nil then
      log.verbose('[Long Polling] Empty body received | Status: %s | Reason: %s',
        res.status, res.reason)

      log.verbose('[Server] timeout')
      fiber.sleep(1)

      goto continue
    end

    local body = json.decode(res.body)

    if body.ok == false then
      log.error(res)
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
