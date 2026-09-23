-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\DialogReview\\DialogReviewCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local PuppetData = require("Data.puppet_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local DialogReviewCtrl = Class.LightClass("DialogReviewCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local DialogueConst = require("Const.DialogueConst")
local ToBool = ToBool

function DialogReviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local logs = self:getHandledDialogReviewLogs(info)

	self.logs = logs

	self.view.contentList:SetList(logs)
	self.view.contentList:GoToIndex(-1, true)
	self:refreshConsoleBarState()
	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarUWidget.transform, {
		right = {
			{
				path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove,
				label = pg.getGameString("CONSOLE_BAR_SCROLL_VIEW")
			},
			{
				path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast,
				label = pg.getGameString("CONSOLE_BAR_EXIT")
			}
		}
	})
end

function DialogReviewCtrl:addListener()
	local function closeFunc()
		self:close()
	end

	self.view.returnBtn.luaClick = closeFunc

	function self.view.contentList.luaRenderItem(button, index, data)
		self:setItemData(button, index, data)
	end

	self:bindHotKeyPerform("Common/ClosePanelCommon", closeFunc, self.view.returnBtn.gameObject, "Common/ClosePanelCommon")
	self:bindGamepadScrollUList(self.view.contentList, nil, true)
end

function DialogReviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DialogReviewCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function DialogReviewCtrl:onShow()
	UICtrl.onShow(self)
end

function DialogReviewCtrl:close()
	if self.view.blurUWidget then
		self.view.blurUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end

	UICtrl.close(self)
end

function DialogReviewCtrl:getHandledDialogReviewLogs(info)
	if not info then
		return
	end

	local ret = {}
	local lastSpeaker = "invalidDefault"
	local curSpeaker

	for _, data in ipairs(info) do
		local isChoice = data.isChoice
		local dialogId = data.dialogId
		local dialogIndex = data.dialogIndex or 1
		local dialogText, npcId
		local isNpc = false
		local isNarration = false

		if isChoice then
			dialogText = LuaUIUtils.getReplacedDialogueText(data.branchText)
		else
			dialogText = LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogId][dialogIndex].chat)
			npcId = NpcDialogueData[dialogId][dialogIndex].npcId
			isNpc = npcId == nil or npcId ~= 0
		end

		if isNpc then
			if NpcDialogueData[dialogId][dialogIndex].npcName then
				curSpeaker = LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogId][dialogIndex].npcName) or pg.getGameString("DIALOGUE_NARRATION")
			elseif data.chatType == DialogueConst.ChatType.BLACK_SCREEN then
				isNarration = true
			else
				local npcData = PuppetData[npcId]

				if npcData then
					curSpeaker = LuaUIUtils.getReplacedDialogueText(npcData.name)
				else
					curSpeaker = pg.getGameString("DIALOGUE_NARRATION")
				end
			end
		elseif dialogId and NpcDialogueData[dialogId][dialogIndex].npcName then
			curSpeaker = LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogId][dialogIndex].npcName) or pg.getGameString("DIALOGUE_NARRATION")
		elseif data.chatType == DialogueConst.ChatType.BLACK_SCREEN then
			isNarration = true
		else
			curSpeaker = pg.getGameString("ME")
		end

		local curSplitPos = curSpeaker and string.find(curSpeaker, "<localizationIdTag")
		local lastSplitPos = lastSpeaker and string.find(lastSpeaker, "<localizationIdTag")
		local checkSameSpeaker = curSpeaker == lastSpeaker

		if curSplitPos and lastSplitPos and curSplitPos > 0 and lastSplitPos > 0 then
			checkSameSpeaker = string.sub(curSpeaker, 1, curSplitPos - 1) == string.sub(lastSpeaker, 1, lastSplitPos - 1)
		end

		if isNarration then
			lastSpeaker = nil

			table.insert(ret, {
				needTitle = true,
				speakerName = pg.getGameString("DIALOGUE_NARRATION"),
				text = dialogText,
				isNpc = isNpc
			})
		elseif not checkSameSpeaker then
			lastSpeaker = curSpeaker

			table.insert(ret, {
				needTitle = true,
				speakerName = lastSpeaker,
				text = dialogText,
				isNpc = isNpc
			})
		else
			table.insert(ret, {
				speakerName = lastSpeaker,
				text = dialogText,
				isNpc = isNpc
			})
		end
	end

	return ret
end

function DialogReviewCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function DialogReviewCtrl:refreshConsoleBarState()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local scrollbar = self.view.contentList.gameObject.transform:GetComponentInChildren(typeof(CS.XGUI.UScrollbar))

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_DialogReview_Scroll", scrollbar and scrollbar.renderOpacity > 0)
end

function DialogReviewCtrl:setItemData(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("nameText")
	local sentenceText = objectReference:GetRefValue("sentenceText")

	ClientTextUtils.setText(nameText, data.speakerName or "")
	ClientTextUtils.setText(sentenceText, data.text)

	local isNpc = data.isNpc and 1 or 0
	local hideName = data.needTitle and 0 or 1

	button:TryChangePage("Role", isNpc)
	button:TryChangePage("HideName", hideName)
end

return DialogReviewCtrl
