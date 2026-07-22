--- Telegram Bot API method names enum.
-- See: https://core.telegram.org/bots/api
--

--- API method names.
local methods = {
  --
  -- Getting updates
  --
  getUpdates = 'getUpdates',
  setWebhook = 'setWebhook',
  deleteWebhook = 'deleteWebhook',
  getWebhookInfo = 'getWebhookInfo',

  --
  -- Available methods
  --
  getMe = 'getMe',
  logOut = 'logOut',
  close = 'close',
  sendMessage = 'sendMessage',
  forwardMessage = 'forwardMessage',
  copyMessage = 'copyMessage',
  sendPhoto = 'sendPhoto',
  sendAudio = 'sendAudio',
  sendDocument = 'sendDocument',
  sendVideo = 'sendVideo',
  sendAnimation = 'sendAnimation',
  sendVoice = 'sendVoice',
  sendVideoNote = 'sendVideoNote',
  sendMediaGroup = 'sendMediaGroup',
  sendLocation = 'sendLocation',
  editMessageLiveLocation = 'editMessageLiveLocation',
  stopMessageLiveLocation = 'stopMessageLiveLocation',
  sendVenue = 'sendVenue',
  sendContact = 'sendContact',
  sendPoll = 'sendPoll',
  sendDice = 'sendDice',
  sendChatAction = 'sendChatAction',
  getUserProfilePhotos = 'getUserProfilePhotos',
  getFile = 'getFile',
  banChatMember = 'banChatMember',
  unbanChatMember = 'unbanChatMember',
  restrictChatMember = 'restrictChatMember',
  promoteChatMember = 'promoteChatMember',
  setChatAdministratorCustomTitle = 'setChatAdministratorCustomTitle',
  banChatSenderChat = 'banChatSenderChat',
  unbanChatSenderChat = 'unbanChatSenderChat',
  setChatPermissions = 'setChatPermissions',
  exportChatInviteLink = 'exportChatInviteLink',
  createChatInviteLink = 'createChatInviteLink',
  editChatInviteLink = 'editChatInviteLink',
  revokeChatInviteLink = 'revokeChatInviteLink',
  approveChatJoinRequest = 'approveChatJoinRequest',
  declineChatJoinRequest = 'declineChatJoinRequest',
  setChatPhoto = 'setChatPhoto',
  deleteChatPhoto = 'deleteChatPhoto',
  setChatTitle = 'setChatTitle',
  setChatDescription = 'setChatDescription',
  pinChatMessage = 'pinChatMessage',
  unpinChatMessage = 'unpinChatMessage',
  unpinAllChatMessages = 'unpinAllChatMessages',
  leaveChat = 'leaveChat',
  getChat = 'getChat',
  getChatAdministrators = 'getChatAdministrators',
  getChatMemberCount = 'getChatMemberCount',
  getChatMember = 'getChatMember',
  setChatStickerSet = 'setChatStickerSet',
  deleteChatStickerSet = 'deleteChatStickerSet',
  getForumTopicIconStickers = 'getForumTopicIconStickers',
  createForumTopic = 'createForumTopic',
  editForumTopic = 'editForumTopic',
  closeForumTopic = 'closeForumTopic',
  reopenForumTopic = 'reopenForumTopic',
  deleteForumTopic = 'deleteForumTopic',
  unpinAllForumTopicMessages = 'unpinAllForumTopicMessages',
  editGeneralForumTopic = 'editGeneralForumTopic',
  closeGeneralForumTopic = 'closeGeneralForumTopic',
  reopenGeneralForumTopic = 'reopenGeneralForumTopic',
  hideGeneralForumTopic = 'hideGeneralForumTopic',
  unhideGeneralForumTopic = 'unhideGeneralForumTopic',
  unpinAllGeneralForumTopicMessages = 'unpinAllGeneralForumTopicMessages',
  answerCallbackQuery = 'answerCallbackQuery',
  setMyCommands = 'setMyCommands',
  deleteMyCommands = 'deleteMyCommands',
  getMyCommands = 'getMyCommands',
  setMyName = 'setMyName',
  getMyName = 'getMyName',
  setMyDescription = 'setMyDescription',
  getMyDescription = 'getMyDescription',
  setMyShortDescription = 'setMyShortDescription',
  getMyShortDescription = 'getMyShortDescription',
  setChatMenuButton = 'setChatMenuButton',
  getChatMenuButton = 'getChatMenuButton',
  setMyDefaultAdministratorRights = 'setMyDefaultAdministratorRights',
  getMyDefaultAdministratorRights = 'getMyDefaultAdministratorRights',

  --
  -- Chat Boost
  --
  getChatBoostStatus = 'getChatBoostStatus',
  getChatBoostList = 'getChatBoostList',

  --
  -- Business
  --
  getBusinessConnection = 'getBusinessConnection',
  getBusinessConnections = 'getBusinessConnections',
  setBusinessConnectionMenuButton = 'setBusinessConnectionMenuButton',
  setBusinessConnectionCommands = 'setBusinessConnectionCommands',
  setBusinessAccountName = 'setBusinessAccountName',
  setBusinessAccountUsername = 'setBusinessAccountUsername',
  setBusinessAccountBio = 'setBusinessAccountBio',
  setBusinessAccountProfilePhoto = 'setBusinessAccountProfilePhoto',
  removeBusinessAccountProfilePhoto = 'removeBusinessAccountProfilePhoto',
  setBusinessAccountGiftSettings = 'setBusinessAccountGiftSettings',
  getBusinessAccountStarBalance = 'getBusinessAccountStarBalance',
  transferBusinessAccountStars = 'transferBusinessAccountStars',
  getBusinessAccountGifts = 'getBusinessAccountGifts',
  convertGiftToStars = 'convertGiftToStars',
  upgradeGift = 'upgradeGift',
  transferGift = 'transferGift',

  --
  -- Stories
  --
  postStory = 'postStory',
  editStory = 'editStory',
  deleteStory = 'deleteStory',

  --
  -- Updating messages
  --
  editMessageText = 'editMessageText',
  editMessageCaption = 'editMessageCaption',
  editMessageMedia = 'editMessageMedia',
  editMessageReplyMarkup = 'editMessageReplyMarkup',
  stopPoll = 'stopPoll',
  deleteMessage = 'deleteMessage',

  --
  -- Stickers
  --
  sendSticker = 'sendSticker',
  getStickerSet = 'getStickerSet',
  getCustomEmojiStickers = 'getCustomEmojiStickers',
  uploadStickerFile = 'uploadStickerFile',
  createNewStickerSet = 'createNewStickerSet',
  addStickerToSet = 'addStickerToSet',
  setStickerPositionInSet = 'setStickerPositionInSet',
  deleteStickerFromSet = 'deleteStickerFromSet',
  setStickerEmojiList = 'setStickerEmojiList',
  setStickerKeywords = 'setStickerKeywords',
  setStickerMaskPosition = 'setStickerMaskPosition',
  setStickerSetTitle = 'setStickerSetTitle',
  setStickerSetThumbnail = 'setStickerSetThumbnail',
  setCustomEmojiStickerSetThumbnail = 'setCustomEmojiStickerSetThumbnail',
  deleteStickerSet = 'deleteStickerSet',

  --
  -- Inline mode
  --
  answerInlineQuery = 'answerInlineQuery',
  answerWebAppQuery = 'answerWebAppQuery',

  --
  -- Payments
  --
  sendInvoice = 'sendInvoice',
  createInvoiceLink = 'createInvoiceLink',
  answerShippingQuery = 'answerShippingQuery',
  answerPreCheckoutQuery = 'answerPreCheckoutQuery',
  getStarTransactions = 'getStarTransactions',
  refundStarPayment = 'refundStarPayment',
  editUserStarSubscription = 'editUserStarSubscription',

  --
  -- Telegram Passport
  --
  setPassportDataErrors = 'setPassportDataErrors',

  --
  -- Games
  --
  sendGame = 'sendGame',
  setGameScore = 'setGameScore',
  getGameHighScores = 'getGameHighScores',

  --
  -- Chat Background
  --
  setChatBackground = 'setChatBackground',
  deleteChatBackground = 'deleteChatBackground',

  --
  -- Premium
  --
  giftPremiumSubscription = 'giftPremiumSubscription',
}

return methods