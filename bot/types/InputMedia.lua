--- InputMedia type builder.
-- See: https://core.telegram.org/bots/api#inputmedia
local json = require('json')

local function InputMedia(data)
  if not data then
    return nil
  end

  return json.encode(data)
end

return InputMedia
