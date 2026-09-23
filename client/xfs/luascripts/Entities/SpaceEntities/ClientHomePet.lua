-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientHomePet.lua

local class = require("Core.Framework.Class")
local ClientPuppet = require("Entities.SpaceEntities.ClientPuppet")
local ClientHomelandWorkComponent = require("Entities.SpaceEntities.Home.ClientHomelandWorkComponent")
local ClientFloorHeightCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientFloorHeightCheckComponent")
local ClientBeCarryComponent = require("Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent")
local ClientHomePetInteractComponent = require("Entities.SpaceEntities.Home.ClientHomePetInteractComponent")
local ClientHomeCarPetComp = require("Entities.SpaceEntities.CommonComponent.ClientHomeCarPetComp")
local ClientHomelandAIComponent = require("Entities.SpaceEntities.Home.ClientHomelandAIComponent")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientPetAccessoryComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetAccessoryComponent")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientHomePet = class.Class("ClientHomePet", ClientPuppet)
local HomePetComponents = {
	ClientHomelandWorkComponent,
	ClientHomePetInteractComponent,
	ClientFloorHeightCheckComponent,
	ClientPetAccessoryComponent,
	ClientBeCarryComponent,
	ClientHomeCarPetComp,
	ClientHomelandAIComponent
}

class.AddComponents(ClientHomePet, HomePetComponents)

function ClientHomePet:ctor(entityId)
	ClientHomePet.super.ctor(self, entityId)

	self.isHomePet = true
	self.overrideGroundHeight = 0
	self.overrideTopLogoEnterDistance = HomelandConfigData.facilityTopLogoEnterDistance or 15

	self:initInteraction()
end

function ClientHomePet:init(bdict)
	ClientHomePet.super.init(self, bdict)

	local space = pg.space

	self.homeSpace = space
	self.homeEntity = Utils.isHomeland(space.spaceType) and space or HomeLandUtils.getCampCarEntity(self.ownerUid)

	if not self.homeEntity then
		self.logger:error("%s init fail, homeEntity is nil, ownerUid=%s, space=%s", self:repr(), self.ownerUid, space:repr())

		return false
	end

	self.petInfo = self.homeEntity.pets[self.id]
	self.useSimpleTimeScale = true

	return true
end

function ClientHomePet:getHomelandConfigData()
	return {
		petId = self.id
	}
end

function ClientHomePet:getStepHeightUp()
	local configuredStepHeightUp = self:getConfigData().stepHeightUp or 0
	local space = self.homeSpace or self.space or pg and pg.space

	if space and space.demoMode == true then
		return math.max(configuredStepHeightUp, Const.HOMELAND_DEMO_PET_STEP_HEIGHT_UP)
	end

	return configuredStepHeightUp
end

function ClientHomePet:refreshDemoModeStepHeightUp()
	if self.eModel == nil then
		return false
	end

	self.eModel.stepHeightUp = self:getStepHeightUp()

	return true
end

function ClientHomePet:getInteractPriority()
	return InteractionConst.EntInteractPriority.HomePet
end

function ClientHomePet:repr()
	return string.format("ClientHomePet(entityId=%s, actorId=%d)", self.id, self.actorId or 0)
end

function ClientHomePet:initInteraction()
	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomePet:getInteractionListData()
	return self.interactionListData
end

function ClientHomePet:getMasterEntity()
	local ownerId = self.ownerId

	return pg.getEntity(ownerId)
end

function ClientHomePet:getMasterEntityByUid()
	return pg.getEntityByUid(self.ownerUid or 0)
end

function ClientHomePet:getCareerNameFromEnt()
	local master = self:getMasterEntityByUid()

	return master and master.playerName or ""
end

return ClientHomePet
