-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRobSpaceEgg.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local InteractionConst = require("Common.Const.InteractionConst")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientConst = require("Const.ClientConst")
local CollectItemData = require("Data.collect_item_data")
local EggRandomModelIdData = require("Data.egg_random_model_id_data")
local EggIdToModelResData = require("Data.egg_id_to_model_res_data")
local RigidbodyData = require("Data.rigidbody_data")
local InteractData = require("Data.interact_data")
local SysConfigData = require("Data.sys_config_data")
local ConflictTypes = require("Common.ConflictTypes")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local lume = require("Core.Common.lume")
local ListPool = require("Common.Container.ListPool")
local AddressDataConst = require("Const.AddressDataConst")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientRobSpaceEgg = class.Class("ClientRobSpaceEgg", ClientInteractor)
local RobSpaceEggComponents = {
	ClientAttachComponent,
	ClientPhysicsComponent,
	ClientStateCheckComponent,
	ClientVoxelComponent,
	ClientPrefabModelComponent
}

class.AddComponents(ClientRobSpaceEgg, RobSpaceEggComponents)

function ClientRobSpaceEgg:ctor(entityId)
	ClientRobSpaceEgg.super.ctor(self, entityId)

	self.isRobSpaceEgg = true
	self.entityCanMove = true
	self.isPhysxPlayer = true
	self.isClientEnt = false
end

function ClientRobSpaceEgg:init(bdict)
	ClientRobSpaceEgg.super.init(self, bdict)

	local randomCfgData = EggRandomModelIdData[self.templateId]

	self.subType = bdict.subType
	self.bodyMass = randomCfgData.weight or 30
	self.bodyDrag = randomCfgData.drag or 0.2
	self.carryEggType = randomCfgData.carryEggType or self.subType
	self.bodySize = 0.5
	self.bodyHeight = 1
	self.patternType = bdict.patternType
	self.patternColorType = bdict.patternColorType
	self.modelDataInfo = self.patternType and EggIdToModelResData[self.patternType]

	local cdd = self:getConfigData()

	self.attachId = cdd.attachId or 11021
	self.effect = cdd.effect
	self.bornPreset = cdd.PresetName

	if self.subType == Const.ROB_EGG_TYPE.SMALL then
		self.pickInteractionData = {
			{
				actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.PICK_SEGG,
				interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
				globalId = self:getGlobalId(),
				name = cdd.name or "",
				interactFunc = function()
					self:pick(pg.me)
				end
			}
		}
	end

	local carryEggActionId = self.subType == Const.ROB_EGG_TYPE.SMALL and ItemConst.ROB_EGG_INTERACT_TYPE.CARRY_SEGG or ItemConst.ROB_EGG_INTERACT_TYPE.CARRY_BEGG
	local controlEggActionId = self.subType == Const.ROB_EGG_TYPE.SUPER_BIG and ItemConst.ROB_EGG_INTERACT_TYPE.CONTROL_HUGE_EGG or ItemConst.ROB_EGG_INTERACT_TYPE.CONTROL_EGG

	if not InteractData[controlEggActionId] then
		controlEggActionId = ItemConst.ROB_EGG_INTERACT_TYPE.CONTROL_EGG
	end

	self.controlInteractionData = {
		{
			actionPrototypeId = controlEggActionId,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = cdd.name or "",
			interactFunc = function()
				self:tryControlEgg(pg.me)
			end
		}
	}
	self.carryInteractionData = {
		{
			actionPrototypeId = carryEggActionId,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = cdd.name or "",
			interactFunc = function()
				self:move(pg.me)
			end
		}
	}
	self.dropInteractionData = {
		{
			actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.DROP,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = cdd.name or "",
			interactFunc = function()
				self:drop(pg.me)
			end
		}
	}

	return true
end

function ClientRobSpaceEgg:getConfigData()
	if not self.templateId then
		return {}
	end

	return CollectItemData[self.templateId] or {}
end

function ClientRobSpaceEgg:getBasicControlInfo()
	local randomCfgData = EggRandomModelIdData[self.templateId]
	local defaultMoveForce = 600
	local defaultMaxVelocity = 3.7
	local defaultDashImpulseRatio = 10
	local defaultMaxAngularVelocity = 10

	if self.subType == Const.ROB_EGG_TYPE.SUPER_BIG then
		defaultMoveForce = 500
		defaultMaxVelocity = 2
		defaultDashImpulseRatio = 13
	end

	local moveForce = randomCfgData and randomCfgData.moveForce or defaultMoveForce
	local maxVelocity = randomCfgData and randomCfgData.maxVelocity or defaultMaxVelocity
	local dashImpulseRatio = randomCfgData and randomCfgData.dashImpulseRatio or defaultDashImpulseRatio
	local maxAngularVelocity = randomCfgData and randomCfgData.maxAngularVelocity or defaultMaxAngularVelocity
	local maxVelocityInAir = randomCfgData and randomCfgData.maxVelocityInAir or 4.2
	local accelerationDuration = randomCfgData and randomCfgData.accelerationDuration or 3
	local decelerationDuration = randomCfgData and randomCfgData.decelerationDuration or 0.6
	local endOverEndSpeedRatio = randomCfgData and randomCfgData.endOverEndSpeedRatio or 0.2

	return {
		moveForce,
		maxVelocity,
		dashImpulseRatio,
		maxAngularVelocity,
		maxVelocityInAir,
		accelerationDuration,
		decelerationDuration,
		endOverEndSpeedRatio
	}
end

function ClientRobSpaceEgg:getOverrideDistanceInfo()
	local randomCfgData = EggRandomModelIdData[self.templateId]
	local modelScale = randomCfgData and randomCfgData.modelScale or 1
	local minDistance = modelScale * 0.5

	if minDistance < 1 then
		minDistance = 1
	end

	local baseDistance = 5

	return baseDistance, minDistance
end

function ClientRobSpaceEgg:isConfigKinematic()
	if self.subType == Const.ROB_EGG_TYPE.SUPER_BIG then
		return self.neverControlled
	end

	return false
end

function ClientRobSpaceEgg:getDetectionMode()
	return 3
end

function ClientRobSpaceEgg:getRewardItemId()
	local configData = self:getConfigData()

	return configData.reward
end

function ClientRobSpaceEgg:getInteractionListData()
	local player = pg.me

	if not player then
		return nil
	end

	if player.enableDebugCarryEgg then
		return self.carryInteractionData
	end

	local isBeControlled = self:isBeControlled()

	if self.subType == Const.ROB_EGG_TYPE.SMALL and not isBeControlled and player:checkRobEggBagCanInstallEgg() then
		return self.pickInteractionData
	elseif not isBeControlled then
		return self.controlInteractionData
	elseif self.controller ~= player.id then
		return self.carryInteractionData
	end
end

function ClientRobSpaceEgg:checkCanInteract(unit)
	if pg.me:isControllingEgg() then
		return false
	end

	if not string.isNilOrEmpty(pg.me.carryEggEntId) then
		return false
	end

	if not string.isNilOrEmpty(self.moveUser) then
		return false
	end

	return true
end

function ClientRobSpaceEgg:refreshModel(configData, extraData)
	local modelRes = self.modelDataInfo and self.modelDataInfo.model

	if modelRes then
		self.eModel.itemModelView.forceColliderLayer = ClientConst.LayerDefine.LAYER_NOACROSS

		self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, modelRes)
	end
end

function ClientRobSpaceEgg:onPrefabModelLoaded()
	local randomCfgData = EggRandomModelIdData[self.templateId]
	local modelScale = randomCfgData and randomCfgData.modelScale
	local modelView = self.eModel.itemModelView

	if modelScale then
		modelView:SetModelScale(modelScale)
		self:onSyncScale(modelScale)
	end

	if not self.effectId and self.effect then
		self.effectId = self:playEffect(self.effect)
	end

	ClientModelUtils.applyEggModelMaterialEffect(self, modelView, randomCfgData, self.patternColorType)

	if self.bornPreset then
		for _, presetName in pairs(self.bornPreset) do
			ClientEffectUtils.PlayPreset(self, presetName, -1, false)
		end
	end

	self:onModelRefreshed()

	self.eModel.modelView.firstLoaded = true

	self:genRobEggCollider()
	self:applyCrackEffect(self.crackLevel)
end

function ClientRobSpaceEgg:onEnterSpace()
	ClientRobSpaceEgg.super.onEnterSpace(self)
end

function ClientRobSpaceEgg:refreshFootPrintVisible()
	return
end

function ClientRobSpaceEgg:refreshEffectAfterModelLoaded()
	if self.subType ~= Const.ROB_EGG_TYPE.SUPER_BIG then
		return
	end

	local needShowEffect = pg.space.checkNeedShowSpaceEggEffect and pg.space:checkNeedShowSpaceEggEffect()

	if not needShowEffect then
		return
	end

	self:playPerformRecorder(AddressDataConst.GRAB_EGG_SPACE_EGG_EFFECT, Vector3.constZero, false, function(recorder)
		recorder:ApplyArchiveByName("Archive_1")

		self.pfRecorder = recorder
	end)
end

function ClientRobSpaceEgg:endEffect()
	if self.subType ~= Const.ROB_EGG_TYPE.SUPER_BIG then
		return
	end

	if self.pfRecorder then
		self.pfRecorder:ApplyArchiveByName("Archive_2")
	end
end

function ClientRobSpaceEgg:pick(serverProxy)
	if self.subType > Const.ROB_EGG_TYPE.SMALL then
		return
	end

	if self:isBeControlled() then
		return
	end

	serverProxy:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.PICK)
	self:refreshInteractTriggerEvent()
end

function ClientRobSpaceEgg:tryControlEgg(serverProxy)
	if not serverProxy then
		return
	end

	if not serverProxy:checkStatus(ConflictTypes.CT_PICK_UP_EGG) then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return
	end

	serverProxy:serverMsg("RPC_CS_ControlEgg", self.actorId, function(ret)
		if ret then
			self:refreshInteractTriggerEvent()
		else
			pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)
		end
	end)
end

function ClientRobSpaceEgg:move(serverProxy)
	if not serverProxy then
		return
	end

	if not serverProxy:checkCanChangeModelBeforeInteract() then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return
	end

	if not serverProxy:checkStatus(ConflictTypes.CT_PICK_UP_EGG) then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return
	end

	serverProxy:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.MOVE, function(ret, reason)
		if not ret then
			if reason then
				pg.global.showBubbleMessage(reason)
			end
		elseif pg.me then
			pg.me.carryEggEntId = self.id

			if self.eModel then
				self.eModel.itemModelView:SetForceColliderLayer(ClientConst.LayerDefine.LAYER_NO_COLLISION)
			end

			if pg.me.eModel then
				pg.me.eModel.carrayItemInt = self.carryEggType
			end

			pg.me:registerCarryEggAnimEvent(self, self.attachId)
			self:refreshInteractTriggerEvent()
		end
	end)
end

function ClientRobSpaceEgg:drop(serverProxy)
	if not serverProxy then
		return
	end

	serverProxy:exitCarryEgg()
end

function ClientRobSpaceEgg:RPC_SC_RobEggForceSetPosition(posX, posY, posZ)
	if not self.eModel then
		return
	end

	self:forceSetPosEx(posX, posY, posZ, true)
end

function ClientRobSpaceEgg:beAttached()
	self:clearAttachingTimer()

	self.attachingTimer = self:addRepeatTimer(1, function()
		local attachTargetEnt = self.attachTargetEntId ~= nil and pg.getEntity(self.attachTargetEntId) or nil

		if not attachTargetEnt then
			return
		end

		local closestPlayerList = ListPool.getList(1)
		local cnt = self:entitiesInRangeWithTable(100, Const.SEARCH_USR_TYPE_PLAYER, 8, closestPlayerList)
		local closestDistanceSqr = 99999

		for i = 1, cnt do
			if closestPlayerList[i] ~= attachTargetEnt.actorId then
				local closestPlayer = pg.getEntityByActorId(closestPlayerList[i])

				if closestPlayer then
					local curDistanceSqr = Vector3.SqrDistance(self:getPosition(), closestPlayer:getPosition())

					if curDistanceSqr < closestDistanceSqr then
						closestDistanceSqr = curDistanceSqr
					end
				end
			end
		end

		local level = 0

		level = closestDistanceSqr > 10000 and 0 or closestDistanceSqr > 2500 and 3 or closestDistanceSqr > 400 and 2 or 1

		if level == 1 then
			self.eModel:PlayShakeEggModel(Const.COMPONENT_IDX_ITEM, 0.7, Const.ROB_EGG_SHAKE_AMPLITUDE_LIGHT, 10, 90, false)
		elseif level == 2 then
			self.eModel:PlayShakeEggModel(Const.COMPONENT_IDX_ITEM, 0.7, Const.ROB_EGG_SHAKE_AMPLITUDE_HEAVY, 10, 90, false)
		elseif level == 3 then
			self.eModel:PlayShakeEggModel(Const.COMPONENT_IDX_ITEM, 0.7, Const.ROB_EGG_SHAKE_AMPLITUDE_HEAVY, 30, 90, false)
		end

		ListPool.returnList(closestPlayerList, 1)
	end)
end

function ClientRobSpaceEgg:beDetached()
	self:clearAttachingTimer()
end

function ClientRobSpaceEgg:onAttachTargetIdChanged(oldv, newv)
	if not self:isBeControlled() then
		return
	end

	if not pg.me or self.controller ~= pg.me.id then
		return
	end

	if not string.isNilOrEmpty(newv) then
		local carrier = pg.getEntity(newv)
		local carrierActorId = carrier and carrier.actorId or nil

		pg.me:onControlledEggBeCarried(carrierActorId)
	else
		pg.me:onControlledEggBeDropped()
	end
end

function ClientRobSpaceEgg:isBeControlled()
	return ToBool(self.controller)
end

function ClientRobSpaceEgg:isBeCarried()
	return not string.isNilOrEmpty(self.attachTargetId)
end

function ClientRobSpaceEgg:getMasterEntity()
	return pg.getEntity(self.controller)
end

function ClientRobSpaceEgg:getHitPosition()
	local radius, height, center = self:getEggPhysxData()
	local centerHeight = center.y or 0

	return self:getPosition() + self:getRotation():MulVec3(Vector3(0, centerHeight, 0))
end

function ClientRobSpaceEgg:getLockPosition()
	local radius, height, center = self:getEggPhysxData()
	local centerHeight = center.y or 0

	return self:getPosition() + self:getRotation():MulVec3(Vector3(0, centerHeight, 0))
end

function ClientRobSpaceEgg:getInteractPos(dist, interactEnt)
	local entPos = self:getHitPosition()
	local dir = Vector3.one
	local playerPos = interactEnt:getPosition()
	local xzPosOffset = playerPos - entPos

	xzPosOffset.y = 0

	if xzPosOffset:Magnitude() < 0.0001 then
		dir = self:getForward()
	else
		dir = Vector3.Normalize(xzPosOffset)
	end

	local radius, height, center = self:getEggPhysxData()
	local minDist = math.max(radius, center.y) + (interactEnt and interactEnt.bodySize or 0) + 0.1

	if dist then
		minDist = math.max(dist, minDist)
	end

	return entPos + dir * minDist
end

function ClientRobSpaceEgg:getCameraHeightInfo()
	local radius, height, center = self:getEggPhysxData()

	return center.y, height * 0.5 + radius, height * 0.5
end

function ClientRobSpaceEgg:getOverrideInteractLocalOffset()
	local radius, height, center = self:getEggPhysxData()

	return Vector3(0, center.y, 0)
end

function ClientRobSpaceEgg:getEggPhysxData()
	local rigidbodyData = RigidbodyData.GrabEGG_Egg

	if not rigidbodyData then
		return
	end

	local center = Vector3.New()

	if rigidbodyData.center == nil then
		center = Vector3.New(0, rigidbodyData.height * 0.5, 0)
	else
		center:Copy(rigidbodyData.center)
	end

	local randomCfgData = EggRandomModelIdData[self.templateId]
	local modelScale = randomCfgData and randomCfgData.modelScale or 1
	local radius = ToBool(rigidbodyData.radius) and rigidbodyData.radius or 0.1

	radius = radius * modelScale

	local height = ToBool(rigidbodyData.height) and rigidbodyData.height or 0.1

	height = height * modelScale

	local isTrigger = ToBool(rigidbodyData.trigger)

	center.y = center.y * modelScale

	return radius, height, center, isTrigger
end

function ClientRobSpaceEgg:getEggMaxHp()
	local eggMaxHpMap = SysConfigData.GRABEGG_egg_form_hp

	return eggMaxHpMap and eggMaxHpMap[self.subType] or 100
end

function ClientRobSpaceEgg:getEggHp()
	return self.eggHp or 0
end

function ClientRobSpaceEgg:genRobEggCollider()
	if not self.eModel then
		return
	end

	local radius, height, center, isTrigger = self:getEggPhysxData()

	if radius and self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		self.eModel:GenCapsule(Const.COMPONENT_IDX_PHYSX, radius, height, center, isTrigger, not isTrigger, true)

		local randomCfgData = EggRandomModelIdData[self.templateId]
		local waterDrag = randomCfgData.waterDrag or 5
		local waterAngularDrag = randomCfgData.waterAngularDrag or 5

		self.eModel:EnableSimpleBuoyance(Const.COMPONENT_IDX_PHYSX, waterDrag, waterAngularDrag)
	end

	if ToBool(self.controller) and self.controller == pg.me.id then
		self:addEModelComponent(Const.COMPONENT_PHYSIC_CONTROLLER)
		self.eModel:SetupController(Const.COMPONENT_PHYSIC_CONTROLLER, pg.me.eModel, 0)
	end
end

function ClientRobSpaceEgg:isCurrentPlayableHasTag()
	return false
end

function ClientRobSpaceEgg:clearAttachingTimer()
	if self.attachingTimer ~= nil then
		self:removeTimer(self.attachingTimer)

		self.attachingTimer = nil
	end
end

function ClientRobSpaceEgg:onEnterScene()
	ClientRobSpaceEgg.super.onEnterScene(self)
end

function ClientRobSpaceEgg:onLeaveScene()
	ClientRobSpaceEgg.super.onLeaveScene(self)
end

function ClientRobSpaceEgg:preDestroy()
	self:playBreakEffect()

	if self.effectId then
		self:stopEffectById(self.effectId)

		self.effectId = nil
	end

	if self.attachTargetEntId ~= nil then
		local ent = pg.getEntity(self.attachTargetEntId)

		if self.eModel then
			self:detach()
		else
			self.attachTargetEntId = nil
		end

		if ent and ent.exitCarryEgg then
			ent:exitCarryEgg(true)
		end
	end

	self:clearAttachingTimer()
	ClientRobSpaceEgg.super.preDestroy(self)
end

function ClientRobSpaceEgg:receiveFallToGroundDamage(height)
	if self:isBeCarried() then
		return
	end

	local controller = pg.getEntity(self.controller)

	if controller and Utils.isPlayer(controller) then
		if self.space and self.space:checkImmuneFallDamage() then
			return
		end

		local curCombatPet = controller.petPrepareList[1] and pg.getEntity(controller.petPrepareList[1])

		if curCombatPet then
			curCombatPet:serverMsg("RPC_CS_SpecialDamage", 0 --[[SPDMG0]], Const.LIFE_DEAD_BY_FALL_TO_GROUND)
		end

		self:reportEggHurt(self:calcEggFallHurtTimes(height), Const.LIFE_DEAD_BY_FALL_TO_GROUND)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:info(string.format("@hyj onReceiveFallToGroundDamage: height = %f, dmgPercent = %f, eggDmg = %f", height, Utils.calcFallToGroundDamage(height), self:calcEggFallHurtTimes(height)))
		end
	end
end

function ClientRobSpaceEgg:receiveImpactDamage(velocity)
	if not self:isBeControlled() then
		return
	end

	if self:isBeCarried() then
		return
	end

	local dmg = self:calcEggImpactHurtTimes(velocity)

	if dmg > 0 then
		self:reportEggHurt(dmg, Const.LIFE_DEAD_BY_FALL_TO_GROUND)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:info(string.format("@hyj onReceiveImpactDamage: velocity = %f, eggDmg = %f", velocity, dmg))
		end
	end
end

function ClientRobSpaceEgg:calcEggFallHurtTimes(height)
	local fallDmgHeightRange = SysConfigData.GRABEGG_egg_form_height_range
	local fallDmgMap = SysConfigData.GRABEGG_egg_form_height_dmg
	local dmg = 0

	if fallDmgHeightRange and fallDmgMap then
		for i = #fallDmgHeightRange, 1, -1 do
			if height > fallDmgHeightRange[i] then
				dmg = fallDmgMap[i] or 0

				break
			end
		end
	end

	return dmg
end

function ClientRobSpaceEgg:calcEggImpactHurtTimes(velocity)
	local impactDmgSpeedRange = SysConfigData.GRABEGG_egg_form_speed_range
	local impactDmgMap = SysConfigData.GRABEGG_egg_form_speed_dmg
	local dmg = 0

	if impactDmgSpeedRange and impactDmgMap then
		for i = #impactDmgSpeedRange, 1, -1 do
			if velocity > impactDmgSpeedRange[i] then
				dmg = impactDmgMap[i] or 0

				break
			end
		end
	end

	return dmg
end

function ClientRobSpaceEgg:reportEggHurt(times, reason)
	if not times or times <= 0 then
		return
	end

	if not pg.me or self.controller ~= pg.me.id then
		return
	end

	pg.me:serverMsg("RPC_CS_RobEggHurt", self.id, times, reason)
end

function ClientRobSpaceEgg:canBeLocked()
	return self:isBeControlled() and self:getMasterEntity() ~= pg.me
end

function ClientRobSpaceEgg:onControllerChange(ov, nv)
	self.isInControl = ToBool(nv)

	self:refreshInteractTriggerEvent()

	if pg.game.grabEgg then
		pg.game.grabEgg:refreshEggDynamicMark(self.id)
	end

	if self.checkTopLogoRobEggControlled then
		self:checkTopLogoRobEggControlled()
	end
end

function ClientRobSpaceEgg.cancelSuperBigEggMapTrack()
	if not pg.space or not pg.space.sceneId then
		return
	end

	local cData = RobEggBaseData[pg.space.sceneId]
	local staticId = cData and cData.maxEggMarkId

	if not staticId then
		return
	end

	local minimap = pg.global.ui.hudV2 and pg.global.ui.hudV2.LU and pg.global.ui.hudV2.LU.minimapV2

	minimap = minimap or pg.game.map.GetMiniMapUI and pg.game.map:GetMiniMapUI()

	if minimap and minimap.deleteTrackMark then
		minimap:deleteTrackMark(staticId)
	end
end

function ClientRobSpaceEgg:onNeverControlledChange(ov, nv)
	self:refreshPhysicsState()
end

function ClientRobSpaceEgg:onCrackLevelChange(ov, nv)
	self:applyCrackEffect(nv)
end

function ClientRobSpaceEgg:applyCrackEffect(level)
	if self.crackEffectId then
		self:stopEffectById(self.crackEffectId)

		self.crackEffectId = nil
	end

	if not level or level <= 0 then
		return
	end

	local randomCfgData = EggRandomModelIdData[self.templateId]
	local modelScale = randomCfgData and randomCfgData.modelScale or 1

	if level == 1 then
		self.crackEffectId = self:playEffect("Eff_Env_GrabEggBattle_EggDestory_BreakSmall01")
	elseif level == 2 then
		self.crackEffectId = self:playEffect("Eff_Env_GrabEggBattle_EggDestory_BreakSmall02")
	elseif level == 3 then
		self.crackEffectId = self:playEffect("Eff_Env_GrabEggBattle_EggDestory_BreakSmall03")
	end
end

function ClientRobSpaceEgg:playBreakEffect()
	if self.subType == Const.ROB_EGG_TYPE.SMALL then
		pg.game.effect:playEffectAt(0, "Eff_Env_GrabEggBattle_EggDestory_DestroySmall", self:getPosition(), self:getRotation():ToEulerAngles(), self)
	else
		pg.game.effect:playEffectAt(0, "Eff_Env_GrabEggBattle_EggDestory_DestroysmallBig", self:getPosition(), self:getRotation():ToEulerAngles(), self)
	end
end

function ClientRobSpaceEgg:getMapMarkPosition()
	return self:getHitPosition()
end

function ClientRobSpaceEgg:onThornsCollision(normal, isSpike, impulseId)
	local master = self:getMasterEntity()

	if master and master.onThornsCollision then
		return master:onThornsCollision(normal, isSpike, impulseId)
	end
end

return ClientRobSpaceEgg
