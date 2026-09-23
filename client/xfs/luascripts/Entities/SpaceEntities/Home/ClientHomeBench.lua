-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeBench.lua

local Class = require("Core.Framework.Class")
local ClientHomelandComponent = require("Entities.SpaceEntities.Home.ClientHomelandComponent")
local ClientBench = require("Entities.SpaceEntities.VehicleEntities.ClientBench")
local ClientHomeEditorComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientConst = require("Const.ClientConst")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeObjectData = require("Data.home_object_data")
local ClientHomeBench = Class.Class("ClientHomeBench", ClientBench)
local ClientHomeBenchComponents = {
	ClientHomelandComponent,
	ClientEntityEditorComponent,
	ClientHomeEditorComponent
}

Class.AddComponents(ClientHomeBench, ClientHomeBenchComponents)

function ClientHomeBench:postInit(bdict)
	local ret = ClientHomeBench.super.postInit(self, bdict)
	local homeObjectConfig = self.homeTemplateId and HomeObjectData[self.homeTemplateId]

	if homeObjectConfig and homeObjectConfig.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = homeObjectConfig.IndicatorIconHeight
	else
		self.forbiddenTopLogo = true
	end

	return ret
end

function ClientHomeBench:getInteractionListData()
	local interactionListData = ClientHomeBench.super.getInteractionListData(self)
	local interactDistance = self:getHomelandConfigData().interactDistance

	if interactionListData and interactDistance then
		for _, interactionData in ipairs(interactionListData) do
			interactionData.overrideInteractDis = interactDistance
		end
	end

	return interactionListData
end

function ClientHomeBench:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
end

return ClientHomeBench
