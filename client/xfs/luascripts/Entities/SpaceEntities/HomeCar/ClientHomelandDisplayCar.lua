-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomelandDisplayCar.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientHomeCarAppearanceComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarAppearanceComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientHomelandDisplayCar = Class.Class("ClientHomelandDisplayCar", ClientModelEntity)
local ClientHomelandDisplayCarComponents = {
	ClientAoiComponent,
	ClientModelComponent,
	ClientHomeCarAppearanceComponent
}

Class.AddComponents(ClientHomelandDisplayCar, ClientHomelandDisplayCarComponents)

function ClientHomelandDisplayCar:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = Const.ACTOR_TYPE_HOME_OBJECT
	self.clenUsrType = Const.CLEN_USE_TYPE_HOME
	self.forbiddenTopLogo = true

	ClientHomelandDisplayCar.super.init(self, dict)

	return true
end

function ClientHomelandDisplayCar:setBasicInfo(basicInfo)
	self.basicInfo = basicInfo

	self:setShapeInfo(basicInfo, true)
end

function ClientHomelandDisplayCar:refreshAppearance()
	ClientHomelandDisplayCar.super.refreshAppearance(self)
	self:refreshCarAppearance()
end

function ClientHomelandDisplayCar:onModelRefreshed()
	self.isModelLoaded = true

	self:openHomeCarDoor()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientHomelandDisplayCar:openHomeCarDoor()
	if self.eModel then
		self.eModel.modelView:SetModelPartRotation(Quaternion.Euler(0, -90, 0), "HomeCarDoor")
	end
end

return ClientHomelandDisplayCar
