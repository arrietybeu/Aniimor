-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPetAccessoryComponent.lua

local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientPetAccessoryComponent = Class.Component("ClientPetAccessoryComponent")

function ClientPetAccessoryComponent:start()
	return
end

function ClientPetAccessoryComponent:on_petJewelryInfo_Changed(old, new)
	self:reloadAccessory()
end

function ClientPetAccessoryComponent:Event_BeforeRefreshModels(modelView)
	self:applyPetAccesses(modelView)
end

function ClientPetAccessoryComponent:EVENT_IsInControlChange()
	self:reloadAccessory()
	self:refreshFootPrintVisible()
end

function ClientPetAccessoryComponent:EVENT_MergedFormPeripheralStateChange()
	self:reloadAccessory()
	self:refreshFootPrintVisible()
end

function ClientPetAccessoryComponent:Event_AfterRefreshModels(modelView)
	self:refreshFootPrintVisible()
end

function ClientPetAccessoryComponent:reloadAccessory()
	if not self.eModel then
		return
	end

	local modelView = self.eModel.modelModelView

	self:applyPetAccesses(modelView)
	ClientModelUtils.refreshModels(self, modelView)
end

function ClientPetAccessoryComponent:setTempJewelryInfo(jewelryInfo)
	self.tempJewelryInfo = jewelryInfo

	self:reloadAccessory()
end

function ClientPetAccessoryComponent:applyPetAccesses(modelView)
	modelView:InitAttachModel()
	modelView.modelInfo:RemoveAllAttach()

	self.appearanceEffectInfo = {}

	local height = 1.2

	if self.getPetHeight then
		height = self:getPetHeight()
	elseif self.getHeight then
		height = self:getHeight()
	end

	self.adjustHeight = height * 1.2

	if self.tempJewelryInfo then
		ClientModelUtils.showPetTempAccesses(self)
	else
		ClientModelUtils.showPetAccesses(self)
	end

	ClientModelUtils.addMergedFormPeripheralAttachments(self, modelView.modelInfo)
end

return ClientPetAccessoryComponent
