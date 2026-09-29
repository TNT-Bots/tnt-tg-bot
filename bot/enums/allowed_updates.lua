--- Allowed update types enum.
-- Values for the allowed_updates option of the transports,
-- also available as bot.enums.allowed_updates.
-- See: https://core.telegram.org/bots/api#update
-- @usage
-- bot:startLongPolling({
--   allowed_updates = {
--     bot.enums.allowed_updates.MESSAGE,
--     bot.enums.allowed_updates.CALLBACK_QUERY,
--   },
-- })

--- Update types.
local allowed_updates = {
  MESSAGE = 'message',                                     -- new incoming message of any kind
  EDITED_MESSAGE = 'edited_message',                       -- new version of a message that was edited
  CHANNEL_POST = 'channel_post',                           -- new incoming channel post of any kind
  EDITED_CHANNEL_POST = 'edited_channel_post',             -- new version of a channel post that was edited
  BUSINESS_CONNECTION = 'business_connection',             -- the bot was connected to or disconnected from a business account
  BUSINESS_MESSAGE = 'business_message',                   -- new message from a connected business account
  EDITED_BUSINESS_MESSAGE = 'edited_business_message',     -- new version of a message from a connected business account
  DELETED_BUSINESS_MESSAGES = 'deleted_business_messages', -- messages were deleted from a connected business account
  MESSAGE_REACTION = 'message_reaction',                   -- a reaction to a message was changed by a user
  MESSAGE_REACTION_COUNT = 'message_reaction_count',       -- reactions to a message with anonymous reactions were changed
  INLINE_QUERY = 'inline_query',                           -- new incoming inline query
  CHOSEN_INLINE_RESULT = 'chosen_inline_result',           -- the result of an inline query that was chosen by a user
  CALLBACK_QUERY = 'callback_query',                       -- new incoming callback query
  SHIPPING_QUERY = 'shipping_query',                       -- new incoming shipping query, only for invoices with flexible price
  PRE_CHECKOUT_QUERY = 'pre_checkout_query',               -- new incoming pre-checkout query
  PURCHASED_PAID_MEDIA = 'purchased_paid_media',           -- a user purchased paid media with a non-empty payload
  POLL = 'poll',                                           -- new poll state
  POLL_ANSWER = 'poll_answer',                             -- a user changed their answer in a non-anonymous poll
  MY_CHAT_MEMBER = 'my_chat_member',                       -- the bot's chat member status was updated in a chat
  CHAT_MEMBER = 'chat_member',                             -- a chat member's status was updated, the bot must be an administrator
  CHAT_JOIN_REQUEST = 'chat_join_request',                 -- a request to join the chat has been sent
  CHAT_BOOST = 'chat_boost',                               -- a chat boost was added or changed
  REMOVED_CHAT_BOOST = 'removed_chat_boost',               -- a boost was removed from a chat
  MANAGED_BOT = 'managed_bot',                             -- a bot managed by the bot was created or changed
}

return allowed_updates
