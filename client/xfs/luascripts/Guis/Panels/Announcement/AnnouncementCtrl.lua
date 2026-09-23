-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Announcement\\AnnouncementCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local AnnouncementCtrl = Class.LightClass("AnnouncementCtrl", UICtrl)
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local logger = LoggerManager.getLogger("AnnouncementCtrl")
local selectedIndex = 1
local leftList

AnnouncementCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local GAMEPAD_SCROLL_SPEED = 150

function AnnouncementCtrl:onCreate()
	UICtrl.onCreate(self)

	self.isTranslationEnabled = false
	self.isTranslationAvailable = pg ~= nil and pg.me ~= nil

	if self.isTranslationAvailable then
		pg.global.gmeManager:InitApp()
	end

	self._translationUICallbackGeneration = (self._translationUICallbackGeneration or 0) + 1

	self.model:getSaveLastAnnouncementId()

	leftList = self.model:getAnnouncementList()
end

function AnnouncementCtrl:onDestroy()
	self._translationUICallbackGeneration = (self._translationUICallbackGeneration or 0) + 1

	self.model:cancelTranslationRequests()

	if self.view and self.view.btnTranslateUButton then
		self.view.btnTranslateUButton.luaSelectChanged = nil
	end

	UICtrl.onDestroy(self)

	if self.sprites then
		self.view:setSpritesForRelease(self.sprites)

		self.sprites = nil
	end

	if self._scrollTimer then
		self:killTimer(self._scrollTimer)

		self._scrollTimer = nil
	end
end

function AnnouncementCtrl:onInputDeviceChanged(deviceType)
	return
end

function AnnouncementCtrl:_bindGamepadScroll(uList)
	if uList == nil or IsNil(uList.gameObject) then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(uList.gameObject, "announcementScrollGamepadBind")

	bind.actionPath = "Raw/GamepadRightStickMove"
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		self._scrollGamepadDelta = inputInfo.valueVec2 * GAMEPAD_SCROLL_SPEED
		self._scrollGamepadDelta.x = 0

		if inputInfo.phase == "Performed" then
			if self._scrollTimer == nil then
				logger:info(string.format("[Announcement] right-stick scroll START: delta=(%.2f,%.2f)", self._scrollGamepadDelta.x, self._scrollGamepadDelta.y))

				self._scrollTimer = self:startTimer(function()
					if uList == nil or IsNil(uList.gameObject) then
						if self._scrollTimer then
							self:killTimer(self._scrollTimer)

							self._scrollTimer = nil
						end

						return
					end

					local cur = uList.currentScrollPosition
					local targetPos = cur - self._scrollGamepadDelta

					uList:GoToPos(targetPos, false)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self._scrollTimer then
			logger:info("[Announcement] right-stick scroll STOP")
			self:killTimer(self._scrollTimer)

			self._scrollTimer = nil
		end
	end
end

function AnnouncementCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	self.view.btnTranslateUButton:SetSelected(false)

	function self.view.btnTranslateUButton.luaSelectChanged(isSelected)
		self:onTranslateSelectedChanged(isSelected)
	end
end

function AnnouncementCtrl:refreshTranslateButton()
	if not self.view or not self.view.btnTranslateUButton then
		return
	end

	self.view.btnTranslateUButton:SetActive(self.isTranslationAvailable and self.model:canTranslateSelectedAnnouncement())
end

function AnnouncementCtrl:refreshCurrentAnnouncementContent()
	if self.model:getCurState() == 1 then
		local openObj = self.view:GetOpenServerObj(self.view.openServerObj)
		local detail = self.model:getSelectedAnnouncementDetail()

		if openObj and detail and detail.content then
			openObj.listUList:SetList(detail.content)
		end

		return
	end

	self:onRefreshAnnouncementRightInfo()
end

function AnnouncementCtrl:onTranslationCompleted(cacheKey, announcementId, targetLanguage, callbackGeneration)
	local isCurrentCallback = self._translationUICallbackGeneration == callbackGeneration
	local isCurrentLanguage = self.model:getTargetAnnouncementLanguage() == targetLanguage

	if not isCurrentCallback or not isCurrentLanguage or not self.isTranslationEnabled or not self.view then
		return
	end

	if cacheKey == "title" then
		self:onRefreshAnnouncementChannelList()
	elseif self.model:getSelCurId() == announcementId then
		self:refreshCurrentAnnouncementContent()
	end
end

function AnnouncementCtrl:translateSelectedAnnouncement(translateAllTitles)
	local callbackGeneration = self._translationUICallbackGeneration

	local function callback(cacheKey, announcementId, targetLanguage)
		self:onTranslationCompleted(cacheKey, announcementId, targetLanguage, callbackGeneration)
	end

	self.model:translateCurrentAnnouncement(callback)

	if translateAllTitles then
		self.model:translateAllAnnouncementTitles(callback)

		return
	end

	local announcement = self.model:getSelectedAnnouncement()

	if announcement then
		self.model:translateAnnouncementTitle(announcement, callback)
	end
end

function AnnouncementCtrl:onTranslateSelectedChanged(isSelected)
	self.isTranslationEnabled = isSelected

	self:onRefreshAnnouncementChannelList()
	self:refreshCurrentAnnouncementContent()
	self:refreshTranslateButton()

	if not isSelected then
		return
	end

	self:translateSelectedAnnouncement(true)
end

function AnnouncementCtrl:backToHome()
	self.model.silentRefresh = false

	pg.global.ui.announcement.model:reqAnnouncementList()
end

function AnnouncementCtrl:closePanel()
	self.model:saveLastAnnouncementId()
	self:dismiss()
end

function AnnouncementCtrl:onShow()
	local isEmpty = self.model:getCurEmpty()

	self.view.rootCmp:TryChangePage("Empty", isEmpty)

	local curState = self.model:getCurState()

	self.view.rootCmp:TryChangePage("State", curState)

	if self.sprites == nil then
		self.sprites = {}
	end

	if curState == 0 then
		if leftList and leftList[1] then
			selectedIndex = leftList[1].id
		end

		self:setGameOrActivityAnnouncement()
	elseif curState == 1 then
		self:setOpenAnnouncement()
	end

	if self.view.txtTranslateNameUSDFText then
		ClientTextUtils.setText(self.view.txtTranslateNameUSDFText, pg.getGameString("AI_TRANSLATE"))
	end

	if self.view.txtTitleUSDFText then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("ANNOUNCEMENT_TITLE"))
	end

	self:refreshTranslateButton()
end

function AnnouncementCtrl:setGameOrActivityAnnouncement()
	local curState = self.model:getCurState()

	self.view.rootCmp:TryChangePage("State", curState)

	function self.view.tabListUList.luaRenderItem(button, index, data)
		self:onAnnouncementLeftTb(button, index, data)
	end

	function self.view.contentListUList.luaRenderItem(button, index, data)
		self:onAnnouncementRightInfo(button, index, data)
	end

	self:onRefreshAnnouncementChannelList()
	self:onRefreshAnnouncementRightInfo()
	self:_bindGamepadScroll(self.view.contentListUList)
end

function AnnouncementCtrl:onAnnouncementLeftTb(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local titleText = objectReference:GetRefValue("name")

	ClientTextUtils.setText(titleText, self.model:getAnnouncementTitle(data, self.isTranslationEnabled))

	button.isSelected = selectedIndex == data.id

	if button.isSelected then
		self.model:setSelCurId(data.id)
	end

	if selectedIndex == data.id then
		self.model:setRedPointState(data.id)
	end

	function button.luaClick()
		self.model:setSelCurId(data.id)

		selectedIndex = data.id

		self:onRefreshAnnouncementChannelList()
		self:onRefreshAnnouncementRightInfo()
		self:refreshTranslateButton()

		if self.isTranslationEnabled then
			self:translateSelectedAnnouncement(false)
		end
	end

	local isShowRedDot = self.model:getRedPointState(data.id)
	local treePath = string.format(RedDotConst.RedDotPath.ANNOUNCEMENT_TREE_LIST_ITEM, index)

	pg.global.setRedDot(treePath, button, isShowRedDot, RedDotConst.RedDotStyle.NEW)
end

function AnnouncementCtrl:onRefreshAnnouncementChannelList()
	if self.view then
		leftList = self.model:getAnnouncementList()

		if leftList and #leftList > 0 then
			self.view.tabListUList:SetList(leftList)
		end
	end
end

function AnnouncementCtrl:onRefreshAnnouncementRightInfo()
	if self.view then
		local connectList = self.model:getAnnouncementDetail()

		if connectList and connectList[1] and connectList[1].content then
			self.view.contentListUList:SetList(connectList[1].content)
		end
	end
end

function AnnouncementCtrl:onAnnouncementRightInfo(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local titleText = objectReference:GetRefValue("titleText")

		ClientTextUtils.setText(titleText, self.model:getAnnouncementContentText(data, self.isTranslationEnabled))

		function titleText.luaOnHyperlinkClick(action, content)
			LuaUIUtils.clickHyperText(action, content)
		end
	elseif data.tIndex == 1 or data.tIndex == 3 then
		local objectReference = button:GetComponent("ObjectReference")
		local bgUImage = objectReference:GetRefValue("bgUImage")

		if self.sprites and self.sprites[data.image] then
			bgUImage.sprite = self.sprites[data.image]
		else
			local sprites = self.sprites

			LuaUIUtils.setUIViewVisible(bgUImage, false)
			UIUtils.SetTextureByUrl(data.image, function(image)
				if self.sprites ~= sprites or IsNil(bgUImage) then
					if image then
						pg.global.uiMgr:ReleaseTexture2D(image.texture)
					end

					return
				end

				LuaUIUtils.setUIViewVisible(bgUImage, true)

				bgUImage.sprite = image
				sprites[data.image] = image
			end)
		end
	elseif data.tIndex == 2 then
		local objectReference = button:GetComponent("ObjectReference")
		local titleText = objectReference:GetRefValue("txtName")

		ClientTextUtils.setText(titleText, self.model:getAnnouncementContentText(data, self.isTranslationEnabled))

		function titleText.luaOnHyperlinkClick(action, content)
			LuaUIUtils.clickHyperText(action, content)
		end
	end
end

function AnnouncementCtrl:setOpenAnnouncement()
	local openObj = self.view:GetOpenServerObj(self.view.openServerObj)

	if not openObj then
		return
	end

	function openObj.listUList.luaRenderItem(button, index, data)
		self:onAnnouncementRightInfo(button, index, data)
	end

	function openObj.btnCloseUButton.luaClick(button, index, data)
		self:dismiss()
	end

	local curState = self.model:getCurStateByConfData()

	openObj.announcementCmp:TryChangePage("State", curState and 2 or 3)

	local connectList = self.model:getAnnouncementDetail()

	if connectList and connectList[1] and connectList[1].content then
		openObj.listUList:SetList(connectList[1].content)
	end

	function openObj.mediaListUList.luaRenderItem(button, index, data)
		self:onSetMediaBtn(button, index, data)
	end

	local mediaList = self.model:getAnnouncementMediaList()

	openObj.mediaListUList:SetList(mediaList)

	local time = math.round((self.model:getLeftTime() - Time.secondCache) / 3600)
	local timeStr = LuaUIUtils.getCountDownString(time, UIConst.TimeType.Short, true)

	ClientTextUtils.setText(openObj.leftTimeText, timeStr)
	self:_bindGamepadScroll(openObj.listUList)
end

function AnnouncementCtrl:onSetMediaBtn(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconBtn = objectReference:GetRefValue("iconUImage")
	local bgUImage = objectReference:GetRefValue("bgUImage")

	bgUImage.url = data.iconUrl

	function button.luaClick()
		button:TryChangePage("button", 5)

		button.isSelected = true

		pg.global.sdkManager:openUrl("AnnouncementCtrl", "data.media_url", data.media_url)
	end
end

return AnnouncementCtrl
