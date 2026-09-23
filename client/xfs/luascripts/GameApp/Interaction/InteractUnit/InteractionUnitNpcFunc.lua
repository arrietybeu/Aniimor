-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitNpcFunc.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local logger = LoggerManager.getLogger("InteractionUnitNpcFunc")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local lume = require("Core.Common.lume")
local InteractData = require("Data.interact_data")
local NpcFuncConfigData = require("Data.npc_func_config_data")
local SysEventData = require("Data.sys_event_data")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local HomeSeasonCelebrationUtils = require("Common.Utils.HomeSeasonCelebrationUtils")
local Vector3 = Vector3
local InteractionUnitNpcFunc = Class.LightClass("InteractionUnitNpcFunc", InteractionUnitBase)

function InteractionUnitNpcFunc:ctor(info, interactId)
	InteractionUnitNpcFunc.super.ctor(self, info, interactId)

	self.funcMenuId = info.funcMenuId

	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil and npcFuncConfigData.npcFunc[1] ~= nil then
		local interactId = npcFuncConfigData.npcFunc[1][5]

		if interactId then
			self.interactData = InteractData[interactId] and lume.clone(InteractData[interactId]) or {}
		end
	end
end

function InteractionUnitNpcFunc:interactive(index)
	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil and npcFuncConfigData.npcFunc[index] ~= nil then
		local eventIds = npcFuncConfigData.npcFunc[index][4] or {}

		if MonthCardUtils.isNpcFuncEventBannedByPreorderGuide(eventIds) then
			return
		end

		local interactEntity = self:getEntity(self.info.globalId)

		if not interactEntity then
			return
		end

		if not pg.pawn:checkInteractNpc(true) then
			return
		end

		local isDialogueEvent = false
		local hasClientUIEvent = false

		for _, eventId in ipairs(eventIds) do
			local eventData = SysEventData[eventId]

			if eventData and eventData.eventType == "dialogue" or eventData.eventType == "playDialogueGraph" then
				isDialogueEvent = true
				hasClientUIEvent = true
			end

			if eventData and eventData.eventType == "shop" then
				hasClientUIEvent = true
			end
		end

		local npcRawRot

		if not isDialogueEvent then
			npcRawRot = interactEntity:getRotation():Clone()
			interactEntity.interactRawRot = npcRawRot
		end

		if Utils.isVirtualEntity(interactEntity) then
			for _, eventId in ipairs(eventIds) do
				pg.me:doEvent(eventId, self.info)
			end

			interactEntity:npcFuncInteract(self.funcMenuId, index)

			return
		end

		if self.info.isClient then
			pg.me:serverMsg("RPC_CS_ClientEventNotifyInteractWithNPC", self.info.globalId, index)

			for _, eventId in ipairs(eventIds) do
				pg.me:doEvent(eventId, self.info)
			end
		else
			pg.me:serverMsg("RPC_CS_InteractWithNPC", self.info.globalId, index, function(noticeId)
				if noticeId == NoticeDef.SUCCESS then
					if interactEntity and not hasClientUIEvent then
						local pData = interactEntity:getConfigData()

						if pData and pData.resetRotation then
							interactEntity:faceToRotation(npcRawRot)
						end
					end

					return
				end

				pg.global.showBubbleMessage(noticeId)
			end)
		end
	end
end

function InteractionUnitNpcFunc:canInteractive()
	local interactEntity = self:getEntity(self.info.globalId)

	if not interactEntity then
		return false
	end

	if not interactEntity:checkNpcInteractState() then
		return false
	end

	if not self:checkCondition() then
		return false
	end

	if not self:checkDistanceInRange(interactEntity) then
		return false
	end

	if pg.me.inTeleportFinding then
		return false
	end

	return InteractionUnitNpcFunc.super.canInteractive(self)
end

function InteractionUnitNpcFunc:checkDistanceInRange(target)
	local interactDis = self:getConfigDis()

	if interactDis > 0 then
		if target.getPlayerDistance and interactDis < target:getPlayerDistance() then
			return false
		end

		if target.getPlayerYDistance and interactDis < target:getPlayerYDistance() then
			return false
		end
	end

	return true
end

function InteractionUnitNpcFunc:getConfigDis()
	local interactEntity = self:getEntity(self.info.globalId)

	if interactEntity then
		return interactEntity.interactiveDist
	end

	return InteractionUnitNpcFunc.super.getConfigDis(self)
end

function InteractionUnitNpcFunc:isFuncDisabled(funcId, eventIds)
	local player = pg.me
	local isCelebrationEntry = HomeSeasonCelebrationUtils.isEntryNpcFuncMenu(self.funcMenuId)

	if isCelebrationEntry then
		local celebrationDisabled = HomeSeasonCelebrationUtils.isEntryNpcFuncDisabled(player.space, self.funcMenuId)

		if celebrationDisabled then
			return true
		end
	elseif player:checkBanNpcFunc(self.funcMenuId, funcId) then
		return true
	end

	return player:checkBanNpcDuelFuncByIds(self.globalId, eventIds) or MonthCardUtils.isNpcFuncEventBannedByPreorderGuide(eventIds)
end

function InteractionUnitNpcFunc:getIcon()
	local btnStyle = self:getInteractBtnStyle()

	if #btnStyle > 0 then
		return btnStyle[1].iconId
	end
end

function InteractionUnitNpcFunc:getText()
	local btnStyle = self:getInteractBtnStyle()

	if #btnStyle == 1 then
		return pg.getLocalizationText(btnStyle[1].actionName)
	elseif #btnStyle > 1 then
		local entity = self:getEntity(self.info.globalId)
		local name = entity:getName()

		if not string.isNilOrEmpty(name) then
			return pg.getLocalizationText(name)
		end
	end
end

function InteractionUnitNpcFunc:checkCondition()
	local conditions, eventIds
	local conditionComplete = true
	local player = pg.me
	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if not npcFuncConfigData or not npcFuncConfigData.npcFunc then
		return false
	end

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil then
		for idx, val in ipairs(npcFuncConfigData.npcFunc) do
			conditions = val[3]
			eventIds = val[4]
			conditionComplete = true

			for _, condition in ipairs(conditions) do
				if not player.triggerMap:isCompleteOrMeetCondition(condition) then
					conditionComplete = false

					break
				end
			end

			local checkBanState = self:isFuncDisabled(idx, eventIds)

			if conditionComplete and not checkBanState then
				return true
			end
		end
	end

	return false
end

function InteractionUnitNpcFunc:getInteractBtnStyle()
	local ret = {}
	local conditions, eventIds
	local conditionComplete = true
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

			local checkBanState = self:isFuncDisabled(idx, eventIds)

			if conditionComplete and not checkBanState then
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

function InteractionUnitNpcFunc:needCheckPetEthnicGroup(index)
	local ret = false
	local npcFuncConfigData = NpcFuncConfigData[self.funcMenuId]

	if npcFuncConfigData ~= nil and npcFuncConfigData.npcFunc ~= nil and npcFuncConfigData.npcFunc[index] ~= nil then
		local eventIds = npcFuncConfigData.npcFunc[index][4]

		if eventIds then
			for _, eventId in ipairs(eventIds) do
				local eventData = SysEventData[eventId]

				if eventData and eventData.eventType == "dialogue" or eventData.eventType == "playDialogueGraph" or eventData.eventType == "reportReward" then
					ret = true

					break
				end
			end
		end
	end

	return ret
end

return InteractionUnitNpcFunc
