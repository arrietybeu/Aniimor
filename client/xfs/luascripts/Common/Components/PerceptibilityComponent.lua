-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\PerceptibilityComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local PuppetData = require("Data.puppet_data")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local VisionSensor = require("Common.Components.AI.Perceptibility.VisionSensor")
local VisionSensorDebug = require("Common.Components.AI.Perceptibility.VisionSensorDebug")
local NoImpVisionSensor = require("Common.Components.AI.Perceptibility.NoImpVisionSensor")
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")
local CTRPool = require("Common.AICt.CTRPool")
local TablePool = require("Common.Container.TablePool")
local ListPool = require("Common.Container.ListPool")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PetOtherInteractData = require("Data.pet_other_entity_interact_data")
local EventConst = require("Common.Const.EventConst")
local pg = pg
local Vector3 = Vector3
local bit_band = bit.band
local bit_lshift = bit.lshift
local math_abs = math.abs
local pairs = pairs
local table_clear = table.clear
local PERCEPTIBILITY_SEARCH_USER_TYPE = -1
local PerceptibilityComponent = Class.Component("PerceptibilityComponent")

function PerceptibilityComponent:ctor()
	self.perceptibility = {
		isPause = true,
		senseState = PerceptibilityConst.SenseState.None,
		pauseReasonSet = {
			[PerceptibilityConst.PauseReason.AIPause] = true,
			[PerceptibilityConst.PauseReason.Authority] = true
		}
	}
	self._perceptibilityRangeOwner = false
	self._perceptibilityRangeEventHandle = 0
	self._perceptibilityRangeRadius = 0
	self._perceptibilityRangeActive = false
	self._perceptibilityAoiActorTypeMap = {}
end

function PerceptibilityComponent:_perceptibilityAddRangeEvent(rangeOwner, radius)
	if rangeOwner.addRangeEvent then
		return rangeOwner:addRangeEvent(Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY, radius, radius)
	end

	local aoi = rangeOwner.aoi

	if aoi and aoi.addRangeEvent then
		return aoi:addRangeEvent(Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY, radius, radius)
	end

	return 0
end

function PerceptibilityComponent:_perceptibilityRemoveRangeEvent(rangeOwner, eventHandle)
	if rangeOwner.removeRangeEvent then
		rangeOwner:removeRangeEvent(eventHandle, true)

		return
	end

	local aoi = rangeOwner.aoi

	if aoi and aoi.removeRangeEvent then
		aoi:removeRangeEvent(eventHandle, true)
	end
end

function PerceptibilityComponent:_perceptibilityGetMaxSensorRange()
	local perceptibility = self.perceptibility
	local maxRange = 0
	local visionSensor = perceptibility.visionSensor

	if visionSensor and visionSensor.tickAllow then
		maxRange = visionSensor.VP_maxVisionDistance or 0
	end

	local noImpVisionSensor = perceptibility.noImpVisionSensor

	if noImpVisionSensor and noImpVisionSensor.tickAllow then
		local noImpRange = noImpVisionSensor.VP_maxVisionDistance or 0

		if maxRange < noImpRange then
			maxRange = noImpRange
		end
	end

	return maxRange
end

function PerceptibilityComponent:_perceptibilityRebuildAoiActorTypes()
	local candidates = self._perceptibilityAoiActorTypeMap

	table_clear(candidates)

	local actorIds = ListPool.getList(3)
	local rangeOwner = self._perceptibilityRangeOwner
	local searchTarget = rangeOwner

	if searchTarget and searchTarget.entitiesInRangeWithCache then
		searchTarget:entitiesInRangeWithCache(self._perceptibilityRangeRadius, PERCEPTIBILITY_SEARCH_USER_TYPE, actorIds)

		for index = 1, #actorIds do
			local actorId = actorIds[index]
			local entity = pg.getEntityByActorId(actorId)
			local clenUsrType = entity and entity.clenUsrType

			if clenUsrType and clenUsrType >= 0 then
				candidates[actorId] = clenUsrType
			end
		end
	end

	ListPool.returnList(actorIds, 3)
end

function PerceptibilityComponent:onPerceptibilityEnterTrap(targetActorId)
	if not self._perceptibilityRangeActive or not targetActorId then
		return
	end

	local entity = pg.getEntityByActorId(targetActorId)
	local clenUsrType = entity and entity.clenUsrType

	if clenUsrType and clenUsrType >= 0 then
		self._perceptibilityAoiActorTypeMap[targetActorId] = clenUsrType
	end
end

function PerceptibilityComponent:onPerceptibilityLeaveTrap(targetActorId)
	if self._perceptibilityRangeActive and targetActorId then
		self._perceptibilityAoiActorTypeMap[targetActorId] = nil
	end
end

function PerceptibilityComponent:onEnterTrap(targetActorId, eventId)
	if eventId == Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY then
		self:onPerceptibilityEnterTrap(targetActorId)
	end
end

function PerceptibilityComponent:onLeaveTrap(targetActorId, eventId)
	if eventId == Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY then
		self:onPerceptibilityLeaveTrap(targetActorId)
	end
end

function PerceptibilityComponent:onEnterSpace()
	if not Utils.checkIsAuthorityMaster(self) then
		self:pausePerceptibility(PerceptibilityConst.PauseReason.Authority)
	else
		self:resumePerceptibility(PerceptibilityConst.PauseReason.Authority)
	end

	self.perceivedValuePercent = self.perceivedValuePercent or 0
	self.perceivedActorId = self.perceivedActorId or 0
	self.perceivedValue = self.perceivedValue or 0

	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:onLeaveSpace()
	self:releasePerceptibilityRange()
end

function PerceptibilityComponent:EVENT_OnAuthorityChanged()
	if not Utils.checkIsAuthorityMaster(self) then
		self:pausePerceptibility(PerceptibilityConst.PauseReason.Authority)
	else
		self:resumePerceptibility(PerceptibilityConst.PauseReason.Authority)

		if self.perceptibility.visionSensor then
			self.perceptibility.visionSensor:refreshVisualPerceptibilityGroup()
		end

		if self.perceptibility.noImpVisionSensor then
			self.perceptibility.noImpVisionSensor:refreshNoImpPerceptibilityGroup()
		end
	end

	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:onAIStartAgent()
	self:initAllSensor()
	self:resumePerceptibility(PerceptibilityConst.PauseReason.AIPause)
end

function PerceptibilityComponent:onAIPauseAgent()
	local pauseReason = PerceptibilityConst.PauseReason.AIPause

	if not self.perceptibility.pauseReasonSet[pauseReason] then
		self:pausePerceptibility(pauseReason)
	end

	self:releasePerceptibilityRange()
end

function PerceptibilityComponent:onAIResumeAgent()
	local pauseReason = PerceptibilityConst.PauseReason.AIPause

	if self.perceptibility.pauseReasonSet[pauseReason] then
		self:resumePerceptibility(pauseReason)
	end

	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:initAllSensor()
	if Utils.isHomePet(self) then
		self:releasePerceptibilityRange()

		return
	end

	if Utils.isPuppet(self) then
		local perceptGroupId = PuppetData[self.templateId].perceptGroupId
		local nolmpPerceptGroupId = PuppetData[self.templateId].nolmpPerceptGroupId
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
		local staticId = self.staticId
		local staticData = sceneEntityData[staticId]

		if staticData and staticData.override_perceptGroupId then
			perceptGroupId = string.isNilOrEmpty(staticData.override_perceptGroupId) and AiConst.DefaultPGCommonNone or staticData.override_perceptGroupId
		end

		if staticData and staticData.override_nolmpPerceptGroupId then
			nolmpPerceptGroupId = staticData.override_nolmpPerceptGroupId
		end

		if Utils.isCreatePlenty(self) then
			local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData()

			if emergenceOverrideData then
				perceptGroupId = string.isNilOrEmpty(emergenceOverrideData.perceptGroupId) and AiConst.DefaultPGCommonNone or emergenceOverrideData.perceptGroupId
			end
		end

		if perceptGroupId then
			if not self.perceptibility.visionSensor then
				self.perceptibility.visionSensor = VisionSensor.new(self)
			end

			self.perceptibility.visionSensor:init(perceptGroupId)
		elseif self.perceptibility.visionSensor then
			self.perceptibility.visionSensor:destroy()

			self.perceptibility.visionSensor = nil
		end

		if not Utils.isServerPuppet(self) then
			if nolmpPerceptGroupId then
				if not self.perceptibility.noImpVisionSensor then
					self.perceptibility.noImpVisionSensor = NoImpVisionSensor.new(self)
				end

				self.perceptibility.noImpVisionSensor:init(nolmpPerceptGroupId)
			elseif self.perceptibility.noImpVisionSensor then
				self.perceptibility.noImpVisionSensor:destroy()

				self.perceptibility.noImpVisionSensor = nil
			end
		end
	elseif Utils.isPet(self) then
		local nolmpPerceptGroupId = self:getConfigData().nolmpPerceptGroupId

		if nolmpPerceptGroupId then
			if not self.perceptibility.noImpVisionSensor then
				self.perceptibility.noImpVisionSensor = NoImpVisionSensor.new(self)
			end

			self.perceptibility.noImpVisionSensor:init(nolmpPerceptGroupId)
		elseif self.perceptibility.noImpVisionSensor then
			self.perceptibility.noImpVisionSensor:destroy()

			self.perceptibility.noImpVisionSensor = nil
		end
	end

	if UNITY_EDITOR then
		if not self.perceptibility.visionSensorDebug then
			self.perceptibility.visionSensorDebug = VisionSensorDebug.new(self)
		end

		self.perceptibility.visionSensorDebug:init()
	end

	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:destroy()
	self:releasePerceptibilityRange()

	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:destroy()

		self.perceptibility.visionSensor = nil
	end

	if self.perceptibility.visionSensorDebug then
		self.perceptibility.visionSensorDebug:destroy()

		self.perceptibility.visionSensorDebug = nil
	end

	if self.perceptibility.noImpVisionSensor then
		self.perceptibility.noImpVisionSensor:destroy()

		self.perceptibility.noImpVisionSensor = nil
	end
end

function PerceptibilityComponent:releasePerceptibilityRange()
	local rangeOwner = self._perceptibilityRangeOwner
	local eventHandle = self._perceptibilityRangeEventHandle

	self._perceptibilityRangeOwner = false
	self._perceptibilityRangeEventHandle = 0
	self._perceptibilityRangeRadius = 0
	self._perceptibilityRangeActive = false

	table_clear(self._perceptibilityAoiActorTypeMap)

	if rangeOwner and eventHandle ~= 0 then
		self:_perceptibilityRemoveRangeEvent(rangeOwner, eventHandle)
	end
end

function PerceptibilityComponent:refreshPerceptibilityRange()
	local radius = self:_perceptibilityGetMaxSensorRange()

	if radius <= 0 or not Utils.checkIsAuthorityMaster(self) then
		self:releasePerceptibilityRange()

		return
	end

	local rangeOwner = AIUtils.getPerceptibilitySearchEnt(self)

	if not rangeOwner then
		self:releasePerceptibilityRange()

		return
	end

	if self._perceptibilityRangeActive and self._perceptibilityRangeOwner == rangeOwner and self._perceptibilityRangeRadius == radius then
		return
	end

	self:releasePerceptibilityRange()

	local eventHandle = self:_perceptibilityAddRangeEvent(rangeOwner, radius)

	if not eventHandle or eventHandle == 0 then
		return
	end

	self._perceptibilityRangeOwner = rangeOwner
	self._perceptibilityRangeEventHandle = eventHandle
	self._perceptibilityRangeRadius = radius
	self._perceptibilityRangeActive = true

	self:_perceptibilityRebuildAoiActorTypes()
end

function PerceptibilityComponent:getPerceptibilityRangeCandidates()
	return self._perceptibilityAoiActorTypeMap
end

function PerceptibilityComponent:isPerceptibilityActive()
	return self._perceptibilityRangeActive
end

function PerceptibilityComponent:searchPerceptibilityRangeCandidates(radius, userType, outputList)
	if not self._perceptibilityRangeActive or radius < 0 then
		return false
	end

	local rangeOwner = self._perceptibilityRangeOwner

	if not rangeOwner then
		return false
	end

	if radius > self._perceptibilityRangeRadius then
		return false
	end

	local checkPosition = radius < self._perceptibilityRangeRadius
	local ownerPosition

	if checkPosition then
		ownerPosition = rangeOwner:getPosition()
	end

	local ownerX = checkPosition and ownerPosition[1] or 0
	local ownerZ = checkPosition and ownerPosition[3] or 0
	local oldOutputCount = #outputList
	local outputCount = 0
	local candidates = self._perceptibilityAoiActorTypeMap

	for actorId, clenUsrType in pairs(candidates) do
		if bit_band(bit_lshift(1, clenUsrType), userType) ~= 0 then
			local entity = pg.getEntityByActorId(actorId)

			if entity and (clenUsrType ~= Const.CLEN_USR_TYPE_PET or entity.isSummon) then
				if not checkPosition then
					outputCount = outputCount + 1
					outputList[outputCount] = actorId
				else
					local entityPosition = entity:getPosition()

					if radius > math_abs(entityPosition[1] - ownerX) and radius > math_abs(entityPosition[3] - ownerZ) then
						outputCount = outputCount + 1
						outputList[outputCount] = actorId
					end
				end
			end
		end
	end

	for index = outputCount + 1, oldOutputCount do
		outputList[index] = nil
	end

	return true, outputCount
end

function PerceptibilityComponent:EVENT_PerceptibilitySearchEntityChanged()
	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:onAIStateChange(oldRootState, newRootState, oldBehaviorState, newBehaviorState)
	if oldRootState ~= newRootState then
		self:refreshPerceptibility()
	end
end

function PerceptibilityComponent:refreshPerceptibility()
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:refreshSensor()
	end

	if self.perceptibility.noImpVisionSensor then
		self.perceptibility.noImpVisionSensor:refreshSensor()
	end

	self:refreshPerceptibilityRange()
end

function PerceptibilityComponent:getPerceivedValue(targetActorId)
	local perceivedMap = self:getPerceivedMap()

	targetActorId = targetActorId or 0

	return perceivedMap[targetActorId] or 0
end

function PerceptibilityComponent:onPerceptibilityUpdate()
	local visionSensor = self.perceptibility.visionSensor

	if visionSensor and visionSensor:isValid() then
		local oldPercent = self.perceivedValuePercent

		self.perceivedValuePercent = visionSensor:getMaxPerceivePercent()
		self.perceivedActorId = visionSensor:getMaxPerceivedActorId()
		self.perceivedValue = visionSensor:getMaxPerceivedValue()

		local curVal = self.perceivedValue
		local valueIdle = visionSensor:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueIdle)
		local valueAlert = visionSensor:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueAlert)
		local valueSensed = visionSensor:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueSensed)

		if self.perceptibility.senseState == PerceptibilityConst.SenseState.None then
			if valueSensed <= curVal then
				self.perceptibility.senseState = PerceptibilityConst.SenseState.Sensed

				AIUtils.enterSensed(self)
			elseif valueAlert <= curVal then
				self.perceptibility.senseState = PerceptibilityConst.SenseState.Alert

				AIUtils.enterAlert(self)
			end
		elseif self.perceptibility.senseState == PerceptibilityConst.SenseState.Alert then
			if valueSensed <= curVal then
				self.perceptibility.senseState = PerceptibilityConst.SenseState.Sensed

				AIUtils.enterSensed(self)
			elseif curVal <= valueIdle then
				self.perceptibility.senseState = PerceptibilityConst.SenseState.None

				AIUtils.enterIdle(self)
			end
		elseif self.perceptibility.senseState == PerceptibilityConst.SenseState.Sensed and curVal <= valueIdle then
			self.perceptibility.senseState = PerceptibilityConst.SenseState.None

			AIUtils.enterIdle(self)
		end

		if oldPercent ~= self.perceivedValuePercent then
			self:m_notifyPerceptChanged()
		end
	else
		self:resetPerceivedProperty()
	end
end

function PerceptibilityComponent:m_notifyPerceptChanged()
	if not Utils.checkClient() then
		return
	end

	if self.eventEmitter then
		self.eventEmitter:emit(EventConst.TOPLOGO_PERCEPT_CHANGED, self.perceivedValuePercent)
	end
end

function PerceptibilityComponent:on_perceivedValuePercent_changed(oldVal, newVal)
	self:m_notifyPerceptChanged()
end

function PerceptibilityComponent:onClearAllPerceptibility()
	self.perceptibility.senseState = PerceptibilityConst.SenseState.None

	self:resetPerceivedProperty()
end

function PerceptibilityComponent:resetPerceivedProperty()
	self.perceivedValuePercent = 0
	self.perceivedActorId = 0
	self.perceivedValue = 0
end

function PerceptibilityComponent:getMaxPerceptibility()
	return self.perceivedActorId, self.perceivedValue
end

function PerceptibilityComponent:getVisionPerceptMaxLimit()
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueMax)
	end

	return 0
end

function PerceptibilityComponent:onNoImpPerceptibilityUpdate()
	local subjectPrototypeId = self.petPrototypeId

	if subjectPrototypeId then
		local petOtherInteractData = PetOtherInteractData[subjectPrototypeId]

		if petOtherInteractData then
			local aiInteractList = self:getNoImpPerceivedMap(Const.SEARCH_USR_TYPE_AI_INTERACT)
			local ent, tagRet, chemRet

			for _, actorId in ipairs(aiInteractList) do
				ent = pg.getEntityByActorId(actorId)

				for _, data in ipairs(petOtherInteractData) do
					tagRet = Utils.tableIsEmptyOrNil(data.interactObjectEntityTag) or Utils.hasAnyEntityTag(ent, data.interactObjectEntityTag)
					chemRet = Utils.tableIsEmptyOrNil(data.interactObjectChemState) or AIUtils.checkAnyChemStateAndAbility(ent, data.interactObjectChemState)

					if tagRet and chemRet then
						local context = CTRPool.getContext()

						context.interactObjectActorId = actorId
						context.interactArg = data.interactArg

						AIControllerUtils.sendAIEvent(self, data.interactBehav, context)
					end
				end
			end
		end

		local actorIdMap = TablePool.getTable()

		self:getEcologyEthnicEntActorIds(actorIdMap)

		local ent, interactData

		for actorId, _ in pairs(actorIdMap) do
			ent = pg.getEntityByActorId(actorId)

			if Utils.isPuppet(ent) or Utils.isPet(ent) then
				interactData = AIUtils.getEcologyEthnicData(subjectPrototypeId, ent.petPrototypeId)

				if interactData then
					local context = CTRPool.getContext()

					context.interactObjectActorId = actorId
					context.interactArg = interactData.interactArg

					AIControllerUtils.sendAIEvent(self, interactData.interactBehav, context)
				end
			elseif Utils.isPlayer(ent) then
				local playerKey = -1

				interactData = AIUtils.getEcologyEthnicData(subjectPrototypeId, playerKey)

				if interactData then
					local context = CTRPool.getContext()

					context.interactObjectActorId = actorId
					context.interactArg = interactData.interactArg

					AIControllerUtils.sendAIEvent(self, interactData.interactBehav, context)
				end

				if AIUtils.checkPuppetAffinity(self, ent.actorId) then
					local context = CTRPool.getContext()

					context.interactObjectActorId = actorId
					context.interactArg = nil

					AIControllerUtils.sendAIEvent(self, "Event_PER_Affinity", context)
				end
			end
		end

		TablePool.returnTable(actorIdMap)
	end
end

function PerceptibilityComponent:setVisualPerceptibilityGroup(vpGroupName)
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:setVPGroupName(vpGroupName)
		self:refreshPerceptibilityRange()
	end
end

function PerceptibilityComponent:getMaxPerceivedValuePercent()
	if Utils.isServerPuppet(self) then
		return self.perceivedValuePercent
	else
		local visionSensor = self.perceptibility.visionSensor

		return visionSensor and visionSensor:getMaxPerceivePercent() or 0
	end
end

function PerceptibilityComponent:EVENT_BeTrapped()
	self:pausePerceptibility(PerceptibilityConst.PauseReason.BeTrapped)
end

function PerceptibilityComponent:EVENT_CancelTrapped()
	self:resumePerceptibility(PerceptibilityConst.PauseReason.BeTrapped)

	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:addBallComingHitPerceptibility(pg.me.actorId)
	end
end

function PerceptibilityComponent:addDeformationTerrorPerceptibility(entityActorId)
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:addDeformationTerrorPerceptibility(entityActorId)
	end
end

function PerceptibilityComponent:addBallComingNearbyPerceptibility(entityActorId)
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:addBallComingNearByTimer(0.5, entityActorId)
	end
end

function PerceptibilityComponent:addOncePerceptibility(entityActorId, oncePerceptibilityValue)
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:addOncePerceptibility(entityActorId, oncePerceptibilityValue)
	end
end

function PerceptibilityComponent:getPerceivedMap()
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor.perceivedMap
	end

	return AiConst.DefaultNullTable
end

function PerceptibilityComponent:getPerceivedFilterMap()
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor.perceivedFilterMap
	end

	return AiConst.DefaultNullTable
end

function PerceptibilityComponent:getNoImpPerceivedMap(searchType)
	if self.perceptibility.noImpVisionSensor then
		return self.perceptibility.noImpVisionSensor.perceivedNoImpMap[searchType] or AiConst.DefaultNullTable
	end

	return AiConst.DefaultNullTable
end

function PerceptibilityComponent:getNoImpPerceivedFilterMap()
	if self.perceptibility.noImpVisionSensor then
		return self.perceptibility.noImpVisionSensor.perceivedFilterMap or AiConst.DefaultNullTable
	end

	return AiConst.DefaultNullTable
end

function PerceptibilityComponent:getEcologyEthnicEntActorIds(actorIdMap)
	actorIdMap = actorIdMap or {}

	local perceivedMap = self:getPerceivedMap()

	for actorId, value in pairs(perceivedMap) do
		if value > 0 then
			local ent = pg.getEntityByActorId(actorId)

			if ent then
				local pet = ent.getControllingPet and ent:getControllingPet()

				actorIdMap[pet and pet.actorId or actorId] = true
			end
		end
	end

	local parmonList = self:getNoImpPerceivedMap(Const.SEARCH_USR_TYPE_ACTOR)

	for _, actorId in ipairs(parmonList) do
		actorIdMap[actorId] = true
	end

	return actorIdMap
end

function PerceptibilityComponent:getVisionPerceivedAreaMulti(actorId)
	if self.perceptibility.visionSensor then
		return AIUtils.getVisionPerceivedAreaMultiFunc(self.perceptibility.visionSensor, actorId)
	end
end

function PerceptibilityComponent:getPerceptibilityGroupValueChange()
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor:getPerceptibilityGroupValueChange()
	end
end

function PerceptibilityComponent:getEntityEnvironmentMatch(actorId)
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor:getEntityEnvironmentMatch(actorId)
	end
end

function PerceptibilityComponent:getVisionValueChangeRatio(actorId)
	if self.perceptibility.visionSensor then
		return self.perceptibility.visionSensor:getVisionValueChangeRatio(actorId)
	end
end

function PerceptibilityComponent:setAttenuationMultiple(attenuationMultiple)
	if self.perceptibility.visionSensor then
		self.perceptibility.visionSensor:setAttenuationMultiple(attenuationMultiple)
	end
end

function PerceptibilityComponent:pausePerceptibility(pauseReason)
	self.perceptibility.pauseReasonSet[pauseReason] = true
	self.perceptibility.isPause = true

	self:refreshPerceptibility()
end

function PerceptibilityComponent:resumePerceptibility(pauseReason)
	self.perceptibility.pauseReasonSet[pauseReason] = nil

	self:refreshPerceptibilityPauseState()
	self:refreshPerceptibility()
end

function PerceptibilityComponent:refreshPerceptibilityPauseState()
	self.perceptibility.isPause = next(self.perceptibility.pauseReasonSet) ~= nil
end

function PerceptibilityComponent:checkPerceptibilityIsPause()
	return self.perceptibility.isPause
end

function PerceptibilityComponent:getEcologyEthnicInteractResult(subjectActorId, objectActorId)
	local subjectEntity = pg.getEntityByActorId(subjectActorId)
	local objectEntity = pg.getEntityByActorId(objectActorId)
	local subjectPrototypeId = subjectEntity and subjectEntity.petPrototypeId or 0
	local objectPrototypeId = objectEntity and (Utils.isPlayer(objectEntity) and -1 or objectEntity.petPrototypeId) or 0
	local data, dataId = AIUtils.getEcologyEthnicData(subjectPrototypeId, objectPrototypeId)

	if data then
		return {
			dataId,
			data.interactBehav,
			inspect(data.interactArg)
		}
	else
		return {
			0,
			"",
			""
		}
	end
end

function PerceptibilityComponent:forceUpdateNoImpSensor()
	if self.perceptibility.noImpVisionSensor then
		self.perceptibility.noImpVisionSensor:updateNoImpVision()
	end
end

function PerceptibilityComponent:EVENT_PostReload()
	self:initAllSensor()
	self:refreshPerceptibility()
end

function PerceptibilityComponent:RPC_SC_PausePerceptionGM()
	self:pausePerceptibility(PerceptibilityConst.PauseReason.GM)
end

function PerceptibilityComponent:RPC_SC_ResumePerceptionGM()
	self:resumePerceptibility(PerceptibilityConst.PauseReason.GM)
end

return PerceptibilityComponent
