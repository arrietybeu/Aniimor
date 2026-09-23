-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientTempPlayer.lua

local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local GlobalData = require("Core.Client.GlobalData")
local EntityFactory = require("Core.Common.EntityFactory")
local TimerManager = require("Core.Timer.TimerManager")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local AttributeConst = require("Common.Const.AttributeConst")
local EventBus = require("Common.Ability.Buff.EventBus")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local EModelUtils = require("Entities.Utils.EModelUtils")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local PropertyData = require("Data.property_data")
local ActorInterface = require("Common.Ability.Attribute.ActorInterface")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local PetData = require("Data.pet_data")
local ClientTempPlayer = class.Class("ClientTempPlayer", ClientPawnEntity)
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ActorCombatAttribute = require("Common.Ability.Attribute.ActorCombatAttribute")
local CharacterController = require("Common.Components.CharacterController")
local ClientDyingComponent = require("Entities.SpaceEntities.CommonComponent.ClientDyingComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local PlayerComponents = {
	CharacterController,
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientDyingComponent,
	ClientMotionComponent
}

class.AddComponents(ClientTempPlayer, PlayerComponents)

function ClientTempPlayer:initializeComponents()
	ClientTempPlayer.super.initializeComponents(self)
	self:addEModelComponent(Const.COMPONENT_INDEX_MAIN_PLAYER)
	self:addEModelComponent(Const.COMPONENT_MOTION)
	self:addEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	self:addEModelComponent(Const.COMPONENT_MAGNESIS_CONTROLLER)
end

function ClientTempPlayer:postInit(dict)
	ClientTempPlayer.super.postInit(self, dict)
end

function ClientTempPlayer:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.MAIN_PLAYER
end

function ClientTempPlayer:getEModelResId()
	return AddressDataConst.Ent_MainPlayer
end

function ClientTempPlayer:onEnterScene()
	ClientTempPlayer.super.onEnterScene(self)
	self:postComponentMethod("EVENT_RefreshPhysx")
end

function ClientTempPlayer:setControllerMachine()
	self.eModel:SetControllerMachine(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, ClientModelUtils.getAnimController(self.templateData))
end

function ClientTempPlayer:isInCombat()
	return false
end

local function checkStatus(self, event, showMsg, exclude, noCancel)
	return true
end

local function ABILITY_ST(self)
	return false
end

local function getEntityIdByStaticId(self, staticId)
	return nil
end

function ClientTempPlayer:start()
	ClientTempPlayer.super.start(self)

	self.ABILITY_ST = ABILITY_ST
	self.actorType = Const.ACTOR_TYPE_PLAYER
	self.buffImmuneTag = 0
	self.buffTag = 0
	self.guidanceCurs = {}
	self.checkStatus = checkStatus
	self.bodyMass = SysConfigData.avatarMass
	self.bodyWeight = SysConfigData.avatarWeight or 6
	self.authority = Const.AUTHORITY_MASTER
	self.subject = EventBus.EventSubject(self.actorId)
	self.baseAttr = {}
	self.teamInfo = {
		membersInfo = {}
	}
	self.timeScale = 1

	for i = 1, AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN - 1 do
		self.baseAttr[i] = 0
	end

	local templateData = self:getTemplateData()
	local propData = PropertyData[templateData.propId]

	self.actorCombatAttribute = ActorCombatAttribute(ActorInterface(self), pg.global.abilityMgr.actorAttributeModifier)

	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_max_cur, propData.stamina_max_v or 0)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_cur, propData.stamina_max_v or 0)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_regen_v, propData.stamina_regen_v or 0)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_regen_p, propData.stamina_regen_p or 0)

	self.maxStamina = propData.stamina_max_v
end

function ClientTempPlayer:getWeather()
	return 0
end

function ClientTempPlayer:getCurPetEntity()
	return nil
end

function ClientTempPlayer:isDead()
	return false
end

function ClientTempPlayer:isControllingPet()
	return false
end

function ClientTempPlayer:canRotate()
	return false
end

function ClientTempPlayer:inBreak()
	return false
end

function ClientTempPlayer:canMove()
	return true
end

function ClientTempPlayer:isControllingMaster()
	return true
end

function ClientTempPlayer:isControllingExploreEnt()
	return false
end

function ClientTempPlayer:getPetInfo(petId)
	return petId
end

function ClientTempPlayer:getSpecificAbilityPetId(abilityId)
	return tostring(abilityId)
end

function ClientTempPlayer:getTemplateData()
	return self.templateData
end

function ClientTempPlayer:getConfigData()
	if self.deformData or self.deformContext and self.deformContext.templateId then
		self.deformData = self.deformData or PetData[self.deformContext.templateId]

		return self.deformData
	end

	return self.templateData
end

function ClientTempPlayer:addStatData(data)
	return
end

function ClientTempPlayer:getStamina()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.stamina_cur)
end

function ClientTempPlayer:getGameTime()
	return 0
end

function ClientTempPlayer:isInCatchMode()
	return false
end

function ClientTempPlayer:cancelAbility()
	return
end

function ClientTempPlayer:getEntityIdByStaticId()
	return nil
end

function ClientTempPlayer:isAbilityEdgeBlocking()
	return false
end

function ClientTempPlayer:isAlive()
	return true
end

function ClientTempPlayer:tryClientTrigger(triggerType, triggerId, count, triggerParams)
	return
end

function ClientTempPlayer:tryClientTriggerAll(triggerType, count, triggerParams)
	return
end

function ClientTempPlayer:refreshModel(configData, extraData)
	local entityId = self.lastPawnId
	local pawn = pg.getEntity(entityId)

	if pawn ~= nil and pawn:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		local other = pawn:getEModelComponent(Const.COMPONENT_INDEX_MODEL)

		if NotNil(other) then
			self.eModel:SeizeModel(Const.COMPONENT_INDEX_MODEL, other)
		end
	end
end

function ClientTempPlayer:onLoseControlled()
	return
end

function ClientTempPlayer:testCreate()
	local EntityFactory = require("Core.Common.EntityFactory")
	local SafeCallback = require("Core.Framework.SafeCallback")
	local player = EntityFactory.createEntity("ClientTempPlayer", "10000")
	local position = pg.playerPos
	local rotation = pg.playerRot
	local id = pg.pawn.templateId
	local templateData = pg.pawn:getTemplateData()

	player.templateData = templateData
	player.spaceId = 1

	local function initFun()
		player:init({
			yaw = 0,
			buffTag = 0,
			__Properties__ = {
				actorId = VirtualEntUtils.getNewVirtualEntActorId(),
				templateId = id
			},
			position = position
		})
		player:postInit({})
		player:start()
		player:setInScene(true)
	end

	SafeCallback(initFun)
	EModelUtils.setAgentPositionAndRotation(player, position, rotation)
	pg.game.controller:controlTempPlayer(player)

	return player
end

function ClientTempPlayer:testReplace(player)
	pg.me:_destroyClientEntity(pg.me.id)
	pg.game.controller:controlTempPlayer(player)
end

function ClientTempPlayer:test()
	pg.game.seamless:seam_sys_setSwitchState(true)

	local ClientUtils = require("Utils.ClientUtils")

	ClientUtils.safeDestroy(pg.me)
end

return ClientTempPlayer
