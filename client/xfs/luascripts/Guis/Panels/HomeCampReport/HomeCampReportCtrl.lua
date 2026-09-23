-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampReport\\HomeCampReportCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCampReportCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomelandReportUtils = require("Utils.HomelandReportUtils")
local Const = require("Common.Const.Const")
local HotkeyConst = require("Const.HotkeyConst")
local SysConfigData = require("Data.sys_config_data")
local HomeCampReportCtrl = Class.LightClass("HomeCampReportCtrl", UICtrl)

HomeCampReportCtrl.REPORT_REASON_CONTENT_SEPARATOR = ":"
HomeCampReportCtrl.SECTION_TYPE = {
	TIP = 2,
	REASON = 1,
	PLAYER = 0
}
HomeCampReportCtrl.SECTION_LIST = {
	{
		tIndex = HomeCampReportCtrl.SECTION_TYPE.PLAYER
	},
	{
		tIndex = HomeCampReportCtrl.SECTION_TYPE.REASON
	},
	{
		tIndex = HomeCampReportCtrl.SECTION_TYPE.TIP
	}
}
HomeCampReportCtrl.REASON_LIST = {
	{
		gameStringKey = "HOME_CAMP_REPORT_REASON_NAME_VIOLATION",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOME_NAME
	},
	{
		gameStringKey = "HOME_CAMP_REPORT_REASON_FURNISHING_VIOLATION",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOMECAMP
	},
	{
		gameStringKey = "ACCUSATION_TYPE_1",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOMECAMP
	},
	{
		gameStringKey = "HOME_CAMP_REPORT_REASON_CONTENT_ABUSE",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOMECAMP
	},
	{
		gameStringKey = "HOME_CAMP_REPORT_REASON_CONTENT_FRAUD",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOMECAMP
	},
	{
		gameStringKey = "HOME_REPORT_OTHER",
		reportType = Const.ACCUSATION_TYPE.PLAYER_HOMECAMP
	}
}

function HomeCampReportCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeCampReportCtrl:getSendLimit()
	return tonumber(SysConfigData.ACCUSATION_DESC_LIMIT) or 0
end

function HomeCampReportCtrl:getPlayerInfo(uid)
	local chat = pg.game and pg.game.chat

	return chat and chat:getPlayerInfo(uid) or nil
end

function HomeCampReportCtrl:getPlayerRawName(data)
	local playerInfo = data and data.playerInfo
	local uid = data and data.uid or ""
	local playerName = playerInfo and playerInfo.playerName or ""

	playerName = LuaUIUtils.getPlayerDisplayName(uid, playerName, true)

	if string.isNilOrEmpty(playerName) then
		playerName = uid
	end

	return playerName
end

function HomeCampReportCtrl:getPlayerDisplayName(data)
	local displayName = data and data.homeName or ""
	local isHomeName = not string.isNilOrEmpty(displayName)

	if not isHomeName then
		displayName = self:getPlayerRawName(data)
	end

	local hooks = HomeCampReportCtrl._platformHooks

	displayName = hooks and hooks.renderPlayerName and hooks.renderPlayerName(self, data, displayName, isHomeName) or displayName

	return displayName
end

function HomeCampReportCtrl:refreshPlayerData(playerUids)
	playerUids = playerUids or HomelandReportUtils.getHomeCampReportablePlayerUids(self._isGmPreview)

	local homeCarNamesByUid = HomelandReportUtils.getHomeCarNamesByUid()
	local availableUids = {}
	local playerList = {}

	for _, uid in ipairs(playerUids) do
		uid = tostring(uid or "")

		if not string.isNilOrEmpty(uid) and not availableUids[uid] then
			availableUids[uid] = true
			playerList[#playerList + 1] = {
				uid = uid,
				playerInfo = self:getPlayerInfo(uid),
				homeName = homeCarNamesByUid[uid],
				isSelected = self._selectedPlayerUids[uid] == true
			}
		end
	end

	for uid in pairs(self._selectedPlayerUids) do
		if not availableUids[uid] then
			self._selectedPlayerUids[uid] = nil
		end
	end

	self._playerList = playerList

	self:refreshPlayerListView()
	self:queryPlayerInfoList()
end

function HomeCampReportCtrl:refreshPlayerListView()
	local playerListUList = self._playerListUList

	if playerListUList and not IsNil(playerListUList) then
		playerListUList:SetList(self._playerList or EMPTY_TABLE)
	end
end

function HomeCampReportCtrl:queryPlayerInfoList()
	local uids = {}

	for _, data in ipairs(self._playerList or EMPTY_TABLE) do
		uids[#uids + 1] = data.uid
	end

	if #uids == 0 or not pg.me or not pg.me.queryPlayerInfoList or not pg.game or not pg.game.chat then
		return
	end

	local queryToken = {}

	self._playerInfoQueryToken = queryToken

	pg.me:queryPlayerInfoList(uids, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, true, nil, function()
		self:onPlayerInfoListLoaded(queryToken)
	end)
end

function HomeCampReportCtrl:onPlayerInfoListLoaded(queryToken)
	if self._playerInfoQueryToken ~= queryToken or not self.view then
		return
	end

	for _, data in ipairs(self._playerList or EMPTY_TABLE) do
		data.playerInfo = self:getPlayerInfo(data.uid)
	end

	local playerListUList = self._playerListUList

	if playerListUList and not IsNil(playerListUList) then
		playerListUList:RefreshList()
	end
end

function HomeCampReportCtrl:setConfirmInteractable(interactable)
	local confirmButton = self.view and self.view.btnConfirmUButton

	if confirmButton and not IsNil(confirmButton) then
		confirmButton.interactable = interactable
	end
end

function HomeCampReportCtrl:renderPlayerSection(button)
	button.luaClick = nil

	local objectReference = button:GetComponent("ObjectReference")
	local txtTitle = objectReference and objectReference:GetRefValue("gameUSDFText")

	if txtTitle then
		ClientTextUtils.setText(txtTitle, pg.getGameString("ACCUSATION_NAME"))
	end

	local playerListUList = objectReference and objectReference:GetRefValue("listUList")

	if not playerListUList then
		logger:error("home camp report player list is missing")

		return
	end

	self._playerListUList = playerListUList
	playerListUList.groupType = CS.XGUI.EGroupType.Check

	function playerListUList.luaRenderItem(playerButton, index, data)
		self:renderPlayerItem(playerButton, index, data)
	end

	function playerListUList.luaFinishRender()
		self:focusInitialPlayerItem()
	end

	playerListUList:SetList(self._playerList or EMPTY_TABLE)
end

function HomeCampReportCtrl:renderPlayerHead(objectReference, playerInfo)
	local headUWidget = objectReference and objectReference:GetRefValue("headUWidget")

	if not headUWidget or IsNil(headUWidget) then
		return
	end

	LuaUIUtils.renderPlayerAvatarImages(headUWidget, {
		avatarIconId = playerInfo and playerInfo.headIcon,
		avatarFrameIconId = playerInfo and playerInfo.headFrame,
		showAvatar = playerInfo ~= nil,
		showAvatarFrame = playerInfo ~= nil
	})
end

function HomeCampReportCtrl:renderPlayerItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference and objectReference:GetRefValue("txtNameUSDFText")
	local txtUid = objectReference and objectReference:GetRefValue("uidUSDFText")

	if txtName then
		ClientTextUtils.setText(txtName, self:getPlayerDisplayName(data))
	end

	if txtUid then
		ClientTextUtils.setText(txtUid, string.format("UID:%s", data.uid))
	end

	self:renderPlayerHead(objectReference, data.playerInfo)

	data.isSelected = self._selectedPlayerUids[data.uid] == true

	button:SetSelected(data.isSelected)

	function button.luaClick()
		data.isSelected = not data.isSelected
		self._selectedPlayerUids[data.uid] = data.isSelected and true or nil
	end

	button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
		button:OnClickSimulate()

		return false
	end)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("CHAT_REPORT_CHAT_CHOICE", 0)
end

function HomeCampReportCtrl:renderReasonSection(button)
	button.luaClick = nil

	local objectReference = button:GetComponent("ObjectReference")
	local txtTitle = objectReference and objectReference:GetRefValue("titleUSDFText")

	if txtTitle then
		ClientTextUtils.setText(txtTitle, pg.getGameString("ACCUSATION_TYPE"))
	end

	local reasonListUList = objectReference and objectReference:GetRefValue("listUList")

	if reasonListUList then
		self._reasonListUList = reasonListUList
		reasonListUList.groupType = CS.XGUI.EGroupType.Radio

		function reasonListUList.luaRenderItem(reasonButton, index, data)
			self:renderReasonItem(reasonButton, index, data)
		end

		reasonListUList:SetList(HomeCampReportCtrl.REASON_LIST)
		reasonListUList:SelectItem(self._selectedReasonIndex - 1, false)
	else
		logger:error("home camp report reason list is missing")
	end

	local inputField = objectReference and objectReference:GetRefValue("inputFieldUTMPInputField")

	if not inputField then
		logger:error("home camp report input field is missing")

		return
	end

	self._inputField = inputField

	inputField:SetTextWithoutNotify(self._reportContent or "")

	function inputField.luaValueChanged(text)
		self:onInputValueChanged(text)
	end

	local inputObjectReference = inputField:GetComponent("ObjectReference")
	local placeHolder = inputObjectReference and inputObjectReference:GetRefValue("placeHolderUSDFText")

	if placeHolder then
		ClientTextUtils.setText(placeHolder, pg.getGameString("ACCUSATION_TYPE_INPUT"))
	end

	self:setupInputConsoleBar()
end

function HomeCampReportCtrl:renderReasonItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference and objectReference:GetRefValue("txtNameUSDFText")

	if txtName then
		ClientTextUtils.setText(txtName, pg.getGameString(data.gameStringKey))
	end

	function button.luaClick()
		self._selectedReasonIndex = index + 1

		local reasonListUList = self._reasonListUList

		if reasonListUList and not IsNil(reasonListUList) then
			reasonListUList:SelectItem(index, false)
			reasonListUList:RefreshList()
		end
	end

	button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
		if button.luaClick then
			button.luaClick()
		end

		return false
	end)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("CHAT_REPORT_CHAT_CHOICE", 0)
end

function HomeCampReportCtrl:renderTipSection(button)
	button.luaClick = nil
	button.interactable = false

	local objectReference = button:GetComponent("ObjectReference")
	local txtTips = objectReference and objectReference:GetRefValue("txtTipsUSDFText")

	if txtTips then
		ClientTextUtils.setText(txtTips, pg.getGameString("HOME_REPORT_SCREENSHOT_DES"))
	end
end

function HomeCampReportCtrl:renderSection(button, index, data)
	if data.tIndex == HomeCampReportCtrl.SECTION_TYPE.PLAYER then
		self:renderPlayerSection(button)
	elseif data.tIndex == HomeCampReportCtrl.SECTION_TYPE.REASON then
		self:renderReasonSection(button)
	elseif data.tIndex == HomeCampReportCtrl.SECTION_TYPE.TIP then
		self:renderTipSection(button)
	end
end

function HomeCampReportCtrl:onInputValueChanged(text)
	local finalText = tostring(text or "")
	local maxLen = self:getSendLimit()

	if maxLen > 0 and maxLen < string.utf8len(finalText) then
		finalText = string.utf8sub(finalText, 1, maxLen)

		if self._inputField and not IsNil(self._inputField) then
			self._inputField:SetTextWithoutNotify(finalText)
		end
	end

	self._reportContent = finalText
end

function HomeCampReportCtrl:setupInputConsoleBar()
	local inputField = self._inputField

	if not inputField or IsNil(inputField) then
		return
	end

	inputField:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth)
	inputField:SetHotkeyActiveOnlyInCurrentItem(true)
	inputField:SetHotkeyConsoleBar("CHAT_REPORT_CHAT_WRITE", 0)
end

function HomeCampReportCtrl:focusInitialPlayerItem()
	local playerListUList = self._playerListUList

	if not playerListUList or IsNil(playerListUList) then
		return
	end

	local hasPlayer, playerButton = playerListUList:TryGetChildAt(0)

	if not hasPlayer or not playerButton or IsNil(playerButton) then
		return
	end

	local sectionListUList = self.view and self.view.listUList

	if sectionListUList and not IsNil(sectionListUList) then
		sectionListUList:SetNavGroupDefaultItem(playerButton)
	end

	if self._hasInitialGamepadFocus or not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if navMgr and navMgr:FocusItem(playerButton) then
		self._hasInitialGamepadFocus = true
	end
end

function HomeCampReportCtrl:refreshConsoleBarState()
	self:focusInitialPlayerItem()
end

function HomeCampReportCtrl:getSelectedReasonConfig()
	return HomeCampReportCtrl.REASON_LIST[self._selectedReasonIndex]
end

function HomeCampReportCtrl:buildReportInfos()
	local reasonConfig = self:getSelectedReasonConfig()

	if not reasonConfig then
		return {}
	end

	local reason = pg.getGameString(reasonConfig.gameStringKey)
	local content = self._reportContent or ""
	local desc = tostring(reason or "") .. HomeCampReportCtrl.REPORT_REASON_CONTENT_SEPARATOR .. tostring(content)
	local homeCarNamesByUid = HomelandReportUtils.getHomeCarNamesByUid()
	local reportInfos = {}

	for _, data in ipairs(self._playerList or EMPTY_TABLE) do
		if self._selectedPlayerUids[data.uid] then
			local homeName = homeCarNamesByUid[data.uid] or data.homeName

			reportInfos[#reportInfos + 1] = {
				msgId = "",
				uid = data.uid,
				name = homeName,
				character = homeName,
				homeName = homeName,
				content = content,
				reason = reason,
				desc = desc,
				reportType = reasonConfig.reportType,
				detailType = HomelandReportUtils.HOME_CAMP_REPORT_SOURCE
			}
		end
	end

	return reportInfos
end

function HomeCampReportCtrl:submit()
	local reportInfos = self:buildReportInfos()

	if #reportInfos == 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("HOME_CAMP_REPORT_PLAYER_REQUIRED"))

		return
	end

	local content = self._reportContent or ""
	local maxLen = self:getSendLimit()

	if maxLen > 0 and maxLen < string.utf8len(content) then
		pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

		return
	end

	if self._isGmPreview then
		pg.global.ui.tips:showTextTip("GM preview only: report was not submitted")

		return
	end

	if self._reportSubmitHandler then
		self._reportSubmitHandler(reportInfos, self._reportImageContext, self)

		return
	end

	for _, reportInfo in ipairs(reportInfos) do
		pg.me:reportChat(reportInfo)
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))
	self:dismiss()
end

function HomeCampReportCtrl:addListener()
	local view = self.view

	if view.btnCloseUButton then
		function view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if view.btnConfirmUButton then
		function view.btnConfirmUButton.luaClick()
			self:submit()
		end

		view.btnConfirmUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth)
		view.btnConfirmUButton:SetHotkeyActiveOnlyInCurrentItem(false)
	end
end

function HomeCampReportCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._selectedPlayerUids = {}
	self._selectedReasonIndex = 1
	self._reportContent = ""
	self._reportImageContext = info and info.reportImageContext
	self._reportSubmitHandler = info and info.reportSubmitHandler
	self._reportCancelHandler = info and info.reportCancelHandler
	self._isGmPreview = info and info.isGmPreview == true
	self._hasInitialGamepadFocus = false

	self:refreshPlayerData({})
end

function HomeCampReportCtrl:onPostOpen(info, isReOpen)
	UICtrl.onPostOpen(self, info, isReOpen)

	if not HomelandReportUtils.isHomeCampReportContextValid(self._reportImageContext) then
		self:dismiss()

		return
	end

	local playerUids = HomelandReportUtils.getHomeCampReportablePlayerUids(self._isGmPreview)

	if #playerUids == 0 then
		self:dismiss()

		if HomelandReportUtils.isHomeCampInfoReady() then
			HomelandReportUtils.showNoHomeCampReportablePlayerNotice()
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))
		end

		return
	end

	self:refreshPlayerData(playerUids)
	self:setConfirmInteractable(not self._reportImageContext.isSubmitting)
end

function HomeCampReportCtrl:onShow()
	if self.view.txtTitle then
		ClientTextUtils.setText(self.view.txtTitle, pg.getGameString("ACCUSATION_TITLE"))
	end

	if self.view.txtConfirm then
		ClientTextUtils.setText(self.view.txtConfirm, pg.getGameString("ACCUSATION_BTN"))
	end

	if not self.view.listUList then
		logger:error("home camp report section list is missing")

		return
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderSection(button, index, data)
	end

	self.view.listUList:SetList(HomeCampReportCtrl.SECTION_LIST)
end

function HomeCampReportCtrl:onHide()
	return
end

function HomeCampReportCtrl:onDestroy()
	self._playerInfoQueryToken = nil

	if self._reportCancelHandler then
		self._reportCancelHandler(self._reportImageContext, self)
	end

	self._playerListUList = nil
	self._reasonListUList = nil
	self._inputField = nil
	self._hasInitialGamepadFocus = nil
	self._reportImageContext = nil
	self._reportSubmitHandler = nil
	self._reportCancelHandler = nil
	self._isGmPreview = nil

	UICtrl.onDestroy(self)
end

return HomeCampReportCtrl
