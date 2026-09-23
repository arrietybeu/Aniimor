-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientVehicle.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local Utils = require("Common.Utils.Utils")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local BenchController = require("GameApp.Controller.BenchController")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local vehicle_seat_attach_data = require("Data.vehicle_seat_attach_data")
local vehicle_data = require("Data.vehicle_data")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientSeatComponent = require("Entities.SpaceEntities.CommonComponent.ClientSeatComponent")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientVehicleBodyAnimationComponent = require("Entities.SpaceEntities.VehicleEntities.ClientVehicleBodyAnimationComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local SysConfigData = require("Data.sys_config_data")
local RouteController = require("GameApp.Controller.RouteController")
local DandelionController = require("GameApp.Controller.DandelionController")
local SkateboardVehicleController = require("GameApp.Controller.SkateboardVehicleController")
local ClientVehicle = class.Class("ClientVehicle", ClientModelEntity)
local Components = {
	ClientActorComponent,
	ClientPrefabModelComponent,
	ClientTopLogoComponent,
	ClientInteractionComponent,
	ClientEffectComponent,
	ClientPhysicsComponent,
	ClientAuthorityComponent,
	ClientSeatComponent,
	ClientVehicleBodyAnimationComponent,
	ClientEcsComponent
}

if EnableBotTest then
	Components = {
		ClientActorComponent,
		ClientPhysicsComponent,
		ClientEffectComponent,
		ClientSeatComponent
	}
end

class.AddComponents(ClientVehicle, Components)

function ClientVehicle:ctor(entityId)
	ClientVehicle.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VEHICLE
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.isClientEnt = false
end

function ClientVehicle:isSkateboardVehicleControllerCls(controllerCls)
	return controllerCls == "SkateboardVehicleController" or controllerCls == "SkateboardController"
end

function ClientVehicle:init(bdict)
	local ret = ClientVehicle.super.init(self, bdict)

	if self:isSkateboardVehicleControllerCls(self:getVehicleConfig().controllerCls) then
		self:setIsKinematic(true, ClientConst.IsKinematicKey.SkateboardVehicle)
	end

	return ret
end

function ClientVehicle:postInit(bdict)
	ClientVehicle.super.postInit(self, bdict)

	self.routeId = bdict.routeId

	local vehicleConfig = self:getVehicleConfig()

	if vehicleConfig.forbiddenTopLogo == false and vehicleConfig.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = SysConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = vehicleConfig.IndicatorIconHeight
	else
		self.forbiddenTopLogo = true
	end

	return true
end

function ClientVehicle:getConfigData()
	return self:getVehicleConfig()
end

function ClientVehicle:refreshAppearance()
	ClientVehicle.super.refreshAppearance(self)

	local cfg = self:getVehicleConfig()

	self:loadPrefabModel(cfg.resId)
end

function ClientVehicle:onPrefabModelLoaded()
	return
end

function ClientVehicle:registerFeatureVehicle(featureVehicle)
	self.featureVehicle = featureVehicle
end

function ClientVehicle:getControllerData()
	return Utils.deepCopyTable(self:getVehicleConfig().controllerData or {})
end

function ClientVehicle:isConfigKinematic()
	if self:isSkateboardVehicleControllerCls(self:getVehicleConfig().controllerCls) then
		return false
	end

	return ClientVehicle.super.isConfigKinematic(self)
end

function ClientVehicle:getActorController(player)
	local controllerCls = self:getVehicleConfig().controllerCls

	if self:isSkateboardVehicleControllerCls(controllerCls) then
		return SkateboardVehicleController.new(player, self)
	elseif controllerCls == "RouteController" then
		return DandelionController.new(player, self)
	elseif controllerCls == "RideVehicleController" then
		return RouteController.new(player, self)
	else
		return BenchController.new(player, self)
	end
end

function ClientVehicle:onEntityMount(entity, seatId)
	if not self.featureVehicle then
		return
	end

	self.featureVehicle:OnMount(entity.actorId)
end

function ClientVehicle:onEntityDismount(entity, seatId)
	if not self.featureVehicle then
		return
	end

	self.featureVehicle:OnDismount()
end

function ClientVehicle:onVehicleMountLoopEntered(passenger, sessionId)
	self:postComponentMethod("EVENT_OnVehiclePassengerEnterFinished", passenger, sessionId)
end

function ClientVehicle:onVehicleMountExitFinished(passenger, sessionId)
	self:postComponentMethod("EVENT_OnVehiclePassengerExitFinished", passenger, sessionId)
end

function ClientVehicle:onVehicleMoveStateChanged(isMoving)
	if self.setVehicleBodyMoving then
		self:setVehicleBodyMoving(isMoving == true)
	end
end

function ClientVehicle:onEnterControl()
	return
end

function ClientVehicle:onExitControl()
	return
end

function ClientVehicle:onDoSkill1()
	return
end

function ClientVehicle:onDoSkill2()
	return
end

function ClientVehicle:onTriggerBreak(entId)
	return
end

function ClientVehicle:getInteractionListData()
	return self:getSeatInteractionList()
end

function ClientVehicle:destroyEntity(reason, delay)
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.DESTROYING, true, false)
	pg.me:reliableServerSpaceMsg("RPC_CS_DestroyVehicleByEcs", {
		self.actorId,
		delay or 0,
		reason or 0
	})
end

function ClientVehicle:preDestroy()
	self:playDestroyEffect()
	ClientVehicle.super.preDestroy(self)
end

function ClientVehicle:canDirectMountRideVehicle()
	self:getVehicleConfig()

	return false
end

return ClientVehicle
