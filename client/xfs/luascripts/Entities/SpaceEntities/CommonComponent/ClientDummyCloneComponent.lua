-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientDummyCloneComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityConst = require("Common.Const.AbilityConst")
local AiConst = require("Common.Const.AiConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientDummyCloneComponent = Class.Component("ClientDummyCloneComponent")
local pg = pg

function ClientDummyCloneComponent:init(bdict)
	self.isDummyClone = bdict.isDummyClone
	self.masterActorType = bdict.masterActorType
	self.masterTemplateId = bdict.masterTemplateId
	self.enableDummyCloneHitTimeline = bdict.enableDummyCloneHitTimeline

	if self.isDummyClone then
		if self.masterActorType == Const.ACTOR_TYPE_PUPPET then
			self.deformData = PuppetData[self.masterTemplateId]
		elseif self.masterActorType == Const.ACTOR_TYPE_PET then
			self.deformData = PetData[self.masterTemplateId]
		end

		local masterEntity = self:getMasterEntity()

		if masterEntity then
			self.overrideScale = masterEntity.curModelScale
		end
	end

	return true
end

function ClientDummyCloneComponent:start()
	if self.isDummyClone then
		self:setRootMotionScale(0, ClientAbilityConst.ROOT_MOTION_SCALE_KEYS.DUMMY_CLONE)

		self.castAbilityEventToken = pg.global.abilityMgr:genTokenId()

		local masterEntity = self:getMasterEntity()

		if masterEntity then
			masterEntity.subject:add(self.castAbilityEventToken, AbilityConst.COMBAT_EVENT_CAST_ABILITY, function(combatContext)
				if CombatActionTool.isBlockTriggerAbilityEvent(combatContext.abilityId, combatContext.actorId) then
					return
				end

				if self.abilityMap[combatContext.abilityId] then
					local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
					local targetEnt = pg.getEntityByActorId(targetActorId)

					if targetEnt then
						self:faceToEnt(targetEnt, true)
						self:clientCastAbilityOnTarget(combatContext.abilityId, targetActorId)
					else
						self:setRotation(masterEntity:getRotation(), true)
						self:clientCastAbilityNoTarget(combatContext.abilityId)
					end
				end
			end)
		end

		self:pauseBt(AiConst.PauseBtReason.DummyClone)
	end
end

function ClientDummyCloneComponent:preDestroy()
	if self.isDummyClone then
		local masterEntity = self:getMasterEntity()

		if masterEntity and masterEntity.subject and self.castAbilityEventToken then
			masterEntity.subject:remove(self.castAbilityEventToken, AbilityConst.COMBAT_EVENT_CAST_ABILITY)
		end

		if masterEntity and self.eModel and masterEntity.eModel then
			self.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, masterEntity.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX))
		end

		if masterEntity and masterEntity.eModel and self.eModel then
			masterEntity.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, self.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX))
		end
	end
end

function ClientDummyCloneComponent:EVENT_RefreshPhysx()
	if self.isDummyClone then
		local masterEntity = self:getMasterEntity()

		if masterEntity then
			self.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, masterEntity.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX))
			masterEntity.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, self.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX))
		end
	end
end

return ClientDummyCloneComponent
