--- Module for making HTTP requests to the Telegram Bot API.
-- @module bot.middlewares.request
local config = require('bot.config')
local request = {}

local json = require('json')
local http = require('http.client')
local fiber = require('fiber')
local log = require('bot.libs.logger')
local mpEncode = require('multipart-post')

local MAX_RETRIES = 3

local function build_body(params)
  local opts = {}
  local body

  if params.fields then
    -- Set parse mode
    if params.fields.text or params.fields.caption then
      if not params.fields.parse_mode then
        params.fields.parse_mode = config.parse_mode
      end
    end

    -- Make multipart-data
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
-- @param params The request parameters.
-- @return The response from the API, or nil if there was an error.
function request.send(params)
  local body, opts = build_body(params)

  local urlFmt = config.api_url..'%s/%s'
  local url = urlFmt:format(config.token, params.method)

  for attempt = 1, MAX_RETRIES do
    local raw = http.post(url, body, opts)

    -- Network error (no body)
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

        return nil, { description = 'Empty data received', __method = params.method }
      end
    else
      local data = json.decode(raw.body)

      -- Rate limited (429)
      if data.ok == false and data.error_code == 429 then
        if attempt < MAX_RETRIES then
          local retry_after = data.parameters
            and data.parameters.retry_after or 1

          log.warn('[Request] 429 Too Many Requests, retry after %ds (attempt %d/%d)',
            retry_after, attempt, MAX_RETRIES)

          fiber.sleep(retry_after)
        else
          data.__method = params.method
          return nil, data
        end

      -- Other errors
      elseif data.ok == false then
        local err = data
        err.__method = params.method
        return nil, err

      -- Success
      else
        -- Proxy
        -- tg: data.result.object.key
        -- proxy: result.object.key
        --
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

  return nil, { ok = false, description = 'Max retries exceeded', __method = params.method }
end

return request
