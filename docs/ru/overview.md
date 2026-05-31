[English](../en/overview.md) | [Russian](../ru/overview.md)

# Обзор

Эта страница объясняет, **что включает в себя tnt-tg-bot** и **как апдейт проходит через библиотеку**. Когда эта модель в голове - остальные доки это просто детали отдельных подсистем.

## Что это

tnt-tg-bot - тонкая и явная прослойка над Telegram Bot API для Tarantool:

- Превращает сырые апдейты Telegram в **типизированные контекст-объекты** (`Message`, `CallbackQuery`, …).
- Выкладывает **все методы Bot API** на объект `bot` (`bot:sendMessage{…}`).
- Даёт строительные блоки для **команд**, **клавиатур**, **платежей** и **WebApp**, но маршрутизацию/архитектуру оставляет на тебя.

Библиотека намеренно без навязанных решений: единственное событие, которое вызывает рантайм, - `bot.events.onGetUpdate(ctx)`. Всё остальное - как раскладывать апдейты по типам, как строить команды и события - проектируешь сам.

## Жизненный цикл апдейта

```
Telegram
   │  сырой апдейт (JSON)
   ▼
transport            bot/transport/{longpolling,webhook}.lua
   │  по одному fiber на апдейт → switch(update)
   ▼
processMessage       bot/processes/processMessage.lua
   │  оборачивает сырой апдейт в типизированный контекст-объект
   ▼
bot.events.onGetUpdate(ctx)        ← единственная встроенная точка входа (определяешь сам)
   │  маршрутизируешь по типу/содержимому апдейта
   ▼
твои обработчики     команды, клавиатуры, твои события (EventEmitter), …
```

1. **Transport** (`longpolling` или `webhook`) получает сырые апдейты и выполняет каждый в отдельном fiber Tarantool, вызывая внутренний `switch`.
2. **`switch`** делает ровно одно: `bot.events.onGetUpdate(processMessage(update))`.
3. **`processMessage`** смотрит на апдейт и возвращает подходящий контекст-объект: `Message` (`message`), `CallbackQuery` (`callback_query`), `ChatMember` (`chat_member`), `MyChatMember` (`my_chat_member`), `PreCheckoutQuery` (`pre_checkout_query`). Всё прочее проходит как есть.
4. **`bot.events.onGetUpdate(ctx)`** - твоя. Обычно она ветвится по типу апдейта и передаёт дальше в твои именованные события / процессор команд.

> Обращаться к неопределённым событиям безопасно: `bot.events.someEvent` вернёт пустышку, которая логирует на уровне `verbose`. Поэтому можно звать `bot.events.onChatMessage(ctx)` ещё до того, как ты её определил.

## Объект `bot`

Настраивается один раз через `bot:cfg{…}`. Основная поверхность:

| Член | Назначение |
|------|------------|
| `bot:cfg(opts)` | Инициализация: `token`, `parse_mode` (по умолчанию `HTML`), `api_url`, `username`. Создаёт `bot.commands`, `bot.events`, оборачивает методы API. |
| `bot.call(method, fields, opts)` | Сырой вызов Bot API. |
| `bot:<method>{…}` | Авто-обёртки для каждого метода из `enums/methods` (напр. `bot:sendMessage`, `bot:banChatMember`). |
| `bot.sendImage(data)` | Упрощённый `sendPhoto` из пути к файлу или URL. |
| `bot.events` | Таблица твоих обработчиков; рантайм вызывает только `onGetUpdate`. |
| `bot.command(ctx)` / `bot.callbackCommand(ctx)` | Находят зарегистрированную команду/callback в апдейте по имени. |
| `bot.commands` | Реестр: `имя → команда`. Заполняется вручную или через `commandLoader`. |
| `bot:getBotId()` | Числовой id бота, разобранный из токена. |
| `bot.subdir(deep, ...)` | Хелпер для относительных `require`. |
| `bot:startLongPolling(opts)` | Запуск через long polling. |
| `bot:startWebHook(opts)` / `bot:sendCertificate(opts)` | Запуск через webhook. |
| `bot:debugRoutes(opts)` | Поднять HTTP-сервер с произвольными ручками во время long polling. |

## Карта подсистем

| Директория | Что внутри |
|------------|------------|
| [`bot/init.lua`](../../bot/init.lua) | Точка входа. Собирает объект `bot`, связывает жизненный цикл (`switch`), даёт конфиг, транспорты, резолверы команд и обёрнутые методы. |
| [`bot/api.lua`](../../bot/api.lua) | Клиент API: `call`, `wrapMethods` (генерирует `bot:<method>`), `sendImage`. |
| [`bot/commands.lua`](../../bot/commands.lua) | Поиск текстовой команды или callback в контексте по первому токену (и `/cmd@username`). |
| [`bot/config.lua`](../../bot/config.lua) | Дефолты библиотеки: `api_url`, `parse_mode`, `token`. |
| [`bot/classes/`](../../bot/classes) | Типизированные контексты апдейтов с геттерами и хелперами: `Message`, `CallbackQuery`, `ChatMember`, `MyChatMember`, `PreCheckoutQuery`, `SuccessfulPayment`. См. [Контекст и события](context.md). |
| [`bot/enums/`](../../bot/enums) | Константы Telegram: `methods`, `chat_type`, `chat_member_status`, `chat_permissions`, `command_flags`, `entity_type`, `parse_mode`, `allowed_updates`, `bot_command_scope`, `message_effect`, `errors`. |
| [`bot/interfaces/`](../../bot/interfaces) | `EventEmitter` (`on`/`emit`) - примитив-наблюдатель для построения своей диспетчеризации событий. |
| [`bot/libs/`](../../bot/libs) | Хелперы: `hdec` (HTML-форматирование), `sql` (обёртка над Tarantool 3 SQL/NoSQL), `rateLimiter` (токен-бакет), `sendQueue` (очередь исходящих на чат), `parseInitData` (валидация WebApp initData), `inputFile`, `getter`. См. [Библиотеки](libs.md). |
| [`bot/middlewares/`](../../bot/middlewares) | `request` (HTTP-транспорт к API: ретраи, подстановка parse_mode), `inlineKeyboard` и `inlineCallbackKeyboard` (сборка клавиатур). См. [Клавиатуры](keyboards.md). |
| [`bot/processes/`](../../bot/processes) | `processMessage` (сырой апдейт → типизированный ctx) и `processCommand` (рантайм команд: разбор аргументов, pre/post-хуки, rate-limit). |
| [`bot/transport/`](../../bot/transport) | `longpolling`, `webhook`, `debug`. См. [Транспорт](transport.md). |
| [`bot/types/`](../../bot/types) | Сборщики/валидаторы payload'ов Telegram: inline- и reply-клавиатуры, кнопки, `ForceReply`, `LinkPreviewOptions`, `InputMedia*` (медиа-группы). |
| [`bot/utils/`](../../bot/utils) | `commandLoader` (загрузка модулей команд в `bot.commands`), `fstring` (`string.f`-шаблоны), `pagination`, `colors`. |

## Куда дальше

- [Начало работы](getting-started.md) - установка и запуск минимального бота.
- [Команды](commands.md) - класс `Command`, флаги, загрузчик и callback'и.
- [Контекст и события](context.md) - контекст-объекты, геттеры и своя диспетчеризация событий.
- [Клавиатуры](keyboards.md) - inline- и reply-клавиатуры.
- [Библиотеки](libs.md) - хелперы из `bot/libs` и `bot/utils`.
- [Транспорт](transport.md) - long polling, webhook и отладочный сервер.
