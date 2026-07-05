--- Token-bucket rate limiter keyed by an arbitrary value.
--[[
Each key owns a bucket of tokens; every call spends one.
Buckets refill at refill_per_sec tokens/sec up to capacity,
allowing short bursts and then a steady rate -
a good fit for Telegram's per-chat ~1 msg/sec limit.
Idle buckets are swept by a background fiber. In-memory only.
--]]
local fiber = require('fiber')

--- How often the sweeper scans buckets, in seconds.
local CLEANUP_INTERVAL_SEC = 60

local rateLimiter = {}
rateLimiter.__index = rateLimiter

--- Create a new limiter.
-- @param opts (table)
-- @param opts.capacity (number) burst size (tokens available at once)
-- @param opts.refill_per_sec (number) refill rate
function rateLimiter.new(opts)
  opts = opts or {}

  local self = setmetatable({
    capacity = opts.capacity or 3,
    refill_per_sec = opts.refill_per_sec or 1,
    buckets = {},
  }, rateLimiter)

  -- A bucket fully refills in capacity/refill_per_sec seconds.
  -- Double that before treating it as idle, so a returning key still has full credit.
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

--- Drop buckets untouched for longer than idle_threshold_sec.
-- @return (number) how many keys were removed
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

--- Try to spend one token for a key.
-- @param key (any) usually chat_id or user_id..':'..chat_id
-- @return (boolean) true if allowed, false if the bucket is empty
-- @return (number) seconds until the next token becomes available
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
