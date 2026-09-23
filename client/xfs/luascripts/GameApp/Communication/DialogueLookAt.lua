-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueLookAt.lua

local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local NpcDialogueData = require("Data.npc_dialogue_data")
local Utils = require("Common.Utils.Utils")
local DialogueLookAt = {}
local logger = LoggerManager.getLogger("DialogueLookAt")
local string = string

function DialogueLookAt.EntityLookAt(sourceEnt, targetEnt)
	EntityLookAtUtils.setLookAtManual(sourceEnt, targetEnt)
end

function DialogueLookAt.getSpeaker(communication, dialogueNodeSetting)
	local speakerTemplateId = dialogueNodeSetting.npcId
	local speakerStaticId = dialogueNodeSetting.npcStaticId
	local dialogueGraphTargetEntity = communication.dialogueGraphTargetEntityActorId and pg.getEntityByActorId(communication.dialogueGraphTargetEntityActorId)

	return DialogueUtils.getDialogueEntity(speakerTemplateId, speakerStaticId, communication.dialogueGraphControlEntityIds) or dialogueGraphTargetEntity
end

function DialogueLookAt.handleLookAt(communication, dialogueNodeSetting)
	if dialogueNodeSetting.chatType == DialogueConst.ChatType.BLACK_SCREEN then
		return false
	end

	local speakerEntity = DialogueLookAt.getSpeaker(communication, dialogueNodeSetting)

	if speakerEntity == nil then
		return false
	end

	local flag = false

	if communication.enableDefaultLookAtFromPreset then
		if pg.pawn then
			if pg.pawn.id ~= speakerEntity.id then
				DialogueLookAt.EntityLookAt(pg.pawn, speakerEntity)
			end

			if Utils.isPlayer(pg.pawn) then
				local curPetEntity = pg.pawn:getCurPetEntity()

				if curPetEntity ~= nil then
					DialogueLookAt.EntityLookAt(curPetEntity, speakerEntity)
				end
			end
		end

		if speakerEntity.id ~= pg.pawn.id then
			DialogueLookAt.EntityLookAt(pg.pawn, speakerEntity)
		end

		flag = DialogueLookAt.lookAtDialogue(communication, speakerEntity, dialogueNodeSetting)
	end

	EntityLookAtUtils.doModifyLookAt()

	return flag
end

function DialogueLookAt.lookAtDialogue(communication, speakerEntity, dialogueNodeSetting)
	local dialogueNodeLookAtEntity

	if dialogueNodeSetting.lookAtId then
		dialogueNodeLookAtEntity = DialogueUtils.getDialogueEntityByTemplateId(dialogueNodeSetting.lookAtId, communication.dialogueGraphControlEntityIds)
	end

	if dialogueNodeLookAtEntity == nil then
		return false
	end

	if speakerEntity.id == dialogueNodeLookAtEntity.id then
		EntityLookAtUtils.removeLookAtManual(speakerEntity)
	else
		DialogueLookAt.EntityLookAt(dialogueNodeLookAtEntity, speakerEntity)
		DialogueLookAt.EntityLookAt(speakerEntity, dialogueNodeLookAtEntity)
	end

	return true
end

return DialogueLookAt
