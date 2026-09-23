-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientVirtualHomeCar.lua

local Class = require("Core.Framework.Class")
local ClientHomeCarAppearanceComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarAppearanceComponent")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientVirtualHomeCar = Class.Class("ClientVirtualHomeCar", ClientVirtualEntity)
local ClientVirtualHomeCarComponents = {
	ClientModelComponent,
	ClientHomeCarAppearanceComponent
}

Class.AddComponents(ClientVirtualHomeCar, ClientVirtualHomeCarComponents)

function ClientVirtualHomeCar:init(dict)
	self.camera = dict.camera
	self.uiScene = dict.uiScene

	ClientVirtualHomeCar.super.init(self, dict)
end

function ClientVirtualHomeCar:refreshAppearance()
	ClientVirtualHomeCar.super.refreshAppearance(self)
	self:refreshCarAppearance()
end

function ClientVirtualHomeCar:onModelRefreshed()
	self:createHomeCarPet()
	self:setEffetLevelCamera()
	self.eModel.modelModelView:OverrideStaticShadowCaster(false)
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientVirtualHomeCar:createHomeCarPet()
	if self.eModel and self.uiScene then
		local petRoot = self.eModel.transform:FindRecursive("HomeCarPetRoot")

		if petRoot then
			self.uiScene:createPetEnt(petRoot)
		end
	end
end

function ClientVirtualHomeCar:setEffetLevelCamera()
	if self.eModel and self.camera then
		self.eModel.modelView:SetEffectRuntimeCamera(self.camera)
	end
end

return ClientVirtualHomeCar
