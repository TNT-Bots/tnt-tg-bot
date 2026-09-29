--- Chat permissions enum.
-- See: https://core.telegram.org/bots/api#chatpermissions
--

--- Chat permission names.
local chat_permissions = {
  can_send_messages = 'can_send_messages',                 -- send text messages, contacts, invoices, locations and venues
  can_send_audios = 'can_send_audios',                     -- send audios
  can_send_documents = 'can_send_documents',               -- send documents
  can_send_photos = 'can_send_photos',                     -- send photos
  can_send_videos = 'can_send_videos',                     -- send videos
  can_send_video_notes = 'can_send_video_notes',           -- send video notes
  can_send_voice_notes = 'can_send_voice_notes',           -- send voice notes
  can_send_polls = 'can_send_polls',                       -- send polls and checklists
  can_send_other_messages = 'can_send_other_messages',     -- send animations, games, stickers and use inline bots
  can_add_web_page_previews = 'can_add_web_page_previews', -- add web page previews to messages
  can_react_to_messages = 'can_react_to_messages',         -- react to messages, defaults to can_send_messages
  can_edit_tag = 'can_edit_tag',                           -- edit their own tag, defaults to can_pin_messages
  can_change_info = 'can_change_info',                     -- change the chat title, photo and other settings
  can_invite_users = 'can_invite_users',                   -- invite new users to the chat
  can_pin_messages = 'can_pin_messages',                   -- pin messages
  can_manage_topics = 'can_manage_topics',                 -- create forum topics
}

return chat_permissions
