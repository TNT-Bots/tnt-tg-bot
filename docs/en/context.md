[English](../en/context.md) | [Russian](../ru/context.md)

# Context & events

## Events

`bot.events` holds your handlers. The runtime calls exactly one of them —
`onGetUpdate(ctx)` — for every update. Everything else is yours to define and
call. Referencing an undefined event is safe: it returns a no-op that logs at
`verbose` level, so you can wire `bot.events.onChatMessage(ctx)` before defining it.

Two optional hooks are recognized by [`processCommand`](commands.md):
`preCallCommand(ctx, command)` (return `false` to abort a command) and
`postCallCommand(ctx, command)`.

A typical `onGetUpdate` routes by update type:

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
      return bot.events.onGetEntities(ctx)   -- slash commands live here
    elseif ctx.message.text then
      return bot.events.onGetMessageText(ctx)
    end
  end
end
```

## Context objects

[`processMessage`](../../bot/processes/processMessage.lua) wraps each raw update
into one of these classes (in [`bot/classes/`](../../bot/classes)). Getters are
generated declaratively from dot-paths by [`bot/libs/getter.lua`](../../bot/libs/getter.lua).

| Update field | Class | Notable members |
|--------------|-------|-----------------|
| `message` | [`Message`](../../bot/classes/Message.lua) | `getText`, `getChat(Id)`, `getChatType`, `getMessageId`, `getUserFrom(Id)`, `getReplyToMessage`, `getEntities`, `getSenderChat`, `getSuccessfulPayment`, `getArguments`, `reply`, `replyToMessage`, `trimCommand` |
| `callback_query` | [`CallbackQuery`](../../bot/classes/CallbackQuery.lua) | `is_callback_query = true`, `getQueryData`, `getQueryId`, `getUserFrom(Id)`, `getArguments`, `answer`, `reply`, `getMessage` |
| `chat_member` | [`ChatMember`](../../bot/classes/ChatMember.lua) | `getChat`, `getUserFrom`, `getOldChatMember`, `getNewChatMember`, `getOld/NewChatMemberStatus` |
| `my_chat_member` | [`MyChatMember`](../../bot/classes/MyChatMember.lua) | same shape as `ChatMember`, but for the bot's own membership |
| `pre_checkout_query` | [`PreCheckoutQuery`](../../bot/classes/PreCheckoutQuery.lua) | `getId`, `getInvoicePayload`, `getCurrency`, `getTotalAmount`, `getUserFrom` |
| (in a message) `successful_payment` | [`SuccessfulPayment`](../../bot/classes/SuccessfulPayment.lua) | `getCurrency`, `getTotalAmount`, `getInvoicePayload`, `getTelegramPaymentChargeId`, `isRecurring`, … |

### Message

```lua
ctx:getText()                       -- message text (or nil)
ctx:getChatId()                     -- chat id
ctx:getUserFrom()                   -- sender (User table)
ctx:getArguments({ count = 3 })     -- split text by space (default), max `count` tokens

ctx:reply('Hi')                     -- sendMessage to the same chat
ctx:reply({ text = 'Hi', reply_markup = kb })
ctx:replyToMessage('Hi')            -- reply referencing the current message
```

### CallbackQuery

A callback carries the message it was attached to, so message getters
(`getChatId`, `getMessageId`, `getText`, …) work too.

```lua
ctx:getQueryData()                  -- raw callback_data string
ctx:getArguments({ count = 4 })     -- split callback_data by space
ctx:answer('Done')                  -- answerCallbackQuery (toast)
ctx:answer({ text = 'Nope', show_alert = true })
ctx:reply('…')                      -- sendMessage to the chat
```

### Chat member updates

```lua
local chat   = ctx:getChat()
local oldM   = ctx:getOldChatMember()
local newM   = ctx:getNewChatMember()
local actor  = ctx:getUserFrom()    -- who performed the change
-- newM.status, newM.user, newM.until_date, etc.
```

`ChatMember` is for other users; `MyChatMember` is the bot's own status changes.
The library emits neither into named sub-events — you build that yourself (see below).

## Building your own dispatch

[`EventEmitter`](../../bot/interfaces/EventEmitter.lua) is the observer primitive
(`on` / `emit`). Use it to fan one raw event out to many named handlers:

```lua
local EventEmitter = require('bot.interfaces.EventEmitter')

local emitter = EventEmitter:new()
emitter:on('member_kicked', require('src.emiters.events.chat_member.on_member_kicked'))
emitter:on('member_unbanned', require('src.emiters.events.chat_member.on_member_unbanned'))

-- inside your onChatMember:
emitter:emit('member_kicked', ctx)
```

See also: [Commands](commands.md), [Keyboards](keyboards.md).
