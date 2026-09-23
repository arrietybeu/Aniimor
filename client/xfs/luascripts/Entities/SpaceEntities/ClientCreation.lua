-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCreation.lua

local Class = require("Core.Framework.Class")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local LxGeometry = require("Common.Ability.LxGeometry")
local MessageName = require("Const.MessageName")
local CreationData = require("Data.creation_data")
local EventConst = require("Const.EventConst")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local lume = require("Core.Common.lume")
local AudioConst = require("Const.AudioConst")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientMagicFieldComponent = require("Entities.SpaceEntities.CommonComponent.ClientMagicFieldComponent")
local ClientTrapComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientEntityCacheValComponent = require("Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local EcsElement = CS.FunPlus.WorldX.GameApp.Ecs.EcsElement
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
local CreationComponents = {
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientAuthorityComponent,
	ClientCombatEntityComponent,
	ClientTimeControlComponent,
	ClientAbilityComponent,
	ClientMagicFieldComponent,
	ClientTrapComponent,
	ClientMotionComponent,
	ClientTopLogoComponent,
	ClientEcologyComponent,
	ClientEntityCacheValComponent,
	ClientAnimatorComponent,
	ClientEcsComponent
}
local ClientCreation = Class.Class("ClientCreation", ClientPawnEntity)

Class.AddComponents(ClientCreation, CreationComponents)

local ToBool = ToBool
local Quaternion = Quaternion
local Vector3 = Vector3
local NotNil = NotNil

function ClientCreation:ctor(entityId)
	ClientCreation.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_CREATION
	self.isClientEnt = false
end

function ClientCreation:init(dict)
	ClientCreation.super.init(self, dict)

	self.templateData = CreationData[self.templateId]
	self.timelineId = dict.timelineId
	self.timelineCombatContextId = dict.timelineCombatContextId
	self.timelineStartTime = dict.timelineStartTime

	local configData = self:getConfigData()

	self.bodySize = configData.bodySize or 0.2
	self.bodyHeight = configData.bodySize or 0.5
	self.canBeHit = ToBool(configData.canBeHit)
	self.disableHitEffect = ToBool(configData.disableHitEffect)
	self.shapeType = dict.overrideHitBoxShape and dict.overrideHitBoxShape or AbilityConst.LX_GEOMETRY_TYPE_PARSER[configData.shapeKind]
	self.shapeArgs = dict.overrideHitBoxParam and dict.overrideHitBoxParam or configData.shapeArgs

	local scale = configData.scale or 1

	self.curModelScale = scale
	self.forbiddenTopLogo = not ToBool(self.templateData.isShowTopLogo)
	self.topLogoData.onlyShowAfterHit = self.templateData.isShowTopLogo == Const.TOPLOGO_SHOW_TYPE.AFTER_HIT
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.rawCombatContext = dict.rawCombatContext
	self.masterActorId = dict.masterActorId
	self.isSmoke = ToBool(self.templateData.isSmoke)

	if self.isSmoke then
		pg.me.smokeEntityCnt = (pg.me.smokeEntityCnt or 0) + 1
	end

	if dict.createPropNotifyMasterAbilityEvent ~= nil then
		self.notifyMasterAbilityEvent = dict.createPropNotifyMasterAbilityEvent
	else
		self.notifyMasterAbilityEvent = self.templateData.notifyMasterAbilityEvent
	end

	if self.updateHitBoxParam then
		self:updateHitBoxParam()
	end

	if (self.templateId == 104514 or self.templateId == 104516) and self.setLodTickEnable then
		self:setLodTickEnable(Const.LOD_TICK_KEY.GAME_PLAY, false)
	end

	return true
end

function ClientCreation:postInit(dict)
	ClientCreation.super.postInit(self, dict)

	if self.templateData.noColliderAndInvincible then
		return
	end

	local scale = self.curModelScale

	if self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			self.shapeArgs[1] * scale,
			self.shapeArgs[1] / 2 * scale,
			self.shapeArgs[1] / 2 * scale
		})

		self.lxShape = LxGeometry.LxCircle3D(self:getPosition(), 0, self.shapeArgs[1] * scale, self.shapeArgs[1] / 2 * scale, self.shapeArgs[1] / 2 * scale)
	elseif self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_BOX then
		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_BOX, 3, {
			self.shapeArgs[1] / 2 * scale,
			self.shapeArgs[2] / 2 * scale,
			self.shapeArgs[3] / 2 * scale
		})

		self.lxShape = LxGeometry.LxBox(self:getPosition(), 0, Vector3(self.shapeArgs[1] or 0, self.shapeArgs[2] or 0, self.shapeArgs[3] or 0) * scale)
	else
		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			1,
			0.5,
			0.5
		})

		self.lxShape = LxGeometry.LxCircle3D(self:getPosition(), 0, 1, 0.5, 0.5)
		self.canBeHit = false
	end

	self.aoi:setIsMultiHitBox(false)
end

function ClientCreation:postInitializeComponents()
	ClientCreation.super.postInitializeComponents(self)
	self:inheritMasterRTPC()
end

function ClientCreation:start()
	ClientCreation.super.start(self)

	local template = CreationData[self.templateId]
	local pos = self:getPosition():Clone()

	if template.heightAboveGround then
		local succ, groundHeight = PhysicsUtils.getGroundHeight(pos, 2, self.eModel.rigidbody)

		if succ then
			pos.y = pos.y + template.heightAboveGround - groundHeight

			self:setPosRot(pos, self.rotation)
		end
	elseif ToBool(template.isOnGround) then
		pos = PhysicsUtils.getGroundPos(pos, 4, self.eModel.rigidbody, ToBool(template.isOnWater))

		self:setPosRot(pos, self.rotation)
	elseif ToBool(template.isOnWater) then
		pos = PhysicsUtils.getWaterPos(pos, 4, self.eModel.rigidbody)

		self:setPosRot(pos, self.rotation)
	end

	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, self.curModelScale)
end

function ClientCreation:onEnterSpace()
	ClientPawnEntity.onEnterSpace(self)

	if self.timelineId and self.timelineCombatContextId then
		local combatContext = self.rawCombatContext
		local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

		combatActionTimelineParam.combatContextId = self.timelineCombatContextId
		combatActionTimelineParam.srcActorId = combatContext and combatContext.constCasterInfo.actorId or self.actorId
		combatActionTimelineParam.srcAbilityId = combatContext and combatContext.abilityId or 0
		combatActionTimelineParam.srcAbilityStoreType = combatContext and combatContext.abilityStoreType
		combatActionTimelineParam.constCasterInfo = CombatCasterInfo(self.actorId)
		combatActionTimelineParam.constCasterInfo.srcActorId = combatContext and combatContext.constCasterInfo.srcActorId or self.actorId
		combatActionTimelineParam.srcType = AbilityConst.SRC_TYPE_CREATION
		combatActionTimelineParam.srcCreation = self
		combatActionTimelineParam.castingCombatContextId = combatContext and combatContext.castingCombatContextId

		local isTimelineAccepted = self.actorTimeline:setTimeline(self.timelineId, 1, combatActionTimelineParam, AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL)

		if not isTimelineAccepted then
			pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)
		end

		if isTimelineAccepted and self.timelineStartTime then
			local timeline = self.actorTimeline:getTimelineInstance(self.timelineId)

			if timeline then
				local deltaSeconds = math.max(0, Time.secondCache - self.timelineStartTime)

				timeline:tick(deltaSeconds)
			end
		end
	end
end

function ClientCreation:adjustPosAndRot()
	local template = CreationData[self.templateId]
	local pos = self:getPosition():Clone()
	local rot = self:getRotation():Clone()

	if template.heightAboveGround then
		pos = self:getPosition():Clone()

		local succ, groundHeight = PhysicsUtils.getGroundHeight(pos)

		if succ then
			pos.y = pos.y + template.heightAboveGround - groundHeight
		end
	end

	if template.riseFromGround then
		-- block empty
	end

	self:setPosRot(pos, rot)
end

function ClientCreation:getMasterEntity()
	if self.masterActorId then
		return pg.getEntityByActorId(self.masterActorId)
	end
end

function ClientCreation:destroyEntity(fromChem)
	if fromChem then
		self:serverMsg("RPC_CS_DoDeathByECS")
	end
end

function ClientCreation:destroy()
	if NotNil(self.ecsPhysxComp) then
		PhysxComponent.RemoveTrigger(self.ecsPhysxComp)

		self.ecsPhysxComp = nil
	end

	ClientCreation.super.destroy(self)

	if self.isSmoke then
		pg.me.smokeEntityCnt = (pg.me.smokeEntityCnt or 0) - 1
	end
end

function ClientCreation:getShapeType()
	return self.shapeType
end

function ClientCreation:getShape()
	self.lxShape.center = self:getPosition():Clone()

	if self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
		self.lxShape.center.y = self.lxShape.center.y + self.lxShape.radius / 2
	elseif self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_BOX then
		self.lxShape.center.y = self.lxShape.center.y + self.lxShape.extents.y
	end

	self.rot = Quaternion.ToYaw(self:getRotation())

	return self.lxShape
end

function ClientCreation:getTemplateData()
	return CreationData[self.templateId] or {}
end

function ClientCreation:canBeLocked()
	local configData = self:getConfigData()

	if not ToBool(configData.canBeLocked) then
		return false
	end

	return true
end

function ClientCreation:isCreationColliderTrigger()
	local isTrigger = true

	if self.templateData.isTrigger ~= nil then
		isTrigger = ToBool(self.templateData.isTrigger)
	end

	return isTrigger
end

function ClientCreation:genCreationCollider()
	if self.templateData.noColliderAndInvincible then
		return
	end

	if not self.eModel then
		return
	end

	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)

	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[self.templateData.shapeKind or ""]
	local shapeArgs = self.templateData.shapeArgs
	local isTrigger = self:isCreationColliderTrigger()

	if shapeKind and shapeArgs then
		if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_BOX then
			self.eModel:GenBox(Const.COMPONENT_IDX_PHYSX, Vector3(0, ToBool(self.templateData.colliderCenterByRoot) and 0 or shapeArgs[2] / 2, 0), Vector3(shapeArgs[1], shapeArgs[2], shapeArgs[3]), isTrigger)
		elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			self.eModel:GenSphere(Const.COMPONENT_IDX_PHYSX, Vector3(0, ToBool(self.templateData.colliderCenterByRoot) and 0 or shapeArgs[1], 0), shapeArgs[1], isTrigger)
		end

		if self.templateData.ecsType and self.templateData.ecsPower then
			if NotNil(self.ecsPhysxComp) then
				PhysxComponent.RemoveTrigger(self.ecsPhysxComp)

				self.ecsPhysxComp = nil
			end

			if isTrigger then
				EcsElement.AddEcsElement(self.actorId, self.templateData.ecsType, 1, self.templateData.ecsPower, self.templateId)
			else
				local newPhysxComponent
				local offsetXYZ = Vector3(0, 0, 0)

				shapeArgs = lume.clone(shapeArgs)

				for k, v in pairs(shapeArgs) do
					shapeArgs[k] = shapeArgs[k] + 0.2
				end

				if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
					if not ToBool(self.templateData.colliderCenterByRoot) then
						offsetXYZ.y = shapeArgs[1] * 0.5
					end

					newPhysxComponent = PhysxComponent.AddSphereTrigger(self.eModel, nil, offsetXYZ, shapeArgs[1])
				elseif shapeKind == "Box" then
					if not ToBool(self.templateData.colliderCenterByRoot) then
						offsetXYZ.y = shapeArgs[2] * 0.5
					end

					newPhysxComponent = PhysxComponent.AddBoxTrigger(self.eModel, nil, offsetXYZ, shapeArgs)
				end

				EcsElement.AddEcsElement(newPhysxComponent.gameObject, self.templateData.ecsType, 1, self.templateData.ecsPower, self.templateId)

				self.ecsPhysxComp = newPhysxComponent
			end
		end
	end
end

function ClientCreation:getConfigData()
	return CreationData[self.templateId] or {}
end

function ClientCreation:on_curHp_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.HEALTH_POINT_CHANGE, self)
	self.eventEmitter:emit(EventConst.TOPLOGO_HEALTH_POINT, oldv, newv)
end

function ClientCreation:RPC_SC_StartWaterPoolBeAbsorbed(duration, waterPoolVanishDuration, delayTime, waterPoolDelayTime, waterPoolDissolveRangeMin, waterPoolDissolveRangeMax, targetActorId, commonMount)
	self.logger:debug("RPC_SC_StartWaterPoolBeAbsorbed", duration, waterPoolVanishDuration, delayTime, waterPoolDelayTime, waterPoolDissolveRangeMin, waterPoolDissolveRangeMax, commonMount)

	if self.eModel then
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if not targetEnt then
			return
		end

		local effectTrans = self:getEffectTransform("Eff_Parmon_10194_Skill_waterPolishing")

		if effectTrans then
			local comp = effectTrans:GetComponent(typeof(CS.FunPlus.WorldX.Effect.WaterAbsorbEffectPlayer))

			if NotNil(comp) and commonMount then
				local mountData = ClientEffectUtils.getBestFitCommonMount(targetEnt, commonMount)
				local bone = mountData.bone or commonMount

				comp:PlayAbsorbEffect(targetEnt.eModel, bone, duration, waterPoolVanishDuration, delayTime, waterPoolDelayTime, waterPoolDissolveRangeMin, waterPoolDissolveRangeMax)
			end
		end
	end
end

function ClientCreation:RPC_SC_CreateStartTimeline(timelineCombatContextId)
	if self.timelineCombatContextId then
		return
	end

	self.timelineCombatContextId = timelineCombatContextId

	if self.actorTimeline:getTimelineInstance(self.timelineId) then
		return
	end

	local combatContext = self.rawCombatContext
	local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

	combatActionTimelineParam.combatContextId = self.timelineCombatContextId
	combatActionTimelineParam.srcActorId = combatContext and combatContext.constCasterInfo.actorId or self.actorId
	combatActionTimelineParam.srcAbilityId = combatContext and combatContext.abilityId or 0
	combatActionTimelineParam.srcAbilityStoreType = combatContext and combatContext.abilityStoreType
	combatActionTimelineParam.castingCombatContextId = combatContext and combatContext.castingCombatContextId
	combatActionTimelineParam.constCasterInfo = CombatCasterInfo(self.actorId)
	combatActionTimelineParam.constCasterInfo.srcActorId = combatContext and combatContext.constCasterInfo.srcActorId or self.actorId
	combatActionTimelineParam.srcType = AbilityConst.SRC_TYPE_CREATION
	combatActionTimelineParam.srcCreation = self

	if not self.actorTimeline:setTimeline(self.timelineId, 1, combatActionTimelineParam, AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL) then
		pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)
	end
end

function ClientCreation:inheritMasterRTPC()
	local entity = self:getMasterEntity()

	if entity then
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, entity:getSoundRTPCValue(AudioConst.RTPC_VOLUME_3P) or 1)
	end
end

return ClientCreation
