-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\BindAccountComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("BindAccountComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local MessageName = require("Const.MessageName")
local EventCommonGuideData = require("Data.event_common_guide_data")
local ActivityConst = require("Common.Const.ActivityConst")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local json = require("json")
local BindAccountComponent = Class.LightClass("BindAccountComponent", EventContainerComponent)
local CHANNEL_TYPE_MINI_PROGRAM = "MiniProgram"
local CHANNEL_TYPE_WE_COM = "WeCom"
local MINI_PROGRAM_API_HOSTS = {
	test = {
		cn = "priv-platform-yimoo-api-test.funplus.com.cn",
		global = "priv-platform-yimoo-api-test.funplus.com"
	},
	stage = {
		cn = "priv-platform-yimoo-api-stage.funplus.com.cn",
		global = "priv-platform-yimoo-api-stage.funplus.com"
	},
	prod = {
		cn = "priv-platform-yimoo-api.funplus.com.cn",
		global = "priv-platform-yimoo-api.funplus.com"
	}
}
local MINI_PROGRAM_URL_LINK_PATH = "/api/game/url-link"
local MINI_PROGRAM_URL_LINK_TIMEOUT_MS = 10000

BindAccountComponent.messages = {
	[MessageName.SDK_ACCOUNT_BIND_CHANGED] = {
		"_onBindStatusChanged",
		false
	},
	[MessageName.BIND_ACCOUNT_AWARD_STATUS_CHANGED] = {
		"_onAwardStatusChanged",
		false
	},
	[MessageName.SDK_QRCODE_RECEIVED] = {
		"_onQRCodeReceived",
		false
	}
}

function BindAccountComponent:ctor(ctrl, refUContainer, id)
	EventContainerComponent.ctor(self, ctrl, refUContainer, id)

	self._qrCodeRequestToken = 0
	self._miniProgramUrlRequestToken = 0
end

function BindAccountComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	if not self.objectReference then
		return
	end

	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.rewardContentUWidget = self.objectReference:GetRefValue("rewardContentUWidget")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.channelUList = self.objectReference:GetRefValue("channelUList")
	self.tipsUSDFText = self.objectReference:GetRefValue("tipsUSDFText")
	self.iconQWUImage = self.objectReference:GetRefValue("iconQWUImage")
	self.rewardTitleTxt = self.objectReference:GetRefValue("rewardTitleTxt")
	self.qrCodeURawImage = self.objectReference:GetRefValue("qrCodeURawImage")
	self.qrImageUComponent = self.objectReference:GetRefValue("qrImageUComponent")
	self.mobile1UImage = self.objectReference:GetRefValue("mobile1UImage")
	self.mobile2UImage = self.objectReference:GetRefValue("mobile2UImage")
	self.btnGotoUButton = self.objectReference:GetRefValue("btnGotoUButton")
	self.gotBtnUWidget = self.objectReference:GetRefValue("gotBtnUWidget")

	local btnGoObjectRef = self.btnGotoUButton and self.btnGotoUButton:GetComponent("ObjectReference")

	if btnGoObjectRef then
		self.btnGotoTxt = btnGoObjectRef:GetRefValue("txtNameUText")
	end

	self.gotBtnNameUSDFText = self.objectReference:GetRefValue("gotBtnNameUSDFText")
	self.rewardTipsUSDFText = self.objectReference:GetRefValue("rewardTipsUSDFText")
end

function BindAccountComponent:addListener()
	if self.btnGotoUButton then
		function self.btnGotoUButton.luaClick()
			self:_onGoToBtnClick()
		end
	end
end

function BindAccountComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	local bindAccountSystem = pg.game and pg.game.bindAccount

	if bindAccountSystem and type(bindAccountSystem.checkAndGrantAwards) == "function" then
		bindAccountSystem:checkAndGrantAwards()
	end
end

function BindAccountComponent:refreshPage()
	if not self:checkContentLoaded() then
		return
	end

	if self.eventTitleUContainer then
		self:setEventTitle(self.eventTitleUContainer)
	end

	if self.rewardContentUWidget then
		self.rewardContentUWidget:SetActive(true)
	end

	if self.btnGotoUButton then
		self.btnGotoUButton:SetActive(true)
	end

	local gotoBtnText = pg.getLocalizationText(1997095361)

	ClientTextUtils.setText(self.btnGotoTxt, gotoBtnText)

	local gotBtnText = pg.getLocalizationText(1581350620)

	ClientTextUtils.setText(self.gotBtnNameUSDFText, gotBtnText)

	local rewardTitleText = pg.getGameString("BIND_ACCOUNT_AWARD_DESC")

	ClientTextUtils.setText(self.rewardTipsUSDFText, rewardTitleText)
	self:_refreshChannelPage()
end

function BindAccountComponent:onBeforeExitPage()
	if self.rewardContentUWidget then
		self.rewardContentUWidget:SetActive(false)
	end

	if self.btnGotoUButton then
		self.btnGotoUButton:SetActive(false)
	end
end

function BindAccountComponent:_refreshChannelPage()
	if self.iconQWUImage then
		self.iconQWUImage:SetActive(false)
	end

	if self.btnGotoUButton then
		self.btnGotoUButton:SetActive(false)
	end

	if self.gotBtnUWidget then
		self.gotBtnUWidget:SetActive(true)
	end

	if not self.channelUList then
		return
	end

	local lastSelectedTypeName

	if self.channelDataList and self.selectedChannelIndex then
		local lastChannel = self.channelDataList[self.selectedChannelIndex + 1]

		if lastChannel then
			lastSelectedTypeName = lastChannel.typeName
		end
	end

	function self.channelUList.luaRenderItem(button, index, data)
		self:_renderChannelPageItem(button, index, data)
	end

	function self.channelUList.luaClick(button, data)
		self:_onChannelItemClick(button, data)
	end

	local dataList = self.model:getChannelBindInfoList()

	self.channelDataList = dataList
	self.channelDataListLength = #dataList

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("_refreshChannelPage dataList length=%d", #dataList)

		if #dataList == 0 then
			logger:warn("_refreshChannelPage: channelBindInfoList is EMPTY! Check SDKManager.GetSocialList()")
		end
	end

	self.channelUList:SetList(dataList)

	local restoredIndex = 0

	if lastSelectedTypeName then
		for i, channel in ipairs(dataList) do
			if channel.typeName == lastSelectedTypeName then
				restoredIndex = i - 1

				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					logger:debug("_refreshChannelPage: restored selected channel=%s at index=%d", lastSelectedTypeName, restoredIndex)
				end

				break
			end
		end
	end

	self.selectedChannelIndex = restoredIndex

	self.channelUList:RefreshList()

	if #dataList > 0 then
		self:_updateChannelContent(dataList[restoredIndex + 1])
	end
end

function BindAccountComponent:_renderChannelPageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local selUImage = objectReference:GetRefValue("selUImage")

	button:TryChangePage("Size", data.areaType == 2 and 1 or 0)

	local isSelected = self.selectedChannelIndex == index

	button:TryChangePage("State", isSelected and 1 or 0)

	if iconUImage and data.iconName then
		iconUImage.url = data.iconName
	end
end

function BindAccountComponent:_onChannelItemClick(button, data)
	local clickedIndex = self.channelUList:GetChildIndex(button)

	self.selectedChannelIndex = clickedIndex

	if self.channelUList then
		self.channelUList:RefreshList()
	end

	self:_updateChannelContent(data)
end

function BindAccountComponent:_refreshChannelReward(data)
	if not self.listRewardUList then
		return
	end

	self.listRewardUList:SetActive(data.bindAward ~= nil)

	if data.bindAward then
		local bindAccountSystem = pg.game and pg.game.bindAccount
		local receivedState = bindAccountSystem and bindAccountSystem:getAwardReceivedState(self.eventId, data.societyID)
		local hasReceivedAward = receivedState == true

		LuaUIUtils.setRewardListByDropId(self.listRewardUList, data.bindAward, nil, hasReceivedAward, false)
	end
end

function BindAccountComponent:_updateChannelContent(data)
	if not data then
		return
	end

	self:_refreshChannelReward(data)

	if self.tipsUSDFText then
		local tipsText = pg.getLocalizationText(data.tipsDes) or ""

		ClientTextUtils.setText(self.tipsUSDFText, tipsText)
	end

	local isMobile = IS_MOBILE
	local isDomesticChannel = data.areaType == 1 and data.languageType == 0
	local isMiniProgram = data.typeName == CHANNEL_TYPE_MINI_PROGRAM
	local isWeCom = data.typeName == CHANNEL_TYPE_WE_COM

	if isDomesticChannel and not isMobile then
		if self.iconQWUImage then
			self.iconQWUImage:SetActive(isMiniProgram)
		end

		if self.qrImageUComponent then
			self.qrImageUComponent:SetActive(isWeCom)
		end

		if self.mobile1UImage then
			self.mobile1UImage:SetActive(true)
		end

		if self.mobile2UImage then
			self.mobile2UImage:SetActive(true)
		end

		if self.btnGotoUButton then
			self.btnGotoUButton:SetActive(false)
		end

		if isWeCom then
			self._qrCodeRequestToken = (self._qrCodeRequestToken or 0) + 1
			self._qrCodeRequestSerial = self.prepareEnterSerial
			self._qrCodeRequestEventId = self.eventId
			self._qrCodeRequestTypeName = data.typeName

			pg.me:reqBindAccountQRCode(self.eventId, data.typeName)
		end
	elseif isDomesticChannel and isMobile then
		if self.iconQWUImage then
			self.iconQWUImage:SetActive(false)
		end

		if self.qrImageUComponent then
			self.qrImageUComponent:SetActive(false)
		end

		if self.mobile1UImage then
			self.mobile1UImage:SetActive(false)
		end

		if self.mobile2UImage then
			self.mobile2UImage:SetActive(false)
		end

		if self.btnGotoUButton then
			self.btnGotoUButton:SetActive(not data.isBound)
		end
	else
		if self.iconQWUImage then
			self.iconQWUImage:SetActive(false)
		end

		if self.qrImageUComponent then
			self.qrImageUComponent:SetActive(false)
		end

		if self.mobile1UImage then
			self.mobile1UImage:SetActive(false)
		end

		if self.mobile2UImage then
			self.mobile2UImage:SetActive(false)
		end

		if self.btnGotoUButton then
			self.btnGotoUButton:SetActive(not data.isBound)
		end
	end

	if self.gotBtnUWidget then
		self.gotBtnUWidget:SetActive(data.isBound)
	end
end

function BindAccountComponent:_onBindStatusChanged()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("_onBindStatusChanged: refreshing channel list due to bind status change")
	end

	self:_refreshChannelPage()
end

function BindAccountComponent:_onAwardStatusChanged()
	local selectedChannel = self.channelDataList and self.selectedChannelIndex and self.channelDataList[self.selectedChannelIndex + 1]

	if selectedChannel then
		self:_refreshChannelReward(selectedChannel)
	end
end

function BindAccountComponent:_onQRCodeReceived(data)
	if self.isDestroyed then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("_onQRCodeReceived ignored: component destroyed")
		end

		return
	end

	if self.prepareEnterSerial ~= self._qrCodeRequestSerial then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("_onQRCodeReceived ignored: serial mismatch (request=%s, current=%s)", tostring(self._qrCodeRequestSerial), tostring(self.prepareEnterSerial))
		end

		return
	end

	if self.eventId ~= self._qrCodeRequestEventId then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("_onQRCodeReceived ignored: eventId changed (request=%s, current=%s)", tostring(self._qrCodeRequestEventId), tostring(self.eventId))
		end

		return
	end

	if self.channelDataList and self.selectedChannelIndex then
		local currentChannel = self.channelDataList[self.selectedChannelIndex + 1]

		if not currentChannel or currentChannel.typeName ~= self._qrCodeRequestTypeName then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				logger:debug("_onQRCodeReceived ignored: channel changed (request=%s, current=%s)", tostring(self._qrCodeRequestTypeName), tostring(currentChannel and currentChannel.typeName))
			end

			return
		end
	end

	if not NotNil(self.qrCodeURawImage) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("_onQRCodeReceived: qrCodeURawImage is nil or destroyed")
		end

		return
	end

	local qrCode = data and data.qrCode

	if not qrCode or #qrCode == 0 then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("_onQRCodeReceived: qrCode is empty")
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("_onQRCodeReceived: displaying base64 image, data length=%s", #qrCode)
	end

	pg.global.qrCodeMgr:ShowBase64Image(self.qrCodeURawImage, qrCode)
end

function BindAccountComponent:_onGoToBtnClick()
	if type(self.channelDataList) ~= "table" or not self.selectedChannelIndex then
		return
	end

	local targetIndex = self.selectedChannelIndex + 1
	local channelData = self.channelDataList[targetIndex]

	if not channelData or not channelData.typeName then
		return
	end

	if channelData.typeName == CHANNEL_TYPE_WE_COM then
		local uid = pg.me:getCopyPlayerUid()

		pg.global.sdkManager:openUrl("BindAccount", "BindAccount.WeCom.URL", "https://a.greentool.net/?k=tv6IXu&userid=" .. uid)
	elseif channelData.typeName == CHANNEL_TYPE_MINI_PROGRAM then
		self:_requestMiniProgramUrlLink()
	elseif pg and pg.global and pg.global.sdkManager and type(pg.global.sdkManager.bindSocial) == "function" then
		pg.global.sdkManager:bindSocial(channelData.typeName)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("@BindAccountComponent _onGoToBtnClick: pg.global.sdkManager.bindSocial is not available")
	end
end

function BindAccountComponent:_getMiniProgramApiHost()
	local environmentKey = _G_IsDebugMode and "test" or "prod"
	local regionKey = LuaUIUtils.isOverseas() and "global" or "cn"

	return MINI_PROGRAM_API_HOSTS[environmentKey][regionKey]
end

function BindAccountComponent:_requestMiniProgramUrlLink()
	self._miniProgramUrlRequestToken = (self._miniProgramUrlRequestToken or 0) + 1

	local requestToken = self._miniProgramUrlRequestToken
	local requestSerial = self.prepareEnterSerial
	local requestEventId = self.eventId
	local sdkManager = pg and pg.global and pg.global.sdkManager
	local sessionKey = sdkManager and sdkManager:getSessionKey()
	local uid = pg and pg.me and pg.me.uid

	if sessionKey == nil or uid == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("[BindAccountComponent][_requestMiniProgramUrlLink] missing request parameters, hasSessionKey=%s, hasUid=%s", sessionKey ~= nil, uid ~= nil)
		end

		return
	end

	sessionKey = tostring(sessionKey)
	uid = tostring(uid)

	if not string.find(sessionKey, "%S") or not string.find(uid, "%S") then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("[BindAccountComponent][_requestMiniProgramUrlLink] request parameters cannot be blank")
		end

		return
	end

	local body = json.encode({
		session_key = sessionKey,
		uid = uid
	})
	local headers = {
		["Content-Type"] = "application/json",
		Accept = "application/json"
	}
	local request = HttpRequest(self:_getMiniProgramApiHost(), nil, HttpRequest.Method.POST, MINI_PROGRAM_URL_LINK_PATH, headers, body, true)
	local proxy = HttpClientProxy()

	proxy:httpRequest(request, MINI_PROGRAM_URL_LINK_TIMEOUT_MS, function(reply)
		if self.isDestroyed or requestToken ~= self._miniProgramUrlRequestToken or requestSerial ~= self.prepareEnterSerial or requestEventId ~= self.eventId then
			return
		end

		local channelData = self.channelDataList and self.selectedChannelIndex and self.channelDataList[self.selectedChannelIndex + 1]

		if not channelData or channelData.typeName ~= CHANNEL_TYPE_MINI_PROGRAM then
			return
		end

		local httpStatus = tonumber(reply and reply.header and reply.header.HTTP_STATUS)

		if not reply or reply.err ~= 0 or not httpStatus or httpStatus < 200 or httpStatus >= 300 then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("[BindAccountComponent][_requestMiniProgramUrlLink] request failed, err=%s, httpStatus=%s", reply and reply.err, httpStatus)
			end

			return
		end

		local decodeOk, response = pcall(json.decode, reply.body)
		local urlLink = decodeOk and type(response) == "table" and type(response.data) == "table" and response.data.url_link or nil

		if not decodeOk or type(response) ~= "table" or tonumber(response.code) ~= 0 or response.msg ~= "success" or type(urlLink) ~= "string" or urlLink == "" then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("[BindAccountComponent][_requestMiniProgramUrlLink] invalid response, code=%s, msg=%s", type(response) == "table" and response.code, type(response) == "table" and response.msg)
			end

			return
		end

		pg.global.sdkManager:openUrl("BindAccount", "BindAccount.MiniProgram.URL", urlLink)
	end, false)
end

function BindAccountComponent:onDestroy()
	EventContainerComponent.onDestroy(self)

	self._qrCodeRequestToken = (self._qrCodeRequestToken or 0) + 1
	self._miniProgramUrlRequestToken = (self._miniProgramUrlRequestToken or 0) + 1

	if self.qrCodeURawImage and NotNil(self.qrCodeURawImage) then
		pg.global.qrCodeMgr:ClearImage(self.qrCodeURawImage)
	end

	self.channelUList = nil
	self.channelDataList = nil
	self.selectedChannelIndex = nil
end

return BindAccountComponent
