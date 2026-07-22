--- Local file reader for multipart uploads.
local fio = require('fio')
local log = require('log')

--- Read a local file into the format expected by multipart upload.
-- @tparam string filename path to the file
-- @treturn ?table { data = <content>, filename = <path> }, nil if unreadable
local function inputFile(filename)
  if type(filename) ~= 'string' then
    return nil
  end

  local fd = fio.open(filename, 'O_RDONLY')

  if fd == nil then
    log.error('Cannot open file: ' .. filename)

    return nil
  end

  local data = fd:read()
  fd:close()

  return {
    data = data,
    filename = filename
  }
end

return inputFile
