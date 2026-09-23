-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientEcsComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CommonConst = require("Common.Const.Const")
local class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local ECSConst = require("Common.Const.ECSConst")
local NoticeDef = require("Common.NoticeDef")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ElementBuffData = require("Data.element_buff_data")
local Time = require("Core.Common.Time")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Const.Const")
local ClientEcsComponent = class.Component("ClientEcsComponent")

function ClientEcsComponent:ctor()
	self.ecsAmountCache = {}
	self.ecsBuffLayerCache = {
		[0] = 0,
		0,
		0,
		0,
		0
	}
	self.ecsAmountNotifyOwners = {}
end

function ClientEcsComponent:init(dict)
	pg.game.ecs:registerSyncObject(dict.ecsSyncObject)
end

function ClientEcsComponent:EVENT_PostInitialized()
	if not self.eModel then
		return
	end

	self.eModel.spawnIceHeightCorrection = SysConfigData.spawnIceHeightCorrection
end

function ClientEcsComponent:EVENT_AddEComponent()
	if not self.eModel then
		return
	end

	self:addEModelComponent(CommonConst.COMPONENT_CHEM_MATERIAL)
end

function ClientEcsComponent:onEnterSpace()
	self:_initChemMaterials()
end

function ClientEcsComponent:onLeaveSpace()
	if not self.eModel then
		return
	end

	self.eModel:ClearMain(CommonConst.COMPONENT_ECS, self.delayDestroyReason or 0)
end

function ClientEcsComponent:_initChemMaterials()
	if Utils.isStaticNpc(self) then
		return
	end

	local cfg = self:getConfigData()

	if cfg.ecsBodyMaterialId and self.eModel and not Utils.isNpc(self) then
		self:addEModelComponent(CommonConst.COMPONENT_ECS)
		self.eModel:InitECSBody(CommonConst.COMPONENT_ECS, self:getConfigData().ecsBodyMaterialId, cfg.initEcsState or 0, cfg.initEcsElements or {})

		local elePerLayer = AbilitySettingGlobalConstData.elementValuePerLayer
		local ecsMgr = appFacade.ecsMgr

		for element = 0, 4 do
			ecsMgr:SetSectionAmountPerLayer(self.ecsId, element, elePerLayer)
			self:_updateEcsDecayRate(element, 0)
		end
	end
end

function ClientEcsComponent:resetMaterialByRevive()
	return
end

function ClientEcsComponent:isChemStateActive(stateName, state)
	if not ECSConst.AI_STATE_CONVERTER[stateName] then
		return false
	end

	if self.ecsShare == nil then
		return false
	end

	return bit.band(state or self.ecsShare.state, ECSConst.AI_STATE_CONVERTER[stateName]) ~= 0
end

function ClientEcsComponent:isChemAbilityActive(stateName)
	if not ECSConst.AI_ABILITY_CONVERTER[stateName] then
		return false
	end

	if self.ecsShare == nil then
		return false
	end

	return bit.band(self.ecsShare.ability, ECSConst.AI_ABILITY_CONVERTER[stateName]) ~= 0
end

function ClientEcsComponent:setEcsId(ecsId)
	self.ecsId = ecsId

	if pg.space then
		self.ecsShare = pg.game.ecs:getEcsShares(ecsId)
	else
		self.ecsShare = {
			ability = 0,
			state = 0
		}
	end
end

function ClientEcsComponent:destroy()
	self.ecsShare = nil
end

function ClientEcsComponent:castIce(abilityId, pos, rot, shapeKind, shapeArgs)
	if not self.eModel then
		return
	end

	self.eModel:CastIce(CommonConst.COMPONENT_CHEM_MATERIAL, abilityId, SysConfigData.floatIceCreateInterval, pos, rot, shapeKind, shapeArgs)
end

function ClientEcsComponent:spawnIce(position, rot)
	local iceTemplateId = SysConfigData.IceTemplated

	pg.game.envObj:createServerEntAt(iceTemplateId, position, rot)
end

function ClientEcsComponent:onEcsStateChange()
	local state

	state = not self.ecsShare and 0 or self.ecsShare.state

	if self.lastEcsState ~= state then
		self:postComponentMethod("EVENT_OnEcsStateChange", state)
		pg.game.ecs:onEcsStateChange(self, self.lastEcsState or 0, state)

		self.lastEcsState = state
	end
end

function ClientEcsComponent:onReceiveImpulse(impulse, reachThreshold)
	if reachThreshold then
		self:postComponentMethod("EVENT_OnReachImpulseThreshold", impulse)
		self:serverMsg("RPC_CS_OnReachImpulseThreshold")
	end

	if self.ShiningItemFeature then
		self.ShiningItemFeature:onReceiveImpulse(impulse, reachThreshold)
	end
end

function ClientEcsComponent:_updateEcsDecayRate(element, layer)
	local filter = self:getConfigData().ecsBuffDecayFilter

	for i, v in ipairs(filter or EMPTY_TABLE) do
		if v == element then
			return
		end
	end

	local decayList = AbilitySettingGlobalConstData.elementValue
	local decayRate = 0

	for i, v in ipairs(decayList) do
		if layer < v[1] then
			break
		end

		decayRate = v[2]
	end

	appFacade.ecsMgr:OverrideDecayRate(self.ecsId, element, decayRate)
end

function ClientEcsComponent:onEcsBuffCountChange(element, layer)
	self.ecsBuffLayerCache = self.ecsBuffLayerCache or {}

	local previousLayer = self.ecsBuffLayerCache[element] or 0

	self.ecsBuffLayerCache[element] = layer

	if self.isMainAuthority and previousLayer ~= layer then
		local ecsSkillSrcActorId = pg.game.ecs:getSkillCasterByElement(self, element)

		pg.game.ecs:queueBuffCountChange(self.actorId, element, layer, ecsSkillSrcActorId)
	end

	self:_updateEcsDecayRate(element, layer)
end

function ClientEcsComponent:onEcsAmountChange(maxElementType, maxValue)
	self.ecsAmountCache.maxElementType = maxElementType
	self.ecsAmountCache.maxValue = maxValue

	if Utils.isPlayer(self) then
		-- block empty
	else
		facade:SendMessageCommand(MessageName.ECS_MAX_AMOUNT_CHANGE, self)
		self.eventEmitter:emit(EventConst.ECS_MAX_AMOUNT_CHANGE, self)
	end
end

function ClientEcsComponent:RPC_SC_ApplyECSElement(elementType, value, part)
	if not self.eModel then
		return
	end

	self.eModel:ApplyElement(CommonConst.COMPONENT_ECS, elementType, value, part)
end

function ClientEcsComponent:canBreakByImpulse(impulse)
	return appFacade.ecsMgr:CanBreakByImpulse(self.ecsId, impulse)
end

function ClientEcsComponent:EVENT_onModelLoaded()
	local mode = self.getDetectionMode and self:getDetectionMode()

	if mode and self.eModel then
		self.eModel:SetCollisionDetectionMode(Const.COMPONENT_IDX_PHYSX, mode)
	end
end

local AbilityUtils = require("Common.Utils.AbilityUtils")
local TriggerConst = require("Common.Const.TriggerConst")

function ClientEcsComponent:onEcsSkillHit(ret, abilityId, elementType, srcActorId)
	if ret == 2 then
		pg.global.showBubbleMessage(NoticeDef.ECS_ADD_ELEMENT_FAILED)
	elseif elementType < 5 then
		pg.pawn.eventEmitter:emit(EventConst.CAST_CHEM_SKILL_ON_TARGET, self:getGlobalId(), abilityId)
	end

	if ToBool(srcActorId) then
		local srcEntity = pg.getEntityByActorId(srcActorId)
		local srcPet = AbilityUtils.getPet(srcEntity)

		if srcPet and Utils.isChest(self) and srcPet:getConfigData().petPrototypeId and ToBool(abilityId) then
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_CHEST_REACH_IMPULSE_THRESHOLD, srcPet:getConfigData().baseFormPet, 1, AbilityUtils.getAbilityParamId(abilityId))
		end
	end

	pg.game.ecs:onEcsSkillHit(self, ret, abilityId, elementType, srcActorId)
end

function ClientEcsComponent:enableNotifyEcsAmount(value, owner)
	owner = owner or ECSConst.ECS_AMOUNT_NOTIFY_OWNER.LEGACY
	self.ecsAmountNotifyOwners = self.ecsAmountNotifyOwners or {}

	if value then
		self.ecsAmountNotifyOwners[owner] = true
	else
		self.ecsAmountNotifyOwners[owner] = nil
	end

	self:applyEcsAmountNotify()
end

function ClientEcsComponent:onInConstraintWind(inConstraintWind)
	local ent = self

	if Utils.isPet(self) then
		ent = self.master
	end

	ent.inConstraintWind = inConstraintWind

	facade:SendMessageCommand(MessageName.HIGH_GRASS_STATE_CHANGE)
end

function ClientEcsComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.GLIDING) then
		facade:sendMsgToUI(MessageName.HIGH_GRASS_STATE_CHANGE)
	elseif CharacterStateConst.isChildOfState(newState, CharacterStateConst.GLIDING) then
		facade:sendMsgToUI(MessageName.HIGH_GRASS_STATE_CHANGE)
	end
end

function ClientEcsComponent:onPetSummon()
	self.eModel:WakeUp(CommonConst.COMPONENT_ECS)
end

function ClientEcsComponent:EVENT_BeControlled()
	self.eModel:WakeUp(CommonConst.COMPONENT_ECS)
end

function ClientEcsComponent:RPC_SC_ClearElement(elementType, layer)
	appFacade.ecsMgr:ReduceElementBuff(self.ecsId, elementType, layer)
end

function ClientEcsComponent:ecsFilterCamp(otherActor)
	if Utils.isPlayer(self) or Utils.isPet(self) then
		local target = pg.getEntityByActorId(otherActor)

		return not Utils.isPartner(self, target)
	end

	return true
end

function ClientEcsComponent:triggerExplode()
	if not self.ecsId then
		return false
	end

	return appFacade.ecsMgr:TriggerExplode(self.ecsId)
end

function ClientEcsComponent:applyEcsAmountNotify()
	local enabled = self.ecsAmountNotifyOwners and next(self.ecsAmountNotifyOwners) ~= nil or false

	if self.eModel and self.eModel.enableNotifyEcsAmount ~= enabled then
		self.eModel.enableNotifyEcsAmount = enabled
	end
end

return ClientEcsComponent
