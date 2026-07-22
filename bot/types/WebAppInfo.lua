--- WebAppInfo type builder.
-- See: https://core.telegram.org/bots/api#webappinfo
--

--- Build a WebAppInfo object.
-- @tparam string|table data HTTPS URL of the Web App, or { url = ... }
-- @treturn ?table WebAppInfo, nil when data is missing
local function WebAppInfo(data)
  if not data then
    return nil
  end

  if type(data) == 'table' then
    return { url = tostring(data.url) }
  end

  return { url = tostring(data) }
end

return WebAppInfo
