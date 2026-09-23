-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\BenchController.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ControllerBase = require("GameApp.Controller.ControllerBase")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local InputCommand = require("GameApp.Input.InputCommand")
local TimerManager = require("Core.Timer.TimerManager")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local PlayableConst = require("Common.Const.PlayableConst")
local pg = pg
local BenchController = Class.LightClass("BenchController", ControllerBase)

function BenchController:ctor(pawn, vehicle)
	self.pawn = pawn
	self.vehicle = vehicle
	self.controllerData = self.vehicle:getVehicleConfig().controllerData or {}
end

function BenchController:enter()
	return
end

function BenchController:isVehicle()
	return
end

function BenchController:exit()
	return
end

function BenchController:checkPawn()
	return self.pawn and not self.pawn.isDestroyed and self.pawn.eModel ~= nil
end

function BenchController:onHandleMove(x, y, z)
	if x == 0 and y == 0 then
		return
	end

	if self.vehicle:getVehicleConfig().moveLeave then
		self.me:dismountVehicle(self.vehicle.actorId)
	end
end

return BenchController
