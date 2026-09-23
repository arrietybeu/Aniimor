-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientAIHelperComponent.lua

local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local AiAssistantData = require("Data.ai_assistant_data")
local AiAssistantGroupToId = require("Data.ai_assistant_group_to_id_data")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientAIHelperComponent = class.Component("ClientAIHelperComponent")

function ClientAIHelperComponent:start()
	self:resetAiHelperData()

	self.AiHelperDetect.updateTimer = self:addRepeatTimer(0.3, function()
		self:tryRefreshBy3DDist()
	end)
end

function ClientAIHelperComponent:onEnterTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_AI_HELPER then
		return
	end

	if self.AiHelperDetect.rangeEntsAmber[actorId] or self.AiHelperDetect.rangeEntsShiny[actorId] or self.AiHelperDetect.rangeEntsDark[actorId] or self.AiHelperDetect.rangeEntsRainbow[actorId] then
		return
	end

	local ent = pg.getEntityByActorId(actorId)

	self:insertAITrapEnt(actorId, ent)
end

function ClientAIHelperComponent:isLuminAmber(ent)
	return Utils.isChest(ent) and ent.templateId == ClientConst.AI_HELPER.Special_Item.Amber
end

function ClientAIHelperComponent:tryRefreshBy3DDist()
	if self:trackNearLuminAmber() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Lumin_Amber)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Lumin_Amber)
	end

	if self:trackNearShinyPuppet() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Shiny)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Shiny)
	end

	if self:trackNearDarkPuppet() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Dark)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Dark)
	end

	if self:trackNearRainbowPuppet() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Rainbow)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Rainbow)
	end

	if self:trackNearEnvObj() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Special_Env)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Special_Env)
	end

	if self:trackNearLevelItem() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Lumin_Level_Item)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Lumin_Level_Item)
	end

	if self:trackNearSpecialEntTag() then
		self:tryRefreshAiIds(true, ClientConst.AI_HELPER.Special_Id.Entity_Tag)
	else
		self:tryRefreshAiIds(false, ClientConst.AI_HELPER.Special_Id.Entity_Tag)
	end
end

function ClientAIHelperComponent:insertAITrapEnt(actorId, ent)
	local isEnemyPuppet = Utils.isEnemy(self, ent) and Utils.isPuppet(ent) and not Utils.isNpc(ent)
	local hasSpriteIdAfterCatch = ent.spriteIdAfterCatch ~= nil and ent.spriteIdAfterCatch ~= ""

	if isEnemyPuppet and hasSpriteIdAfterCatch and Utils.isLabelShiny(ent.label) then
		self.AiHelperDetect.rangeEntsShiny[actorId] = ent
	elseif isEnemyPuppet and hasSpriteIdAfterCatch and Utils.isLabelDark(ent.label) then
		self.AiHelperDetect.rangeEntsDark[actorId] = ent
	elseif isEnemyPuppet and hasSpriteIdAfterCatch and Utils.isRainbowType(Utils.getPuppetPetPrototypeId(ent.templateId)) then
		self.AiHelperDetect.rangeEntsRainbow[actorId] = ent
	elseif self:isLuminAmber(ent) then
		if Utils.openChestLimit(self, ent) then
			return
		end

		self.AiHelperDetect.rangeEntsAmber[actorId] = ent
	elseif Utils.isEnvObj(ent) and ent.templateId == ClientConst.AI_HELPER.Special_Item.EnvObj then
		self.AiHelperDetect.rangeSpecialEnv[actorId] = ent
	elseif Utils.isCrystal(ent) then
		self.AiHelperDetect.rangeEntityTag[actorId] = ent
	end
end

function ClientAIHelperComponent:onLeaveTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_AI_HELPER then
		return
	end

	if self.AiHelperDetect.rangeEntsAmber[actorId] then
		self.AiHelperDetect.rangeEntsAmber[actorId] = nil
	elseif self.AiHelperDetect.rangeEntsShiny[actorId] then
		self.AiHelperDetect.rangeEntsShiny[actorId] = nil
	elseif self.AiHelperDetect.rangeEntsDark[actorId] then
		self.AiHelperDetect.rangeEntsDark[actorId] = nil
	elseif self.AiHelperDetect.rangeEntsRainbow[actorId] then
		self.AiHelperDetect.rangeEntsRainbow[actorId] = nil
	elseif self.AiHelperDetect.rangeSpecialEnv[actorId] then
		self.AiHelperDetect.rangeSpecialEnv[actorId] = nil
	elseif self.AiHelperDetect.rangeEntityTag[actorId] then
		self.AiHelperDetect.rangeEntityTag[actorId] = nil
	end
end

function ClientAIHelperComponent:resetAiHelperData()
	self.AiHelperDetect = {
		rangeEntsAmber = {},
		rangeEntsShiny = {},
		rangeEntsDark = {},
		rangeEntsRainbow = {},
		rangeLevelItem = {},
		rangeSpecialEnv = {},
		rangeEntityTag = {},
		curAIIds = {},
		aiIdsTs = {}
	}
end

function ClientAIHelperComponent:destroy()
	self:clearAIHelperRangeEvent()
	self:clearAIHelperUpdateTimer()
end

function ClientAIHelperComponent:clearAIHelperRangeEvent()
	if self.AiHelperDetect.rangeEvent then
		self:removeRangeEvent(self.AiHelperDetect.rangeEvent, true)
		self:resetAiHelperData()
	end
end

function ClientAIHelperComponent:clearAIHelperUpdateTimer()
	if self.AiHelperDetect.updateTimer then
		self:removeTimer(self.AiHelperDetect.updateTimer)
	end

	self.AiHelperDetect.updateTimer = nil
end

function ClientAIHelperComponent:onEnterSpace()
	local dist = SysConfigData.AI_TRACK_DISTANCE or 30

	if self.AiHelperDetect then
		self.AiHelperDetect.rangeEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_AI_HELPER, dist, dist)
	end
end

function ClientAIHelperComponent:registerAiHelperLevelItem(levelKey, levelItemInfo)
	self.AiHelperDetect.rangeLevelItem[levelKey] = levelItemInfo
end

function ClientAIHelperComponent:unRegisterAiHelperLevelItem(levelKey)
	self.AiHelperDetect.rangeLevelItem[levelKey] = nil
end

function ClientAIHelperComponent:onLeaveSpace()
	self:clearAIHelperRangeEvent()
end

function ClientAIHelperComponent:checkAiHelperEnterLimit(aiCfgData)
	local sceneList = aiCfgData.scene

	if sceneList and next(sceneList) then
		local curSceneId = self.space and self.space.sceneId

		if not curSceneId or not table.contains(sceneList, curSceneId) then
			return false
		end
	end

	local limitConditionId = SysConfigData.AI_TRACK_LIMIT

	if limitConditionId and limitConditionId ~= 0 and (not self.triggerMap or not self.triggerMap:isCompleteOrMeetCondition(limitConditionId)) then
		return false
	end

	return true
end

function ClientAIHelperComponent:getAiIdByGroupId(groupId)
	local groupData = AiAssistantGroupToId[groupId]

	if not groupData then
		return
	end

	local aiId = tonumber(groupData)

	if not aiId then
		local curPlatform = ClientUtils.getAdaptionPlatform()

		aiId = groupData[curPlatform]
	end

	return aiId
end

function ClientAIHelperComponent:setForbidAllAiHelper(forbid)
	self._forbidAllAiHelper = forbid or nil
end

function ClientAIHelperComponent:tryRefreshAiIds(isEnter, groupId, isEvent, extraInfo)
	if EnableBotTest then
		return
	end

	if self._forbidAllAiHelper then
		return
	end

	local groupData = AiAssistantGroupToId[groupId]

	if not groupData then
		return
	end

	local aiId = tonumber(groupData)

	if not aiId then
		local curPlatform = ClientUtils.getAdaptionPlatform()

		aiId = groupData[curPlatform]
	end

	local aiCfgData = AiAssistantData[aiId]

	if not aiCfgData then
		return
	end

	local settingStrength = pg.game.setting:getAiHelperStrength()

	if settingStrength < aiCfgData.strength then
		return
	end

	if isEvent then
		local tipType = aiCfgData.AIType

		if tipType == ClientConst.AI_HELPER.TYPE.Lit then
			facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
				id = aiId,
				isInsert = isEnter,
				extraInfo = extraInfo
			})
		elseif tipType == ClientConst.AI_HELPER.TYPE.Pop then
			facade:sendMsgToUI(MessageName.UI_AI_HELPER_POP, {
				id = aiId,
				isInsert = isEnter,
				extraInfo = extraInfo
			})
		end

		return
	end

	if self.AiHelperDetect.aiIdsTs[aiId] and isEnter and os.time() - self.AiHelperDetect.aiIdsTs[aiId] < SysConfigData.AI_TRACK_CD then
		return
	end

	local changed = false

	if isEnter then
		if not self.AiHelperDetect.curAIIds[aiId] then
			self.AiHelperDetect.curAIIds[aiId] = true
			self.AiHelperDetect.aiIdsTs[aiId] = os.time()
			changed = true
		end
	elseif self.AiHelperDetect.curAIIds[aiId] then
		self.AiHelperDetect.curAIIds[aiId] = nil
		changed = true
	end

	if changed then
		local tipType = aiCfgData.AIType

		if tipType == ClientConst.AI_HELPER.TYPE.Lit then
			facade:sendMsgToUI(MessageName.UI_AI_HELPER_LIT, {
				id = aiId,
				isInsert = isEnter,
				extraInfo = extraInfo
			})
		elseif tipType == ClientConst.AI_HELPER.TYPE.Pop then
			facade:sendMsgToUI(MessageName.UI_AI_HELPER_POP, {
				id = aiId,
				isInsert = isEnter,
				extraInfo = extraInfo
			})
		end
	end
end

function ClientAIHelperComponent:trackNearLuminAmber()
	return self:trackNearEntByType(self.AiHelperDetect.rangeEntsAmber)
end

function ClientAIHelperComponent:trackNearEntByType(rangeEnt)
	local minDist = SysConfigData.AI_TRACK_DISTANCE
	local curPos = self:getPosition()
	local targetEnt

	for actorId, ent in pairs(rangeEnt) do
		local entPos = ent:getPosition()
		local dist = Utils.distance(curPos, entPos)

		if dist < minDist then
			minDist = dist
			targetEnt = ent
		end
	end

	return targetEnt
end

function ClientAIHelperComponent:trackNearShinyPuppet()
	return self:trackNearEntByType(self.AiHelperDetect.rangeEntsShiny)
end

function ClientAIHelperComponent:trackNearDarkPuppet()
	return self:trackNearEntByType(self.AiHelperDetect.rangeEntsDark)
end

function ClientAIHelperComponent:trackNearBlackShinyPuppet()
	return self:trackNearDarkPuppet()
end

function ClientAIHelperComponent:trackNearRainbowPuppet()
	return self:trackNearEntByType(self.AiHelperDetect.rangeEntsRainbow)
end

function ClientAIHelperComponent:trackNearEnvObj()
	return self:trackNearEntByType(self.AiHelperDetect.rangeSpecialEnv)
end

function ClientAIHelperComponent:trackNearSpecialEntTag()
	return self:trackNearEntByType(self.AiHelperDetect.rangeEntityTag)
end

function ClientAIHelperComponent:trackNearLevelItem()
	local minDist = SysConfigData.AI_TRACK_DISTANCE
	local curPos = self:getPosition()
	local targetLevelInfo

	for actorId, levelInfo in pairs(self.AiHelperDetect.rangeLevelItem) do
		local pos = levelInfo.targetPos
		local dist = Utils.distance(curPos, pos)

		if dist < minDist then
			minDist = dist
			targetLevelInfo = levelInfo
		end
	end

	return targetLevelInfo
end

return ClientAIHelperComponent
