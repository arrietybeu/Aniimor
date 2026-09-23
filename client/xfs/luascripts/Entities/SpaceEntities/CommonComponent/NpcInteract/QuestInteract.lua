-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\NpcInteract\\QuestInteract.lua

local InteractionConst = require("Common.Const.InteractionConst")
local TriggerConst = require("Common.Const.TriggerConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local MessageName = require("Const.MessageName")
local QuestInteract = {}

function QuestInteract:getQuestCommitInfo()
	if pg.me == nil or not QuestUtils.isEntityHasConsumeQuest(self) then
		return nil
	end

	local curTemplateId = self.templateId or 0
	local curStaticId = self.staticId or 0

	local function addQuestCommitInfo(commitInfo, items, triggerType)
		for _, data in ipairs(items) do
			if data[1] == TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE then
				local questId = data[2]

				if not commitInfo[questId] then
					commitInfo[questId] = {}
				end

				table.insert(commitInfo[questId], {
					conditionParam = data,
					commitType = triggerType,
					npcId = self.id
				})
			end
		end
	end

	local questCommitInfo = {}
	local _, templateIdConsumeItems = pg.me:getCheckingCondDicts(TriggerConst.TRIGGER_TARGET_ITEM_CONSUME, curTemplateId)

	if templateIdConsumeItems ~= nil then
		addQuestCommitInfo(questCommitInfo, templateIdConsumeItems, TriggerConst.TRIGGER_TARGET_ITEM_CONSUME)
	end

	local _, staticIdConsumeItems = pg.me:getCheckingCondDicts(TriggerConst.TRIGGER_TARGET_ITEM_CONSUME, curStaticId)

	if staticIdConsumeItems ~= nil then
		addQuestCommitInfo(questCommitInfo, staticIdConsumeItems, TriggerConst.TRIGGER_TARGET_ITEM_CONSUME)
	end

	local _, templateIdConsumePets = pg.me:getCheckingCondDicts(TriggerConst.TRIGGER_TARGET_PET_CONSUME, curTemplateId)

	if templateIdConsumePets ~= nil then
		addQuestCommitInfo(questCommitInfo, templateIdConsumePets, TriggerConst.TRIGGER_TARGET_PET_CONSUME)
	end

	local _, staticIdConsumePets = pg.me:getCheckingCondDicts(TriggerConst.TRIGGER_TARGET_PET_CONSUME, curStaticId)

	if staticIdConsumePets ~= nil then
		addQuestCommitInfo(questCommitInfo, staticIdConsumePets, TriggerConst.TRIGGER_TARGET_PET_CONSUME)
	end

	return questCommitInfo
end

function QuestInteract:getInteractionData()
	local questDialogInfo = QuestUtils.getEntityQuestDialogInfo(self)
	local questCommitInfo = QuestInteract.getQuestCommitInfo(self)

	if ToBool(questDialogInfo) and ToBool(questCommitInfo) then
		for i = #questDialogInfo, 1, -1 do
			local questId = questDialogInfo[i].questId

			if questCommitInfo[questId] then
				questCommitInfo[questId].successConversationId = questDialogInfo[i].dialogId
				questCommitInfo[questId].successPlotDialogueId = questDialogInfo[i].dialogueGraphId
				questDialogInfo[i] = nil
			end
		end
	end

	local questDialogData

	if ToBool(questDialogInfo) then
		questDialogData = {
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_QUEST_DIALOGUE,
			actionPrototypeId = InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID,
			questDialogInfo = questDialogInfo
		}
	end

	local questCommitData

	if ToBool(questCommitInfo) then
		questCommitData = {
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_QUEST_COMMIT,
			actionPrototypeId = InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID,
			questCommitInfo = questCommitInfo
		}
	end

	return questDialogData, questCommitData
end

function QuestInteract:onEnter()
	self._questDialogData, self._questCommitData = QuestInteract.getInteractionData(self)

	if self._questDialogData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self._questDialogData)
	end

	if self._questCommitData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self._questCommitData)
	end
end

function QuestInteract:onLeave()
	if self._questDialogData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self._questDialogData)
	end

	if self._questCommitData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self._questCommitData)
	end
end

function QuestInteract:contributeDist(currentDist)
	if QuestUtils.isEntityHasRelatedQuest(self) and currentDist <= 0 then
		return 3
	end

	return 0
end

return QuestInteract
