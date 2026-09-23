-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientDandelion.lua

local class = require("Core.Framework.Class")
local ClientVehicle = require("Entities.SpaceEntities.VehicleEntities.ClientVehicle")
local InteractionConst = require("Common.Const.InteractionConst")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local EffectConst = require("Const.EffectConst")
local ClientDandelion = class.Class("ClientDandelion", ClientVehicle)
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local RouteController = require("GameApp.Controller.RouteController")
local DandelionController = require("GameApp.Controller.DandelionController")
local VehicleInteractUtils = require("Entities.SpaceEntities.VehicleEntities.VehicleInteractUtils")
local Components = {}

class.AddComponents(ClientDandelion, Components)

function ClientDandelion:ctor(entityId)
	ClientDandelion.super.ctor(self, entityId)
end

function ClientDandelion:init(bdict)
	ClientDandelion.super.init(self, bdict)
	self:setIsKinematic(true, ClientConst.IsKinematicKey.Dandelion)

	local vehicleData = self:getVehicleConfig()
	local playInteractIds = VehicleInteractUtils.toInteractIdList(vehicleData.playInteractId)

	self.playInteractData = {
		actionPrototypeId = playInteractIds[1],
		overrideType = InteractionConst.INTERACTION_TYPE_QUICK_PHOTO,
		globalId = self:getGlobalId(),
		interactFunc = function()
			self:doSkill1()
		end
	}

	return true
end

function ClientDandelion:onDoSkill1()
	self:serverMsg("RPC_CS_RequestDestroy")
end

function ClientDandelion:getControllerData()
	local data = ClientDandelion.super.getControllerData(self)

	data.warningDuration = self:getVehicleConfig().rideDuration - self:getVehicleConfig().warningDuration

	return data
end

function ClientDandelion:onEnterControl()
	ClientDandelion.super.onEnterControl(self)
	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.playInteractData)
	pg.global.ui.tips:refreshHotKeyHint(true)
end

function ClientDandelion:onExitControl()
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.playInteractData)
	pg.global.ui.tips:refreshHotKeyHint(true)
	ClientDandelion.super.onExitControl(self)
end

function ClientDandelion:isConfigKinematic()
	local controllerCls = self:getVehicleConfig().controllerCls

	if controllerCls == "DandelionController" then
		return false
	end

	return true
end

function ClientDandelion:getActorController(player)
	local controllerCls = self:getVehicleConfig().controllerCls

	if controllerCls == "RouteController" then
		return RouteController.new(player, self)
	else
		return DandelionController.new(player, self)
	end
end

function ClientDandelion:onTriggerEnter(userData, entId)
	ClientDandelion.super.onTriggerEnter(self, userData)

	local ent = pg.getEntity(entId)

	if Utils.isVehicle(ent) then
		if ent == self then
			return
		end

		if self.entityMap[pg.me.actorId] then
			pg.me:dismountVehicle(self.actorId)
			pg.me:mountVehicle(ent.actorId, (ent:getClosestSeat(pg.me)))
		end
	else
		self:tryMount(ent)
	end
end

function ClientDandelion:destroy()
	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.playInteractData)
	pg.global.ui.tips:refreshHotKeyHint(true)
	ClientDandelion.super.destroy(self)
end

return ClientDandelion
