[English](../../README.md) | Russian</br>

[![luacheck](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml/badge.svg?branch=master)](https://github.com/uriid1/tnt-tg-bot/actions/workflows/luacheck.yml)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](../../LICENSE)

## Описание
**tnt-tg-bot** — библиотека на Lua для платформы [Tarantool](https://www.tarantool.io/), дающая интерфейс к [Telegram Bot API](https://core.telegram.org/bots/api). Текущая версия: `2.0`.

> [!NOTE]
> Для production используйте последнюю стабильную ветку или релиз.
> В ветке `master` API может меняться или быть частично несовместимым с релизами.

> [!WARNING]
> В `master` могут прилетать force push, hard reset и иногда поломки.
> Пользуйтесь стабильной веткой или последним релизом.

## Особенности
- Простые и явные интерфейсы
- Асинхронная обработка апдейтов — по одному fiber Tarantool на апдейт
- Все методы Telegram Bot API автоматически навешиваются на объект бота (`bot:sendMessage{...}`)
- Встроенная обработка команд и callback-команд
- Имена событий задаёшь сам — из коробки только `bot.events.onGetUpdate(ctx)`
- Транспорты long polling и webhook
- Платежи в Telegram Stars
- WebApp (TWA): [валидация initData](https://core.telegram.org/bots/webapps#validating-data-received-via-the-mini-app) через [`bot/libs/parseInitData.lua`](../../bot/libs/parseInitData.lua) и HTTP-ручки
- Аннотации LDoc
- Готовые к запуску примеры

## Документация
Подробные доки — в [`docs/ru/`](.) (English — [`docs/en/`](../en)):

| Тема | Описание |
|------|----------|
| [Обзор](overview.md) | Что включает библиотека: жизненный цикл апдейта и карта подсистем |
| [Начало работы](getting-started.md) | Установка, минимальный бот, запуск |
| [Команды](commands.md) | Класс `Command`, флаги, `commandLoader`, callback'и |
| [Контекст и события](context.md) | `bot.events`, `onGetUpdate`, контекст-объекты и геттеры |
| [Клавиатуры](keyboards.md) | Inline- и reply-клавиатуры |
| [Библиотеки](libs.md) | `hdec`, `sql`, `fstring`, `rateLimiter`, `sendQueue`, … |
| [Транспорт](transport.md) | Long polling, webhook, отладочный сервер |

Справочник API по аннотациям LDoc генерируется командой `bash bin/ldoc` (вывод в `doc/`).

## Быстрый старт
```lua
local bot = require('bot')

bot:cfg({ token = os.getenv('BOT_TOKEN') })

function bot.events.onGetUpdate(ctx)
  local text = ctx:getText()
  if text then
    ctx:reply(text)
  end
end

bot:startLongPolling()
```
```bash
BOT_TOKEN="1348551682:AAFK..." tarantool examples/echo-bot.lua
```

## Установка

### Автоматическая
1. Установите `git`, `curl`, `lua 5.1` и `luarocks`.
2. Установите [Tarantool](https://www.tarantool.io/ru/download/os-installation).
3. (Опционально, для WebApp) установите заголовочные файлы OpenSSL и Lua 5.1 — нужны для сборки rock'а `luaossl`.
4. Запустите установщик зависимостей:
```bash
bash tnt-tg-bot.pre-build.sh
```
5. Если не получилось — перейдите к ручной установке.

> [!NOTE]
> `luaossl` (биндинг к OpenSSL) требует заголовки OpenSSL и Lua 5.1. В Ubuntu:
> `sudo apt install libssl-dev liblua5.1-0-dev`. Нужен только модулю
> [`bot/libs/parseInitData.lua`](../../bot/libs/parseInitData.lua) для валидации WebApp initData.

### Ручная
1. Установите `git`, `curl`, `lua 5.1`, `luarocks` и [Tarantool](https://www.tarantool.io/ru/download/os-installation).
2. Установите rock'и:
```bash
# HTTP клиент/сервер (обязательно)
luarocks install --local --tree=$PWD/.rocks --server=https://rocks.tarantool.org/ http
# Multipart POST (обязательно)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 lua-multipart-post 1.0-0
# Биндинг к OpenSSL (опционально, только для WebApp)
luarocks install --local --tree=$PWD/.rocks --lua-version 5.1 luaossl
```

## Примеры

Запуск примера через docker (рекомендуется):

```bash
env BOT_TOKEN="BOT_TOKEN_HERE" ./bin/tarantool examples/echo-bot-new-ctx.lua
```

| Пример | Что показывает |
|--------|----------------|
| [echo-bot.lua](../../examples/echo-bot.lua) | Эхо через `bot:sendMessage` |
| [reply-bot.lua](../../examples/reply-bot.lua) | Эхо через шорткат `ctx:reply()` |
| [callback-answer.lua](../../examples/callback-answer.lua) | Inline-клавиатура + обработка callback (`ctx:answer`, `ctx:getQueryData`) |
| [pagination.lua](../../examples/pagination.lua) | Постраничная inline-клавиатура с деталями (`bot.utils.pagination`) |
| [command-start-help/](../../examples/command-start-help) | Структурированный проект: `commandLoader` + модули `/start`, `/help` |

## Структура библиотеки
```
bot/
├── init.lua        Точка входа: объект bot, cfg, транспорты, резолверы команд, обёрнутые методы API
├── api.lua         Клиент API: call, wrapMethods (генерирует bot:<method>), sendImage
├── commands.lua    Поиск команды / callback в апдейте по имени
├── config.lua      Дефолты (api_url, parse_mode, token)
├── classes/        Типизированные контексты: Message, CallbackQuery, ChatMember, MyChatMember, PreCheckoutQuery, SuccessfulPayment
├── enums/          Константы Telegram (methods, chat_type, command_flags, parse_mode, …)
├── interfaces/     EventEmitter (наблюдатель) для своей диспетчеризации событий
├── libs/           Хелперы: hdec, sql, rateLimiter, sendQueue, parseInitData, inputFile, getter
├── middlewares/    request (HTTP-транспорт) + сборщики inline/callback-клавиатур
├── processes/      processMessage (сырой → типизированный ctx), processCommand (рантайм команд)
├── transport/      longpolling, webhook, debug
├── types/          Сборщики payload'ов Telegram: клавиатуры, кнопки, медиа
└── utils/          commandLoader, fstring (string.f), pagination, colors
```
Полная карта подсистем и жизненный цикл — в [docs/ru/overview.md](overview.md).

## Генерация документации
```bash
bash bin/ldoc
```

## Вклад в проект
Через форк репозитория и Pull Request.

## Лицензия
[MIT](../../LICENSE)
