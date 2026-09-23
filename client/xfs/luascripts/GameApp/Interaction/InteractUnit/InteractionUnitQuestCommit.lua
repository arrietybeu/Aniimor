-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitQuestCommit.lua

local Class = require("Core.Framework.Class")
local InteractionUnitQuestBase = require("GameApp.Interaction.InteractUnit.InteractionUnitQuestBase")
local ItemUtils = require("Common.Utils.ItemUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")
local TriggerConst = require("Common.Const.TriggerConst")
local NoticeDef = require("Common.NoticeDef")
local QuestBaseData = require("Data.Quest.quest_base")
local QuestConst = require("Common.Const.QuestConst")
local InteractionUnitQuestCommit = Class.LightClass("InteractionUnitQuestCommit", InteractionUnitQuestBase)

InteractionUnitQuestCommit.COMMIT_TYPE_MAP = {
	[TriggerConst.TRIGGER_TARGET_ITEM_CONSUME] = 2,
	[TriggerConst.TRIGGER_TARGET_PET_CONSUME] = 3
}

function InteractionUnitQuestCommit:ctor(info, interactId)
	InteractionUnitQuestCommit.super.ctor(self, info, interactId)

	self.questCommitInfo = self:initMulInteractData(info.questCommitInfo)
end

function InteractionUnitQuestCommit:interactive(idx)
	if not self:checkCanInteract(idx) then
		return
	end

	local questId = self.questCommitInfo[idx].questId
	local conditionParams = self.questCommitInfo[idx].conditionParam
	local commitType = conditionParams and conditionParams[1] and conditionParams[1].commitType
	local commitPanelType = self.COMMIT_TYPE_MAP[commitType]
	local autoCommit = false

	if commitType then
		if autoCommit and commitPanelType == 2 then
			for i, v in ipairs(conditionParams) do
				local conditionParam = v.conditionParam
				local conditionData = TriggerUtils.getConditionByRegInfo(conditionParam[1], conditionParam[2], conditionParam[3])
				local itemId = type(conditionData[3]) == "number" and conditionData[3] or conditionData[3][1]
				local needNum = conditionData[5]
				local ownNum = ItemUtils.getItemCountById(pg.me, itemId)

				if needNum <= ownNum then
					pg.me:serverMsg("RPC_CS_SubItem", conditionParam[1], conditionParam[2], conditionParam[3], v.npcId, needNum, function(noticeId)
						if noticeId ~= NoticeDef.SUCCESS then
							pg.global.showBubbleMessageRaw(pg.getGameString("FAILED"))

							return
						end

						self:triggerDeliverDialog(questId, self.questCommitInfo[idx].successConversationId, self.questCommitInfo[idx].successPlotDialogueId)
					end)
				else
					pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK, pg.getGameString("PROP"))
				end
			end
		else
			pg.global.ui:open(UIConst.UI_ID_REPORT, {
				data = conditionParams,
				ids = commitPanelType,
				questId = questId,
				callback = function()
					self:triggerDeliverDialog(questId, self.questCommitInfo[idx].successConversationId, self.questCommitInfo[idx].successPlotDialogueId)
				end
			})
		end
	end
end

function InteractionUnitQuestCommit:getInteractBtnStyle()
	return self.questCommitInfo
end

function InteractionUnitQuestCommit:initMulInteractData(questCommitInfo)
	local ret = {}

	for questId, data in pairs(questCommitInfo) do
		local questDesc, iconId = self:getActionNameTextAndIcon(questId)
		local commitType = data and data[1] and data[1].commitType

		if commitType and not iconId then
			local commitPanelType = self.COMMIT_TYPE_MAP[commitType]

			iconId = commitPanelType == 2 and AddressDataConst.QUEST_ICON_SUBMIT_PROP or AddressDataConst.QUEST_ICON_SUBMIT_PARMON
		end

		iconId = iconId or AddressDataConst.BRANCH_OPTION_ICON
		ret[#ret + 1] = {
			styleId = self.actionPrototypeId,
			actionName = questDesc,
			iconId = iconId,
			conditionParam = data,
			questId = questId
		}
	end

	local function Sort(a, b)
		return a.questId < b.questId
	end

	table.sort(ret, Sort)

	return ret
end

function InteractionUnitQuestCommit:getIcon()
	return AddressDataConst.UI_INTERACT_COMMIT_QUEST_ICON
end

function InteractionUnitQuestCommit:getText()
	return self.questCommitInfo[1].actionName
end

return InteractionUnitQuestCommit
