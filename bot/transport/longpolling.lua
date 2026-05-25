--- Long polling transport
-- @module bot.transport.longpolling
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

--- Start long polling
--
-- @param bot (table) Bot object
-- @param opts (table) Options table
-- @param switch (function) Update handler
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
