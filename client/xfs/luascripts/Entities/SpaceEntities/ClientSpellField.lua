-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientSpellField.lua

local Class = require("Core.Framework.Class")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local lume = require("Core.Common.lume")
local AudioConst = require("Const.AudioConst")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local ClientMagicFieldComponent = require("Entities.SpaceEntities.CommonComponent.ClientMagicFieldComponent")
local ClientTrapComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientEntityCacheValComponent = require("Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local EcsElement = CS.FunPlus.WorldX.GameApp.Ecs.EcsElement
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
local SpellFieldComponents = {
	ClientStateCheckComponent,
	ClientAuthorityComponent,
	ClientCombatEntityComponent,
	ClientTimeControlComponent,
	ClientAbilityComponent,
	ClientMagicFieldComponent,
	ClientTrapComponent,
	ClientEntityCacheValComponent
}
local ClientSpellField = Class.Class("ClientSpellField", ClientPawnEntity)

Class.AddComponents(ClientSpellField, SpellFieldComponents)

local ToBool = ToBool
local Quaternion = Quaternion
local Vector3 = Vector3
local NotNil = NotNil

function ClientSpellField:ctor(entityId)
	ClientSpellField.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_SPELLFIELD
end

function ClientSpellField:init(dict)
	ClientSpellField.super.init(self, dict)

	self.timelineId = dict.timelineId
	self.timelineCombatContextId = dict.timelineCombatContextId
	self.castingCombatContextId = dict.castingCombatContextId
	self.timelineStartTime = dict.timelineStartTime

	local scale = dict.scale or 1

	self.curModelScale = scale
	self.masterActorId = dict.masterActorId
	self.srcAbilityId = dict.srcAbilityId
	self.srcAbilityStoreType = dict.srcAbilityStoreType
	self.isOnGround = dict.isOnGround
	self.isOnWater = dict.isOnWater or false
	self.entityCanMove = false

	return true
end

function ClientSpellField:postInitializeComponents()
	ClientSpellField.super.postInitializeComponents(self)
	self:inheritMasterRTPC()
end

function ClientSpellField:start()
	ClientSpellField.super.start(self)
	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, self.curModelScale)
end

function ClientSpellField:onEnterSpace()
	ClientPawnEntity.onEnterSpace(self)

	local pos = self:getPosition():Clone()
	local rotation = self:getRotation()

	if self.isOnGround == nil or self.isOnGround then
		pos = PhysicsUtils.getGroundPos(pos, 4, self.eModel.rigidbody, ToBool(self.isOnWater))

		self:setPosRot(pos, rotation)
	elseif ToBool(self.isOnWater) then
		pos = PhysicsUtils.getWaterPos(pos, 4, self.eModel.rigidbody)

		self:setPosRot(pos, rotation)
	end

	if self.timelineId and self.timelineCombatContextId then
		local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

		combatActionTimelineParam.combatContextId = self.timelineCombatContextId
		combatActionTimelineParam.srcActorId = self.masterActorId or 0
		combatActionTimelineParam.srcAbilityId = self.srcAbilityId or 0
		combatActionTimelineParam.srcAbilityStoreType = self.srcAbilityStoreType or 0
		combatActionTimelineParam.constCasterInfo = CombatCasterInfo(self.masterActorId)
		combatActionTimelineParam.castingCombatContextId = self.castingCombatContextId

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

function ClientSpellField:getMasterEntity()
	if self.masterActorId then
		return pg.getEntityByActorId(self.masterActorId)
	end
end

function ClientSpellField:inheritMasterRTPC()
	local entity = self:getMasterEntity()

	if entity then
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, entity:getSoundRTPCValue(AudioConst.RTPC_VOLUME_3P) or 1)
	end
end

function ClientSpellField:RPC_SC_CreateStartTimeline(timelineCombatContextId)
	if self.timelineCombatContextId then
		return
	end

	self.timelineCombatContextId = timelineCombatContextId

	if self.actorTimeline:getTimelineInstance(self.timelineId) then
		return
	end

	local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

	combatActionTimelineParam.combatContextId = self.timelineCombatContextId
	combatActionTimelineParam.srcActorId = self.masterActorId
	combatActionTimelineParam.srcAbilityId = self.srcAbilityId or 0
	combatActionTimelineParam.srcAbilityStoreType = self.srcAbilityStoreType or 0
	combatActionTimelineParam.constCasterInfo = CombatCasterInfo(self.masterActorId)

	if not self.actorTimeline:setTimeline(self.timelineId, 1, combatActionTimelineParam, AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL) then
		pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)
	end
end

return ClientSpellField
