-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Accusation\\AccusationCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("AccusationCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local GameStringHash = require("Data.gamestring_hash_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HotkeyConst = require("Const.HotkeyConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ShowTitleUtils = require("Utils.ShowTitleUtils")
local AccusationCtrl = Class.LightClass("AccusationCtrl", UICtrl)

AccusationCtrl.REPORT_SOURCE_HOMELAND = "homeland"
AccusationCtrl.REPORT_REASON_CONTENT_SEPARATOR = ":"
AccusationCtrl.REPORT_UI_CONFIG_BY_SOURCE = {
	[AccusationCtrl.REPORT_SOURCE_HOMELAND] = {
		titleKey = "HOME_REPORT_TITLE",
		tipTextKey = "HOME_REPORT_SCREENSHOT_DES",
		nameTitleKey = "HOME_REPORT_HOME_NAME",
		contentRequired = true
	}
}
AccusationCtrl.REPORT_REASON_CONFIG_BY_SOURCE = {
	[AccusationCtrl.REPORT_SOURCE_HOMELAND] = {
		{
			gameStringKey = "HOME_REPORT_NAME_VIOLATION",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOME_NAME
		},
		{
			gameStringKey = "HOME_REPORT_BUILD_VIOLATION",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOMELAND
		},
		{
			gameStringKey = "ACCUSATION_TYPE_1",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOMELAND
		},
		{
			gameStringKey = "ACCUSATION_TYPE_3",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOMELAND
		},
		{
			gameStringKey = "ACCUSATION_TYPE_4",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOMELAND
		},
		{
			gameStringKey = "HOME_REPORT_OTHER",
			reportType = Const.ACCUSATION_TYPE.PLAYER_HOMELAND
		}
	}
}
AccusationCtrl.SPECIAL_REPORT_TEXT_GAME_STRING = {
	[Const.ACCUSATION_TYPE.PLAYER_NAME] = "CHAT_REPORT_NAME_CONTENT",
	[Const.ACCUSATION_TYPE.PLAYER_SIGNATURE] = "CHAT_REPORT_SIGNATURE_CONTENT",
	[Const.ACCUSATION_TYPE.PLAYER_TITLE] = "CHAT_REPORT_TITLES_CONTENT"
}
AccusationCtrl.messages = {}

function AccusationCtrl:cloneTable(src)
	local dst = {}

	if not Utils.isTable(src) then
		return dst
	end

	for key, value in pairs(src) do
		dst[key] = value
	end

	return dst
end

function AccusationCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function AccusationCtrl:_getInputText(inputField)
	if not inputField or string.isNilOrEmpty(inputField.text) then
		return ""
	end

	return tostring(inputField.text)
end

function AccusationCtrl:_refreshDescLimit(text)
	local maxLen = self.model:getSendLimit()
	local finalText = text or ""
	local len = finalText ~= "" and string.utf8len(finalText) or 0

	if maxLen > 0 and maxLen < len then
		finalText = string.utf8sub(finalText, 1, maxLen)
		len = string.utf8len(finalText)

		if self.view and self.view.txtDescInput then
			self.view.txtDescInput:SetTextWithoutNotify(finalText)
		end
	end

	if self.view then
		self.view:refreshInputLimit(len, maxLen)
	end
end

function AccusationCtrl:isHomelandReport()
	return self._reportSource == AccusationCtrl.REPORT_SOURCE_HOMELAND
end

function AccusationCtrl:getReportUIConfig()
	return AccusationCtrl.REPORT_UI_CONFIG_BY_SOURCE[self._reportSource] or EMPTY_TABLE
end

function AccusationCtrl:_buildReasonList()
	local list = {}
	local sourceConfig = AccusationCtrl.REPORT_REASON_CONFIG_BY_SOURCE[self._reportSource]

	if sourceConfig then
		for _, item in ipairs(sourceConfig) do
			list[#list + 1] = self:cloneTable(item)
		end

		return list
	end

	for i = 1, Const.ACCUSATION_TYPE_MAX_COUNT do
		local key = "ACCUSATION_TYPE_" .. i

		if GameStringConfig[key] or GameStringHash[key] then
			list[#list + 1] = {
				gameStringKey = key,
				reportType = i
			}
		end
	end

	return list
end

function AccusationCtrl:_getSelectedReasonItem()
	local selectedIndex = self._selectedReasonIndex

	if not selectedIndex then
		return nil
	end

	return self._reasonList and self._reasonList[selectedIndex]
end

function AccusationCtrl:_getSelectedReason()
	local item = self:_getSelectedReasonItem()

	return item and pg.getGameString(item.gameStringKey) or nil
end

function AccusationCtrl:_getSelectedReportType()
	local item = self:_getSelectedReasonItem()

	return item and item.reportType
end

function AccusationCtrl:buildHomelandReportText(reason, content)
	return tostring(reason or "") .. AccusationCtrl.REPORT_REASON_CONTENT_SEPARATOR .. tostring(content or "")
end

function AccusationCtrl:getSpecialReportContent(reportType)
	local playerInfo = self._targetPlayerInfo

	if reportType == Const.ACCUSATION_TYPE.PLAYER_NAME then
		return playerInfo and playerInfo.playerName or self._reportInfo.character or self._reportInfo.name or self._playerName or ""
	elseif reportType == Const.ACCUSATION_TYPE.PLAYER_SIGNATURE then
		return playerInfo and playerInfo.showSignature or ""
	elseif reportType == Const.ACCUSATION_TYPE.PLAYER_TITLE then
		if playerInfo then
			local showTitles = {}

			for titleType, titleId in pairs(playerInfo.showTitles or EMPTY_TABLE) do
				showTitles[tonumber(titleType) or titleType] = titleId
			end

			return ShowTitleUtils.getShowTitleText(showTitles, nil, playerInfo.isWholeTitle)
		end

		return ""
	end

	return ""
end

function AccusationCtrl:getCurrentReportText()
	if self:isHomelandReport() then
		return self._sourceReportText
	end

	local reportType = self:_getSelectedReportType()
	local gameStringKey = reportType and AccusationCtrl.SPECIAL_REPORT_TEXT_GAME_STRING[reportType]

	if not gameStringKey then
		return self._sourceReportText
	end

	return pg.getFormatText(pg.getGameString(gameStringKey), self:getSpecialReportContent(reportType))
end

function AccusationCtrl:refreshReportText()
	self._reportText = self:getCurrentReportText()

	local input = self.view and self.view.txtTypeInput

	if not input or IsNil(input) then
		return
	end

	local hasReportText = not string.isNilOrEmpty(self._reportText)

	input.text = self._reportText or ""
	input.interactable = false
	input.readOnly = true

	input:SetActive(hasReportText)
end

function AccusationCtrl:getTargetPlayerId()
	local playerId = self._playerId

	if string.isNilOrEmpty(playerId) then
		playerId = self._reportInfo and self._reportInfo.uid
	end

	return tostring(playerId or "")
end

function AccusationCtrl:_refreshPlayerName()
	local view = self.view

	if not view or not view.txtName then
		return
	end

	local playerName = self._playerDisplayName or self._reportInfo.name or self._playerName or ""
	local hooks = AccusationCtrl._platformHooks

	playerName = hooks and hooks.renderPlayerName and hooks.renderPlayerName(self, playerName) or playerName

	ClientTextUtils.setText(view.txtName, playerName)
end

function AccusationCtrl:queryTargetPlayerInfo()
	if self:isHomelandReport() then
		return
	end

	local queryToken = {}

	self._playerInfoQueryToken = queryToken

	local playerId = self:getTargetPlayerId()

	if string.isNilOrEmpty(playerId) then
		return
	end

	self._targetPlayerInfo = pg.game.chat:getPlayerInfo(playerId)

	if not pg.game.chat:getPlayerInfoFromServer(playerId, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, function(playerInfo)
		self:onTargetPlayerInfoLoaded(queryToken, playerId, playerInfo)
	end) then
		self:refreshReportText()
	end
end

function AccusationCtrl:onTargetPlayerInfoLoaded(queryToken, playerId, playerInfo)
	if self._playerInfoQueryToken ~= queryToken or self:getTargetPlayerId() ~= playerId then
		return
	end

	self._targetPlayerInfo = playerInfo or pg.game.chat:getPlayerInfo(playerId)

	self:refreshReportText()
end

function AccusationCtrl:_initSelectedReason()
	self._selectedReasonIndex = #self._reasonList > 0 and 1 or nil

	local reason = self._reportInfo and self._reportInfo.reason

	if Utils.isTable(reason) then
		reason = reason[1]
	end

	if self:isHomelandReport() and not string.isNilOrEmpty(reason) then
		for index, item in ipairs(self._reasonList or EMPTY_TABLE) do
			if pg.getGameString(item.gameStringKey) == reason then
				self._selectedReasonIndex = index

				return
			end
		end
	end

	local reportType = self._reportInfo and tonumber(self._reportInfo.reportType)

	if reportType then
		for index, item in ipairs(self._reasonList) do
			if item.reportType == reportType then
				self._selectedReasonIndex = index

				return
			end
		end
	end

	if string.isNilOrEmpty(reason) then
		return
	end

	for index, item in ipairs(self._reasonList or EMPTY_TABLE) do
		if pg.getGameString(item.gameStringKey) == reason then
			self._selectedReasonIndex = index

			return
		end
	end
end

function AccusationCtrl:_buildReportInfo()
	local reportInfo = self:cloneTable(self._reportInfo)
	local playerName = reportInfo.name or self._playerName or ""
	local reportContent = self:_getInputText(self.view and self.view.txtDescInput)
	local reportReason = self:_getSelectedReason()

	reportInfo.uid = tostring(reportInfo.uid or self._playerId or "")
	reportInfo.name = playerName
	reportInfo.content = reportContent
	reportInfo.reason = reportReason
	reportInfo.desc = self:isHomelandReport() and self:buildHomelandReportText(reportReason, reportContent) or self:_getInputText(self.view and self.view.txtTypeInput)
	reportInfo.msgId = tostring(reportInfo.msgId or "")
	reportInfo.reportType = self:_getSelectedReportType()

	return reportInfo
end

function AccusationCtrl:addListener()
	local view = self.view

	if view.btnCloseUButton then
		function view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if view.btnConfirmUButton then
		function view.btnConfirmUButton.luaClick()
			local descText = view.txtDescInput and view.txtDescInput.text or ""
			local descLen = descText ~= "" and string.utf8len(descText) or 0

			if descLen > self.model:getSendLimit() then
				pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_FAIL"))

				return
			end

			local reportContent = self:_getInputText(view.txtDescInput)

			if self:getReportUIConfig().contentRequired ~= false and string.isNilOrEmpty(reportContent) then
				pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_REPORT_CHAT_FAIL"))

				return
			end

			local reportInfo = self:_buildReportInfo()

			if string.isNilOrEmpty(reportInfo.uid) then
				logger:error("report target uid is empty")

				return
			end

			if self._reportSubmitHandler then
				self._reportSubmitHandler(reportInfo, self._reportImageContext, self)

				return
			end

			pg.me:reportChat(reportInfo)
			pg.global.ui.tips:showTextTip(pg.getGameString("ACCUSATION_CHAT_SUCCESS"))
			self:dismiss()
		end
	end

	if view.txtDescInput then
		function view.txtDescInput.luaValueChanged(text)
			self:_refreshDescLimit(text)
		end
	end

	if view.listUList then
		function view.listUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference and objectReference:GetRefValue("txtNameUSDFText")

			if txtNameUSDFText then
				ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.gameStringKey))
			end

			button:TryChangePage("Selected", self._selectedReasonIndex == index + 1 and 1 or 0)

			function button.luaClick()
				self._selectedReasonIndex = index + 1

				self:refreshReportText()
				view.listUList:SelectItem(index, false)
				view.listUList:RefreshList()
			end

			if not IsNil(button) then
				button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
					if button.luaClick then
						button.luaClick()
					end

					return false
				end)
				button:SetHotkeyActiveOnlyInCurrentItem(true)
				button:SetHotkeyConsoleBar("CHAT_REPORT_CHAT_CHOICE", 0)
			end
		end
	end

	self:_setupInputConsoleBar()
end

function AccusationCtrl:_setupInputConsoleBar()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local view = self.view

	self._consoleBarInputs = {}

	for _, input in ipairs({
		view.txtDescInput,
		view.txtTypeInput
	}) do
		if input and not IsNil(input) then
			input:SetHotkeyConsoleBar("CHAT_REPORT_CHAT_WRITE", 0)
			input:SetHotkeyForceHidden(true)

			self._consoleBarInputs[#self._consoleBarInputs + 1] = input
		end
	end

	if #self._consoleBarInputs > 0 then
		self:addNavFocusListener(CallbackHandler(self, "_onNavFocusChanged"), "AccusationConsoleBar")
	end
end

function AccusationCtrl:_onNavFocusChanged()
	if not self._consoleBarInputs then
		return
	end

	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	for _, input in ipairs(self._consoleBarInputs) do
		if not IsNil(input) then
			input:SetHotkeyForceHidden(focused ~= input)
		end
	end
end

function AccusationCtrl:onDestroy()
	self._playerInfoQueryToken = nil
	self._consoleBarInputs = nil

	if self._reportCancelHandler then
		self._reportCancelHandler(self._reportImageContext, self)
	end

	if self._reportImageContext then
		self._reportImageContext.submitToken = nil
		self._reportImageContext.isSubmitting = false
	end

	self._reportImageContext = nil
	self._reportSource = nil
	self._reportSubmitHandler = nil
	self._reportCancelHandler = nil
	self._playerDisplayName = nil

	UICtrl.onDestroy(self)
end

function AccusationCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._playerName = info and info.playerName or ""
	self._playerDisplayName = info and info.playerDisplayName
	self._playerId = info and info.playerId or ""
	self._reportInfo = self:cloneTable(info and info.reportInfo)
	self._reportSource = info and info.reportSource
	self._reasonList = self:_buildReasonList()
	self._sourceReportText = info and info.reportText
	self._reportText = self._sourceReportText
	self._targetPlayerInfo = nil
	self._reportImageContext = info and info.reportImageContext
	self._reportSubmitHandler = info and info.reportSubmitHandler
	self._reportCancelHandler = info and info.reportCancelHandler

	if info then
		self._reportInfo.uid = self._reportInfo.uid or info.playerId
		self._reportInfo.name = self._reportInfo.name or info.playerName
		self._reportInfo.content = self._reportInfo.content or info.content
		self._reportInfo.reason = self._reportInfo.reason or info.reason
		self._reportInfo.desc = self._reportInfo.desc or info.desc
		self._reportInfo.msgId = self._reportInfo.msgId or info.msgId
		self._reportInfo.reportType = self._reportInfo.reportType or info.reportType
	end

	self:_initSelectedReason()
	self:refreshReportText()
	self:queryTargetPlayerInfo()
end

function AccusationCtrl:onShow()
	local view = self.view
	local uiConfig = self:getReportUIConfig()
	local hasTip = not string.isNilOrEmpty(uiConfig.tipTextKey)

	if view.txtTitle then
		ClientTextUtils.setText(view.txtTitle, pg.getGameString(uiConfig.titleKey or "ACCUSATION_TITLE"))
	end

	if view.txtNameTitle then
		ClientTextUtils.setText(view.txtNameTitle, pg.getGameString(uiConfig.nameTitleKey or "ACCUSATION_NAME"))
	end

	if view.txtDescTitle then
		ClientTextUtils.setText(view.txtDescTitle, pg.getGameString("ACCUSATION_DESC_TITLE"))
	end

	if view.txtTypeTitle then
		ClientTextUtils.setText(view.txtTypeTitle, pg.getGameString("ACCUSATION_TYPE"))
	end

	if view.txtConfirm then
		ClientTextUtils.setText(view.txtConfirm, pg.getGameString("ACCUSATION_BTN"))
	end

	if view.tipsUWidget and not IsNil(view.tipsUWidget) then
		view.tipsUWidget:SetActive(hasTip)
	end

	if view.txtTipsUSDFText and not IsNil(view.txtTipsUSDFText) then
		ClientTextUtils.setText(view.txtTipsUSDFText, hasTip and pg.getGameString(uiConfig.tipTextKey) or "")
	end

	self:_refreshPlayerName()

	if view.txtDescInput then
		view.txtDescInput.text = self._reportInfo.desc or ""
	end

	self:refreshReportText()

	if view.txtDescPlaceHolder then
		ClientTextUtils.setText(view.txtDescPlaceHolder, pg.getGameString("ACCUSATION_DESC_INPUT"))
	end

	if view.txtTypePlaceHolder then
		ClientTextUtils.setText(view.txtTypePlaceHolder, self._reportText or pg.getGameString("ACCUSATION_TYPE_INPUT"))
	end

	self:_refreshDescLimit(view.txtDescInput and view.txtDescInput.text or "")

	if view.listUList then
		view.listUList:SetList(self._reasonList)

		if self._selectedReasonIndex then
			view.listUList:SelectItem(self._selectedReasonIndex - 1, false)
		end
	end
end

function AccusationCtrl:onHide()
	return
end

return AccusationCtrl
