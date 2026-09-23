-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\HistoryInformationComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local HistoryInformationComponent = Class.LightClass("HistoryInformationComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Const = require("Common.Const.Const")

function HistoryInformationComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBgCloseUButton = self.objectReference:GetRefValue("btnBgCloseUButton")
	self.historyListUlist = self.objectReference:GetRefValue("historyListUlist")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function HistoryInformationComponent:initView()
	self.selectedMessageData = nil

	function self.btnCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	function self.btnBgCloseUButton.luaClick()
		self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.btnCloseUButton.luaClick()
	end

	function self.historyListUlist.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if data.extraInfo and (data.extraInfo[Const.CHAT_EXTRA_TYPE.Item] or data.extraInfo[Const.CHAT_EXTRA_TYPE.Pet] or data.extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard]) then
			ClientTextUtils.setText(txtNameUSDFText, pg.getFormatText(pg.getGameString("HYPER_LINK"), data.textContent))
		else
			ClientTextUtils.setText(txtNameUSDFText, data.textContent)
		end

		function button.luaClick(navConfirm)
			if navConfirm then
				return
			end

			self.selectedMessageData = data

			local text = self.selectedMessageData.textContent
			local subType = self.selectedMessageData.subType
			local extraInfo = self.selectedMessageData.extraInfo
			local curSelectedChannelData = self.view.channelListUList.selectedItem

			pg.game.chat:sendMessage(text, subType, curSelectedChannelData.type, curSelectedChannelData.channelId or curSelectedChannelData.playerId, extraInfo)
			self.btnCloseUButton.luaClick()
		end
	end
end

function HistoryInformationComponent:refreshHistoryInformationList(selectedChannelId)
	self.view.panelUComponent:TryChangePage("ShowPopup", 1)

	local chatMessageListData = pg.game.chat:getChatMessageListData()
	local historyList = {}

	for _, data in pairs(chatMessageListData) do
		for _, msg in pairs(data) do
			if msg.tIndex == pg.game.chat.messageType.SelfPlayer then
				local alreadyHave = false

				for _, historyInfo in pairs(historyList) do
					if self:checkHistoryTextEqual(historyInfo, msg) then
						alreadyHave = true
						historyInfo.timeStamp = msg.timeStamp

						break
					end
				end

				if not alreadyHave then
					table.insert(historyList, {
						textContent = pg.game.chat:getTextContentFromExtraInfo(msg.extraInfo) or msg.textContent,
						subType = msg.subType,
						timeStamp = msg.timeStamp,
						extraInfo = msg.extraInfo
					})
				end
			end
		end
	end

	local function sort(a, b)
		return a.timeStamp > b.timeStamp
	end

	table.sort(historyList, sort)
	self.historyListUlist:SetList(historyList)
end

function HistoryInformationComponent:checkHistoryTextEqual(msg1, msg2)
	if msg1.extraInfo and msg2.extraInfo then
		local text1 = pg.game.chat:getTextContentFromExtraInfo(msg1.extraInfo) or msg1.textContent
		local text2 = pg.game.chat:getTextContentFromExtraInfo(msg2.extraInfo) or msg2.textContent

		return text1 == text2
	end

	if msg1.textContent == msg2.textContent then
		return true
	end

	return false
end

return HistoryInformationComponent
