-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\ImpChatTranslation.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local logger = require("Core.Log.LoggerManager").getLogger("ImpChatTranslation")
local TEXT_TRANSLATION_CACHE_MAX_COUNT = 500
local CLIENT_LANGUAGE_TO_GME_LANGUAGE_CODE = {
	zh_CN = Const.COUNTRY_LANGUAGES_CODE.CN,
	zh_TW = Const.COUNTRY_LANGUAGES_CODE.CN_TW,
	en = Const.COUNTRY_LANGUAGES_CODE.EN_US,
	ko_KR = Const.COUNTRY_LANGUAGES_CODE.KO_KR,
	ja_JP = Const.COUNTRY_LANGUAGES_CODE.JA_JP,
	vi_VN = Const.COUNTRY_LANGUAGES_CODE.VI_VN,
	ru_RU = Const.COUNTRY_LANGUAGES_CODE.RU_RU,
	de_DE = Const.COUNTRY_LANGUAGES_CODE.DE_DE,
	fr_FR = Const.COUNTRY_LANGUAGES_CODE.FR_FR,
	es_ES = Const.COUNTRY_LANGUAGES_CODE.ES_ES,
	pt_PT = Const.COUNTRY_LANGUAGES_CODE.PT_PT,
	id_ID = Const.COUNTRY_LANGUAGES_CODE.ID_ID,
	th_TH = Const.COUNTRY_LANGUAGES_CODE.TH_TH
}

function ChatSystem:getCurrentGmeLanguageCode()
	return CLIENT_LANGUAGE_TO_GME_LANGUAGE_CODE[pg.game.setting:getLanguage()]
end

function ChatSystem:resetTextTranslationData()
	self:_cancelAllTextTranslationRequests()

	self.textTranslationGeneration = (self.textTranslationGeneration or 0) + 1
	self.textTranslationRecords = {}
	self.textTranslationCacheEntries = {}
	self.textTranslationCacheNextIndex = 1
	self.textTranslationLanguage = nil
end

function ChatSystem:translateText(text, sourceClientLanguage, callback, owner)
	if string.isNilOrEmpty(sourceClientLanguage) or callback == nil then
		return false
	end

	local sourceLanguage = CLIENT_LANGUAGE_TO_GME_LANGUAGE_CODE[sourceClientLanguage]
	local targetClientLanguage = pg.game.setting:getLanguage()
	local translateLanguage = CLIENT_LANGUAGE_TO_GME_LANGUAGE_CODE[targetClientLanguage]

	if sourceLanguage == nil or translateLanguage == nil then
		self:cancelTextTranslationOwner(owner)

		return false
	end

	self:_updateTextTranslationLanguage(translateLanguage)

	if text == "" or sourceLanguage == translateLanguage then
		self:cancelTextTranslationOwner(owner)
		callback(true, text)

		return true
	end

	local languageRecords = self.textTranslationRecords[sourceLanguage]
	local translatedText = languageRecords and languageRecords[text]

	if translatedText ~= nil then
		self:cancelTextTranslationOwner(owner)
		callback(true, translatedText)

		return true
	end

	local languageRequests = self.pendingTextTranslationRequests[sourceLanguage]
	local request = languageRequests and languageRequests[text]

	if request and owner ~= nil and self.textTranslationOwnerRequests[owner] == request then
		return true
	end

	self:cancelTextTranslationOwner(owner)

	if request then
		self:_addTextTranslationCallback(request, callback, owner)

		return true
	end

	request = {
		text = text,
		sourceLanguage = sourceLanguage,
		callbacks = {},
		owners = {}
	}

	if languageRequests == nil then
		languageRequests = {}
		self.pendingTextTranslationRequests[sourceLanguage] = languageRequests
	end

	languageRequests[text] = request

	self:_addTextTranslationCallback(request, callback, owner)

	local translateCallback = CallbackHandler(self, "_onTextTranslated", self.textTranslationGeneration, request)

	pg.global.gmeManager:TranslateText(text, sourceLanguage, translateLanguage, translateCallback)

	return true
end

function ChatSystem:_addTextTranslationCallback(request, callback, owner)
	local callbackKey = owner or callback

	request.callbacks[callbackKey] = callback

	if owner ~= nil then
		request.owners[owner] = true
		self.textTranslationOwnerRequests[owner] = request
	end
end

function ChatSystem:cancelTextTranslationOwner(owner)
	if owner == nil or self.textTranslationOwnerRequests == nil then
		return false
	end

	local request = self.textTranslationOwnerRequests[owner]

	if request == nil then
		return false
	end

	self.textTranslationOwnerRequests[owner] = nil
	request.callbacks[owner] = nil
	request.owners[owner] = nil

	return true
end

function ChatSystem:_isPendingTextTranslationRequest(request)
	local languageRequests = self.pendingTextTranslationRequests[request.sourceLanguage]

	return languageRequests ~= nil and languageRequests[request.text] == request
end

function ChatSystem:_removePendingTextTranslationRequest(request)
	local languageRequests = self.pendingTextTranslationRequests[request.sourceLanguage]

	if languageRequests == nil or languageRequests[request.text] ~= request then
		return
	end

	languageRequests[request.text] = nil

	if next(languageRequests) == nil then
		self.pendingTextTranslationRequests[request.sourceLanguage] = nil
	end
end

function ChatSystem:_updateTextTranslationLanguage(translateLanguage)
	if self.textTranslationLanguage == translateLanguage then
		return
	end

	self:_cancelAllTextTranslationRequests()

	self.textTranslationGeneration = self.textTranslationGeneration + 1
	self.textTranslationRecords = {}
	self.textTranslationCacheEntries = {}
	self.textTranslationCacheNextIndex = 1
	self.textTranslationLanguage = translateLanguage
end

function ChatSystem:_cancelAllTextTranslationRequests()
	for _, languageRequests in pairs(self.pendingTextTranslationRequests or EMPTY_TABLE) do
		for _, request in pairs(languageRequests) do
			request.callbacks = nil
			request.owners = nil
		end
	end

	self.pendingTextTranslationRequests = {}
	self.textTranslationOwnerRequests = {}
end

function ChatSystem:_onTextTranslated(generation, request, requestId, success, targetText)
	if generation ~= self.textTranslationGeneration then
		return
	end

	if not self:_isPendingTextTranslationRequest(request) then
		return
	end

	self:_removePendingTextTranslationRequest(request)

	if success ~= true or string.isNilOrEmpty(targetText) then
		logger:warning("Translate text failed: requestId=%s", tostring(requestId))
		self:_notifyTextTranslationCallbacks(request, false, nil)

		return
	end

	self:_cacheTextTranslation(request.sourceLanguage, request.text, targetText)
	self:_notifyTextTranslationCallbacks(request, true, targetText)
end

function ChatSystem:_cacheTextTranslation(sourceLanguage, sourceText, translatedText)
	local cacheEntries = self.textTranslationCacheEntries
	local cacheIndex = #cacheEntries + 1

	if cacheIndex > TEXT_TRANSLATION_CACHE_MAX_COUNT then
		cacheIndex = self.textTranslationCacheNextIndex

		self:_removeTextTranslationCacheEntry(cacheEntries[cacheIndex])

		self.textTranslationCacheNextIndex = cacheIndex % TEXT_TRANSLATION_CACHE_MAX_COUNT + 1
	end

	local languageRecords = self.textTranslationRecords[sourceLanguage]

	if languageRecords == nil then
		languageRecords = {}
		self.textTranslationRecords[sourceLanguage] = languageRecords
	end

	languageRecords[sourceText] = translatedText
	cacheEntries[cacheIndex] = {
		sourceLanguage = sourceLanguage,
		sourceText = sourceText
	}
end

function ChatSystem:_removeTextTranslationCacheEntry(cacheEntry)
	local languageRecords = self.textTranslationRecords[cacheEntry.sourceLanguage]

	languageRecords[cacheEntry.sourceText] = nil

	if next(languageRecords) == nil then
		self.textTranslationRecords[cacheEntry.sourceLanguage] = nil
	end
end

function ChatSystem:_notifyTextTranslationCallbacks(request, success, translatedText)
	for callbackKey, callback in pairs(request.callbacks) do
		local isCurrentOwner = request.owners[callbackKey] == true and self.textTranslationOwnerRequests[callbackKey] == request

		if isCurrentOwner then
			self.textTranslationOwnerRequests[callbackKey] = nil
		end

		callback(success, translatedText)
	end

	request.callbacks = {}
	request.owners = {}
end
