[English](../en/context.md) | [Russian](../ru/context.md)

# Контекст и события

## События

`bot.events` хранит твои обработчики. Рантайм вызывает ровно один из них -
`onGetUpdate(ctx)` - на каждый апдейт. Всё остальное определяешь и зовёшь сам.
Обращаться к неопределённому событию безопасно: вернётся пустышка, логирующая на
уровне `verbose`, так что можно завязать `bot.events.onChatMessage(ctx)` ещё до
определения.

Два опциональных хука распознаёт [`processCommand`](commands.md):
`preCallCommand(ctx, command)` (верни `false`, чтобы отменить команду) и
`postCallCommand(ctx, command)`.

Типичный `onGetUpdate` маршрутизирует по типу апдейта:

```lua
function bot.events.onGetUpdate(ctx)
  if ctx.callback_query then
    return bot.events.onCallbackQuery(ctx)
  elseif ctx.my_chat_member then
    return bot.events.onMyChatMember(ctx)
  elseif ctx.chat_member then
    return bot.events.onChatMember(ctx)
  elseif ctx.message then
    if ctx.message.entities then
      return bot.events.onGetEntities(ctx)   -- слэш-команды здесь
    elseif ctx.message.text then
      return bot.events.onGetMessageText(ctx)
    end
  end
end
```

## Контекст-объекты

[`processMessage`](../../bot/processes/processMessage.lua) оборачивает каждый
сырой апдейт в один из этих классов (в [`bot/classes/`](../../bot/classes)).
Геттеры генерируются декларативно из dot-путей через
[`bot/libs/getter.lua`](../../bot/libs/getter.lua).

| Поле апдейта | Класс | Заметные члены |
|--------------|-------|----------------|
| `message` | [`Message`](../../bot/classes/Message.lua) | `getText`, `getChat(Id)`, `getChatType`, `getMessageId`, `getUserFrom(Id)`, `getReplyToMessage`, `getEntities`, `getSenderChat`, `getSuccessfulPayment`, `getArguments`, `reply`, `replyToMessage`, `trimCommand` |
| `callback_query` | [`CallbackQuery`](../../bot/classes/CallbackQuery.lua) | `is_callback_query = true`, `getQueryData`, `getQueryId`, `getUserFrom(Id)`, `getArguments`, `answer`, `reply`, `getMessage` |
| `chat_member` | [`ChatMember`](../../bot/classes/ChatMember.lua) | `getChat`, `getUserFrom`, `getOldChatMember`, `getNewChatMember`, `getOld/NewChatMemberStatus` |
| `my_chat_member` | [`MyChatMember`](../../bot/classes/MyChatMember.lua) | та же форма, что у `ChatMember`, но про членство самого бота |
| `pre_checkout_query` | [`PreCheckoutQuery`](../../bot/classes/PreCheckoutQuery.lua) | `getId`, `getInvoicePayload`, `getCurrency`, `getTotalAmount`, `getUserFrom` |
| (внутри message) `successful_payment` | [`SuccessfulPayment`](../../bot/classes/SuccessfulPayment.lua) | `getCurrency`, `getTotalAmount`, `getInvoicePayload`, `getTelegramPaymentChargeId`, `isRecurring`, … |

### Message

```lua
ctx:getText()                       -- текст сообщения (или nil)
ctx:getChatId()                     -- id чата
ctx:getUserFrom()                   -- отправитель (таблица User)
ctx:getArguments({ count = 3 })     -- разбить текст по пробелу (по умолч.), максимум `count` токенов

ctx:reply('Hi')                     -- sendMessage в тот же чат
ctx:reply({ text = 'Hi', reply_markup = kb })
ctx:replyToMessage('Hi')            -- ответ с привязкой к текущему сообщению
```

### CallbackQuery

Callback несёт сообщение, к которому привязан, поэтому геттеры сообщения
(`getChatId`, `getMessageId`, `getText`, …) тоже работают.

```lua
ctx:getQueryData()                  -- сырая строка callback_data
ctx:getArguments({ count = 4 })     -- разбить callback_data по пробелу
ctx:answer('Done')                  -- answerCallbackQuery (всплывашка)
ctx:answer({ text = 'Nope', show_alert = true })
ctx:reply('…')                      -- sendMessage в чат
```

### Апдейты участников чата

```lua
local chat   = ctx:getChat()
local oldM   = ctx:getOldChatMember()
local newM   = ctx:getNewChatMember()
local actor  = ctx:getUserFrom()    -- кто выполнил изменение
-- newM.status, newM.user, newM.until_date и т.д.
```

`ChatMember` - про других участников; `MyChatMember` - про смену статуса самого
бота. В именованные под-события библиотека их не раскладывает - это строишь сам
(см. ниже).

## Своя диспетчеризация

[`EventEmitter`](../../bot/interfaces/EventEmitter.lua) - примитив-наблюдатель
(`on` / `emit`). Разводит одно сырое событие на много именованных обработчиков:

```lua
local EventEmitter = require('bot.interfaces.EventEmitter')

local emitter = EventEmitter:new()
emitter:on('member_kicked', require('src.emiters.events.chat_member.on_member_kicked'))
emitter:on('member_unbanned', require('src.emiters.events.chat_member.on_member_unbanned'))

-- внутри твоего onChatMember:
emitter:emit('member_kicked', ctx)
```

См. также: [Команды](commands.md), [Клавиатуры](keyboards.md).
