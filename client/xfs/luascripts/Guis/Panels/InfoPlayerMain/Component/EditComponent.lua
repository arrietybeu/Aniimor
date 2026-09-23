-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditComponent = Class.LightClass("EditComponent", UIComponent)
local ProfilePageData = require("Data.profile_page_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local EditBaseBarComponent = require("Guis.Panels.InfoPlayerMain.Component.EditBaseBarComponent")
local EditHeadBarComponent = require("Guis.Panels.InfoPlayerMain.Component.EditHeadBarComponent")
local EditTitleBarComponent = require("Guis.Panels.InfoPlayerMain.Component.EditTitleBarComponent")
local EditCardBgBarComponent = require("Guis.Panels.InfoPlayerMain.Component.EditCardBgBarComponent")
local EditBadgeBarComponent = require("Guis.Panels.InfoPlayerMain.Component.EditBadgeBarComponent")
local EditChatBubbleComponent = require("Guis.Panels.InfoPlayerMain.Component.EditChatBubbleComponent")
local EditCircumstancesComponent = require("Guis.Panels.InfoPlayerMain.Component.EditCircumstancesComponent")
local FriendshipLevelData = require("Data.friendship_level_data")
local AddressDataConst = require("Const.AddressDataConst")
local CardBackgroundData = require("Data.card_background_data")
local MessageName = require("Const.MessageName")

EditComponent.messages = {
	[MessageName.PLAYER_VOICE_SIGNATURE_CHANGE] = {
		"refreshVoiceSignatureState",
		true
	}
}
EditComponent.tabIndex = {
	Title = 3,
	ChatBubble = 6
}
EditComponent.tabIndexToState = {
	0,
	1,
	2,
	4,
	3,
	5,
	6
}

function EditComponent:ctor(ctrl, trans, extInfo)
	self.playerInfo = extInfo.playerInfo
	self.defaultTabIndex = extInfo.defaultTabIndex
	self.defaultTitleType = extInfo.defaultTitleType
	self.friendTitleInfo = extInfo.friendTitleInfo

	EditComponent.super.ctor(self, ctrl, trans, extInfo)
end

function EditComponent:initView()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listTab = self.objectReference:GetRefValue("listTab")
	self.panelEditRootComponent = self.objectReference:GetRefValue("panelEditRootComponent")
	self.btnHead = self.objectReference:GetRefValue("btnHead")
	self.txtLevel = self.objectReference:GetRefValue("txtLevel")
	self.txtSignature = self.objectReference:GetRefValue("txtSignature")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.btnCopy = self.objectReference:GetRefValue("btnCopy")
	self.txtUID = self.objectReference:GetRefValue("txtUID")
	self.txtClassInfo = self.objectReference:GetRefValue("txtClassInfo")
	self.basicBarWidget = self.objectReference:GetRefValue("basicBarWidget")
	self.headBarWidget = self.objectReference:GetRefValue("headBarWidget")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.titleBarWidget = self.objectReference:GetRefValue("titleBarWidget")
	self.cardBgBarWidget = self.objectReference:GetRefValue("cardBgBarWidget")
	self.btnConfirmText = self.btnConfirm:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.getWayText = self.objectReference:GetRefValue("getWayText")
	self.playerBgImage = self.objectReference:GetRefValue("playerBgImage")
	self.imgGenderUImage = self.objectReference:GetRefValue("imgGenderUImage")
	self.imgLikabilityUImage = self.objectReference:GetRefValue("imgLikabilityUImage")
	self.usingUWidget = self.objectReference:GetRefValue("usingUWidget")
	self.btnVoiceUButton = self.objectReference:GetRefValue("btnVoiceUButton")
	self.badgeBarUWidget = self.objectReference:GetRefValue("badgeBarUWidget")
	self.chatBubbleUWidget = self.objectReference:GetRefValue("chatBubbleUWidget")
	self.circumstancesUWidget = self.objectReference:GetRefValue("circumstancesUWidget")
	self.titleBackgroundUImage = self.ctrl.view.panelInfoTitleBackgroundUImage
	self.txtTitleUSDFText = self.ctrl.view.panelInfoTitleUSDFText or self.ctrl.view.panelDesignationText
	self.baseBarComponent = EditBaseBarComponent.new(self, self.basicBarWidget, {
		playerInfo = self.playerInfo
	})
	self.headBarComponent = EditHeadBarComponent.new(self, self.headBarWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget
	})
	self.titleBarComponent = EditTitleBarComponent.new(self, self.titleBarWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget,
		friendTitleInfo = self.friendTitleInfo
	})
	self.cardBgBarComponent = EditCardBgBarComponent.new(self, self.cardBgBarWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget
	})
	self.badgeBarComponent = EditBadgeBarComponent.new(self, self.badgeBarUWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget
	})
	self.chatBubbleComponent = EditChatBubbleComponent.new(self, self.chatBubbleUWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget
	})
	self.circumstancesComponent = EditCircumstancesComponent.new(self, self.circumstancesUWidget, {
		playerInfo = self.playerInfo,
		btnConfirm = self.btnConfirm,
		getWayBottomText = self.getWayText,
		usingUWidget = self.usingUWidget
	})
	self.orderToComponent = {
		self.baseBarComponent or nil,
		self.headBarComponent or nil,
		self.titleBarComponent or nil,
		self.cardBgBarComponent or nil,
		self.badgeBarComponent or nil,
		self.chatBubbleComponent or nil,
		self.circumstancesComponent or nil
	}

	self:refreshPlayerCard()
	self:addListener()
	self:setTabList()
	self:setDefaultTabIndex(self.defaultTabIndex, self.defaultTitleType)
end

function EditComponent:addListener()
	function self.btnCopy.luaClick()
		local text = self.playerInfo.uid or ""

		UIUtils.ClipboardWriter(text)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	function self.listTab.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.res

		function button.luaClick()
			self:selectTab(data)
		end
	end

	function self.btnVoiceUButton.luaClick()
		local voiceInfo = string.split(pg.me.voiceSignature, "|")

		pg.global.gmeManager:PlayRecordedFile(voiceInfo[2], function(code, filePath)
			pg.game.speech:onPlayFileComplete(filePath)
		end)
	end
end

function EditComponent:selectTab(data)
	local componentIndex = data.index

	if self.orderToComponent[self.selectedTabIndex] == self.circumstancesComponent and self.orderToComponent[componentIndex] ~= self.circumstancesComponent and self.ctrl.restoreProfileAvatarScene then
		self.ctrl:restoreProfileAvatarScene()
	end

	if self.orderToComponent[self.selectedTabIndex] == self.cardBgBarComponent and self.orderToComponent[componentIndex] ~= self.cardBgBarComponent then
		self.cardBgBarComponent:clearCardBackgroundPreview()
	end

	self.panelEditRootComponent:TryChangePage("State", data.state)

	if self.orderToComponent[componentIndex] then
		self.btnConfirm.luaClick = self.orderToComponent[componentIndex].confirmHandler

		self.orderToComponent[componentIndex].refreshPanelHandler(componentIndex)
		self.view.topTitleUWidget.gameObject:SetActiveEx(self.orderToComponent[componentIndex] == self.titleBarComponent)
		pg.game.speech:stopPlayAudioFile()
	end

	if componentIndex ~= 3 and self.titleBarComponent then
		self.titleBarComponent:clearTitlePreview()
		self.titleBarComponent:refreshTitlePreview()
	end

	self.ctrl.tabIndex = componentIndex
	self.selectedTabIndex = componentIndex

	self.ctrl:refreshConsoleBarState()
end

function EditComponent:selectTabByIndex(tabIndex)
	if not tabIndex or not self.tabInfos then
		return false
	end

	for tabListIndex, tabInfo in ipairs(self.tabInfos) do
		if tabInfo.index == tabIndex then
			self.listTab:SelectItem(tabListIndex - 1, false)
			self.listTab:GoToIndex(tabListIndex - 1)
			self:selectTab(tabInfo)

			return true
		end
	end

	return false
end

function EditComponent:setDefaultTabIndex(defaultTabIndex, defaultTitleType)
	self.pendingDefaultTabIndex = defaultTabIndex
	self.pendingDefaultTitleType = defaultTitleType
end

function EditComponent:selectDefaultTabIndex()
	if not self.pendingDefaultTabIndex then
		return
	end

	local defaultTabIndex = self.pendingDefaultTabIndex
	local defaultTitleType = self.pendingDefaultTitleType

	self.pendingDefaultTabIndex = nil
	self.pendingDefaultTitleType = nil

	self.titleBarComponent:setDefaultTitleType(defaultTitleType)
	self:selectTabByIndex(defaultTabIndex)
end

function EditComponent:onShow()
	self:selectDefaultTabIndex()
end

function EditComponent:setTabList()
	local tabInfos = {}
	local state = 0

	for id, pageData in ipairs(ProfilePageData) do
		if not pageData.isHide then
			state = EditComponent.tabIndexToState[id]

			if state then
				table.insert(tabInfos, {
					order = pageData.order,
					res = pageData.res,
					id = id,
					index = state + 1,
					state = state
				})
			end
		end
	end

	table.sort(tabInfos, function(a, b)
		if a.order == b.order then
			return a.id < b.id
		end

		return (a.order or a.id) < (b.order or b.id)
	end)

	self.tabInfos = tabInfos

	print("tabCount:" .. #tabInfos)
	self.listTab:SetList(tabInfos)

	local tabListIndex = 1

	self.listTab:GoToIndex(tabListIndex - 1)

	local ret, tab = self.listTab:TryGetChildAt(tabListIndex - 1)

	if ret and NotNil(tab) then
		tab:OnClickSimulate()
	elseif tabInfos[tabListIndex] then
		self.listTab:SelectItem(tabListIndex - 1, false)
		self:selectTab(tabInfos[tabListIndex])
	end
end

function EditComponent:refreshPlayerCard()
	self:refreshPlayCardHead()
	ClientTextUtils.setText(self.txtLevel, self.playerInfo.level or "")
	ClientTextUtils.setText(self.txtSignature, string.isNilOrEmpty(self.playerInfo.showSignature) and pg.getGameString("NO_PLAYER_SIGNATURE") or self.playerInfo.showSignature)
	ClientTextUtils.setText(self.txtName, self.playerInfo.playerName or "")
	ClientTextUtils.setText(self.txtUID, self.playerInfo.uid and string.format("UID: %s", self.playerInfo.uid) or "")

	local classInfo = pg.getFormatText(pg.getGameString("PLAYER_SESSION_CLASS_INFO"), Utils.getClass(pg.me.uid))

	ClientTextUtils.setText(self.txtClassInfo, classInfo)

	if CardBackgroundData[self.playerInfo.cardBackground] then
		self.playerBgImage.url = CardBackgroundData[self.playerInfo.cardBackground].res or AddressDataConst.DEFAULT_CARD_BACKGROUND
	else
		self.playerBgImage.url = AddressDataConst.DEFAULT_CARD_BACKGROUND
	end

	if pg.game.chat:checkFriendList(self.playerInfo.uid) then
		local friendshipLevel = pg.game.chat:getFriendship(self.playerInfo.uid)

		self.imgLikabilityUImage:SetActive(true)

		self.imgLikabilityUImage.url = FriendshipLevelData[friendshipLevel] and FriendshipLevelData[friendshipLevel].levelIcon or ""
	else
		self.imgLikabilityUImage:SetActive(false)
	end

	if self.playerInfo.templateId == 3 then
		self.uWidget:TryChangePage("Gender", 1)
	elseif self.playerInfo.templateId == 4 then
		self.uWidget:TryChangePage("Gender", 0)
	else
		self.uWidget:TryChangePage("Gender", 2)
	end

	self:refreshVoiceSignatureState(pg.me.voiceSignature)
end

function EditComponent:refreshVoiceSignatureState(newV)
	local voiceSignature = newV

	self.btnVoiceUButton:SetActive(not string.isNilOrEmpty(voiceSignature))
end

function EditComponent:refreshPlayCardHead()
	local data = {
		isEquip = false,
		isLock = false,
		showAvatarFrame = true,
		showAvatar = true,
		avatarIconId = self.playerInfo.headIcon,
		avatarFrameIconId = self.playerInfo.headFrame
	}

	LuaUIUtils.renderPlayerAvatar(self.btnHead, data)
end

function EditComponent:onDestroy()
	if self.baseBarComponent then
		self.baseBarComponent:onDestroy()

		self.baseBarComponent = nil
	end

	self.headBarComponent = nil
	self.titleBarComponent = nil
end

return EditComponent
