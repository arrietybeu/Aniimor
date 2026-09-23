-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioInvite\\PhotographyStudioInviteCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local RedDotConst = require("Const.RedDotConst")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PhotographyStudioInviteCtrl = Class.LightClass("PhotographyStudioInviteCtrl", UICtrl)

local function setButtonText(button, gameStringKey)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString(gameStringKey))
end

PhotographyStudioInviteCtrl.messages = {
	[MessageName.ON_PHOTOGRAPHY_STUDIO_INVITATIONS_CHANGED] = {
		"onInviteDataChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onInviteDataChanged",
		true
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_NOTICE] = {
		"onStudioNotice",
		true
	},
	[MessageName.RECV_FRIEND_LIST] = {
		"onInviteDataChanged",
		true
	}
}

function PhotographyStudioInviteCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.studioUid = info.studioUid
	self.isMaster = info.isMaster == true
	self.switchStudioCb = info.switchStudioCb
	self.currentTabType = self.isMaster and self.model.TabType.Invite or self.model.TabType.Invited
	self.searchText = nil
	self.pendingLeaveStudioUid = nil
	self.groupExpandState = {}
	self.isRefreshingTabs = false

	local emitter = pg.global.eventEmitter

	if emitter and emitter.addEventListener then
		self._platformPrivacyEventEmitter = emitter

		function self._platformPrivacyChangedListener()
			self:onPlatformPrivacyChanged()
		end

		emitter:addEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self._platformPrivacyChangedListener)
		emitter:addEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, self._platformPrivacyChangedListener)
	end

	self:markCurrentTabRedDotRead()
	self:refreshDataCache()
	self:refreshView()
end

function PhotographyStudioInviteCtrl:addListener()
	if self.view.bgCloseUButton then
		function self.view.bgCloseUButton.luaClick()
			self:closePanel()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:closePanel()
		end
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.PHOTOGRAPH_INVITE_INFO)
	end

	if self.view.searchUTMPInputField then
		function self.view.searchUTMPInputField.luaValueChanged(text)
			self:setSearchText(text)
		end
	end

	if self.view.listTab3thUList then
		function self.view.listTab3thUList.luaRenderItem(button, index, data)
			self:renderTabItem(button, data)
		end

		function self.view.listTab3thUList.luaSelectedChanged(list, isSelected)
			if not isSelected or self.isRefreshingTabs then
				return
			end

			local data = list.selectedItem

			if data then
				self:setTab(data.tabType)
			end
		end
	end

	if self.view.listUList then
		function self.view.listUList.luaRenderItem(button, index, data)
			self:renderGroupItem(button, data)
		end
	end
end

function PhotographyStudioInviteCtrl:refreshDataCache()
	self.tabData = self.model:getTabs(self.studioUid)
	self.listData = self.model:getList(self.currentTabType, self.studioUid, self.searchText)
	self.currentCount, self.maxCount = self.model:getCount(self.currentTabType, self.studioUid)

	for _, group in ipairs(self.listData) do
		local expanded = self.groupExpandState[group.groupType]

		group.expanded = expanded == nil and true or expanded
	end
end

function PhotographyStudioInviteCtrl:refreshView()
	ClientTextUtils.setText(self.view.textTitleUBaseText, pg.getGameString("PHOTO_STUDIO_INVITE_TITLE"))

	local emptyTextKey = self.currentTabType == self.model.TabType.Invite and "PHOTO_STUDIO_INVITE_EMPTY" or "PHOTO_STUDIO_INVITED_EMPTY"

	ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString(emptyTextKey))
	self.view.widget:TryChangePage("Empty", #self.listData == 0 and 1 or 0)

	if self.view.listTab3thUList then
		local onlyOne = self.tabData and #self.tabData == 1

		self.view.tabUWidget:SetActive(not onlyOne)

		local selectedIndex = 1

		for index, data in ipairs(self.tabData) do
			if data.tabType == self.currentTabType then
				selectedIndex = index

				break
			end
		end

		self.isRefreshingTabs = true

		self.view.listTab3thUList:SetList(self.tabData)
		self.view.listTab3thUList:SelectItem(selectedIndex - 1)

		self.isRefreshingTabs = false
	end

	if self.view.listUList then
		self.view.listUList:SetList(self.listData)
	end
end

function PhotographyStudioInviteCtrl:renderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, data.label)

	local redDotPath = data.tabType == self.model.TabType.Invite and RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITE_TAB or RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITED_TAB
	local count = self.model:getTabRedDotCount(data.tabType, self.studioUid)
	local redDotStyle = data.tabType == self.model.TabType.Invite and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NUM
	local redDotNum = data.tabType == self.model.TabType.Invited and count or 0

	pg.global.setRedDot(redDotPath, button, count > 0, redDotStyle, redDotNum)
end

function PhotographyStudioInviteCtrl:refreshInvitationRedDots()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.PHOTOGRAPHY_STUDIO_INVITE_ROOT)
end

function PhotographyStudioInviteCtrl:markCurrentTabRedDotRead()
	if self.model:markTabRedDotRead(self.currentTabType, self.studioUid) then
		self:refreshInvitationRedDots()
	end
end

function PhotographyStudioInviteCtrl:renderGroupItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local friendGroupListUList = objectReference:GetRefValue("friendGroupListUList")
	local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local titleUButton = objectReference:GetRefValue("titleUButton")

	ClientTextUtils.setText(txtTitleUBaseText, data.label)
	ClientTextUtils.setText(txtNumUBaseText, " " .. data.countText)
	button:TryChangePage("expand", data.expanded and 1 or 0)

	function titleUButton.luaClick()
		data.expanded = not data.expanded
		self.groupExpandState[data.groupType] = data.expanded

		button:TryChangePage("expand", data.expanded and 1 or 0)
	end

	function friendGroupListUList.luaRenderItem(friendButton, index, friendData)
		self:renderPlayerItem(friendButton, friendData)
	end

	friendGroupListUList:SetList(data.items)
end

function PhotographyStudioInviteCtrl:renderPlayerItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")
	local onlineStateUSDFText = objectReference:GetRefValue("onlineStateUSDFText")
	local signatureUSDFText = objectReference:GetRefValue("signatureUSDFText")
	local intimateUImage = objectReference:GetRefValue("intimateUImage")
	local textCantInvitedUBaseText = objectReference:GetRefValue("textCantInvitedUBaseText")
	local txtNameChangeCoverUSDFText = objectReference:GetRefValue("txtNameChangeCoverUSDFText")
	local txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	local btnRemoveUButton = objectReference:GetRefValue("btnRemoveUButton")
	local btnLeaveUButton = objectReference:GetRefValue("btnLeaveUButton")
	local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	local btnRefuseUButton = objectReference:GetRefValue("btnRefuseUButton")
	local btnAgreeUButton = objectReference:GetRefValue("btnAgreeUButton")
	local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	local btnInvitedUButton = objectReference:GetRefValue("btnInvitedUButton")

	button:TryChangePage("type", data.type)

	local playerInfo = data.playerInfo or pg.game.chat:getPlayerInfo(data.playerId)

	LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
		canOpenInfoPlayerCard = true,
		showOnlineState = true,
		playerId = data.playerId,
		playerInfo = playerInfo
	})

	local playerName = tostring(data.uid or "")

	if playerInfo and playerInfo.playerName then
		playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)
	end

	local playerUid = data.playerId or data.uid

	playerName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendInviteListName,
		uid = playerUid,
		playerInfo = playerInfo,
		rawText = playerName
	})

	ClientTextUtils.setText(nameUSDFText, playerName)
	ClientTextUtils.setText(txtNameChangeCoverUSDFText, playerName)
	ClientTextUtils.setText(txtNameChangeUSDFText, playerName)

	local isOnline = playerInfo and playerInfo.online == true

	button:TryChangePage("OnlineState", isOnline and 0 or 1)

	local onlineText = ""

	if playerInfo then
		onlineText = isOnline and pg.getGameString("ONLINE") or LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)
	end

	ClientTextUtils.setText(onlineStateUSDFText, onlineText)

	local signature = playerInfo and playerInfo.showSignature or ""

	signature = PlatformNameMaskService:getVisibleProfileSignature(playerUid, playerInfo, signature)

	ClientTextUtils.setText(signatureUSDFText, string.isNilOrEmpty(signature) and pg.getGameString("NO_PLAYER_SIGNATURE") or signature)

	local cantInvitedText = data.cantInvitedText

	cantInvitedText = cantInvitedText or ""

	ClientTextUtils.setText(textCantInvitedUBaseText, cantInvitedText)

	local genderPage = 2

	if playerInfo then
		local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}

		if presetData.templateId == 3 then
			genderPage = 1
		elseif presetData.templateId == 4 then
			genderPage = 0
		end
	end

	button:TryChangePage("Gender", genderPage)
	button:TryChangePage("isChange", pg.game.chat.specialFriendUId == data.playerId and 1 or 0)

	local friendshipLevel = tonumber(pg.game.chat:getFriendship(data.playerId)) or 0
	local friendshipData = FriendshipLevelData[friendshipLevel]

	intimateUImage:SetActive(friendshipData ~= nil)

	if friendshipData then
		intimateUImage.url = friendshipData.levelIcon
	end

	setButtonText(btnRemoveUButton, "PHOTO_STUDIO_REMOVE_MEMBER_ACTION")
	setButtonText(btnLeaveUButton, "PHOTO_STUDIO_LEAVE_ACTION")
	setButtonText(btnGoUButton, "PHOTO_STUDIO_EDIT_GROUP_ACTION")
	setButtonText(btnRefuseUButton, "PHOTO_STUDIO_REFUSE_INVITE_ACTION")
	setButtonText(btnAgreeUButton, "PHOTO_STUDIO_ACCEPT_INVITE_ACTION")
	setButtonText(btnInviteUButton, "PHOTO_STUDIO_INVITE_ACTION")
	setButtonText(btnInvitedUButton, "PHOTO_STUDIO_INVITED_ACTION")

	btnRemoveUButton.luaClick = nil
	btnLeaveUButton.luaClick = nil
	btnGoUButton.luaClick = nil
	btnRefuseUButton.luaClick = nil
	btnAgreeUButton.luaClick = nil
	btnInviteUButton.luaClick = nil
	btnInvitedUButton.luaClick = nil
	btnInvitedUButton.interactable = false

	if data.type == self.model.ItemType.InviteJoined then
		function btnRemoveUButton.luaClick()
			self:removeMember(data)
		end
	elseif data.type == self.model.ItemType.InviteAvailable then
		function btnInviteUButton.luaClick()
			self:invitePlayer(data)
		end
	elseif data.type == self.model.ItemType.InvitedPending then
		function btnRefuseUButton.luaClick()
			self:refuseInvitation(data)
		end

		function btnAgreeUButton.luaClick()
			self:acceptInvitation(data)
		end
	elseif data.type == self.model.ItemType.InvitedJoined then
		function btnLeaveUButton.luaClick()
			self:leaveStudio(data)
		end

		function btnGoUButton.luaClick()
			self:editStudio(data)
		end
	end
end

function PhotographyStudioInviteCtrl:onInviteDataChanged()
	self:markCurrentTabRedDotRead()
	self:refreshDataCache()

	if self.pendingLeaveStudioUid and not pg.me:getStudioInfo(self.pendingLeaveStudioUid) then
		local leftCurrentStudio = self.pendingLeaveStudioUid == self.studioUid

		self.pendingLeaveStudioUid = nil

		if leftCurrentStudio then
			self:closePanel()
			pg.global.ui:close(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT)

			return
		end
	end

	self:refreshView()
end

function PhotographyStudioInviteCtrl:onPlatformPrivacyChanged()
	self:refreshDataCache()
	self:refreshView()
end

function PhotographyStudioInviteCtrl:onStudioNotice(data)
	if data and data.noticeId == NoticeDef.PHOTOGRAPHY_STUDIO_LEAVE_ERROR then
		self.pendingLeaveStudioUid = nil
	end
end

function PhotographyStudioInviteCtrl:setTab(tabType)
	if tabType == self.model.TabType.Invite and not self.isMaster then
		return
	end

	self.currentTabType = tabType

	self:markCurrentTabRedDotRead()

	self.searchText = nil

	if self.view.searchUTMPInputField then
		self.view.searchUTMPInputField:SetTextWithoutNotify("")
	end

	self:refreshDataCache()
	self:refreshView()
end

function PhotographyStudioInviteCtrl:setSearchText(searchText)
	if string.isNilOrEmpty(searchText) then
		-- block empty
	end

	self.searchText = searchText

	self:refreshDataCache()
	self:refreshView()
end

function PhotographyStudioInviteCtrl:invitePlayer(data)
	if not self.isMaster or not data or not data.uid then
		return
	end

	local studioUid = self.studioUid
	local invitedUid = data.uid

	PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.Invite, pg.getGameString("PHOTO_STUDIO_INVITE_CONFIRM_TITLE"), pg.getGameString("PHOTO_STUDIO_INVITE_CONFIRM_DESC"), function()
		pg.me:reqInvitePhotographyStudio(studioUid, invitedUid)
	end)
end

function PhotographyStudioInviteCtrl:removeMember(data)
	if not self.isMaster or not data or not data.uid then
		return
	end

	local studioUid = self.studioUid
	local invitedUid = data.uid

	PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.RemoveMember, pg.getGameString("PHOTO_STUDIO_REMOVE_MEMBER_TITLE"), pg.getGameString("PHOTO_STUDIO_REMOVE_MEMBER_DESC"), function()
		pg.me:reqRemovePhotographyStudioMember(studioUid, invitedUid)
	end)
end

function PhotographyStudioInviteCtrl:acceptInvitation(data)
	if not data or not data.studioUid then
		return
	end

	local invitationUid = self.model:getInvitationUid(data.record) or data.uid

	pg.me:reqAcceptInvitePhotographyStudio(data.studioUid, invitationUid)
end

function PhotographyStudioInviteCtrl:refuseInvitation(data)
	if not data or not data.studioUid then
		return
	end

	local invitationUid = self.model:getInvitationUid(data.record) or data.uid

	pg.me:reqRefuseInvitePhotographyStudio(data.studioUid, invitationUid)
end

function PhotographyStudioInviteCtrl:leaveStudio(data)
	if not data or not data.studioUid then
		return
	end

	local studioUid = data.studioUid
	local invitationUid = self.model:getInvitationUid(data.record) or data.uid

	PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.Leave, pg.getGameString("PHOTO_STUDIO_LEAVE_CONFIRM_TITLE"), pg.getGameString("PHOTO_STUDIO_LEAVE_CONFIRM_DESC"), function()
		self.pendingLeaveStudioUid = studioUid

		pg.me:reqLeavePhotographyStudio(studioUid, invitationUid)
	end)
end

function PhotographyStudioInviteCtrl:editStudio(data)
	local targetStudioUid = data and data.studioUid

	if not targetStudioUid then
		return
	end

	if targetStudioUid == self.studioUid then
		self:closePanel()

		return
	end

	local function switchStudio()
		self:closePanel()

		if self.switchStudioCb then
			self.switchStudioCb(targetStudioUid)
		end
	end

	local editCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT)

	if not editCtrl or not editCtrl.hasUnsavedChanges or not editCtrl:hasUnsavedChanges() then
		switchStudio()

		return
	end

	PhotographyStudioUtils.showSevenDayConfirm(PhotographyStudioUtils.SEVEN_DAY_CONFIRM_TYPE.Unsaved, pg.getGameString("PHOTO_STUDIO_UNSAVED_TITLE"), pg.getGameString("PHOTO_STUDIO_UNSAVED_DESC"), switchStudio)
end

function PhotographyStudioInviteCtrl:onDestroy()
	local emitter = self._platformPrivacyEventEmitter

	if emitter and emitter.removeEventListener and self._platformPrivacyChangedListener then
		emitter:removeEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self._platformPrivacyChangedListener)
		emitter:removeEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, self._platformPrivacyChangedListener)
	end

	self._platformPrivacyEventEmitter = nil
	self._platformPrivacyChangedListener = nil

	UICtrl.onDestroy(self)
end

function PhotographyStudioInviteCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PhotographyStudioInviteCtrl:onShow()
	return
end

function PhotographyStudioInviteCtrl:onHide()
	return
end

function PhotographyStudioInviteCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PHOTOGRAPHY_INVITE)
end

return PhotographyStudioInviteCtrl
