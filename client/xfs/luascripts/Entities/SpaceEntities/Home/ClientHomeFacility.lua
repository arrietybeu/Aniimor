-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeFacility.lua

local Class = require("Core.Framework.Class")
local ClientHomeEntity = require("Entities.SpaceEntities.Home.ClientHomeEntity")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local HomeObjectData = require("Data.home_object_data")
local ClientHomeProduceComponent = require("Entities.SpaceEntities.Home.ClientHomeProduceComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientHomeLevelUpComponent = require("Entities.SpaceEntities.Home.ClientHomeLevelUpComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local HomelandConfigData = require("Data.homeland_config_data")
local TopLogoItemHomeObject = require("Guis.Panels.TopLogo.Node.TopLogoItemHomeObject")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local InteractData = require("Data.interact_data")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientHomeFacility = Class.Class("ClientHomeFacility", ClientHomeEntity)
local ClientHomeFacilityComponents = {
	ClientHomeProduceComponent,
	ClientHomeLevelUpComponent
}

Class.AddComponents(ClientHomeFacility, ClientHomeFacilityComponents)

function ClientHomeFacility:ctor(entityId)
	ClientHomeFacility.super.ctor(self, entityId)

	self.overrideTopLogoEnterDistance = HomelandConfigData.facilityTopLogoEnterDistance or 10
	self.topLogoType = ClientConst.TopLogoType.HomeFacility
end

function ClientHomeFacility:init(dict)
	ClientHomeFacility.super.init(self, dict)

	self.forbiddenTopLogo = false

	return true
end

function ClientHomeFacility:checkEnableRendererBatch()
	if Utils.isClientHomeTrash(self) then
		return ClientUtils.checkEnableRendererBatch()
	end

	return false
end

function ClientHomeFacility:destroy()
	ClientHomeFacility.super.destroy(self)

	if self._destroyShadowPosition and self._destroyShadowBounds then
		pg.game.home:refreshOrnamentShadow(self._destroyShadowPosition, self._destroyShadowBounds)

		self._destroyShadowPosition = nil
		self._destroyShadowBounds = nil
	end
end

function ClientHomeFacility:preDestroy()
	self._destroyShadowBounds = self:getBoundSize()
	self._destroyShadowPosition = self:getPositionClone()

	ClientHomeFacility.super.preDestroy(self)
end

return ClientHomeFacility
