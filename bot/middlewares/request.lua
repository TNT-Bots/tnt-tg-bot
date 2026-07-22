--- HTTP transport for requests to the Telegram Bot API.
local config = require('bot.config')
local request = {}

local log = require('log')
local json = require('json')
local http = require('http.client')
local fiber = require('fiber')
local mpEncode = require('multipart-post')

local MAX_RETRIES = 3
local API_URL_FMT = config.api_url..'%s/%s'

-- Outbound request timeout, seconds.
-- Tarantool's http.client defaults to an effectively infinite timeout.
-- Without a limit a hung connection to the Telegram API blocks
-- the calling fiber forever, and such fibers pile up over time.
local REQUEST_TIMEOUT = 25

local function build_body(params)
  local opts = {}
  local body

  if params.fields then
    -- Default parse mode for text and caption payloads
    if params.fields.text or params.fields.caption then
      if not params.fields.parse_mode then
        params.fields.parse_mode = config.parse_mode
      end
    end

    -- Multipart encoding for file uploads, JSON otherwise
    if params.is_multipart or params.multipart then
      local boundary
      body, boundary = mpEncode(params.fields)

      opts.headers = {
        ['Content-Type'] = 'multipart/form-data; boundary=' .. boundary,
      }
    else
      body = json.encode(params.fields)

      opts.headers = {
        ['Content-Type'] = 'application/json'
      }
    end
  end

  return body, opts
end

--- Send an HTTP request to the Telegram Bot API.
-- @tparam table params
-- @tparam string params.method API method name
-- @tparam[opt] table params.fields method fields
-- @tparam[opt] boolean params.is_multipart encode fields as multipart/form-data
-- @treturn[1] table decoded API response
-- @treturn[2] table err
function request.send(params)
  local body, opts = build_body(params)
  opts.timeout = REQUEST_TIMEOUT

  local url = API_URL_FMT:format(config.token, params.method)

  -- Retry only for network errors.
  for attempt = 1, MAX_RETRIES do
    local raw = http.post(url, body, opts)

    if raw.body == nil then
      if attempt < MAX_RETRIES then
        local delay = math.pow(2, attempt - 1)

        log.warn('[Request] Network error, retry after %ds (attempt %d/%d)',
          delay, attempt, MAX_RETRIES)

        fiber.sleep(delay)
      else
        if raw.ok == false then
          local err = raw
          err.__method = params.method

          return nil, err
        end

        return nil, {
          description = 'Empty data received',
          __method = params.method
        }
      end
    else
      local data = json.decode(raw.body)

      if data.ok == false then
        data.__method = params.method
        return nil, data
      end

      -- Proxy: data.result fields are reachable directly on data.
      -- tg: data.result.object.key
      -- proxy: data.object.key
      setmetatable(data, {
        __index = function(t, key)
          if key == nil then
            return rawget(t, 'result')
          end

          local _raw_t = rawget(t, 'result')
          if _raw_t and _raw_t[key] then
            return _raw_t[key]
          end
        end,

        __newindex = function(tbl, key, value)
          rawget(tbl, 'result')[key] = value
        end,
      })

      return data, nil
    end
  end
end

return request
