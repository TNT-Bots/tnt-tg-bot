--- SQL helpers over box.execute (Tarantool 3.x only).
local log = require('log')
local uuid = require('uuid')

if _TARANTOOL then
  local ver = tonumber(_TARANTOOL:match('(%d)%.'))
  if ver and ver < 3 then
    error('Module SQL support tarantool > 3.x only')
  end
end

-- TODO: switch to bound parameters via box.execute(sql, extra-parameters).
-- Tarantool supports and recommends them directly.

local function escape(value)
  return string.format("'%s'", value:gsub("'", "''"))
end

local function cast(value, field_type)
  if field_type == 'uuid' then
    return string.format("CAST('%s' AS UUID)", value)

  elseif field_type == 'string' then
    return string.format("CAST(%s AS STRING)", escape(value))

  elseif field_type == 'boolean' then
    return string.format("CAST(%s AS BOOLEAN)", value and 'TRUE' or 'FALSE')
  end

  -- TODO: array, map, int, ...
  -- See: https://www.tarantool.io/en/doc/latest/reference/reference_sql/sql_user_guide/#operand-data-types

  return value
end

-- SQL-safe representation of a Lua value (uuid cdata included)
local function castValue(value)
  local _type = type(value)

  if _type == 'cdata' then
    if uuid.is_uuid(value) then
      return cast(tostring(value), 'uuid')
    end

    return value
  end

  return cast(value, _type)
end

local sql = {}

--- Execute an SQL query.
-- ${name} placeholders are substituted with escaped values.
-- @tparam string sql_query SQL string
-- @tparam[opt] table values placeholder values
-- @treturn[1] table rows mapped to field names
-- @treturn[2] table err
-- @usage
-- local rows = sql.execute('SELECT * FROM SEQSCAN users WHERE name = ${name}', { name = 'Alex' })
-- if rows == nil then
--   log.error('No rows')
-- end
function sql.execute(sql_query, values)
  local query
  if values then
    local castValues = {}
    for key, value in pairs(values) do
      castValues[key] = castValue(value)
    end

    query = string.gsub(sql_query, "%${([%w_]+)}", castValues)
  end

  log.verbose('[SQL] %s', '\n'..(query or sql_query):gsub('(\n+)', '\n'))

  local result, err = box.execute(query or sql_query)
  if err then
    return nil, err
  end
  if result == nil then
    return nil, err
  elseif result.rows and next(result.rows) == nil then
    return nil, err
  end

  -- Result mapping: positional tuple -> { field_name = value }
  local metadata = result.metadata
  local rows = {}
  if result.rows then
    for _, row in ipairs(result.rows) do
      local mapped_row = {}
      for i, value in ipairs(row) do
        local field_name = metadata[i].name
        mapped_row[field_name] = value
      end

      table.insert(rows, mapped_row)
    end
  end

  return rows, nil
end

--- Insert a record.
-- @tparam string space space name
-- @tparam table fields { field_name = value, ... }
-- @treturn[1] table box.execute result
-- @treturn[2] table err
function sql.create(space, fields)
  if box.space[space] == nil then
    error(('Space: %s not found'):format(space), 1)
  end
  if fields == nil then
    error('fields == nil', 1)
  end

  local query = {
    [[INSERT INTO ]],
    space,
    [[ VALUES (]]
  }
  local data = {}
  local values = {}
  local spaceFormat = box.space[space]:format()

  for i = 1, #spaceFormat do
    local format = spaceFormat[i]
    local fieldName = format.name
    local fieldValue = fields[fieldName]

    if fieldValue == box.NULL then
      if not format.is_nullable then
        error(('Field %s is required'):format(fieldName), 1)
      end
    end

    local part = ':'..fieldName
    table.insert(values, part)
    table.insert(data, { [part] = fieldValue })
  end

  table.insert(query, table.concat(values, ', '))
  table.insert(query, ');')

  local sqlQuery = table.concat(query)
  log.verbose('[SQL] %s', '\n'..sqlQuery:gsub('(\n+)', '\n'))

  return box.execute(sqlQuery, data)
end

--- Update record(s).
-- @tparam string space space name
-- @tparam table fields columns to update
-- @tparam table where where condition(s)
-- @treturn[1] table box.execute result
-- @treturn[2] table err
function sql.update(space, fields, where)
  if box.space[space] == nil then
    error(('Space: %s not found'):format(space), 1)
  end
  if fields == nil then
    error('fields == nil', 1)
  end
  if where == nil then
    error('where == nil', 1)
  end

  local data = {}
  local setParts = {}

  for key, value in pairs(fields) do
    local part = ':'..key
    table.insert(setParts, ('%s = %s'):format(key, part))
    table.insert(data, { [part] = value })
  end

  local whereParts = {}
  for key, value in pairs(where) do
    table.insert(whereParts, ('%s = %s'):format(key, castValue(value)))
  end

  local query = {
    [[UPDATE ]] .. space .. [[ SET ]],
    table.concat(setParts, ', '),
    [[ WHERE ]],
    table.concat(whereParts, ' AND '),
    [[;]]
  }

  local sqlQuery = table.concat(query)
  log.verbose('[SQL] %s', '\n'..sqlQuery:gsub('(\n+)', '\n'))

  return box.execute(sqlQuery, data)
end

--- Update a record by primary key via box.space:update (NoSQL API).
-- Unlike sql.update it works with map/array/any Tarantool types.
-- SQL UPDATE cannot handle them (see map limitations in SQL).
-- where MUST contain every primary key field.
-- @tparam string space space name
-- @tparam table fields { field_name = new_value, ... }
-- @tparam table where full primary key { pk_field = value, ... }
-- @treturn[1] boolean true
-- @treturn[2] table err
function sql.update_nosql(space, fields, where)
  if box.space[space] == nil then
    error(('Space: %s not found'):format(space), 1)
  end
  if fields == nil then
    error('fields == nil', 1)
  end
  if where == nil then
    error('where == nil', 1)
  end

  local space_obj = box.space[space]

  -- Primary key extraction from where in index part order
  local primary_index = space_obj.index[0]
  if primary_index == nil then
    error(('Space: %s has no primary index'):format(space), 1)
  end

  local space_format = space_obj:format()
  local key = {}
  for i, part in ipairs(primary_index.parts) do
    local field_name = part.field or space_format[part.fieldno].name
    local value = where[field_name]
    if value == nil then
      error(('where missing primary key field: %s'):format(field_name), 1)
    end
    key[i] = value
  end

  -- Assignment operations: { '=', field_name, value }
  local ops = {}
  for field_name, value in pairs(fields) do
    table.insert(ops, { '=', field_name, value })
  end

  log.verbose('[box] %s:update', space)

  local ok, err = pcall(space_obj.update, space_obj, key, ops)
  if not ok then
    return nil, err
  end

  return true, nil
end

--- Upsert a record (atomic insert or update by primary key).
-- Uses box.space:upsert() directly.
-- If the record does not exist - inserts default_fields as a full tuple.
-- If the record exists - applies update operations only to update_fields.
-- @tparam string space space name
-- @tparam table default_fields full record for the insert case
-- @tparam table update_fields fields to update if the record exists
-- @treturn[1] boolean true
-- @treturn[2] table err
function sql.upsert(space, default_fields, update_fields)
  if box.space[space] == nil then
    error(('Space: %s not found'):format(space), 1)
  end
  if default_fields == nil then
    error('default_fields == nil', 1)
  end
  if update_fields == nil then
    error('update_fields == nil', 1)
  end

  local spaceFormat = box.space[space]:format()

  -- Build full tuple for insert case
  local tuple = {}
  for i = 1, #spaceFormat do
    local format = spaceFormat[i]
    local fieldValue = default_fields[format.name]

    if fieldValue == nil or fieldValue == box.NULL then
      tuple[i] = box.NULL
    else
      tuple[i] = fieldValue
    end
  end

  -- Build update operations for existing record
  local ops = {}
  for i = 1, #spaceFormat do
    local format = spaceFormat[i]
    local fieldValue = update_fields[format.name]

    if fieldValue ~= nil then
      table.insert(ops, { '=', i, fieldValue })
    end
  end

  log.verbose('[SQL] upsert into %s', space)

  local ok, err = pcall(box.space[space].upsert, box.space[space], tuple, ops)
  if not ok then
    return nil, err
  end

  return true, nil
end

--- Run several operations atomically in one transaction.
-- If any operation inside fn fails, all changes are rolled back.
-- fn must raise error() on failure for the rollback to trigger.
-- The sql.check() helper simplifies that.
-- @tparam function fn
-- @treturn[1] boolean true
-- @treturn[2] table err
-- @usage
-- local ok, err = sql.atomic(function()
--   sql.check(sql.create('users', userData))
--   sql.check(sql.create('user_credentials', credentials))
--   sql.check(sql.create('sessions', session))
-- end)
--
-- if err then
--   -- all operations are rolled back
-- end
function sql.atomic(fn)
  local ok, err = pcall(box.atomic, fn)

  if not ok then
    return nil, err
  end

  return true, nil
end

--- Check an SQL operation result inside sql.atomic.
-- Raises error on failure so that the transaction rolls back.
-- @tparam any result first return value of sql.create/sql.execute/sql.update
-- @tparam any err second return value (error)
-- @treturn any result
function sql.check(result, err)
  if err then
    error(err, 2)
  end

  return result
end

setmetatable(sql, {
  __call = function(_, ...)
    return sql.execute(...)
  end
})

return sql
