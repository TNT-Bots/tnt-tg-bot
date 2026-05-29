[English](../en/libs.md) | [Russian](../ru/libs.md)

# Libraries

Helpers in [`bot/libs`](../../bot/libs) and [`bot/utils`](../../bot/utils). Import
any of them directly: `local hdec = require('bot.libs.hdec')`.

## hdec — HTML formatting

[`bot/libs/hdec.lua`](../../bot/libs/hdec.lua). Since `parse_mode` defaults to
`HTML`, use these to build safe markup:

```lua
local hdec = require('bot.libs.hdec')

hdec.bold('x'); hdec.italic('x'); hdec.mono('x'); hdec.underline('x')
hdec.code('lua', 'print(1)')         -- <pre language="lua">…</pre>
hdec.url('https://t.me', 'link')
hdec.user(user)                      -- mention link from a User
hdec.chat(chat)                      -- title/link from a Chat
hdec.escape(text)                    -- escape <, >, &, ", '
hdec.sep                             -- a divider string
```

All wrappers escape their input, so `hdec.bold(userText)` is safe.

## sql — Tarantool SQL / NoSQL

[`bot/libs/sql.lua`](../../bot/libs/sql.lua) (Tarantool 3.x). Callable directly
for queries; named helpers for writes:

```lua
local sql = require('bot.libs.sql')

local rows = sql([[ SELECT * FROM users WHERE id = ${id} ]], { id = 42 })
sql.create('users', tuple)
sql.update('users', { name = 'X' }, { id = 42 })          -- SQL UPDATE
sql.update_nosql('chats', { settings = map }, { id = 1 }) -- box:update — needed for map/array fields
sql.upsert('users', defaults, updateFields)               -- atomic insert/update
sql.atomic(function() … end)                              -- transaction; sql.check(res, err) aborts on error
```

`${name}` placeholders are substituted from the values table. A `WHERE` on a
non-indexed field needs an index (or `SEQSCAN`) — add the index to your space
schema. Use `update_nosql` for `map`/`array` columns (plain SQL `UPDATE` can't
touch them).

## rateLimiter — token bucket

[`bot/libs/rateLimiter.lua`](../../bot/libs/rateLimiter.lua). Allow/deny by key
(the library uses it for command antiflood):

```lua
local RateLimiter = require('bot.libs.rateLimiter')
local limiter = RateLimiter.new({ capacity = 3, refill_per_sec = 1 })

local ok, wait = limiter:allow(chat_id)   -- ok=false → retry after `wait` seconds
```

Idle buckets are swept by a background fiber.

## sendQueue — outgoing per-chat queue

[`bot/libs/sendQueue.lua`](../../bot/libs/sendQueue.lua). Serializes outgoing
messages per chat to respect Telegram's per-chat rate limit:

```lua
local sendQueue = require('bot.libs.sendQueue')
local queue = sendQueue.new({ interval = 1.1, max_queue = 100 })

queue:push({ chat_id = id, text = 'hi' }, function(err) log.error(err) end)
```

One worker fiber per chat sends with `interval` spacing; on `429` it waits
`retry_after + 2`s and retries; over `max_queue` it drops with a `log.warn`. The
optional second arg handles non-`429` send errors.

## fstring — string templates

[`bot/utils/fstring.lua`](../../bot/utils/fstring.lua). Substitutes `${key}` from
a table. Commonly installed globally as `string.f`:

```lua
string.f = require('bot.utils.fstring')
('Hello, ${name}!'):f({ name = 'world' })
```

Unmatched `${…}` are left as-is, which allows pre-filling a template in stages.

## pagination — paginated keyboards

[`bot/utils/pagination.lua`](../../bot/utils/pagination.lua). Builds a paginated
inline keyboard (item buttons + `◀️`/`▶️` nav):

```lua
local pagination = require('bot.utils.pagination')
local kb = pagination({
  items = list, total = #list, page = 1, per_page = 5, prefix = 'list',
  make_button = function(item, i) return { text = item.name, callback_data = 'item '..i } end,
})
```

Nav buttons emit `callback_data` `"<prefix> page <n>"`. See the
[`pagination.lua`](../../examples/pagination.lua) example.

## parseInitData — WebApp initData validation

[`bot/libs/parseInitData.lua`](../../bot/libs/parseInitData.lua). Validates
[Mini App initData](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)
(HMAC-SHA256). Requires the `luaossl` rock.

```lua
local parseInitData = require('bot.libs.parseInitData')
local res = parseInitData(init_data, bot_token)  -- { valid = bool, userData = table|nil }
```

## inputFile — local file upload

[`bot/libs/inputFile.lua`](../../bot/libs/inputFile.lua). Reads a local file into
`{ data, filename }` for multipart uploads (used by `bot.sendImage` and similar).

## getter — declarative getters

[`bot/libs/getter.lua`](../../bot/libs/getter.lua). `defineGetters(class, map)`
generates getter methods from dot-paths — the mechanism behind all context-object
getters.

## colors — terminal colors

[`bot/utils/colors.lua`](../../bot/utils/colors.lua). ANSI 256-color escape codes
(`colors.brightRed`, …, `colors.reset`) for colored terminal output.

See also: [Overview](overview.md), [Keyboards](keyboards.md).
