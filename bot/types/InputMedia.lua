--- InputMedia type builder.
-- See: https://core.telegram.org/bots/api#inputmedia
local json = require('json')

--- Encode an InputMedia table as JSON.
-- @tparam table data InputMedia fields
-- @treturn ?string JSON string, nil when data is missing
local function InputMedia(data)
  if not data then
    return nil
  end

  return json.encode(data)
end

return InputMedia
