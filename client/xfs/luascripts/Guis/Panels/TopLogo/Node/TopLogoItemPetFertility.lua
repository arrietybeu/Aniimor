-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPetFertility.lua

local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoPetFertilityComponent = require("Guis.Panels.TopLogo.Component.TopLogoPetFertilityComponent")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoItemPetFertility = Class.LightClass("TopLogoItemPetFertility", TopLogoItem)

function TopLogoItemPetFertility:ctor(entity)
	TopLogoItemPetFertility.super.ctor(self, entity)
end

function TopLogoItemPetFertility:findObjects()
	self.petFertilityContainer = self:getContainerAndAddRef("petFertilityContainer")
end

function TopLogoItemPetFertility:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.PET_FERTILITY] = TopLogoPetFertilityComponent.new(self.petFertilityContainer, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemPetFertility
