--- Wrapper for execute sql (tarantool > 3.x only)
-- @module bot.ext.sql
local log = require('log')
local uuid = require('uuid')

if _TARANTOOL then
  local ver = tonumber(_TARANTOOL:match('(%d)%.'))
  if ver and ver < 3 then
    error('Module SQL support tarantool > 3.x only')
  end
end

-- TODO: Tarantool прямо поддерживает и рекомендует передачу параметров -
-- через box.execute(sql, extra-parameters)

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

local sql = {}

--- Execute sql query
-- @param sql_query (string) SQL string
-- @param values (table) Table of values
-- @return[1] result
-- @return[1] error
-- @usage
  -- local rows = sql.execute("SELECT * FROM SEQSCAN users WHERE name = ${name}", { name = 'Alex' })
  -- if rows == nil then
  --   log.error('No rows')
  -- end
function sql.execute(sql_query, values)
  local query
  if values then
    local castValues = {}
    for key, value in pairs(values) do
      local _type = type(value)
      if _type == 'cdata' then
        if uuid.is_uuid(value) then
          castValues[key] = cast(tostring(value), 'uuid')
        end
      else
        castValues[key] = cast(value, _type)
      end
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

  -- Mapping result
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

--- Create record
-- @param space (string) space
-- @param fields (table)
-- @return[1] result
-- @return[1] error
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
        error(('Field %s not required'):format(fieldName), 1)
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

--- Update record(s)
-- @param space (string) space name
-- @param fields (table) columns to update
-- @param where (table) where condition(s)
-- @return[1] result
-- @return[2] error
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
    table.insert(whereParts, ('%s = %s'):format(key, cast(value)))
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

--- Update record by primary key через box.space:update (NoSQL API).
-- В отличие от sql.update работает с map/array/любыми типами Tarantool —
-- SQL UPDATE для них непригоден (см. ограничения map в SQL).
-- where ДОЛЖЕН содержать все поля первичного ключа.
-- @param space (string) space name
-- @param fields (table) { field_name = new_value, ... }
-- @param where (table) полный первичный ключ { pk_field = value, ... }
-- @return[1] true
-- @return[2] error
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

  -- Достаём первичный ключ из where в правильном порядке частей индекса
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

  -- Операции присваивания: {'=', field_name, value}
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

--- Upsert record (atomic insert or update by primary key)
-- Uses box.space:upsert() directly
-- If record doesn't exist — inserts default_fields as a full tuple
-- If record exists — applies update operations only to update_fields
-- @param space (string) space
-- @param default_fields (table) full record for insert case
-- @param update_fields (table) fields to update if record exists
-- @return[1] true
-- @return[2] error
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

--- Атомарное выполнение нескольких операций в транзакции
-- При ошибке любой операции внутри fn все изменения откатываются.
-- Функция fn должна бросать error() при ошибке, чтобы сработал откат.
-- Вспомогательная функция sql.check() упрощает проверку.
-- @param fn (function)
-- @return[1] result
-- @return[2] error
-- @usage
  -- local ok, err = sql.atomic(function()
  --   sql.check(sql.create('users', userData))
  --   sql.check(sql.create('user_credentials', credentials))
  --   sql.check(sql.create('sessions', session))
  -- end)

  -- if err then
  --   -- все операции откачены
  -- end
function sql.atomic(fn)
  local ok, err = pcall(box.atomic, fn)

  if not ok then
    return nil, err
  end

  return true, nil
end

--- Проверка результата SQL-операции для использования внутри sql.atomic
-- Если операция вернула ошибку — бросает error для отката транзакции
-- @param result Первый возврат sql.create/sql.execute/sql.update
-- @param err Второй возврат (ошибка)
-- @return result
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
