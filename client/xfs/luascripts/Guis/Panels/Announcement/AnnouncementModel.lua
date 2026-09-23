-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Announcement\\AnnouncementModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local AnnouncementModel = Class.LightClass("AnnouncementModel", UIModel)
local UIConst = require("Const.UIConst")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local json = require("json")
local CommonConst = require("Common.Const.Const")
local GameVersion = require("Common.GameVersion")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local GlobalData = require("Core.Client.GlobalData")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local ClientUtils = require("Utils.ClientUtils")
local AnnouncementServerIDData = require("Data.server_group_to_announcement")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local ANNOUNCEMENT_LIST_HOST = "announcement-web-stage.funplus.com.cn"
local ANNOUNCEMENT_LIST = "/api/announce/list"
local ANNOUNCEMENT_DETAIL = "/api/announce/detail"
local GAME_PROJECT = "worldx.cn.prod"
local headers = {
	["Content-Type"] = "application/json"
}
local EMediaType = {
	[136] = {
		name = "bilibili",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_BiliBili
	},
	[137] = {
		name = "taptap",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_TapTap
	},
	[138] = {
		name = "douyin",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_TikTok
	},
	[139] = {
		name = "guanwan",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_OfficialWebsite
	},
	[140] = {
		name = "weibo",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_Microblog
	},
	[141] = {
		name = "weixin",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_WeChat
	},
	[142] = {
		name = "xiaohongshu",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_LittleRedBook
	},
	[143] = {
		name = "discord",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_Discord
	},
	[144] = {
		name = "facebook",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_FaceBook
	},
	[145] = {
		name = "instagram",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_Instagram
	},
	[146] = {
		name = "x",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_X
	},
	[147] = {
		name = "youtube",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_YouTube
	},
	[148] = {
		name = "guanwan",
		iconUrl = AddressDataConst.ANNOUNCEMENT_ICON.UI_Img_OfficialWebsite
	}
}
local listIndex = 1
local ANNOUNCEMENT_LANGUAGE_TO_TRANSLATE_LANGUAGE_CODE = {
	["zh-cn"] = CommonConst.COUNTRY_LANGUAGES_CODE.CN,
	["zh-hk"] = CommonConst.COUNTRY_LANGUAGES_CODE.CN_HK,
	["yue-hk"] = CommonConst.COUNTRY_LANGUAGES_CODE.GD_HK,
	["zh-tw"] = CommonConst.COUNTRY_LANGUAGES_CODE.CN_TW,
	ko = CommonConst.COUNTRY_LANGUAGES_CODE.KO_KR,
	ja = CommonConst.COUNTRY_LANGUAGES_CODE.JA_JP,
	en = CommonConst.COUNTRY_LANGUAGES_CODE.EN_US,
	ru = CommonConst.COUNTRY_LANGUAGES_CODE.RU_RU,
	it = CommonConst.COUNTRY_LANGUAGES_CODE.IT_IT,
	fr = CommonConst.COUNTRY_LANGUAGES_CODE.FR_FR,
	es = CommonConst.COUNTRY_LANGUAGES_CODE.ES_ES,
	pt = CommonConst.COUNTRY_LANGUAGES_CODE.PT_PT,
	fil = CommonConst.COUNTRY_LANGUAGES_CODE.FIL_PH,
	vi = CommonConst.COUNTRY_LANGUAGES_CODE.VI_VN,
	de = CommonConst.COUNTRY_LANGUAGES_CODE.DE_DE,
	id = CommonConst.COUNTRY_LANGUAGES_CODE.ID_ID,
	th = CommonConst.COUNTRY_LANGUAGES_CODE.TH_TH
}

function AnnouncementModel:ctor()
	self.id = ""
	self.count = 0
	self.singleDetail = {}
	self.announcementList = {}
	self.announcementIDList = {}
	self.announcementDetailList = {}
	self.translationRequestIds = {}

	self:resetTranslationCache()
end

function AnnouncementModel:resetTranslationCache()
	self.translationGeneration = (self.translationGeneration or 0) + 1
	self.translationCache = {}
end

function AnnouncementModel:getAnnouncementDetail()
	local id = self:getSelCurId()

	if not self.announcementDetailList then
		return nil
	end

	for annId, v in pairs(self.announcementDetailList) do
		if annId == id then
			return v
		end
	end
end

function AnnouncementModel:getTargetAnnouncementLanguage()
	local languageType = pg.languageType or 0

	if pg.game and pg.game.setting then
		languageType = pg.game.setting:getLanguageType()
	end

	return ClientConst.SDK_ANNOUNCEMENT_LANGUAGE_TYPE_DESC_MAP[languageType]
end

function AnnouncementModel:normalizeAnnouncementLanguage(language)
	if type(language) == "number" then
		return ClientConst.SDK_ANNOUNCEMENT_LANGUAGE_TYPE_DESC_MAP[language]
	end

	if type(language) ~= "string" or language == "" then
		return nil
	end

	local languageType = ClientConst.LANGUAGE_TYPE_MAP[language]

	if languageType ~= nil then
		return ClientConst.SDK_ANNOUNCEMENT_LANGUAGE_TYPE_DESC_MAP[languageType]
	end

	return string.lower(string.gsub(language, "_", "-"))
end

function AnnouncementModel:getTranslateLanguageCode(language)
	local announcementLanguage = self:normalizeAnnouncementLanguage(language)

	return announcementLanguage and ANNOUNCEMENT_LANGUAGE_TO_TRANSLATE_LANGUAGE_CODE[announcementLanguage] or nil
end

function AnnouncementModel:canTranslateLanguage(sourceLanguage, targetLanguage)
	sourceLanguage = self:normalizeAnnouncementLanguage(sourceLanguage)
	targetLanguage = self:normalizeAnnouncementLanguage(targetLanguage)

	if not sourceLanguage or not targetLanguage or sourceLanguage == targetLanguage then
		return false
	end

	return self:getTranslateLanguageCode(sourceLanguage) ~= nil and self:getTranslateLanguageCode(targetLanguage) ~= nil
end

function AnnouncementModel:getSelectedAnnouncement()
	local announcementId = self:getSelCurId()

	for _, announcement in ipairs(self.announcementList or EMPTY_TABLE) do
		if announcement.id == announcementId then
			return announcement
		end
	end

	return nil
end

function AnnouncementModel:getSelectedAnnouncementDetail()
	local detailList = self:getAnnouncementDetail()

	return detailList and detailList[1] or nil
end

function AnnouncementModel:canTranslateSelectedAnnouncement()
	local announcement = self:getSelectedAnnouncement()
	local targetLanguage = self:getTargetAnnouncementLanguage()

	return announcement and self:canTranslateLanguage(announcement.lang, targetLanguage) or false
end

function AnnouncementModel:_getTranslationCache(announcementId, targetLanguage, createIfMissing)
	self.translationCache = self.translationCache or {}

	local announcementCache = self.translationCache[announcementId]

	if not announcementCache and createIfMissing then
		announcementCache = {}
		self.translationCache[announcementId] = announcementCache
	end

	local translationCache = announcementCache and announcementCache[targetLanguage]

	if not translationCache and createIfMissing then
		translationCache = {
			content = {},
			pending = {}
		}
		announcementCache[targetLanguage] = translationCache
	end

	return translationCache
end

function AnnouncementModel:_getContentSourceText(contentData)
	return contentData.tIndex == 0 and contentData.title or contentData.text
end

function AnnouncementModel:_getContentCacheKey(contentData)
	return string.format("content:%s:%s", tostring(contentData.tIndex), tostring(contentData.sort))
end

function AnnouncementModel:getAnnouncementTitle(announcement, useTranslation)
	if not useTranslation then
		return announcement.title
	end

	local targetLanguage = self:getTargetAnnouncementLanguage()
	local translationCache = self:_getTranslationCache(announcement.id, targetLanguage, false)

	return translationCache and translationCache.title or announcement.title
end

function AnnouncementModel:getAnnouncementContentText(contentData, useTranslation)
	local sourceText = self:_getContentSourceText(contentData)

	if not useTranslation then
		return sourceText
	end

	local targetLanguage = self:getTargetAnnouncementLanguage()
	local translationCache = self:_getTranslationCache(self:getSelCurId(), targetLanguage, false)
	local cacheKey = self:_getContentCacheKey(contentData)

	return translationCache and translationCache.content[cacheKey] or sourceText
end

function AnnouncementModel:_requestTranslation(announcementId, cacheKey, text, sourceLanguage, targetLanguage, callback)
	sourceLanguage = self:normalizeAnnouncementLanguage(sourceLanguage)
	targetLanguage = self:normalizeAnnouncementLanguage(targetLanguage)

	if not text or not self:canTranslateLanguage(sourceLanguage, targetLanguage) then
		return
	end

	local translateSourceLanguage = self:getTranslateLanguageCode(sourceLanguage)
	local translateTargetLanguage = self:getTranslateLanguageCode(targetLanguage)
	local translationCache = self:_getTranslationCache(announcementId, targetLanguage, true)
	local translatedText = cacheKey == "title" and translationCache.title or translationCache.content[cacheKey]

	if translatedText or translationCache.pending[cacheKey] then
		return
	end

	translationCache.pending[cacheKey] = true

	local translationGeneration = self.translationGeneration
	local requestCompleted = false
	local requestId = pg.global.gmeManager:TranslateText(text, translateSourceLanguage, translateTargetLanguage, function(completedRequestId, success, result)
		requestCompleted = true

		if self.translationRequestIds then
			self.translationRequestIds[completedRequestId] = nil
		end

		if self.translationGeneration ~= translationGeneration then
			return
		end

		translationCache.pending[cacheKey] = nil

		if not success or not result or result == "" then
			return
		end

		if cacheKey == "title" then
			translationCache.title = result
		else
			translationCache.content[cacheKey] = result
		end

		if callback then
			callback(cacheKey, announcementId, targetLanguage)
		end
	end)

	if requestId and not requestCompleted then
		self.translationRequestIds = self.translationRequestIds or {}
		self.translationRequestIds[requestId] = true
	end
end

function AnnouncementModel:cancelTranslationRequests()
	local requestIds = self.translationRequestIds

	self.translationRequestIds = {}

	for requestId in pairs(requestIds or EMPTY_TABLE) do
		pg.global.gmeManager:CancelTranslateText(requestId)
	end
end

function AnnouncementModel:translateAnnouncementTitle(announcement, callback)
	local targetLanguage = self:getTargetAnnouncementLanguage()

	self:_requestTranslation(announcement.id, "title", announcement.title, announcement.lang, targetLanguage, callback)
end

function AnnouncementModel:translateCurrentAnnouncement(callback)
	local announcement = self:getSelectedAnnouncement()
	local detail = self:getSelectedAnnouncementDetail()

	if not announcement or not detail then
		return
	end

	local sourceLanguage = detail.lang or announcement.lang
	local targetLanguage = self:getTargetAnnouncementLanguage()

	if not self:canTranslateLanguage(sourceLanguage, targetLanguage) then
		return
	end

	for _, contentData in ipairs(detail.content or EMPTY_TABLE) do
		if contentData.tIndex == 0 or contentData.tIndex == 2 then
			local cacheKey = self:_getContentCacheKey(contentData)
			local sourceText = self:_getContentSourceText(contentData)

			self:_requestTranslation(announcement.id, cacheKey, sourceText, sourceLanguage, targetLanguage, callback)
		end
	end
end

function AnnouncementModel:translateAllAnnouncementTitles(callback)
	for _, announcement in ipairs(self.announcementList or EMPTY_TABLE) do
		self:translateAnnouncementTitle(announcement, callback)
	end
end

function AnnouncementModel:getAnnouncementData(opentype, silent)
	self.isOpen = opentype
	self.endTime = 0
	self.opentype = opentype
	self.silentRefresh = silent or false

	self:reqAnnouncementList()
end

function AnnouncementModel:getAnnouncementLang()
	local announcementLanguage = self:getTargetAnnouncementLanguage()

	return announcementLanguage or "zh-cn"
end

function AnnouncementModel:reqAnnouncementList()
	local isCn = ClientConfigAppCountry == "cn"

	if SDKLoginConfig.isEnabled() then
		ANNOUNCEMENT_LIST_HOST = isCn and "announcement-web.funplus.com.cn" or "announcement-web.funplus.com"

		if not UNITY_PS5 or not self.silentRefresh then
			csSDKManager.PatchFlowSDKLog(30005, "", "", "")
		end
	else
		ANNOUNCEMENT_LIST_HOST = isCn and "announcement-web-stage.funplus.com.cn" or "announcement-web-stage.funplus.com"
	end

	self:resetTranslationCache()

	self.singleDetail = {}
	self.announcementDetailList = {}

	local function cb(reply)
		if reply.err == 0 then
			local status, result = pcall(json.decode, reply.body)

			if status and type(result) == "table" then
				local list = {}

				if result.data then
					list = result.data.list
					self.count = result.data.total
				end

				self.isEmpty = not list or not (#list > 0)

				if list and #list > 0 then
					self:paresAnnouncementList(list)
				elseif self.isEmpty and self.isOpen then
					self.isOpen = false

					pg.global.ui:open(UIConst.UI_ID_ANNOUNCEMENT)
				end

				pg.global.refreshRedDotState(RedDotConst.RedDotPath.ANNOUNCEMENT)
			end
		end
	end

	local proxy = HttpClientProxy()
	local requestBody = self:getRequestBody()
	local body = json.encode(requestBody)
	local request = HttpRequest(ANNOUNCEMENT_LIST_HOST, nil, "POST", ANNOUNCEMENT_LIST, headers, body, true)

	proxy:httpRequest(request, 5000, cb, false)
end

function AnnouncementModel:getRequestBody()
	local isCn = ClientConfigAppCountry == "cn"
	local me = pg.me
	local info = {
		page_index = 1,
		iswebpreview = true,
		type = 2,
		sub_channel = "",
		ssl = true,
		page_size = 10,
		game_project = self:getGameProject(),
		os = self:getCurPlatform(),
		channel = self:getCurChannelID(),
		country = isCn and "CN" or "EN",
		lang = self:getAnnouncementLang(),
		version = self:getFullVersion() or "1",
		server_id = tostring(self:getServerIndex()),
		player_level = me and me.level and tostring(me.level) or "",
		role_id = me and me.uid and tostring(me.uid) or "",
		package_id = self:getCurPkgChannel() or ""
	}

	return info
end

function AnnouncementModel:reqAnnouncementDetail(id)
	local function cb(reply)
		if reply.err == 0 then
			local status, result = pcall(json.decode, reply.body)

			if status and type(result) == "table" then
				self:paresAnnouncementDetail(result.data, id)
			end
		end
	end

	local requestBody = {
		announcement_id = id,
		lang = self:getAnnouncementLang()
	}
	local body = json.encode(requestBody)
	local proxy = HttpClientProxy()
	local request = HttpRequest(ANNOUNCEMENT_LIST_HOST, nil, "POST", ANNOUNCEMENT_DETAIL, headers, body, true)

	proxy:httpRequest(request, 5000, cb, false)
end

function AnnouncementModel:getLeftTime()
	return self.endTime
end

function AnnouncementModel:getCurState()
	return self.isMedia and 1 or 0
end

function AnnouncementModel:getCurEmpty()
	return self.isEmpty and 1 or 0
end

function AnnouncementModel:getCurStateByConfData()
	return self.isMedia
end

function AnnouncementModel:setSelCurId(id)
	self.id = id
end

function AnnouncementModel:getSelCurId()
	return self.id
end

function AnnouncementModel:getCurChannelID()
	local sdkManager = pg.global and pg.global.sdkManager
	local channelId = sdkManager and sdkManager:getChannelId() or ""

	if not channelId or channelId == "" then
		return "Funplus-PC"
	end

	return channelId
end

function AnnouncementModel:getCurPkgChannel()
	local sdkManager = pg.global and pg.global.sdkManager
	local playerChannel = sdkManager and sdkManager:getPkgChannel() or ""

	if not playerChannel or playerChannel == "" then
		return "Funplus-PC"
	end

	return playerChannel
end

function AnnouncementModel:getFullVersion()
	if not ClientFullVersion or ClientFullVersion == "" then
		return "1"
	end

	return ClientFullVersion
end

function AnnouncementModel:getCurPlatform()
	local platform = "win"

	if UNITY_ANDROID then
		platform = "android"
	elseif UNITY_IOS then
		platform = "ios"
	elseif UNITY_OPENHARMONY then
		platform = "harmony"
	end

	return platform
end

function AnnouncementModel:getGameProject()
	return ClientConfigAppCountry == "cn" and "worldx.cn.prod" or "worldx.global.prod"
end

function AnnouncementModel:getServerIndex()
	local server_id = ""

	for i, v in pairs(AnnouncementServerIDData) do
		if v.name == ClientUtils.getServerListGroup() then
			server_id = i
		end
	end

	return server_id
end

function AnnouncementModel:paresAnnouncementList(list)
	self.announcementList = {}
	self.announcementIDList = {}
	self.id = ""

	for k, item in ipairs(list) do
		local announcement = {}

		announcement.title = item.title
		announcement.id = item.announcement_id
		announcement.channel = item.channel_key
		announcement.game_project = item.game_project
		announcement.lang = item.lang
		announcement.tag = item.tag or ""
		announcement.is_new = announcement.tag ~= ""
		announcement.detail = {}

		if self.id == "" and not self.silentRefresh then
			listIndex = 1
			self.id = item.announcement_id

			self:reqAnnouncementDetail(self.id)
		end

		self.announcementList[#self.announcementList + 1] = announcement
		self.announcementIDList[#self.announcementIDList + 1] = item.announcement_id
	end

	self:getSaveLastAnnouncementId()
end

function AnnouncementModel:paresAnnouncementDetail(data, curId)
	local temp = {}

	self.singleDetail = {}

	local contTemp = {}

	temp.content = {}
	temp.media_list = {}
	temp.id = curId

	for k, v in pairs(data) do
		if k == "title" then
			temp.title = v
		elseif k == "sub_title" then
			temp.sub_title = v
			contTemp = {}
			contTemp.tIndex = 0
			contTemp.sort = 0
			contTemp.title = v
			temp.content[#temp.content + 1] = contTemp
		elseif k == "content" then
			local contList = json.decode(v)

			for i, item in ipairs(contList) do
				if item.text then
					contTemp = {}
					contTemp.tIndex = 2
					contTemp.sort = i
					contTemp.text = item.text
					temp.content[#temp.content + 1] = contTemp
				elseif item.img then
					contTemp = {
						tIndex = item.img_extend ~= "" and 3 or 1,
						sort = i,
						image = item.img
					}
					contTemp.sprite = ""
					temp.content[#temp.content + 1] = contTemp
				end
			end
		elseif k == "lang" then
			temp.lang = v
		elseif k == "media_list" then
			for i = 1, #v do
				self.isMedia = true

				local mediaList = {}

				mediaList.media_id = tonumber(v[i].media_id)
				mediaList.media_url = v[i].media_url
				temp.media_list[#temp.media_list + 1] = mediaList
			end
		elseif k == "end_time" then
			temp.end_time = tonumber(v) or 0
			self.endTime = temp.end_time
		end
	end

	table.sort(temp.content, function(a, b)
		return a.sort < b.sort
	end)

	self.singleDetail[#self.singleDetail + 1] = temp

	if self.isMedia then
		self.id = curId
		listIndex = self.count
	end

	self:setAnnouncementListDetail(curId)
end

function AnnouncementModel:setImageUrlToSprite(curId)
	local lastImgIndex = self:getLastImg()
	local isCompletion = 0

	for i, v in pairs(self.singleDetail) do
		for k, m in ipairs(v.content) do
			if m.tIndex == 1 or m.tIndex == 3 then
				isCompletion = isCompletion + 1

				UIUtils.SetTextureByUrl(m.image, function(image)
					self.singleDetail[1].content[k].sprite = image
					isCompletion = isCompletion - 1

					if isCompletion == 0 then
						self:setAnnouncementListDetail(curId)
					end
				end)
			elseif lastImgIndex == 0 and k == #v.content then
				self:setAnnouncementListDetail(curId)
			end
		end
	end
end

function AnnouncementModel:setAnnouncementListDetail(curId)
	if self.announcementDetailList[curId] == nil then
		self.announcementDetailList[curId] = self.singleDetail
		listIndex = listIndex + 1

		if listIndex <= self.count and self.announcementList and self.announcementList[listIndex] then
			self:reqAnnouncementDetail(self.announcementList[listIndex].id)
		end

		if listIndex >= self.count then
			self:paresDataCompletion(curId)
		end
	end
end

function AnnouncementModel:getLastImg()
	local lastImgIndex = 0

	for i, v in pairs(self.singleDetail) do
		for k, m in ipairs(v.content) do
			if m.tIndex == 1 then
				lastImgIndex = k
			end
		end
	end

	return lastImgIndex
end

function AnnouncementModel:getAnnouncementMediaList()
	local mediaList = {}

	if self.isMedia then
		local detail = self:getAnnouncementDetail()

		if detail and detail[1] and #detail[1].media_list > 0 then
			for k, m in pairs(detail[1].media_list) do
				local mediaTb = EMediaType[tonumber(m.media_id)]

				m.iconUrl = mediaTb.iconUrl
				mediaList[#mediaList + 1] = m
			end
		end
	end

	return mediaList
end

function AnnouncementModel:paresDataCompletion()
	if self.silentRefresh then
		return
	end

	if self.isOpen or self:redDot_GetPointDotState() then
		self.isOpen = false

		pg.global.ui:open(UIConst.UI_ID_ANNOUNCEMENT)
	end
end

function AnnouncementModel:getAnnouncementList()
	return self.announcementList
end

function AnnouncementModel:saveLastAnnouncementId()
	local viewedIds = {}

	if self.announcementList then
		for i, v in ipairs(self.announcementList) do
			if not v.is_new then
				viewedIds[#viewedIds + 1] = v.id .. "|" .. (v.tag or "")
			end
		end
	end

	local idjson = json.encode(viewedIds)

	pg.global.prefsCacheUtils:setString("announcement_id", idjson)
end

function AnnouncementModel:setRedPointState(id)
	for i, v in ipairs(self.announcementIDList) do
		if id == v then
			self.announcementList[i].is_new = false

			break
		end
	end
end

function AnnouncementModel:getRedPointState(id)
	if not self.announcementIDList then
		return false
	end

	local new = false

	for i, v in pairs(self.announcementIDList) do
		if id == v then
			new = self.announcementList[i].is_new

			break
		end
	end

	return new
end

function AnnouncementModel:getSaveLastAnnouncementId()
	if not self.announcementIDList then
		return
	end

	local preList = pg.global.prefsCacheUtils:getString("announcement_id")
	local preListTb = {}

	if preList ~= "" then
		preListTb = json.decode(preList) or {}
	end

	local needSave = false

	for i, v in pairs(self.announcementIDList) do
		if (self.announcementList[i].tag or "") == "" then
			local prefix = v .. "|"

			for k = #preListTb, 1, -1 do
				if string.find(preListTb[k], prefix, 1, true) == 1 then
					table.remove(preListTb, k)

					needSave = true
				end
			end
		end
	end

	if needSave then
		pg.global.prefsCacheUtils:setString("announcement_id", json.encode(preListTb))
	end

	for i, v in pairs(self.announcementIDList) do
		local key = v .. "|" .. (self.announcementList[i].tag or "")

		for k, m in ipairs(preListTb) do
			if m == key then
				self.announcementList[i].is_new = false

				break
			end
		end
	end
end

function AnnouncementModel:redDot_GetPointDotState()
	if not self.announcementList then
		return false
	end

	for i, v in pairs(self.announcementList) do
		if v.is_new then
			return true
		end
	end

	return false
end

function AnnouncementModel:redDot_GetAnnouncementState()
	if self:redDot_GetPointDotState() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

return AnnouncementModel
