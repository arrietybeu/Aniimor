-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\Component\\EditTitleBarComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EditTitleBarComponent = Class.LightClass("EditTitleBarComponent", UIComponent)
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local ShowTitleData = require("Data.show_title_data")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local ShowTitleUtils = require("Utils.ShowTitleUtils")
local COMBINE_TITLE_TYPES = {
	Const.SHOW_TITLE_TYPE.Prefix,
	Const.SHOW_TITLE_TYPE.Suffix,
	Const.SHOW_TITLE_TYPE.Background
}

EditTitleBarComponent.messages = {
	[MessageName.RECV_FRIEND_LIST] = {
		"onFriendTitleListChanged",
		true
	},
	[MessageName.FRIENDSHIP_UPDATE] = {
		"onFriendTitleListChanged",
		true
	},
	[MessageName.FRIEND_PERMISSION_CHANGED] = {
		"onFriendTitleListChanged",
		true
	}
}

function EditTitleBarComponent:onCtor(info)
	self.playerInfo = info.playerInfo
	self.friendTitleInfo = info.friendTitleInfo
	self.titleListType = self.playerInfo.isWholeTitle and Const.SHOW_TITLE_TYPE.Whole or Const.SHOW_TITLE_TYPE.Prefix
	self.btnConfirm = info.btnConfirm
	self.usingUWidget = info.usingUWidget

	local confirmObjectReference = self.btnConfirm:GetComponent("ObjectReference")

	self.btnConfirmText = confirmObjectReference:GetRefValue("txtNameUText")
	self.getWayBottomText = info.getWayBottomText

	function self.confirmHandler()
		self:onConfirmBtnClick()
	end

	function self.refreshPanelHandler()
		self.uWidget:TryChangePage("TtileTab", 0)

		local isWholeTitle = self.playerInfo.isWholeTitle
		local useFriendTitle = self.pendingDefaultTitleType == Const.SHOW_TITLE_TYPE.Prefix and self:hasFriendTitleContext()

		if self.pendingDefaultTitleType == Const.SHOW_TITLE_TYPE.Prefix then
			isWholeTitle = false
		end

		self.pendingDefaultTitleType = nil
		self.titleListType = isWholeTitle and Const.SHOW_TITLE_TYPE.Whole or Const.SHOW_TITLE_TYPE.Prefix

		self:clearTitlePreview(isWholeTitle)

		if useFriendTitle then
			local friendTitleData = self:getFriendTitleData(self.friendTitleInfo.friendUid)

			if friendTitleData then
				self:applyFriendTitlePreview(friendTitleData)
			end
		end

		self:refreshCurTitle(not isWholeTitle)
		self:refreshTitleList(not isWholeTitle, true, self.titleListType)
	end
end

function EditTitleBarComponent:setDefaultTitleType(titleType)
	self.pendingDefaultTitleType = titleType
end

function EditTitleBarComponent:initView()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.tab1Button = objectReference:GetRefValue("tab1Button")
	self.tab2Button = objectReference:GetRefValue("tab2Button")
	self.word1NameText = objectReference:GetRefValue("word1NameText")
	self.word2NameText = objectReference:GetRefValue("word2NameText")
	self.combineTitleList = objectReference:GetRefValue("combineTitleList")
	self.singleTitleList = objectReference:GetRefValue("singleTitleList")
	self.getWayText = objectReference:GetRefValue("getWayText")
	self.singleWordNameText = objectReference:GetRefValue("singleWordNameText")
	self.word1Button = objectReference:GetRefValue("word1Button")
	self.word2Button = objectReference:GetRefValue("word2Button")
	self.word3Button = objectReference:GetRefValue("word3Button")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.text2USDFText = objectReference:GetRefValue("text2USDFText")
	self.text3USDFText = objectReference:GetRefValue("text3USDFText")
	self.wordInfoUWidget = objectReference:GetRefValue("wordInfoUWidget")
	self.titleBarBubbleUWidget = objectReference:GetRefValue("titleBarBubbleUWidget")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.textDescribeUSDFText = objectReference:GetRefValue("textDescribeUSDFText")
	self.titleBackgroundUImage = self.ctrl.titleBackgroundUImage
	self.txtTitleUSDFText = self.ctrl.txtTitleUSDFText

	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("TITLE_PREFIX"))
	ClientTextUtils.setText(self.text2USDFText, pg.getGameString("TITLE_SUFFIX"))
	ClientTextUtils.setText(self.text3USDFText, pg.getGameString("TITLE_BACKGROUND"))
	self:addListener()
	self:clearTitlePreview()
	self:refreshTitlePreview()
end

function EditTitleBarComponent:addListener()
	function self.tab1Button.luaClick()
		local isCombineTitle = table.contains(COMBINE_TITLE_TYPES, self.titleListType)

		if isCombineTitle then
			return
		end

		self.uWidget:TryChangePage("Tab", 0)
		self:clearTitlePreview(false)
		self:switchTitleListType(Const.SHOW_TITLE_TYPE.Prefix, true, true)
		self.uWidget:TryChangePage("TtileTab", 0)

		if pg.game.input:isUsingGamepad() then
			local objRef = self.uWidget.gameObject:GetComponent("ObjectReference")
			local worldInfoWidget = objRef:GetRefValue("wordInfoUWidget")

			if worldInfoWidget and worldInfoWidget.simulateButtonSwitch then
				worldInfoWidget.simulateButtonSwitch:SetCursor(Const.SHOW_TITLE_TYPE.Prefix - 1, -1)
			end
		end
	end

	function self.tab2Button.luaClick()
		if self.titleListType == Const.SHOW_TITLE_TYPE.Whole then
			return
		end

		self.uWidget:TryChangePage("Tab", 1)
		self:switchTitleListType(Const.SHOW_TITLE_TYPE.Whole, false)
	end

	function self.combineTitleList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if iconUImage then
			iconUImage:SetActive(self:isFriendTitleItem(data))
		end

		if data.tIndex == 0 then
			self:renderTitleListItem(button, index, data)
		elseif data.tIndex == 1 then
			self:renderTitleBackgroundListItem(button, index, data)
		end

		function button.luaClick()
			button.isSelected = true
			self.curSelectedTitle = data.titleId
			self.curSelectedTitleData = data

			if self.titleListType == Const.SHOW_TITLE_TYPE.Prefix then
				local prefixText = self:isFriendTitleItem(data) and ShowTitleUtils.getPlayerNameTitleText(self:resolveFriendTitleDisplayName(data.friendUid, data.friendName), "") or pg.getLocalizationText(data.titleText)

				ClientTextUtils.setText(self.word1NameText, prefixText)
			elseif self.titleListType == Const.SHOW_TITLE_TYPE.Suffix then
				ClientTextUtils.setText(self.word2NameText, pg.getLocalizationText(data.titleText))
			end

			self:refreshTitlePreview(data)
			self:refreshConfirmButtonState(data)
		end
	end

	function self.singleTitleList.luaRenderItem(button, index, data)
		self:renderTitleListItem(button, index, data)

		function button.luaClick()
			if self.titleListType == Const.SHOW_TITLE_TYPE.Whole then
				button.isSelected = true
				self.curSelectedTitle = data.titleId
				self.curSelectedTitleData = data

				ClientTextUtils.setText(self.singleWordNameText, pg.getLocalizationText(data.titleText))
				ClientTextUtils.setText(self.getWayText, pg.getLocalizationText(data.sourceDec))
				self:refreshTitlePreview(data)
				self:refreshConfirmButtonState(data)
			end
		end
	end

	function self.word1Button.luaClick()
		self:switchTitleListType(Const.SHOW_TITLE_TYPE.Prefix, true, true)
	end

	function self.word2Button.luaClick()
		self:switchTitleListType(Const.SHOW_TITLE_TYPE.Suffix, true, false)
	end

	function self.word3Button.luaClick()
		self:switchTitleListType(Const.SHOW_TITLE_TYPE.Background, true, false)
	end
end

function EditTitleBarComponent:switchTitleListType(titleType, isCombineList, isFrontTitle)
	self.titleListType = titleType

	self:refreshCurTitle(isCombineList)
	self:refreshTitleList(isCombineList, isFrontTitle, titleType)
end

function EditTitleBarComponent:clearTitlePreview(isWholeTitle)
	self.previewShowTitles = Utils.deepCopyTable(self.playerInfo.showTitles or {})
	self.previewShowTitleExtra = Utils.deepCopyTable(self.playerInfo.showTitleExtra or {})
	self.previewIsWholeTitle = isWholeTitle == nil and self.playerInfo.isWholeTitle or isWholeTitle
end

function EditTitleBarComponent:hasFriendTitleContext()
	return self.friendTitleInfo ~= nil and not string.isNilOrEmpty(tostring(self.friendTitleInfo.friendUid or ""))
end

function EditTitleBarComponent:getFriendTitleData(friendUid)
	friendUid = tostring(friendUid or "")

	for _, data in ipairs(self.model:getShowTitleList(Const.SHOW_TITLE_TYPE.Prefix)) do
		if data.isFriendTitle and data.friendUid == friendUid then
			return data
		end
	end
end

function EditTitleBarComponent:isFriendTitleItem(data)
	return data ~= nil and data.isFriendTitle == true
end

function EditTitleBarComponent:resolveFriendTitleDisplayName(friendUid, rawName)
	local hooks = EditTitleBarComponent._platformHooks

	if hooks and hooks.resolveFriendTitleDisplayName then
		return hooks.resolveFriendTitleDisplayName(self, friendUid, rawName) or rawName or ""
	end

	return rawName or ""
end

function EditTitleBarComponent:applyFriendTitlePreview(friendTitleData)
	self.previewShowTitles[Const.SHOW_TITLE_TYPE.Prefix] = nil
	self.previewShowTitleExtra = ShowTitleUtils.makeFriendPrefixExtra(friendTitleData.friendUid, friendTitleData.friendName)
	self.previewIsWholeTitle = false
end

function EditTitleBarComponent:getPreviewTitleId(titleType)
	local showTitles = self.previewShowTitles or self.playerInfo.showTitles or {}

	return showTitles[titleType]
end

function EditTitleBarComponent:renderTitleListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local titleBackgroundUImage = objectReference:GetRefValue("titleBackgroundUImage")
	local showBackground = data.titleType == Const.SHOW_TITLE_TYPE.Whole and not string.isNilOrEmpty(data.bgRes)

	if txtNameUSDFText then
		txtNameUSDFText:SetActive(true)
	end

	if titleBackgroundUImage then
		titleBackgroundUImage:SetActive(showBackground)

		if showBackground then
			titleBackgroundUImage.url = data.bgRes
		end
	end

	local isFriendTitle = self:isFriendTitleItem(data)
	local titleText = isFriendTitle and ShowTitleUtils.getPlayerNameTitleText(self:resolveFriendTitleDisplayName(data.friendUid, data.friendName), "") or pg.getLocalizationText(data.titleText)

	if self.titleListType == Const.SHOW_TITLE_TYPE.Whole and data.titleType == 0 then
		titleText = ""
	end

	ClientTextUtils.setText(txtNameUSDFText, titleText)

	local previewTitleId = self:getPreviewTitleId(self.titleListType)

	if self:isPreviewTitleItemSelected(data, previewTitleId) then
		button.isSelected = true
	end

	local equippedTitleId = self.playerInfo.showTitles[self.titleListType]

	if self:isEquippedTitleItem(data, equippedTitleId) then
		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", data.isLock and 1 or 0)
	end
end

function EditTitleBarComponent:isPreviewTitleItemSelected(data, previewTitleId)
	if self.titleListType == Const.SHOW_TITLE_TYPE.Prefix then
		if self:isFriendTitleItem(data) then
			local previewFriendUid = ShowTitleUtils.getFriendPrefixInfo(self.previewShowTitleExtra)

			return not string.isNilOrEmpty(previewFriendUid) and previewFriendUid == data.friendUid
		end

		return not ShowTitleUtils.hasFriendPrefix(self.previewShowTitleExtra) and (previewTitleId == nil and data.titleType == Const.SHOW_TITLE_TYPE.None or data.titleId == previewTitleId)
	end

	return previewTitleId == nil and data.titleType == Const.SHOW_TITLE_TYPE.None or data.titleId == previewTitleId
end

function EditTitleBarComponent:isEquippedTitleItem(data, equippedTitleId)
	if self.titleListType == Const.SHOW_TITLE_TYPE.Prefix then
		if self:isFriendTitleItem(data) then
			local equippedFriendUid = ShowTitleUtils.getFriendPrefixInfo(self.playerInfo.showTitleExtra)

			return not string.isNilOrEmpty(equippedFriendUid) and equippedFriendUid == data.friendUid
		end

		return not ShowTitleUtils.hasFriendPrefix(self.playerInfo.showTitleExtra) and (equippedTitleId == nil and data.titleType == Const.SHOW_TITLE_TYPE.None or data.titleId == equippedTitleId)
	end

	return equippedTitleId == nil and data.titleType == Const.SHOW_TITLE_TYPE.None or data.titleId == equippedTitleId
end

function EditTitleBarComponent:renderTitleBackgroundListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local titleBackgroundUImage = objectReference:GetRefValue("titleBackgroundUImage")

	if txtNameUSDFText then
		txtNameUSDFText:SetActive(false)
	end

	if titleBackgroundUImage then
		local showBackground = not string.isNilOrEmpty(data.bgRes)

		titleBackgroundUImage:SetActive(showBackground)

		if showBackground then
			titleBackgroundUImage.url = data.bgRes
		end
	end

	local previewTitleId = self:getPreviewTitleId(self.titleListType)

	if self:isPreviewTitleItemSelected(data, previewTitleId) then
		button.isSelected = true
	end

	local equippedTitleId = self.playerInfo.showTitles[self.titleListType]

	if self:isEquippedTitleItem(data, equippedTitleId) then
		button:TryChangePage("State", 2)
	else
		button:TryChangePage("State", data.isLock and 1 or 0)
	end
end

function EditTitleBarComponent:getPreviewTitleText(showTitles, showTitleExtra, isWholeTitle)
	return ShowTitleUtils.getShowTitleText(showTitles, showTitleExtra, isWholeTitle)
end

function EditTitleBarComponent:refreshTitlePreview(previewData)
	local showTitles = Utils.deepCopyTable(self.previewShowTitles or self.playerInfo.showTitles or {})
	local showTitleExtra = self.previewShowTitleExtra or self.playerInfo.showTitleExtra or {}
	local isWholeTitle = self.previewIsWholeTitle

	if isWholeTitle == nil then
		isWholeTitle = self.playerInfo.isWholeTitle
	end

	local isFriendTitle = self:isFriendTitleItem(previewData)
	local titleData = previewData and ShowTitleData[previewData.titleId]

	if isFriendTitle then
		showTitles[Const.SHOW_TITLE_TYPE.Prefix] = nil
		showTitleExtra = ShowTitleUtils.makeFriendPrefixExtra(previewData.friendUid, previewData.friendName)
		isWholeTitle = false
	elseif titleData then
		local titleType = titleData.titleType == Const.SHOW_TITLE_TYPE.None and self.titleListType or titleData.titleType

		if titleData.titleType == Const.SHOW_TITLE_TYPE.None then
			showTitles[titleType] = nil
		else
			showTitles[titleType] = previewData.titleId
		end

		if titleType == Const.SHOW_TITLE_TYPE.Prefix then
			showTitleExtra = {}
		end

		if titleType == Const.SHOW_TITLE_TYPE.Whole then
			isWholeTitle = true
		elseif titleType ~= Const.SHOW_TITLE_TYPE.Background then
			isWholeTitle = false
		end
	end

	local hasPreviewData = isFriendTitle or titleData ~= nil

	if hasPreviewData then
		self.previewShowTitles = showTitles
		self.previewShowTitleExtra = showTitleExtra
		self.previewIsWholeTitle = isWholeTitle
	end

	if self.txtTitleUSDFText then
		ClientTextUtils.setText(self.txtTitleUSDFText, self:getPreviewTitleText(showTitles, showTitleExtra, isWholeTitle))
	end

	local backgroundId = showTitles[Const.SHOW_TITLE_TYPE.Background]
	local backgroundData = ShowTitleData[backgroundId]
	local wholeTitleData = ShowTitleData[showTitles[Const.SHOW_TITLE_TYPE.Whole]]
	local backgroundUrl = backgroundData and backgroundData.bgRes

	if isWholeTitle and wholeTitleData and not string.isNilOrEmpty(wholeTitleData.bgRes) then
		backgroundUrl = wholeTitleData.bgRes
	end

	if self.titleBackgroundUImage then
		self.titleBackgroundUImage:SetActive(not string.isNilOrEmpty(backgroundUrl))

		if not string.isNilOrEmpty(backgroundUrl) then
			self.titleBackgroundUImage.url = backgroundUrl
		end
	end

	self:refreshFriendTitleBubble(showTitleExtra)
end

function EditTitleBarComponent:refreshFriendTitleBubble(showTitleExtra)
	local friendUid, friendName = ShowTitleUtils.getFriendPrefixInfo(showTitleExtra)
	local isActive = self.titleListType == Const.SHOW_TITLE_TYPE.Prefix and not string.isNilOrEmpty(friendUid)

	self.titleBarBubbleUWidget:SetActive(isActive)

	if not isActive then
		return
	end

	local displayFriendName = self:resolveFriendTitleDisplayName(friendUid, friendName)
	local prefixName = ShowTitleUtils.getPlayerNameTitleText(displayFriendName, "")

	ClientTextUtils.setText(self.textNameUSDFText, prefixName)
	ClientTextUtils.setText(self.textDescribeUSDFText, pg.getGameString("SHOW_TITLE_FRIEND_NAME"))
end

function EditTitleBarComponent:refreshCurTitle(isCombineList)
	local showTitles = self.previewShowTitles or self.playerInfo.showTitles or {}
	local defaultTitle = pg.getLocalizationText(ShowTitleData[1].titleText)

	if isCombineList then
		local prefixTitle = ShowTitleUtils.getPrefixText(showTitles, self.previewShowTitleExtra)

		if ShowTitleUtils.hasFriendPrefix(self.previewShowTitleExtra) then
			prefixTitle = ShowTitleUtils.getPlayerNameTitleText(prefixTitle, "")
		end

		if string.isNilOrEmpty(prefixTitle) then
			prefixTitle = defaultTitle
		end

		local suffixTitle = self:getTitleTextOrDefault(showTitles[Const.SHOW_TITLE_TYPE.Suffix], defaultTitle)

		ClientTextUtils.setText(self.word1NameText, prefixTitle)
		ClientTextUtils.setText(self.word2NameText, suffixTitle)
	else
		local wholeTitleId = showTitles[Const.SHOW_TITLE_TYPE.Whole]
		local wholeTitle = self:getTitleTextOrDefault(wholeTitleId, defaultTitle)
		local wholeTitleData = ShowTitleData[wholeTitleId]
		local wholeTitleGetWay = wholeTitleData and pg.getLocalizationText(wholeTitleData.sourceDec) or defaultTitle

		ClientTextUtils.setText(self.singleWordNameText, wholeTitle)
		ClientTextUtils.setText(self.getWayText, wholeTitleGetWay)
	end

	self:refreshTitlePreview()
end

function EditTitleBarComponent:getTitleTextOrDefault(titleId, defaultTitle)
	local titleText = ShowTitleUtils.getTitleText(titleId)

	return string.isNilOrEmpty(titleText) and defaultTitle or titleText
end

function EditTitleBarComponent:refreshTitleList(isCombineList, isFrontTitle, titleType)
	self.uWidget:TryChangePage("Tab", isCombineList and 0 or 1)

	local combineTitleType = isFrontTitle and Const.SHOW_TITLE_TYPE.Prefix or Const.SHOW_TITLE_TYPE.Suffix

	titleType = titleType or isCombineList and combineTitleType or Const.SHOW_TITLE_TYPE.Whole

	local res = self.model:getShowTitleList(titleType)
	local selectedData = self:getPreviewTitleData(res, titleType)

	self:refreshConfirmButtonState(selectedData)

	if isCombineList then
		self.combineTitleList:SetList(res)
		self:selectTitleListItem(self.combineTitleList, res, titleType)
	else
		self.singleTitleList:SetList(res)
		self:selectTitleListItem(self.singleTitleList, res, Const.SHOW_TITLE_TYPE.Whole)
	end
end

function EditTitleBarComponent:getPreviewTitleData(dataList, titleType)
	local titleId = self:getPreviewTitleId(titleType)

	for _, data in ipairs(dataList or EMPTY_TABLE) do
		if self:isPreviewTitleItemSelected(data, titleId) then
			return data
		end
	end
end

function EditTitleBarComponent:selectTitleListItem(list, dataList, titleType)
	local titleId = self:getPreviewTitleId(titleType)
	local selectIndex

	for i, data in ipairs(dataList or EMPTY_TABLE) do
		if self:isPreviewTitleItemSelected(data, titleId) then
			self.curSelectedTitle = data.titleId
			self.curSelectedTitleData = data
			selectIndex = i - 1

			list:SelectItem(selectIndex, false)

			local shouldLocateFriendTitle = titleType == Const.SHOW_TITLE_TYPE.Prefix and self:hasFriendTitleContext() and data.friendUid == tostring(self.friendTitleInfo.friendUid)

			if shouldLocateFriendTitle then
				list:GoToIndex(selectIndex)
			end

			if pg.game.input:isUsingGamepad() then
				local ret, titleBtn = list:TryGetChildAt(selectIndex)

				if ret and NotNil(titleBtn) then
					CS.XGUI.Navigation.NavManager.Instance:FocusItem(titleBtn)
				end
			end

			break
		end
	end
end

function EditTitleBarComponent:refreshConfirmButtonState(data)
	self.usingUWidget:SetActive(false)
	self.btnConfirm:SetActive(true)
	self.btnConfirm:TryChangePage("IconState", 0)

	if not data then
		self.btnConfirm:SetActive(false)

		return
	end

	local id = data.titleId
	local isFriendTitle = self:isFriendTitleItem(data)

	if not isFriendTitle and self.model:isTitleLock(id) then
		local sourceData = self:getTitleItemSourceData(id)

		if sourceData and sourceData.param then
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GO_GET_ITEM"))
			self.btnConfirm:TryChangePage("IconState", 1)
			self.btnConfirm:TryChangePage("button", 0)

			self.btnConfirm.interactable = true

			self.getWayBottomText:SetActive(false)
		else
			ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("SKILL_LOCKED"))
			self.btnConfirm:TryChangePage("button", 4)

			self.btnConfirm.interactable = false

			self.getWayBottomText:SetActive(true)
			ClientTextUtils.setText(self.getWayBottomText, pg.getLocalizationText(ShowTitleData[id].sourceDec))
		end
	elseif self:isEquippedTitleItem(data, self.playerInfo.showTitles[self.titleListType]) then
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("GRAB_EGG_USE_LOADING"))
		self.btnConfirm:TryChangePage("button", 4)

		self.btnConfirm.interactable = false

		self.getWayBottomText:SetActive(false)
		self.usingUWidget:SetActive(true)
		self.btnConfirm:SetActive(false)
	else
		ClientTextUtils.setText(self.btnConfirmText, pg.getGameString("USE"))
		self.btnConfirm:TryChangePage("button", 0)

		self.btnConfirm.interactable = true

		self.getWayBottomText:SetActive(false)
	end
end

function EditTitleBarComponent:getTitleItemSourceData(titleId)
	local titleData = ShowTitleData[titleId]
	local itemData = titleData.item and ItemData[titleData.item]
	local sourceId = itemData and itemData.source and itemData.source[1]

	return sourceId and ItemSourceData[sourceId]
end

function EditTitleBarComponent:onConfirmBtnClick()
	local isLockedTitle = not self:isFriendTitleItem(self.curSelectedTitleData) and self.model:isTitleLock(self.curSelectedTitle)

	if isLockedTitle then
		local data = ItemSourceData[ShowTitleData[self.curSelectedTitle].item]

		pg.me:doEventByData({
			data.param[1],
			data.param[2]
		})
	end

	local curShowTitles = Utils.deepCopyTable(self.previewShowTitles or self.playerInfo.showTitles or {})
	local curShowTitleExtra = Utils.deepCopyTable(self.previewShowTitleExtra or self.playerInfo.showTitleExtra or {})
	local isWholeTitle = self.previewIsWholeTitle == true

	pg.me:serverMsg("RPC_CS_SetShowTitle", curShowTitles, isWholeTitle, curShowTitleExtra)
end

function EditTitleBarComponent:onShowTitlesChange()
	self:clearTitlePreview()

	local isCombineList = self.titleListType ~= Const.SHOW_TITLE_TYPE.Whole

	self:refreshCurTitle(isCombineList)
	self:refreshTitleList(isCombineList, self.titleListType == Const.SHOW_TITLE_TYPE.Prefix, self.titleListType)
end

function EditTitleBarComponent:onFriendTitleListChanged()
	if self.titleListType == Const.SHOW_TITLE_TYPE.Prefix then
		self:refreshTitleList(true, true, Const.SHOW_TITLE_TYPE.Prefix)
	end
end

return EditTitleBarComponent
