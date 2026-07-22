--- ReactionType builders for setMessageReaction.
-- See: https://core.telegram.org/bots/api#reactiontype
--

local ReactionType = {}

--- Build a ReactionTypeEmoji object.
-- @tparam string emoji reaction emoji from the list allowed by the API
-- @treturn table ReactionTypeEmoji
function ReactionType.emoji(emoji)
  return {
    type = 'emoji',
    emoji = tostring(emoji)
  }
end

--- Build a ReactionTypeCustomEmoji object.
-- @tparam string customEmojiId custom emoji identifier
-- @treturn table ReactionTypeCustomEmoji
function ReactionType.customEmoji(customEmojiId)
  return {
    type = 'custom_emoji',
    custom_emoji_id = tostring(customEmojiId)
  }
end

--- Build a ReactionTypePaid object.
-- @treturn table ReactionTypePaid
function ReactionType.paid()
  return {
    type = 'paid'
  }
end

return ReactionType
