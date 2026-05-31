[English](../en/getting-started.md) | [Russian](../ru/getting-started.md)

# Начало работы

## Требования

- [Tarantool](https://www.tarantool.io/ru/download/os-installation)
- `git`, `curl`, `lua 5.1`, `luarocks`
- (опционально, только для WebApp) заголовки OpenSSL + Lua 5.1 - для rock'а `luaossl`

## Установка

Самый быстрый путь - встроенный установщик:

```bash
bash tnt-tg-bot.pre-build.sh
```

Или поставить rock'и вручную:

```bash
# HTTP клиент/сервер (обязательно)
luarocks install --local --tree=$PWD/.rocks --server=https://rocks.tarantool.org/ http
# Multipart POST (обязательно)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 lua-multipart-post 1.0-0
# Биндинг к OpenSSL (опционально, только для WebApp)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 luaossl
```

Детали про заголовки OpenSSL - в [README](../../README.md#installation).

## Первый бот

```lua
local log = require('log')
local bot = require('bot')

-- 1. Настраиваем один раз. parse_mode по умолчанию HTML.
bot:cfg({ token = os.getenv('BOT_TOKEN') })

-- 2. Рантайм вызывает ровно одно событие: onGetUpdate.
function bot.events.onGetUpdate(ctx)
  local text = ctx:getText()
  if not text then return end

  local _, err = ctx:reply(text)   -- ctx:reply - шорткат для sendMessage в этот чат
  if err then
    log.error(err)
  end
end

-- 3. Запускаем.
bot:startLongPolling()
```

`ctx` - типизированный контекст-объект (здесь `Message`). У него есть геттеры вроде
`ctx:getText()` / `ctx:getChatId()` и хелперы вроде `ctx:reply(...)`. См.
[Контекст и события](context.md).

## Запуск

```bash
BOT_TOKEN="1348551682:AAFK..." tarantool examples/echo-bot.lua
```

Любой файл из [`examples/`](../../examples) запускается так же.

## Структура большого бота

Для всего, что сложнее игрушки, разбивай бота на модули и маршрутизируй апдейты
из `onGetUpdate` в свои именованные события. Рекомендуемая раскладка:

```
┌─ app.lua                     - Точка входа: bot:cfg, привязка событий, загрузка команд, старт транспорта
├── bot                        - Библиотека tnt-tg-bot
├── conf                       - Конфиги
├── bin                        - Скрипты (запуск, линтер, …)
├── src                        - Исходники твоего бота
│   ├── enums                  - Инамы
│   ├── events                 - Обработчики onGetUpdate (диспетчеризация по типу апдейта)
│   ├── commands               - Команды, сгруппированные по типу
│   │   ├── private            - Команды только для ЛС
│   │   ├── public             - Публичные (группы, супергруппы)
│   │   └── maint              - Команды режима обслуживания
│   ├── models                 - Модели/валидаторы хранилища
│   ├── services               - CRUD-сервисы над спейсами
│   ├── spaces                 - Схемы спейсов
│   └── utils                  - Хелперы
└── var                        - Рантайм Tarantool (логи, снапшоты, xlog)
```

Минимальная связка точки входа:

```lua
local bot = require('bot')
local commandLoader = require('bot.utils.commandLoader')

bot:cfg { token = os.getenv('BOT_TOKEN') }

-- Маршрутизация апдейтов: определяешь onGetUpdate, отдаёшь entities в процессор команд и т.д.
bot.events.onGetUpdate = require('src.events.onGetUpdate')
bot.events.onGetEntities = require('src.events.onGetEntities')

-- Загрузка модулей команд в bot.commands.
-- Модуль резолвится в <base>.<group>.<command>, напр. src/commands/private/start/init.lua
commandLoader.setPath('src.commands')
commandLoader {
  private = {
    start = {},
    help = {},
  },
  -- Команда с inline-callback обработчиками:
  -- settings = { callback_commands = { 'cb_settings' } },
}

bot:startLongPolling()
```

Формат `commandLoader` и callback-команды - в [Командах](commands.md).

> Совет: включи строгий режим, чтобы ловить случайные глобалы - `require('strict').on()`.

## Куда дальше

- [Обзор](overview.md) - жизненный цикл апдейта и полная карта подсистем.
- [Команды](commands.md) - класс `Command`, флаги, загрузчик, callback'и.
- [Контекст и события](context.md) - контекст-объекты и своя диспетчеризация.
- [Клавиатуры](keyboards.md) - inline- и reply-клавиатуры.
