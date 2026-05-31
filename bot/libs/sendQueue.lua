--- Очередь исходящих сообщений: не чаще одного сообщения в interval на чат.
--
-- На каждый chat_id поднимается отдельный fiber, который по очереди шлёт
-- накопленные сообщения с паузой interval между ними. Telegram держит лимит
-- примерно одно сообщение в секунду на чат, поэтому очередь сглаживает
-- всплески (например массовые баны) и не ловит 429. Разные чаты идут
-- параллельно - лимит у Telegram на каждый чат свой.
--
-- Хранение в памяти. Если сообщения в чат валят быстрее отправки очень долго
-- и очередь дорастает до max_queue - новые сообщения отбрасываются с log.warn.
--
local log = require('log')
local fiber = require('fiber')
local bot = require('bot')

-- Сколько секунд сверх retry_after подождать при 429 (запас).
local RETRY_AFTER_PADDING_SEC = 2

local sendQueue = {}
sendQueue.__index = sendQueue

--- Создаёт очередь.
-- @param opts (table)
-- @param opts.interval (number) пауза между сообщениями в один чат, секунды
-- @param opts.max_queue (number) максимум сообщений в очереди одного чата
function sendQueue.new(opts)
  opts = opts or {}

  return setmetatable({
    interval = opts.interval or 1,
    max_queue = opts.max_queue or 100,
    queues = {},   -- chat_id -> список { fields, on_error }
    workers = {},  -- chat_id -> true, пока fiber чата работает
  }, sendQueue)
end

--- Опустошает очередь одного чата. Крутится в отдельном fiber.
function sendQueue:drain(chatId)
  local queue = self.queues[chatId]

  while queue and #queue > 0 do
    local item = queue[1]

    local _, err = bot:sendMessage(item.fields)

    -- 429: ждём сколько сказал Telegram + запас и повторяем это же сообщение
    if err and err.error_code == 429 then
      local retryAfter = (err.parameters and err.parameters.retry_after) or self.interval

      log.warn('[sendQueue] 429 в чате %s, повтор через %ss',
        tostring(chatId), tostring(retryAfter))

      fiber.sleep(retryAfter + RETRY_AFTER_PADDING_SEC)
    else
      if err then
        if item.on_error then
          item.on_error(err)
        else
          log.error(err)
        end
      end

      table.remove(queue, 1)
      fiber.sleep(self.interval)
    end
  end
end

--- Ставит сообщение в очередь отправки.
-- @param fields (table) поля sendMessage, обязателен chat_id
-- @param onError (function) необязательный обработчик ошибки отправки (кроме 429)
function sendQueue:push(fields, onError)
  local chatId = fields.chat_id

  if chatId == nil then
    error('sendQueue:push requires fields.chat_id', 2)
  end

  local queue = self.queues[chatId]

  if queue == nil then
    queue = {}
    self.queues[chatId] = queue
  end

  if #queue >= self.max_queue then
    log.warn('[sendQueue] очередь чата %s переполнена (%d), сообщение отброшено',
      tostring(chatId), self.max_queue)
    return
  end

  table.insert(queue, { fields = fields, on_error = onError })

  -- Поднимаем fiber чата, если ещё не работает. По опустошении он сам выходит,
  -- поэтому чистим флаг и очередь здесь же (в т.ч. если drain упал с ошибкой).
  if not self.workers[chatId] then
    self.workers[chatId] = true

    fiber.create(function()
      fiber.self():name('sendQueue-'..tostring(chatId))

      local ok, drainErr = pcall(self.drain, self, chatId)

      if not ok then
        log.error(drainErr)
      end

      self.queues[chatId] = nil
      self.workers[chatId] = nil
    end)
  end
end

return sendQueue
