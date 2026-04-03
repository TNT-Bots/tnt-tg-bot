--- https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app
-- @module bot.libs.parseInitData
local openssl_hmac = require('openssl.hmac')
local json = require('json')

local function parse_query(query)
  local parsed = {}
  for key, value in query:gmatch("([^&=]+)=([^&]*)") do
    parsed[key] = value
  end

  return parsed
end

local function url_decode(str)
  return (str:gsub("%%([0-9a-fA-F][0-9a-fA-F])", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

-- Validating data received via the mini app
--- @param init_data (string)
--- @param bot_token (string)
local function parseInitData(init_data, bot_token)
  -- Parse the init_data query string
  local parsed = parse_query(init_data)
  local received_hash = parsed.hash or ""
  parsed.hash = nil

  -- Try to parse user field as JSON if present
  local userData
  if parsed.user then
    local user = url_decode(parsed.user)
    userData = json.decode(user)
  end

  -- Sort keys alphabetically
  local keys = {}
  for k in pairs(parsed) do
    table.insert(keys, k)
  end
  table.sort(keys)

  -- Build data_check_string: key=value pairs joined by \n
  local parts = {}
  for _, key in ipairs(keys) do
    table.insert(parts, key .. "=" .. url_decode(parsed[key]))
  end
  local data_check_string = table.concat(parts, "\n")

  -- Compute secret key: HMAC_SHA256(bot_token, "WebAppData")
  local secret_hmac = openssl_hmac.new("WebAppData", "sha256")
  secret_hmac:update(bot_token)
  local secret_key = secret_hmac:final()  -- binary string

  -- Compute HMAC of data_check_string with secret_key
  local hmac_obj = openssl_hmac.new(secret_key, "sha256")
  hmac_obj:update(data_check_string)
  local calc_hash_bin = hmac_obj:final()  -- binary string

  -- Convert binary hash to lowercase hex string
  local expected_hash = calc_hash_bin:gsub('.', function(c)
    return string.format('%02x', string.byte(c))
  end)

  return {
    valid = (expected_hash == string.lower(received_hash)),
    userData = userData,
  }
end

return parseInitData
