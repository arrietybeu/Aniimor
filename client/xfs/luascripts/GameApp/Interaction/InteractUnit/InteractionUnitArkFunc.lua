-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitArkFunc.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local logger = LoggerManager.getLogger("InteractionUnitArkFunc")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local NpcFuncConfigData = require("Data.npc_func_config_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local InteractionUnitArkFunc = Class.LightClass("InteractionUnitArkFunc", InteractionUnitBase)

function InteractionUnitArkFunc:ctor(info, interactId)
	InteractionUnitArkFunc.super.ctor(self, info, interactId)

	self.funcMenuId = info.funcMenuId
end

function InteractionUnitArkFunc:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	return true
end

function InteractionUnitArkFunc:interactive(index)
	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil and npcFuncConfigData.npcFunc[index] ~= nil then
		local eventId = npcFuncConfigData.npcFunc[index][4][1]

		if eventId == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("@策划 事件未配表！")
			end

			return
		end

		local interactEntity = pg.getEntityByGlobalId(self.info.globalId)

		if Utils.isNpc(interactEntity) and not interactEntity.playerInTrigger then
			return
		end

		if not pg.pawn:checkInteractNpc(true) then
			return
		end

		if self.info.isClient then
			pg.me:doEvent(eventId, self.info)
		else
			pg.me:serverMsg("RPC_CS_InteractWithNPC", self.info.globalId, index, function(noticeId)
				if noticeId == NoticeDef.SUCCESS then
					return
				end

				pg.global.showBubbleMessage(noticeId)
			end)
		end
	end
end

function InteractionUnitArkFunc:getInteractBtnStyle()
	local ret = {}
	local conditions, eventIds
	local conditionComplete = true
	local checkQuest = true
	local player = pg.me
	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil then
		for idx, val in ipairs(npcFuncConfigData.npcFunc) do
			conditions = val[3]
			eventIds = val[4]
			conditionComplete = true

			for _, condition in ipairs(conditions) do
				if not player.triggerMap:isCompleteOrMeetCondition(condition) then
					conditionComplete = false

					if LoggerManager.checkLogger(LoggerConst.INFO) then
						logger:info(">>>> getInteractBtnStyle: condition check failed", self.funcMenuId, idx, condition, conditionComplete)
					end

					break
				end
			end

			local questCond = val[5]

			if ToBool(questCond) then
				checkQuest = false

				local questId = questCond[1]
				local questState = questCond[2]

				if questId and QuestUtils.isQuestInState(questId, questState) then
					checkQuest = true
				elseif LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info(">>>> getInteractBtnStyle: quest check failed", self.funcMenuId, idx, questId, questState, checkQuest)
				end
			end

			local checkBanState = false

			if player:checkBanNpcFunc(self.funcMenuId, idx) or player:checkBanNpcDuelFuncByIds(self.globalId, eventIds) then
				checkBanState = true
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info(">>>> getInteractBtnStyle: quest check failed", self.funcMenuId, idx, checkBanState)
			end

			if conditionComplete and checkQuest and not checkBanState then
				ret[#ret + 1] = {
					styleId = self.actionPrototypeId,
					actionName = val[1],
					iconId = val[2],
					index = idx
				}
			end
		end
	end

	return ret
end

return InteractionUnitArkFunc
