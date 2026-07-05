--- Outgoing message queue: at most one message per interval per chat.
--[[
Each chat_id runs its own fiber that sends queued messages with an interval
pause between them. Telegram allows ~1 msg/sec per chat, so the queue smooths
bursts (e.g. mass bans) and avoids 429s; different chats run in parallel.
In-memory - if a chat's queue grows past max_queue, new messages are dropped with a warning.
--]]
local log = require('log')
local fiber = require('fiber')
local bot = require('bot')

-- Extra seconds to wait on top of retry_after on a 429.
local RETRY_AFTER_PADDING_SEC = 2

local sendQueue = {}
sendQueue.__index = sendQueue

--- Create a queue.
-- @param opts (table)
-- @param opts.interval (number) pause between messages to one chat, seconds
-- @param opts.max_queue (number) max pending messages per chat
function sendQueue.new(opts)
  opts = opts or {}

  return setmetatable({
    interval = opts.interval or 1,
    max_queue = opts.max_queue or 100,
    queues = {},   -- chat_id -> list of { fields, on_error }
    workers = {},  -- chat_id -> true while the chat fiber is running
  }, sendQueue)
end

--- Drain one chat's queue. Runs inside its own fiber.
function sendQueue:drain(chatId)
  local queue = self.queues[chatId]

  while queue and #queue > 0 do
    local item = queue[1]

    local _, err = bot:sendMessage(item.fields)

    -- 429: wait for the time Telegram asked plus padding, then retry the same one.
    if err and err.error_code == 429 then
      local retryAfter = (err.parameters and err.parameters.retry_after) or self.interval

      log.warn('[sendQueue] 429 in chat %s, retry in %ss',
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

--- Enqueue a message for sending.
-- @param fields (table) sendMessage fields, chat_id required
-- @param onError (function) optional handler for send errors (other than 429)
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
    log.warn('[sendQueue] chat %s queue overflow (%d), message dropped',
      tostring(chatId), self.max_queue)
    return
  end

  table.insert(queue, { fields = fields, on_error = onError })

  -- Start the chat fiber if idle. It exits once drained, so clear the flag and
  -- queue here (also if drain crashed).
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
