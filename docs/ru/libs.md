[English](../en/libs.md) | [Russian](../ru/libs.md)

# Библиотеки

Хелперы в [`bot/libs`](../../bot/libs) и [`bot/utils`](../../bot/utils). Любой
импортируется напрямую: `local hdec = require('bot.libs.hdec')`.

## hdec - HTML-форматирование

[`bot/libs/hdec.lua`](../../bot/libs/hdec.lua). Так как `parse_mode` по умолчанию
`HTML`, собирай разметку через них:

```lua
local hdec = require('bot.libs.hdec')

hdec.bold('x'); hdec.italic('x'); hdec.mono('x'); hdec.underline('x')
hdec.code('lua', 'print(1)')         -- <pre language="lua">…</pre>
hdec.url('https://t.me', 'link')
hdec.user(user)                      -- mention-ссылка из User
hdec.chat(chat)                      -- название/ссылка из Chat
hdec.escape(text)                    -- экранирует <, >, &, ", '
hdec.sep                             -- строка-разделитель
```

Все обёртки экранируют вход, так что `hdec.bold(userText)` безопасен.

## sql - Tarantool SQL / NoSQL

[`bot/libs/sql.lua`](../../bot/libs/sql.lua) (Tarantool 3.x). Вызывается напрямую
для запросов; именованные хелперы - для записи:

```lua
local sql = require('bot.libs.sql')

local rows = sql([[ SELECT * FROM users WHERE id = ${id} ]], { id = 42 })
sql.create('users', tuple)
sql.update('users', { name = 'X' }, { id = 42 })          -- SQL UPDATE
sql.update_nosql('chats', { settings = map }, { id = 1 }) -- box:update - нужно для map/array полей
sql.upsert('users', defaults, updateFields)               -- атомарный insert/update
sql.atomic(function() … end)                              -- транзакция; sql.check(res, err) откатывает по ошибке
```

Плейсхолдеры `${name}` подставляются из таблицы значений. `WHERE` по
неиндексированному полю требует индекса (или `SEQSCAN`) - добавь индекс в схему
спейса. Для `map`/`array`-колонок используй `update_nosql` (обычный SQL `UPDATE`
их не трогает).

## rateLimiter - токен-бакет

[`bot/libs/rateLimiter.lua`](../../bot/libs/rateLimiter.lua). Allow/deny по ключу
(сама либа применяет его для антифлуда команд):

```lua
local RateLimiter = require('bot.libs.rateLimiter')
local limiter = RateLimiter.new({ capacity = 3, refill_per_sec = 1 })

local ok, wait = limiter:allow(chat_id)   -- ok=false → повтор через `wait` секунд
```

Простаивающие корзинки подчищает фоновый fiber.

## sendQueue - очередь исходящих на чат

[`bot/libs/sendQueue.lua`](../../bot/libs/sendQueue.lua). Сериализует исходящие
сообщения по чату, уважая per-chat лимит Telegram:

```lua
local sendQueue = require('bot.libs.sendQueue')
local queue = sendQueue.new({ interval = 1.1, max_queue = 100 })

queue:push({ chat_id = id, text = 'hi' }, function(err) log.error(err) end)
```

На каждый чат - свой fiber, шлёт с паузой `interval`; на `429` ждёт
`retry_after + 2`с и повторяет; сверх `max_queue` дропает с `log.warn`.
Опциональный второй аргумент обрабатывает ошибки отправки (кроме `429`).

## fstring - строковые шаблоны

[`bot/utils/fstring.lua`](../../bot/utils/fstring.lua). Подставляет `${key}` из
таблицы. Обычно ставится глобально как `string.f`:

```lua
string.f = require('bot.utils.fstring')
('Hello, ${name}!'):f({ name = 'world' })
```

Неподставленные `${…}` остаются как есть - это позволяет заполнять шаблон в
несколько проходов.

## pagination - постраничные клавиатуры

[`bot/utils/pagination.lua`](../../bot/utils/pagination.lua). Строит постраничную
inline-клавиатуру (кнопки элементов + навигация `◀️`/`▶️`):

```lua
local pagination = require('bot.utils.pagination')
local kb = pagination({
  items = list, total = #list, page = 1, per_page = 5, prefix = 'list',
  make_button = function(item, i) return { text = item.name, callback_data = 'item '..i } end,
})
```

Кнопки навигации шлют `callback_data` `"<prefix> page <n>"`. См. пример
[`pagination.lua`](../../examples/pagination.lua).

## parseInitData - валидация WebApp initData

[`bot/libs/parseInitData.lua`](../../bot/libs/parseInitData.lua). Проверяет
[initData мини-приложения](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app)
(HMAC-SHA256). Требует rock `luaossl`.

```lua
local parseInitData = require('bot.libs.parseInitData')
local res = parseInitData(init_data, bot_token)  -- { valid = bool, userData = table|nil }
```

## inputFile - загрузка локального файла

[`bot/libs/inputFile.lua`](../../bot/libs/inputFile.lua). Читает локальный файл в
`{ data, filename }` для multipart-загрузок (используется `bot.sendImage` и т.п.).

## getter - декларативные геттеры

[`bot/libs/getter.lua`](../../bot/libs/getter.lua). `defineGetters(class, map)`
генерирует геттеры из dot-путей - механизм за всеми геттерами контекст-объектов.

## colors - цвета терминала

[`bot/utils/colors.lua`](../../bot/utils/colors.lua). ANSI 256-цветные escape-коды
(`colors.brightRed`, …, `colors.reset`) для цветного вывода в терминал.

См. также: [Обзор](overview.md), [Клавиатуры](keyboards.md).
