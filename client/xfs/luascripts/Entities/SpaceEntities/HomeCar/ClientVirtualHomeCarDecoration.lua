-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientVirtualHomeCarDecoration.lua

local Class = require("Core.Framework.Class")
local ClientHomeCarAppearanceComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarAppearanceComponent")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientVirtualHomeCarDecoration = Class.Class("ClientVirtualHomeCarDecoration", ClientVirtualEntity)
local ClientVirtualHomeCarDecorationComponents = {
	ClientModelComponent,
	ClientHomeCarAppearanceComponent
}

Class.AddComponents(ClientVirtualHomeCarDecoration, ClientVirtualHomeCarDecorationComponents)

function ClientVirtualHomeCarDecoration:init(dict)
	self.camera = dict.camera

	ClientVirtualHomeCarDecoration.super.init(self, dict)
end

function ClientVirtualHomeCarDecoration:refreshAppearance()
	ClientVirtualHomeCarDecoration.super.refreshAppearance(self)
	self:refreshCarDecorationAppearance()
end

function ClientVirtualHomeCarDecoration:onModelRefreshed()
	self:setEffetLevelCamera()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientVirtualHomeCarDecoration:setEffetLevelCamera()
	if self.eModel and self.camera then
		self.eModel.modelView:SetEffectRuntimeCamera(self.camera)
	end
end

return ClientVirtualHomeCarDecoration
