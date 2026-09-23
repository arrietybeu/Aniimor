-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeFacilityHatchBox.lua

local Class = require("Core.Framework.Class")
local ClientHomeEntity = require("Entities.SpaceEntities.Home.ClientHomeEntity")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientHomeFacility = require("Entities.SpaceEntities.Home.ClientHomeFacility")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientHomeFacilityHatchBoxComponent = require("Entities.SpaceEntities.Home.ClientHomeFacilityHatchBoxComponent")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local TopLogoItemHatchBox = require("Guis.Panels.TopLogo.Node.TopLogoItemHatchBox")
local InteractData = require("Data.interact_data")
local SysConfigData = require("Data.sys_config_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientHomeFacilityHatchBox = Class.Class("ClientHomeFacilityHatchBox", ClientHomeFacility)
local Components = {
	ClientHomeFacilityHatchBoxComponent
}

Class.AddComponents(ClientHomeFacilityHatchBox, Components)

function ClientHomeFacilityHatchBox:ctor(entityId)
	ClientHomeFacilityHatchBox.super.ctor(self, entityId)

	self.topLogoType = ClientConst.TopLogoType.HomeFacilityHatchBox
	self.overrideTopLogoEnterDistance = HomelandConfigData.facilityTopLogoEnterDistance or 10
end

function ClientHomeFacilityHatchBox:init(dict)
	ClientHomeFacilityHatchBox.super.init(self, dict)

	return true
end

function ClientHomeFacilityHatchBox:destroy()
	ClientHomeFacilityHatchBox.super.destroy(self)
end

function ClientHomeFacilityHatchBox:getInteractionListData()
	self:parseInteractionName(self.interactionListData or {})

	return self.interactionListData or {}
end

function ClientHomeFacilityHatchBox:getTopLogoHeight()
	local superHeight = ClientHomeFacilityHatchBox.super.getTopLogoHeight(self)

	return superHeight + (HomelandConfigData.hatchBoxTopLogoHeightOffset or 0)
end

return ClientHomeFacilityHatchBox
