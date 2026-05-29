--- Ограничитель частоты вызовов по ключу.
--
-- Каждый ключ имеет "корзинку" с разрешениями (токенами). Каждый вызов
-- забирает 1 разрешение. Корзинка автоматически пополняется со скоростью
-- refill_per_sec штук в секунду, но не больше capacity.
--
-- Пример: capacity=3, refill_per_sec=1 -- юзер может за раз сделать
-- всплеск из 3 вызовов подряд, потом не более 1 в секунду. Подходит для
-- ограничения частоты сообщений в Telegram (где per-chat лимит ~1/сек).
--
-- Хранение: таблица в памяти. Старые ключи (которые давно не дёргали,
-- корзинка успела полностью восстановиться) подчищает фоновая задача.
--
local fiber = require('fiber')

--- Как часто фоновая задача сканирует корзинки, секунды.
local CLEANUP_INTERVAL_SEC = 60

local rateLimiter = {}
rateLimiter.__index = rateLimiter

--- Создаёт новый ограничитель.
-- @param opts (table)
-- @param opts.capacity (number) сколько вызовов разрешено всплеском
-- @param opts.refill_per_sec (number) скорость пополнения корзинки
function rateLimiter.new(opts)
  opts = opts or {}

  local self = setmetatable({
    capacity = opts.capacity or 3,
    refill_per_sec = opts.refill_per_sec or 1,
    buckets = {},
  }, rateLimiter)

  -- Через сколько секунд корзинку можно считать неактивной и удалить:
  -- за capacity/refill_per_sec она точно успеет полностью восстановиться,
  -- удваиваем для запаса (если юзер вернётся через минуту -- корзинка ещё
  -- здесь и у него full credit, как и должно быть).
  self.idle_threshold_sec = (self.capacity / self.refill_per_sec) * 2

  self.cleaner_fiber = fiber.create(function()
    fiber.self():name('rateLimiter-cleaner')

    while true do
      fiber.sleep(CLEANUP_INTERVAL_SEC)
      self:cleanup()
    end
  end)

  return self
end

--- Удаляет корзинки, к которым не обращались дольше idle_threshold_sec.
-- @return (number) сколько ключей удалено
function rateLimiter:cleanup()
  local now = fiber.time()
  local removed = 0

  for key, bucket in pairs(self.buckets) do
    if now - bucket.last_refill > self.idle_threshold_sec then
      self.buckets[key] = nil
      removed = removed + 1
    end
  end

  return removed
end

--- Попытаться потратить 1 разрешение по ключу.
-- @param key (any) ключ (обычно chat_id или user_id..':'..chat_id)
-- @return (boolean) true если разрешено, false если корзинка пуста
-- @return (number) через сколько секунд появится следующее разрешение
function rateLimiter:allow(key)
  local now = fiber.time()
  local bucket = self.buckets[key]

  if bucket == nil then
    bucket = {
      tokens = self.capacity,
      last_refill = now
    }

    self.buckets[key] = bucket
  else
    local delta = now - bucket.last_refill

    bucket.tokens = math.min(
      self.capacity,
      bucket.tokens + delta * self.refill_per_sec
    )

    bucket.last_refill = now
  end

  if bucket.tokens >= 1 then
    bucket.tokens = bucket.tokens - 1

    return true, 0
  end

  local missing_tokens = 1 - bucket.tokens

  return false, missing_tokens / self.refill_per_sec
end

return rateLimiter
