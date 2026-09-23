-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitQuestDialogue.lua

local Class = require("Core.Framework.Class")
local InteractionUnitQuestBase = require("GameApp.Interaction.InteractUnit.InteractionUnitQuestBase")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local AddressDataConst = require("Const.AddressDataConst")
local QuestBaseData = require("Data.Quest.quest_base")
local InteractionUnitQuestDialogue = Class.LightClass("InteractionUnitQuestDialogue", InteractionUnitQuestBase)

function InteractionUnitQuestDialogue:ctor(info, interactId)
	InteractionUnitQuestDialogue.super.ctor(self, info, interactId)

	self.questDialogInfo = self:initMulInteractData(info.questDialogInfo)
end

function InteractionUnitQuestDialogue:interactive(idx)
	if not self:checkCanInteract(idx) then
		return
	end

	local questId = self.questDialogInfo[idx].questId
	local conversationId = self.questDialogInfo[idx].conversationId
	local plotDialogueId = self.questDialogInfo[idx].plotDialogueId
	local state = self.questDialogInfo[idx].questState

	self:triggerDeliverDialog(questId, conversationId, plotDialogueId, state)
end

function InteractionUnitQuestDialogue:getInteractBtnStyle()
	return self.questDialogInfo
end

function InteractionUnitQuestDialogue:getIcon()
	return self.questDialogInfo[1].iconId
end

function InteractionUnitQuestDialogue:getText()
	return self.questDialogInfo[1].actionName
end

function InteractionUnitQuestDialogue:initMulInteractData(questDialogInfo)
	local ret = {}

	for i = 1, #questDialogInfo do
		local info = questDialogInfo[i]
		local questId = info.questId
		local questDesc, _ = self:getActionNameTextAndIcon(questId)
		local isColorIcon = true
		local questIcon = QuestUtils.getQuestTypeIcon(questId)

		if questIcon == nil then
			questIcon = AddressDataConst.BRANCH_OPTION_ICON
			isColorIcon = false
		end

		ret[#ret + 1] = {
			styleId = self.actionPrototypeId,
			actionName = questDesc,
			iconId = questIcon,
			isColorIcon = isColorIcon,
			conversationId = info.dialogId,
			plotDialogueId = info.dialogueGraphId,
			questId = questId,
			questState = info.state
		}
	end

	local function Sort(a, b)
		if a.state == b.state then
			return a.questId < b.questId
		end

		return a.state > b.state
	end

	table.sort(ret, Sort)

	return ret
end

return InteractionUnitQuestDialogue
