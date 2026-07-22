--- Telegram Bot API method names enum.
-- See: https://core.telegram.org/bots/api
--

--- API method names.
-- @table methods
local methods = {
  getUpdates = 'getUpdates', -- Getting updates
  setWebhook = 'setWebhook',
  deleteWebhook = 'deleteWebhook',
  getWebhookInfo = 'getWebhookInfo',

  getMe = 'getMe', -- Available methods
  logOut = 'logOut',
  close = 'close',
  sendMessage = 'sendMessage',
  forwardMessage = 'forwardMessage',
  forwardMessages = 'forwardMessages',
  copyMessage = 'copyMessage',
  copyMessages = 'copyMessages',
  sendPhoto = 'sendPhoto',
  sendLivePhoto = 'sendLivePhoto',
  sendAudio = 'sendAudio',
  sendDocument = 'sendDocument',
  sendVideo = 'sendVideo',
  sendAnimation = 'sendAnimation',
  sendVoice = 'sendVoice',
  sendVideoNote = 'sendVideoNote',
  sendMediaGroup = 'sendMediaGroup',
  sendPaidMedia = 'sendPaidMedia',
  sendLocation = 'sendLocation',
  editMessageLiveLocation = 'editMessageLiveLocation',
  stopMessageLiveLocation = 'stopMessageLiveLocation',
  sendVenue = 'sendVenue',
  sendContact = 'sendContact',
  sendPoll = 'sendPoll',
  sendDice = 'sendDice',
  sendChatAction = 'sendChatAction',
  getUserProfilePhotos = 'getUserProfilePhotos',
  getUserProfileAudios = 'getUserProfileAudios',
  getUserPersonalChatMessages = 'getUserPersonalChatMessages',
  getUserChatBoosts = 'getUserChatBoosts',
  setUserEmojiStatus = 'setUserEmojiStatus',
  getFile = 'getFile',
  banChatMember = 'banChatMember',
  unbanChatMember = 'unbanChatMember',
  restrictChatMember = 'restrictChatMember',
  promoteChatMember = 'promoteChatMember',
  setChatAdministratorCustomTitle = 'setChatAdministratorCustomTitle',
  setChatMemberTag = 'setChatMemberTag',
  banChatSenderChat = 'banChatSenderChat',
  unbanChatSenderChat = 'unbanChatSenderChat',
  setChatPermissions = 'setChatPermissions',
  exportChatInviteLink = 'exportChatInviteLink',
  createChatInviteLink = 'createChatInviteLink',
  editChatInviteLink = 'editChatInviteLink',
  revokeChatInviteLink = 'revokeChatInviteLink',
  createChatSubscriptionInviteLink = 'createChatSubscriptionInviteLink',
  editChatSubscriptionInviteLink = 'editChatSubscriptionInviteLink',
  approveChatJoinRequest = 'approveChatJoinRequest',
  declineChatJoinRequest = 'declineChatJoinRequest',
  answerChatJoinRequestQuery = 'answerChatJoinRequestQuery',
  sendChatJoinRequestWebApp = 'sendChatJoinRequestWebApp',
  answerGuestQuery = 'answerGuestQuery',
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
  setMyProfilePhoto = 'setMyProfilePhoto',
  removeMyProfilePhoto = 'removeMyProfilePhoto',
  setChatMenuButton = 'setChatMenuButton',
  getChatMenuButton = 'getChatMenuButton',
  setMyDefaultAdministratorRights = 'setMyDefaultAdministratorRights',
  getMyDefaultAdministratorRights = 'getMyDefaultAdministratorRights',

  setMessageReaction = 'setMessageReaction', -- Reactions
  deleteMessageReaction = 'deleteMessageReaction',
  deleteAllMessageReactions = 'deleteAllMessageReactions',

  verifyUser = 'verifyUser', -- Verification
  verifyChat = 'verifyChat',
  removeUserVerification = 'removeUserVerification',
  removeChatVerification = 'removeChatVerification',

  getBusinessConnection = 'getBusinessConnection', -- Business
  readBusinessMessage = 'readBusinessMessage',
  deleteBusinessMessages = 'deleteBusinessMessages',
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

  getAvailableGifts = 'getAvailableGifts', -- Gifts
  sendGift = 'sendGift',
  getChatGifts = 'getChatGifts',
  getUserGifts = 'getUserGifts',

  postStory = 'postStory', -- Stories
  editStory = 'editStory',
  deleteStory = 'deleteStory',
  repostStory = 'repostStory',

  editMessageText = 'editMessageText', -- Updating messages
  editMessageCaption = 'editMessageCaption',
  editMessageMedia = 'editMessageMedia',
  editMessageReplyMarkup = 'editMessageReplyMarkup',
  stopPoll = 'stopPoll',
  deleteMessage = 'deleteMessage',
  deleteMessages = 'deleteMessages',

  sendChecklist = 'sendChecklist', -- Checklists
  editMessageChecklist = 'editMessageChecklist',

  approveSuggestedPost = 'approveSuggestedPost', -- Suggested posts
  declineSuggestedPost = 'declineSuggestedPost',

  deleteEphemeralMessage = 'deleteEphemeralMessage', -- Ephemeral messages
  editEphemeralMessageText = 'editEphemeralMessageText',
  editEphemeralMessageCaption = 'editEphemeralMessageCaption',
  editEphemeralMessageMedia = 'editEphemeralMessageMedia',
  editEphemeralMessageReplyMarkup = 'editEphemeralMessageReplyMarkup',

  sendMessageDraft = 'sendMessageDraft', -- Drafts and rich messages
  sendRichMessage = 'sendRichMessage',
  sendRichMessageDraft = 'sendRichMessageDraft',

  sendSticker = 'sendSticker', -- Stickers
  getStickerSet = 'getStickerSet',
  getCustomEmojiStickers = 'getCustomEmojiStickers',
  uploadStickerFile = 'uploadStickerFile',
  createNewStickerSet = 'createNewStickerSet',
  addStickerToSet = 'addStickerToSet',
  replaceStickerInSet = 'replaceStickerInSet',
  setStickerPositionInSet = 'setStickerPositionInSet',
  deleteStickerFromSet = 'deleteStickerFromSet',
  setStickerEmojiList = 'setStickerEmojiList',
  setStickerKeywords = 'setStickerKeywords',
  setStickerMaskPosition = 'setStickerMaskPosition',
  setStickerSetTitle = 'setStickerSetTitle',
  setStickerSetThumbnail = 'setStickerSetThumbnail',
  setCustomEmojiStickerSetThumbnail = 'setCustomEmojiStickerSetThumbnail',
  deleteStickerSet = 'deleteStickerSet',

  answerInlineQuery = 'answerInlineQuery', -- Inline mode
  answerWebAppQuery = 'answerWebAppQuery',
  savePreparedInlineMessage = 'savePreparedInlineMessage',
  savePreparedKeyboardButton = 'savePreparedKeyboardButton',

  sendInvoice = 'sendInvoice', -- Payments
  createInvoiceLink = 'createInvoiceLink',
  answerShippingQuery = 'answerShippingQuery',
  answerPreCheckoutQuery = 'answerPreCheckoutQuery',
  getMyStarBalance = 'getMyStarBalance',
  getStarTransactions = 'getStarTransactions',
  refundStarPayment = 'refundStarPayment',
  editUserStarSubscription = 'editUserStarSubscription',

  getManagedBotToken = 'getManagedBotToken', -- Managed bots
  replaceManagedBotToken = 'replaceManagedBotToken',
  getManagedBotAccessSettings = 'getManagedBotAccessSettings',
  setManagedBotAccessSettings = 'setManagedBotAccessSettings',

  setPassportDataErrors = 'setPassportDataErrors', -- Telegram Passport

  sendGame = 'sendGame', -- Games
  setGameScore = 'setGameScore',
  getGameHighScores = 'getGameHighScores',

  giftPremiumSubscription = 'giftPremiumSubscription', -- Premium
}

return methods
