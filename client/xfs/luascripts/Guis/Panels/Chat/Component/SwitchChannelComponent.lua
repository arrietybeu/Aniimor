-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\SwitchChannelComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local SwitchChannelComponent = Class.LightClass("SwitchChannelComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local LanguageAssociateData = require("Data.language_associate_data")
local ChannelStatus = {
	Free = 0,
	Full = 2,
	Busy = 1
}
local HistoryListCapacity = 5
local HistoryCacheCapacity = HistoryListCapacity + 1
local CLASS_CHANNEL_CLASS_NO_PATTERN = "^" .. Const.CHAT_ATTR_CLASS.group_base .. "_([%d]+)"
local CHAT_CHANNEL_TYPE_MAP = {
	[Const.CHAT_ATTR_WORLD.group_base] = Const.CHAT_CHANNEL_TYPE.WORLD,
	[Const.CHAT_ATTR_CLASS.group_base] = Const.CHAT_CHANNEL_TYPE.CLASS,
	[Const.CHAT_ATTR_LANGUAGE.group_base] = Const.CHAT_CHANNEL_TYPE.LANGUAGE
}

function SwitchChannelComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	local scrollRectObjectReference = self.scrollRectUScrollRect.content.transform:GetComponent("ObjectReference")

	self.recommendList = scrollRectObjectReference:GetRefValue("recommendList")
	self.historyList = scrollRectObjectReference:GetRefValue("historyList")
	self.recommendChannelUWidget = scrollRectObjectReference:GetRefValue("recommendChannelUWidget")
	self.historyChannelUWidget = scrollRectObjectReference:GetRefValue("historyChannelUWidget")
end

function SwitchChannelComponent:initView()
	function self.bgCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	function self.btnCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.bgCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.bgCloseUButton.luaClick()
	end

	function self.recommendList.luaRenderItem(button, index, data)
		self:renderChannelItem(button, index, data)
	end

	function self.historyList.luaRenderItem(button, index, data)
		self:renderChannelItem(button, index, data)
	end

	function self.inputFieldUTMPInputField.luaValueChanged(text)
		self.inputChannelLineId = text

		self.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
	end

	function self.inputFieldUTMPInputField.luaEndEdit(text)
		self:gotoChannelLine(tonumber(self.inputChannelLineId))
	end

	function self.btnGoUButton.luaClick()
		self:gotoChannelLine(tonumber(self.inputChannelLineId))
	end

	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("CHAT_NOT_HAVE_CHANNEL"))

	local inputObjectReference = self.inputFieldUTMPInputField:GetComponent("ObjectReference")

	self.btnDeleteUButton = inputObjectReference:GetRefValue("btnDeleteUButton")
	self.placeHolderUSDFText = inputObjectReference:GetRefValue("placeHolderUSDFText")
	self.keyHotKeyContent = inputObjectReference:GetRefValue("keyHotKeyContent")

	ClientTextUtils.setText(self.placeHolderUSDFText, pg.getGameString("CHAT_TIP_CHANNEL_INPUT"))
	LuaUIUtils.bindInputFieldGamepad(self.inputFieldUTMPInputField, self.keyHotKeyContent, self.btnDeleteUButton)
end

function SwitchChannelComponent:renderChannelItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local channelName = pg.game.chat:getWorldChatChannelName(data.groupId, self.channelType)

	ClientTextUtils.setText(textUSDFText, channelName)
	button:TryChangePage("ChannelState", data.status)

	function button.luaClick()
		self:gotoChannelLine(data.lineId)
	end
end

function SwitchChannelComponent:gotoChannelLine(lineId)
	local targetChannel

	for _, channel in ipairs(self.lineIds) do
		if channel.index == lineId then
			targetChannel = channel

			break
		end
	end

	local rpcChannelType = CHAT_CHANNEL_TYPE_MAP[self.channelType]

	if targetChannel and targetChannel.count < Const.CHAT_ATTR_WORLD.group_capacity then
		pg.me:switchChatChannel(rpcChannelType, lineId)
		self:recordChannelHistory(lineId)
		self.bgCloseUButton.luaClick()

		return
	end

	if targetChannel then
		pg.global.showBubbleMessageRaw(pg.getGameString("CHANNEL_LINE_FULL"), 2)

		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("SWITCH_CHANNEL_LINE_FAILED"), 2)

	if self.recommendChannels and self.recommendChannels[1] then
		pg.me:switchChatChannel(rpcChannelType, self.recommendChannels[1].lineId)
	end

	self.bgCloseUButton.luaClick()
end

function SwitchChannelComponent:getChatRecord()
	pg.me:callService("ChatService", "chatRecord", {
		self.uid,
		""
	}, CallbackHandler(self, "_getChatRecordCallback"), {
		callerId = self.uid
	})
end

function SwitchChannelComponent:_getChatRecordCallback(result, resp)
	pg.game.chat:recvChatRecord(result, resp)

	local selectedItem = self.ctrl.view.channelListUList.selectedItem
	local selectionKey = self.ctrl.model:getChannelSelectionKey(selectedItem)

	facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE, {
		tabType = pg.game.chat.tabType.Public,
		selectionKey = selectionKey
	})
	self.ctrl.chatComponent:refreshChatMessageList()
end

function SwitchChannelComponent:getHistoryListCache(lineId)
	local historyChannelKey = pg.me.uid .. self.channelType .. "LineHistory"
	local defaultValue = ""
	local listValueStr = pg.global.prefsCacheUtils:getString(historyChannelKey, defaultValue)
	local listValueTable = {}

	for val in string.gmatch(listValueStr, "[^|]+") do
		if not lineId or tonumber(val) ~= lineId then
			listValueTable[#listValueTable + 1] = tonumber(val)
		end
	end

	return listValueTable
end

function SwitchChannelComponent:recordChannelHistory(lineId)
	local historyListTable = self:getHistoryListCache(lineId)
	local historyChannelKey = pg.me.uid .. self.channelType .. "LineHistory"

	historyListTable[#historyListTable + 1] = lineId

	while #historyListTable > HistoryCacheCapacity do
		table.remove(historyListTable, 1)
	end

	pg.global.prefsCacheUtils:setString(historyChannelKey, table.concat(historyListTable, "|"))
end

function SwitchChannelComponent:refreshChannelList(channelType, currentGroupId)
	self.channelType = channelType
	self.currentGroupId = currentGroupId

	self.view.panelUComponent:TryChangePage("ShowPopup", 7)
	self:chatChannelStatus()
end

function SwitchChannelComponent:chatChannelStatus()
	local groupTags = {}

	if self.channelType == Const.CHAT_ATTR_CLASS.group_base then
		local classNo = string.match(self.currentGroupId, CLASS_CHANNEL_CLASS_NO_PATTERN)

		groupTags = {
			classNo
		}
	elseif self.channelType == Const.CHAT_ATTR_LANGUAGE.group_base then
		local areaNo, languageNo = Utils.parseClassId(pg.me.uid)
		local languageConfig = LanguageAssociateData[areaNo][languageNo]
		local mainLanguageNo = languageConfig.mainLanguageId or languageNo
		local mainLanguageConfig = LanguageAssociateData[areaNo][mainLanguageNo]

		groupTags = {
			mainLanguageConfig.language
		}
	end

	local callback = CallbackHandler(self, "_chatChannelStatusCallback", self.channelType, self.currentGroupId)

	pg.me:callService("ChatService", "getGroupStatus", {
		self.channelType,
		groupTags
	}, callback, {
		callerId = self.uid
	})
end

function SwitchChannelComponent:sortChatChannels()
	local function sortByEnterTime(a, b)
		if a.groupOrder == b.groupOrder then
			return a.lineId < b.lineId
		end

		return a.groupOrder > b.groupOrder
	end

	local function sortByCount(a, b)
		return a.count > b.count
	end

	table.sort(self.recommendChannels, sortByCount)
	table.sort(self.historyChannels, sortByEnterTime)
end

function SwitchChannelComponent:_chatChannelStatusCallback(channelType, currentGroupId, result, resp)
	if not self.view or channelType ~= self.channelType then
		return
	end

	self.historyChannels = {}
	self.recommendChannels = {}
	self.lineIds = {}

	local historyListCache = self:getHistoryListCache()
	local channelCapacity = Const.CHAT_ATTR_WORLD.group_capacity
	local busyCount = math.floor(channelCapacity * 0.8)

	for index, group in ipairs(resp.Groups) do
		self.lineIds[#self.lineIds + 1] = {
			index = index,
			count = group.Count
		}

		local groupOrder = 0

		for historyIndex, historyLineId in ipairs(historyListCache) do
			if index == historyLineId then
				groupOrder = historyIndex

				break
			end
		end

		local groupData = {
			lineId = index,
			count = group.Count,
			groupId = group.Group,
			groupOrder = groupOrder
		}

		if channelCapacity <= groupData.count then
			groupData.status = ChannelStatus.Full
		elseif busyCount <= groupData.count then
			groupData.status = ChannelStatus.Busy
		else
			groupData.status = ChannelStatus.Free
		end

		local isCurrentGroup = group.Group == currentGroupId
		local shouldAddHistory = #self.historyChannels < HistoryListCapacity and groupOrder ~= 0 and not isCurrentGroup

		if shouldAddHistory then
			self.historyChannels[#self.historyChannels + 1] = groupData
		end

		local shouldRecommend = groupData.status ~= ChannelStatus.Full and not isCurrentGroup and #self.recommendChannels < 2

		if shouldRecommend then
			self.recommendChannels[#self.recommendChannels + 1] = groupData
		end
	end

	local isEmpty = next(self.historyChannels) == nil and next(self.recommendChannels) == nil

	self.uWidget:TryChangePage("Empty", isEmpty and 1 or 0)

	if isEmpty then
		return
	end

	self:sortChatChannels()
	self.recommendList:SetList(self.recommendChannels)
	self.historyList:SetList(self.historyChannels)
end

return SwitchChannelComponent
