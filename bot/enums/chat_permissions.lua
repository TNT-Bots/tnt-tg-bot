--- Chat permissions enum.
-- See: https://core.telegram.org/bots/api#chatpermissions
--

--- Chat permission names.
local chat_permissions = {
  can_send_messages = 'can_send_messages',
  can_send_audios = 'can_send_audios',
  can_send_documents = 'can_send_documents',
  can_send_photos = 'can_send_photos',
  can_send_videos = 'can_send_videos',
  can_send_video_notes = 'can_send_video_notes',
  can_send_voice_notes = 'can_send_voice_notes',
  can_send_polls = 'can_send_polls',
  can_send_other_messages = 'can_send_other_messages',
  can_add_web_page_previews = 'can_add_web_page_previews',
  can_change_info = 'can_change_info',
  can_invite_users = 'can_invite_users',
  can_pin_messages = 'can_pin_messages',
  can_manage_topics = 'can_manage_topics',
}

return chat_permissions
