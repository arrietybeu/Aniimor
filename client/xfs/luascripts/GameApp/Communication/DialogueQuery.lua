-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueQuery.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local NpcSpecialStateData = require("Data.npc_special_state_data")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local PuppetData = require("Data.puppet_data")
local Utils = require("Common.Utils.Utils")
local M = {}

function M:checkDialogueDataValid(id, index, chatType)
	if chatType == DialogueConst.ChatType.BLACK_SCREEN then
		return true
	end

	local dialogueData = NpcDialogueData[id]

	if dialogueData == nil then
		if UNITY_EDITOR and LoggerManager.checkLogger(LoggerConst.ERROR) then
			self._logger:error(string.format("[NpcDialogueData] dialogId = %d 条目对白不存在!", id))
		end

		return false
	end

	if dialogueData[index] == nil then
		if UNITY_EDITOR and LoggerManager.checkLogger(LoggerConst.ERROR) then
			self._logger:error(string.format("[NpcDialogueData] dialogId = %d, index = %d 条目对白不存在!", id, index))
		end

		return false
	end

	return true
end

function M:checkDialoguePriorityValid(chatType, overridePriority)
	if self.curChatType ~= DialogueConst.ChatType.NONE and self.curDialogueId ~= nil and self.curDialogueIndex ~= nil then
		local curChatTypePriority = self.chatTypePriority[self.curChatType] or 9999
		local newChatTypePriority = overridePriority and overridePriority or self.chatTypePriority[chatType] or 9999

		if curChatTypePriority < newChatTypePriority then
			return false
		end
	end

	return true
end

function M:checkDifferentEthnicGroup(targetNpcEntity, dialogueId, index, npcStaticId)
	local npcTemplateId = targetNpcEntity ~= nil and targetNpcEntity.templateId or 0
	local staticId = npcStaticId or 0
	local npcData = PuppetData[npcTemplateId]
	local ret = false

	if npcData == nil or npcData.npcType ~= DialogueConst.NpcType.Pet then
		return ret, dialogueId, index
	end

	if pg.me:isControllingMaster() or pg.me:isControllingPet() and not Utils.isPetsCanCommunicate(targetNpcEntity, pg.pawn) then
		ret = true

		local spData = self:getNPCSpecialState(staticId)

		if spData ~= nil and spData.unknowDialogue ~= nil and spData.unknowDialogue > 0 then
			dialogueId = spData.unknowDialogue
		else
			dialogueId = npcData.unknowDialogue or dialogueId
		end

		index = 1
	end

	return ret, dialogueId, index
end

function M:getNPCSpecialState(staticId)
	local player = pg.me

	if player.specialContentDict == nil then
		return
	end

	local spId = player.specialContentDict[staticId]

	if spId ~= nil then
		return NpcSpecialStateData[spId]
	end
end

function M:checkExitControllingPet(dialogueId, index, targetNpcEntity)
	local cData = NpcDialogueData[dialogueId][index]
	local exitMerge1 = pg.me:isControllingPet()
	local exitMerge2 = cData ~= nil and cData.autoExitMerge ~= 0
	local exitMerge3 = true
	local templateId = targetNpcEntity ~= nil and targetNpcEntity.templateId or 0
	local pData = PuppetData[templateId]

	if pData ~= nil and pData.npcType == DialogueConst.NpcType.Pet and targetNpcEntity ~= nil and exitMerge1 then
		exitMerge3 = false
	end

	return exitMerge1 and exitMerge2 and exitMerge3
end

function M:getNpcHeadIconUrl(templateId)
	local pData = PuppetData[templateId]
	local iconUrl = pData ~= nil and pData.iconName

	if iconUrl == nil then
		iconUrl = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)
	end

	return iconUrl
end

function M:getNpcInfoByDialogInfo(dialogueId, index)
	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local npcName = dialogueInfo.npcName
	local npcTemplateId = dialogueInfo.npcId or 0
	local iconUrl = self:getNpcHeadIconUrl(npcTemplateId)

	if npcName == nil then
		local pData = PuppetData[npcTemplateId]

		npcName = pData and pData.name
	end

	if npcName ~= nil then
		npcName = LuaUIUtils.getReplacedDialogueText(npcName)
	end

	return npcName, iconUrl
end

function M:getNpcInfoByTemplateId(npcTemplateId)
	local iconUrl = self:getNpcHeadIconUrl(npcTemplateId)
	local pData = PuppetData[npcTemplateId]
	local npcName = pData ~= nil and pData.name

	if npcName ~= nil then
		npcName = pg.getLocalizationText(npcName)
	end

	return npcName, iconUrl
end

function M:preCalculateTargetPos(selfEnt, target)
	if selfEnt == nil or target == nil then
		return
	end

	local targetDir = target:getPositionAgentPosition() - selfEnt:getPositionAgentPosition()

	targetDir.y = 0

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)
	local targetPos = target:getPosition() - targetRotation * Vector3.forward * 1.5

	targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

	return targetPos
end

function M:getDialogueEntity(npcTemplateId, npcStaticId, dialogueId, dialogueIndex)
	if npcTemplateId == nil then
		npcTemplateId = NpcDialogueData[dialogueId][dialogueIndex].npcId
	end

	return DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)
end

function M:addPlayerChoiceReviewLog(branchText, dialogId, chatType)
	self.reviewLog[#self.reviewLog + 1] = {
		isChoice = true,
		branchText = branchText,
		dialogId = dialogId,
		chatType = chatType
	}
end

function M:openDialogReview(closeCb)
	if pg.global.ui.dialogReview ~= nil then
		pg.global.ui.dialogReview:open(self.reviewLog, nil, closeCb)
	end
end

return M
