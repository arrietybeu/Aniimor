-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IUtilsComponent.lua

local class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local enums = require("Common.AI.Behaviac.Enums")
local EBTStatus = enums.EBTStatus
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CalcUtils = require("Common.Utils.CalcUtils")
local Const = require("Common.Const.Const")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local PetData = require("Data.pet_data")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AIUtils = require("Common.Utils.AIUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local PlayableConst = require("Common.Const.PlayableConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local lume = require("Core.Common.lume")
local PetTalentData = require("Data.pet_talent_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local ListPool = require("Common.Container.ListPool")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local QuaternionPool = require("Common.Container.QuaternionPool")
local Vector3 = require("Common.Math.vector3")
local logger = LoggerManager.getLogger("AI")
local math_epsilon = math.epsilon
local math_max = math.max
local math_random = math.random
local string_isNilOrEmpty = string.isNilOrEmpty
local string_notNilOrEmpty = string.notNilOrEmpty
local table_clear = table.clear
local pairs = pairs
local ipairs = ipairs
local IUtilsComponent = class.Component("IUtilsComponent")

function IUtilsComponent:ctor()
	self.customTimeout = {}

	if UNITY_EDITOR then
		self.debuggerInfo = {}
	end

	self.agentTimer = {}
end

function IUtilsComponent:onInit()
	table_clear(self.customTimeout)

	if UNITY_EDITOR then
		table_clear(self.debuggerInfo)
	end

	table_clear(self.agentTimer)
end

function IUtilsComponent:onRelease()
	table_clear(self.customTimeout)

	if UNITY_EDITOR then
		table_clear(self.debuggerInfo)
	end

	table_clear(self.agentTimer)
end

function IUtilsComponent:startTimer(timerName)
	self.agentTimer[timerName] = self.ent:getCurrScaledTime()

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getTimerValue(timerName)
	if self.agentTimer[timerName] then
		return self.ent:getCurrScaledTime() - self.agentTimer[timerName]
	end

	return -1
end

function IUtilsComponent:cleanTimer(timerName)
	self.agentTimer[timerName] = nil

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:waitTime__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self:_removeCustomTimeout("waitTime")
	end
end

function IUtilsComponent:waitTime(timeout)
	if timeout > math_epsilon and not self:_checkAndSetCustomTimeout("waitTime", timeout) then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getRandomInt(minValue, maxValue)
	return math_random(minValue, maxValue)
end

function IUtilsComponent:getRandomFloat(minValue, maxValue)
	return lume.random(minValue, maxValue)
end

function IUtilsComponent:checkPlayerCaptureCamera()
	if not Utils.checkClient() then
		return false
	end

	local photo = pg.global.ui.photo

	return photo.photoMode == photo.ModeType.QUICK_MODE
end

function IUtilsComponent:checkStringIsEmpty(param)
	return param == nil or param == false or param == ""
end

function IUtilsComponent:getCloseCreationByTemplateId(actorId, range, templateId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return 0
	end

	local selectEntActorId = 0
	local creationList = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(ent, range, Const.SEARCH_USR_TYPE_CREATION, creationList)

	if count > 0 then
		local tSelectEnt = false

		for i = 1, count do
			local tActorId = creationList[i]
			local creation = pg.getEntityByActorId(tActorId)

			if creation and creation.templateId == templateId then
				local tEnt = creation

				if tSelectEnt and Vector3.SqrDistance(tSelectEnt:getPosition(), self.ent:getPosition()) > Vector3.SqrDistance(tEnt:getPosition(), self.ent:getPosition()) then
					tSelectEnt = tEnt
				else
					tSelectEnt = tSelectEnt or tEnt
				end
			end
		end

		if tSelectEnt then
			selectEntActorId = tSelectEnt.actorId
		end
	end

	ListPool.returnList(creationList, 3)

	return selectEntActorId
end

function IUtilsComponent:getCreationCountByTemplateId(actorId, range, templateId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return 0
	end

	local selectEntCount = 0
	local creationList = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(ent, range, Const.SEARCH_USR_TYPE_CREATION, creationList)

	if count > 0 then
		for i = 1, count do
			local tActorId = creationList[i]
			local creation = pg.getEntityByActorId(tActorId)

			if creation and creation.templateId == templateId then
				selectEntCount = selectEntCount + 1
			end
		end
	end

	ListPool.returnList(creationList, 3)

	return selectEntCount
end

function IUtilsComponent:setHidden(useEffect, timeout)
	if not Utils.checkClient() then
		return EBTStatus.BT_SUCCESS
	end

	local ClientConst = require("Const.ClientConst")

	if useEffect then
		local configData = self.ent:getConfigData()

		Vector3.enableCreateFromCache()

		local targetRotation = QuaternionPool.getQuaternion(self.ent:getRotation():ToEulerAngles())

		Vector3.disableCreateFromCache()
		pg.game.effect:playEffectAt(nil, configData.destroyEffect, self.ent:getPosition(), targetRotation, self.ent)
		QuaternionPool.returnQuaternion(targetRotation)
	end

	self.ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.AI, false, false)
	self.ent:addTimer(timeout, CallbackHandlerNoGC.newOnce(self, self.setVisible))
	self.ent:pauseBt(AiConst.PauseBtReason.Visible)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:setVisible()
	if not Utils.checkClient() then
		return EBTStatus.BT_SUCCESS
	end

	local ClientConst = require("Const.ClientConst")
	local configData = self.ent:getConfigData()

	Vector3.enableCreateFromCache()

	local targetRotation = QuaternionPool.getQuaternion(self.ent:getRotation():ToEulerAngles())

	Vector3.disableCreateFromCache()
	pg.game.effect:playEffectAt(nil, configData.destroyEffect, self.ent:getPosition(), targetRotation, self.ent)
	QuaternionPool.returnQuaternion(targetRotation)
	self.ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.AI, true, true)
	self.ent:resumeBt(AiConst.PauseBtReason.Visible)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:convertBool2Number(boolValue)
	return boolValue == true and 1 or 0
end

function IUtilsComponent:_checkCustomTimeoutExist(timeoutId)
	if self.customTimeout[timeoutId] == nil then
		return false
	end

	return true
end

function IUtilsComponent:_settingCustomTimeout(timeoutId, timeout)
	self.customTimeout[timeoutId] = timeout + self.ent:getCurrScaledTime()
end

function IUtilsComponent:_getCustomTimeout(timeoutId)
	return self.customTimeout[timeoutId]
end

function IUtilsComponent:_checkCustomTimeout(timeoutId)
	if self:_checkCustomTimeoutExist(timeoutId) and self.customTimeout[timeoutId] > self.ent:getCurrScaledTime() then
		return false
	end

	return true
end

function IUtilsComponent:_checkAndRemoveCustomTimeout(timeoutId)
	if not self:_checkCustomTimeout(timeoutId) then
		return false
	end

	self:_removeCustomTimeout(timeoutId)

	return true
end

function IUtilsComponent:_checkAndSetCustomTimeout(timeoutId, timeout)
	if self:_checkCustomTimeoutExist(timeoutId) == false then
		self:_settingCustomTimeout(timeoutId, timeout)
	end

	return self:_checkAndRemoveCustomTimeout(timeoutId)
end

function IUtilsComponent:_removeCustomTimeout(timeoutId)
	self.customTimeout[timeoutId] = nil
end

function IUtilsComponent:_getLastCustomTimeout(timeoutId)
	if self.customTimeout[timeoutId] then
		return self.customTimeout[timeoutId] - self.ent:getCurrScaledTime()
	end

	return 0
end

function IUtilsComponent:checkTargetLocation(targetId, minDegree, maxDegree, minDist, maxDist)
	local targetEnt = pg.getEntityByActorId(targetId)

	if not targetEnt then
		return false
	end

	local targetPos = targetEnt:getPosition()
	local myPos = self.ent:getPosition()

	Vector3.enableCreateFromCache()

	local myDir = self.ent:getRotation():Forward()
	local result = CalcUtils.isPointInAnnularSector(targetPos.x, targetPos.z, myDir.x, myDir.z, myPos.x, myPos.z, minDist, maxDist, minDegree, maxDegree, minDist)

	Vector3.disableCreateFromCache()

	return result
end

function IUtilsComponent:checkTargetLabel(actorId, label)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return bit.band(ent.label or 0, label) ~= 0
	end

	return false
end

function IUtilsComponent:checkTargetMBTI(actorId, mbti)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.petInfo and ent.petInfo.talentList then
		for _, talentInfo in ipairs(ent.petInfo.talentList) do
			local templateId = talentInfo.templateId or 0

			if PetTalentData[templateId] and PetTalentData[templateId].mbti == mbti then
				return true
			end
		end
	end

	return false
end

function IUtilsComponent:_debugSettingRunningAction(nodeInfo)
	if UNITY_EDITOR then
		self.debuggerInfo.runningAction = nodeInfo
	end
end

function IUtilsComponent:getDebugInfo()
	if AIUtils.checkAINodeDebug(self.ent.actorId) then
		return self:getSMDebugInfo() .. "|node:" .. self:getDebugAiNode()
	end

	return self:getSMDebugInfo()
end

function IUtilsComponent:getDebugAiNode()
	if UNITY_EDITOR then
		return self.debuggerInfo.runningAction or "nil"
	end

	return "nil"
end

function IUtilsComponent:triggerBlueprint(eventName)
	AIBaseMethodUtils.Base_TriggerBluePrint(self.ent, self.ent.actorId, eventName)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:destroyEnvobj(envObjActorId, delaySecond)
	AIBaseMethodUtils.Base_DestroyEnvObj(self.ent, envObjActorId, delaySecond)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getNearbyEnvObjActorId()
	local tTargetEnvObjActorId = 0
	local tTargetEnvDistance = 99999
	local tSearchEnvObjList = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(self.ent, PetData[self.ent.templateId].EnvCheckRange or 5, Const.SEARCH_USR_TYPE_ENVOBJ, tSearchEnvObjList)

	if tSearchEnvObjList then
		local myPos = self.ent:getPosition()

		for i = 1, count do
			local actorId = tSearchEnvObjList[i]
			local tmpEnt = pg.getEntityByActorId(actorId)
			local tmpDistance = Vector3.SqrDistance(tmpEnt:getPosition(), myPos)

			if tmpDistance < tTargetEnvDistance then
				tTargetEnvObjActorId = actorId
				tTargetEnvDistance = tmpDistance
			end
		end
	end

	ListPool.returnList(tSearchEnvObjList, 3)

	return tTargetEnvObjActorId
end

function IUtilsComponent:checkPosIsOnGround(pos)
	if Utils.checkClient() then
		local ret = VoxelUtils.verticalRayCast(self.ent, pos[1], pos[2], pos[3], -0.1)

		return ret
	end

	return false
end

function IUtilsComponent:sendToTargtEntAITriggerMsg(targetActorId, triggerTemplateName)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return EBTStatus.BT_FAILURE
	end

	AIControllerUtils.sendAIEvent(targetEnt, triggerTemplateName)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:addEntityTag(targetActorId, tag)
	local ent = pg.getEntityByActorId(targetActorId)

	Utils.addEntityTag(ent, tag)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:removeEntityTag(targetActorId, tag)
	local ent = pg.getEntityByActorId(targetActorId)

	Utils.removeEntityTag(ent, tag)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:checkEntityHasTag(targetActorId, tag)
	targetActorId = targetActorId == 0 and self.ent.actorId or targetActorId

	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return false
	end

	return Utils.hasEntityTag(targetEnt, tag)
end

function IUtilsComponent:getEnvObjPos(envActorId, partId)
	local envEnt = pg.getEntityByActorId(envActorId)

	if envEnt == nil or not Utils.isEnvObj(envEnt) then
		return nil
	end

	return envEnt:getLockPartPosition(partId)
end

function IUtilsComponent:isInRange(targetA, targetB, min, max)
	local targetAEntity = pg.getEntityByActorId(targetA)
	local targetBEntity = pg.getEntityByActorId(targetB)

	if targetAEntity == nil or targetBEntity == nil then
		return false
	end

	local distance = Vector3.Distance(targetAEntity:getPosition(), targetBEntity:getPosition())

	return min <= distance and distance <= max
end

function IUtilsComponent:addAITag(targetActorId, tag)
	local ent = targetActorId == 0 and self.ent or pg.getEntityByActorId(targetActorId)

	if ent and ent.addAITag then
		local extraInfo

		ent:addAITag(tag, extraInfo)

		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_FAILURE
end

function IUtilsComponent:removeAITag(targetActorId, tag)
	local ent = targetActorId == 0 and self.ent or pg.getEntityByActorId(targetActorId)

	if ent and ent.removeAITag then
		ent:removeAITag(tag)

		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_FAILURE
end

function IUtilsComponent:hasAITag(targetActorId, tag)
	if Utils.checkClient() then
		local ent = targetActorId == 0 and self.ent or pg.getEntityByActorId(targetActorId)

		if ent and ent.hasAITag then
			return ent:hasAITag(tag)
		end

		return false
	end

	return true
end

function IUtilsComponent:getPlayerVar(key)
	if Utils.checkClient() then
		local ClientUtils = require("Utils.ClientUtils")

		return ClientUtils.getCustomVariableValue(key)
	end

	return -1
end

function IUtilsComponent:setPlayerVal(key, val)
	if Utils.checkClient() then
		pg.me:requestSetCustomVariable(key, val)
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:setNpcStatus(staticId, key, val, forceRefresh)
	if Utils.checkClient() then
		pg.me:requestSetNpcBehaviorStatus(staticId, key, val, forceRefresh)
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getNpcStatusConfigData(key)
	if Utils.checkClient() then
		local NpcBehavStatusData = require("Data.npc_behavior_status_data")

		return NpcBehavStatusData[key]
	end
end

function IUtilsComponent:getNpcStatusServerData(key)
	if Utils.checkClient() then
		local ClientUtils = require("Utils.ClientUtils")

		return ClientUtils.getNpcBehavStatusMap(key)
	end
end

function IUtilsComponent:doSysEvent(actorId, eventId)
	if Utils.checkClient() then
		local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

		if ent then
			pg.me:doEvent(eventId, {
				globalId = ent:getGlobalId()
			})
		end
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getIntByWeight(weightList, valueList)
	return lume.weightRandomChoiceOne(valueList, weightList)
end

function IUtilsComponent:getFloatByWeight(weightList, valueList)
	return lume.weightRandomChoiceOne(valueList, weightList)
end

function IUtilsComponent:getStringByWeight(weightList, valueList)
	return lume.weightRandomChoiceOne(valueList, weightList)
end

function IUtilsComponent:getActorId(staticId)
	local ent = self.ent.space:getEntityByStaticId(staticId)

	return ent and ent.actorId or 0
end

function IUtilsComponent:getStaticId(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	return ent and ent.staticId or 0
end

function IUtilsComponent:getAngleByEntity(actorId, actorId2)
	actorId = actorId == 0 and self.ent.actorId or actorId
	actorId2 = actorId2 == 0 and self.ent.actorId or actorId2

	local ent = pg.getEntityByActorId(actorId)
	local ent2 = pg.getEntityByActorId(actorId2)

	if ent and ent2 then
		return CalcUtils.getAngleByEntityPos(ent, ent2)
	end

	return 0
end

function IUtilsComponent:getChestGuideLevel(chestActorId)
	local chestEnt = pg.getEntityByActorId(chestActorId)

	if Utils.isChest(chestEnt) then
		return chestEnt:getPetGuideLevel()
	end

	return -1
end

function IUtilsComponent:getControllingPetActorId(playerActorId)
	local playerEnt = pg.getEntityByActorId(playerActorId)

	if playerEnt and playerEnt.isControllingPet and playerEnt:isControllingPet() then
		local petEnt = playerEnt:getCurPetEntity()

		return petEnt and petEnt.actorId or 0
	end

	return 0
end

function IUtilsComponent:getDistance(actorId, actorId2, useBodySize)
	if actorId == actorId2 then
		return 0
	end

	actorId = actorId == 0 and self.ent.actorId or actorId
	actorId2 = actorId2 == 0 and self.ent.actorId or actorId2

	local ent = pg.getEntityByActorId(actorId)
	local ent2 = pg.getEntityByActorId(actorId2)

	if ent and ent2 then
		local rootDist = Vector3.Distance(ent:getPosition(), ent2:getPosition())

		return math_max(rootDist - (useBodySize and CalcUtils.getBodySizeBias(ent, ent2) or 0), 0)
	end

	return -1
end

function IUtilsComponent:setVisionAreaOverride(areaName)
	local ent = self.ent

	if ent.setVisualPerceptibilityGroup then
		ent:setVisualPerceptibilityGroup(areaName)
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:sendMessageToTrigger(actorId, msgId)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return EBTStatus.BT_FAILURE
	end

	local basePetPrototypeId = ent.basePetPrototypeId or Utils.getBasePetPrototypeId(ent.petPrototypeId)

	pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_AI_MSG, ent.petPrototypeId, 1, msgId)
	pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_AI_MSG_BASE, basePetPrototypeId, 1, msgId)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:getEntityCacheValue(keyName, entityActorId)
	if entityActorId == nil or entityActorId == 0 then
		entityActorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(entityActorId)

	return EntityCacheValueUtils.getCacheValue(ent, keyName) or 0
end

function IUtilsComponent:getBodyHeight(targetActorId)
	targetActorId = targetActorId == 0 and self.ent.actorId or targetActorId

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity then
		if targetEntity.getRealHeight then
			return targetEntity:getRealHeight()
		elseif targetEntity.getHeight then
			return targetEntity:getHeight()
		end
	end

	return 0
end

function IUtilsComponent:setEntityCacheValue(keyName, value)
	EntityCacheValueUtils.setCacheValue(self.ent, keyName, value)

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:checkEntityExist(actorId)
	return pg.getEntityByActorId(actorId) ~= nil
end

function IUtilsComponent:checkHasChemState(actorId, stateName)
	local ent = pg.getEntityByActorId(actorId)

	if ent and stateName then
		return AIUtils.checkChemStateAndAbility(ent, stateName)
	end

	return false
end

function IUtilsComponent:checkInAIState(actorId, stateName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.agent then
		return BehaviorPathMapData.EnumNameMap[stateName] == ent.agent:getBehaviorState()
	end

	return false
end

function IUtilsComponent:checkInDialog(dialogId)
	local DialogueConst = require("Const.DialogueConst")

	return pg.game.communication.curChatType ~= DialogueConst.ChatType.NONE and pg.game.communication.curDialogueId == dialogId
end

function IUtilsComponent:checkRelation(actorId, actorId2, relationType)
	actorId = actorId == 0 and self.ent.actorId or actorId
	actorId2 = actorId2 == 0 and self.ent.actorId or actorId2

	local ent = pg.getEntityByActorId(actorId)
	local ent2 = pg.getEntityByActorId(actorId2)

	return Utils.checkRelation(ent, ent2, relationType)
end

function IUtilsComponent:isControllingPet(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.isControllingPet then
		return ent:isControllingPet()
	end

	return false
end

function IUtilsComponent:isCurCombatPet(actorId)
	local curPet = pg.me:getCurPetEntity()

	if curPet == nil then
		return false
	end

	actorId = actorId == 0 and self.ent.actorId or actorId

	return actorId == curPet.actorId
end

function IUtilsComponent:isEntityType(actorId, entityType)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return Utils.isActorType(ent, Const[entityType])
	end

	return false
end

function IUtilsComponent:isEnvObjCanInteract(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent.checkCanInteract
	end

	return false
end

function IUtilsComponent:isEthnicGroup(actorId, ethnicGroupId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent:getConfigData().ethnicGroup == ethnicGroupId
	end

	return false
end

function IUtilsComponent:isInAnimState(actorId, animStateName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	return AnimationUtils.isAnimationPlaying(ent, animStateName)
end

function IUtilsComponent:isInAnimTag(actorId, animTag)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	return AnimationUtils.isInAnimTag(ent, animTag)
end

function IUtilsComponent:isInBehavTag(actorId, behavTag)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.getCurrentAIParmonPlan then
		local curPlan = ent:getCurrentAIParmonPlan()

		if curPlan then
			return curPlan:checkPlanBehavTag(behavTag)
		end
	end

	return false
end

function IUtilsComponent:isInCatchMode(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent:CATCH_MODE_ST()
	end

	return false
end

function IUtilsComponent:isInCharState(actorId, checkStateType, stateParam)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		local currentAnimationState = AIControllerUtils.getCurrentAnimationState(ent)

		if checkStateType == 1 then
			return CharacterStateConst.isChildOfState(currentAnimationState, stateParam) or stateParam == currentAnimationState
		else
			if not stateParam then
				return false
			end

			for i = 1, #stateParam do
				local stateConstInt = CharacterStateConst[stateParam[i]]

				if CharacterStateConst.isChildOfState(currentAnimationState, stateConstInt) or stateConstInt == currentAnimationState then
					return true
				end
			end
		end
	end

	return false
end

function IUtilsComponent:isInCrouch(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent:CROUCH_ST()
	end

	return false
end

function IUtilsComponent:isInGroupBehaviour(actorId, includePrepare, groupBehavName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.GroupBehaviour and ent.GroupBehaviour.curGroupBehaviour and (string_isNilOrEmpty(groupBehavName) or groupBehavName == "Any" or groupBehavName == ent.GroupBehaviour.curGroupBehaviour.behaviourName) then
		return includePrepare or ent.GroupBehaviour.curGroupBehaviour:isRunning()
	end

	return false
end

function IUtilsComponent:isInMagnesisMode(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.isInMagnesisMode then
		return ent:isInMagnesisMode()
	end

	return false
end

function IUtilsComponent:isInPetBallExpAction()
	if Utils.checkClient() then
		local petBallUIModel = pg.global.ui.petFertility.model

		if petBallUIModel then
			local status = petBallUIModel:getCurPetBallExpActionStatus()

			return status == Const.PET_BALL.EXP_STATUS_START or status == Const.PET_BALL.EXP_STATUS_PAUSE
		end
	end

	return false
end

function IUtilsComponent:isInSelfieMode()
	if Utils.checkClient() then
		return pg.global.ui.photo:isInSelfie()
	end

	return false
end

function IUtilsComponent:isPlayerTwinPet(petPrototypeId)
	return Utils.isPlayerTwinPet(pg.me, petPrototypeId)
end

function IUtilsComponent:isPuppetInCallFriend(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if ent and Utils.isPetPuppet(ent) then
		return string_notNilOrEmpty(ent.slavesOwnerId)
	end

	return false
end

function IUtilsComponent:isSameSpecies(targetActorId, sourceActorId)
	targetActorId = targetActorId == 0 and self.ent.actorId or targetActorId
	sourceActorId = sourceActorId == 0 and self.ent.actorId or sourceActorId

	local targetEntity = pg.getEntityByActorId(targetActorId)
	local sourceEntity = pg.getEntityByActorId(sourceActorId)

	return Utils.IsSameSpecies(targetEntity, sourceEntity)
end

function IUtilsComponent:isTwinPet(petPrototypeId)
	return Utils.isTwinPet(petPrototypeId)
end

function IUtilsComponent:checkHasAbility(targetActorId, abilityTypeName)
	targetActorId = targetActorId == 0 and self.ent.actorId or targetActorId

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity then
		local abilityType = BaseEnum.AbilityType
		local abilityName = BaseEnum.AbilityType_NAME

		if abilityTypeName == abilityName[abilityType.SwimMimicry] then
			return AIControllerUtils.checkCanSwimMimicry(targetEntity)
		elseif abilityTypeName == abilityName[abilityType.HideMimicry] then
			return AIControllerUtils.checkCanHideMimicry(targetEntity)
		elseif abilityTypeName == abilityName[abilityType.Swim] then
			return AIControllerUtils.checkCanSwim(targetEntity) and true or false
		elseif abilityTypeName == abilityName[abilityType.Climb] then
			return AIControllerUtils.checkCanClimb(targetEntity) and true or false
		elseif abilityTypeName == abilityName[abilityType.Glide] then
			return AIControllerUtils.checkCanGlide(targetEntity) and true or false
		elseif abilityTypeName == abilityName[abilityType.SkateBoard] then
			return AIControllerUtils.checkCanSkateBoard(targetEntity)
		elseif abilityTypeName == abilityName[abilityType.Fly] then
			return AIControllerUtils.checkCanFly(targetEntity)
		end
	end

	return false
end

function IUtilsComponent:getCurMeteorologyId(actorId)
	if Utils.checkClient() then
		local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

		return ent and Utils.getCurMeteorologyId(ent) or 0
	end

	return 0
end

function IUtilsComponent:getCurWeatherId(actorId)
	if Utils.checkClient() then
		local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

		return ent and Utils.getCurWeatherId(ent) or 0
	end

	return 0
end

function IUtilsComponent:playPreset(actorId, presetName, duration, disableWhenFinished, loopCount, renderNameList)
	actorId = actorId == 0 and self.ent.actorId or actorId

	return AIBaseMethodUtils.Base_PlayPreset(self.ent, actorId, presetName, duration, disableWhenFinished, loopCount, renderNameList)
end

function IUtilsComponent:stopPreset(actorId, presetName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	return AIBaseMethodUtils.Base_StopPreset(self.ent, actorId, presetName)
end

function IUtilsComponent:setAttenuationMultiple(actorId, attenuationMultiple)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	if ent and ent.setAttenuationMultiple then
		ent:setAttenuationMultiple(attenuationMultiple)
	end

	return EBTStatus.BT_SUCCESS
end

function IUtilsComponent:isChildOfCharState(actorId, stateName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and CharacterStateConst[stateName] then
		local curState = AIControllerUtils.getCurrentAnimationState(ent)

		return CharacterStateConst.isChildOfState(curState, CharacterStateConst[stateName])
	end

	return false
end

function IUtilsComponent:isChildOrTransitionOfCharState(actorId, stateName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and CharacterStateConst[stateName] then
		local curState = AIControllerUtils.getCurrentAnimationState(ent)

		return CharacterStateConst.isChildOrTransitionOfState(curState, CharacterStateConst[stateName])
	end

	return false
end

function IUtilsComponent:debugLog(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG, "AI") then
		logger:debug("@cyj entity actorId", self.ent.actorId, "debugLog:", value)
	end

	return EBTStatus.BT_SUCCESS
end

return IUtilsComponent
