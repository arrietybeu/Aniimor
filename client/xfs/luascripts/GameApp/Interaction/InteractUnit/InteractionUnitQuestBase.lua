-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitQuestBase.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local Utils = require("Common.Utils.Utils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local UIConst = require("Const.UIConst")
local DialogueConst = require("Const.DialogueConst")
local InteractionUnitQuestBase = Class.LightClass("InteractionUnitQuestBase", InteractionUnitBase)

function InteractionUnitQuestBase:ctor(info, interactId)
	InteractionUnitQuestBase.super.ctor(self, info, interactId)

	self.interactEntity = pg.getEntityByGlobalId(self.info.globalId)
end

function InteractionUnitQuestBase:checkCanInteract(idx)
	if not self.interactEntity then
		return false
	end

	if Utils.isNpc(self.interactEntity) and not self.interactEntity.playerInTrigger then
		return false
	end

	if not pg.pawn:checkInteractNpc(true) then
		return false
	end

	return true
end

function InteractionUnitQuestBase:triggerDeliverDialog(questId, conversationId, plotDialogueGraphId, questState)
	local interactEntity = self.interactEntity
	local conversationId = conversationId and tonumber(conversationId)
	local plotDialogueId = plotDialogueGraphId
	local conversation = pg.game.communication
	local plotDialogue = pg.game.dialogue
	local state = questState or QuestConst.QUEST_STATE.COMPLETED

	if conversationId == nil and plotDialogueId == nil then
		self:triggerQuestDialogueCallback(state, questId)
	elseif conversationId ~= nil and conversation:checkDialogueDataValid(conversationId, 1) then
		pg.global.ui:hide(UIConst.UI_ID_INTERACT)
		conversation:startNpcDialog(conversationId, interactEntity.id, {
			overridePriority = -1,
			callback = function()
				self:triggerQuestDialogueCallback(state, questId, function()
					pg.global.ui:show(UIConst.UI_ID_INTERACT)
				end)
			end,
			src = DialogueConst.SrcType.Interaction
		})
	elseif plotDialogueGraphId ~= nil then
		plotDialogue:playDialogueGraph(plotDialogueId, function(ret)
			self:triggerQuestDialogueCallback(state, questId)
		end)
	else
		self:triggerQuestDialogueCallback(state, questId)
	end
end

function InteractionUnitQuestBase:triggerQuestDialogueCallback(state, questId, callback)
	local interactEntity = self.interactEntity

	if state == QuestConst.QUEST_STATE.UNRECEIVE then
		pg.me:serverMsg("RPC_CS_AcceptQuest", questId, true, interactEntity.id, function()
			pg.me:refreshInteractInfoByEntity(interactEntity)

			if callback then
				callback()
			end

			pg.game.interaction:refreshInteraction(true)
		end)
	elseif state == QuestConst.QUEST_STATE.COMPLETED then
		local questConfig = QuestUtils.getQuestConfig(questId)

		if questConfig == nil or QuestUtils.isQuestDeliverType(questId) then
			self:refreshInteractAfterQuestChanged()

			if callback then
				callback()
			end

			return
		end

		pg.me:serverMsg("RPC_CS_SubmitQuest", questId, true, interactEntity.id, function()
			pg.me:refreshInteractInfoByEntity(interactEntity)

			if callback then
				callback()
			end

			pg.game.interaction:refreshInteraction(true)
		end)
	end
end

function InteractionUnitQuestBase:refreshInteractAfterQuestChanged()
	local interactEntity = self.interactEntity

	if interactEntity and interactEntity.refreshInteractTrigger then
		pg.me:refreshInteractInfoByEntity(interactEntity)
	end

	pg.game.interaction:refreshInteraction(true)
end

function InteractionUnitQuestBase:getActionNameTextAndIcon(questId)
	if not ToBool(questId) then
		return ""
	end

	local desc, icon = QuestUtils.getQuestInteractDescAndIcon(questId)

	if not string.isNilOrEmpty(desc) then
		desc = pg.getLocalizationText(desc)

		local ent = self:getEntity()

		if ent then
			local name

			if ent.getName then
				name = ent:getName()
			else
				local configData = ent:getConfigData()

				name = configData.name
			end

			desc = string.gsub(desc, UIConst.INTERACT_TEXT_REPLACE_PATTERN, pg.getLocalizationText(name))
		end
	end

	return desc, icon
end

function InteractionUnitQuestBase:needCheckPetEthnicGroup(param)
	return true
end

return InteractionUnitQuestBase
