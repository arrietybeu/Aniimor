-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\RouteController.lua

local Class = require("Core.Framework.Class")
local BenchController = require("GameApp.Controller.BenchController")
local pg = pg
local RouteController = Class.LightClass("RouteController", BenchController)
local GlobalData = require("Core.Client.GlobalData")
local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")

function RouteController:ctor(pawn, vehicle)
	RouteController.super.ctor(self, pawn, vehicle)
end

function RouteController:enter()
	local sceneRouteData = SceneUtils.getSceneRouteData(GlobalData.Space.sceneId, GlobalData.Space.id)

	self.routeData = sceneRouteData[self.vehicle.routeId] or {}
	self.index = 1

	self.vehicle.featureVehicle:SetController(self)

	self.mountDelay = self.controllerData.mountDelay or 0

	if self.mountDelay > 0 then
		self.mountDelayTimer = TimerManager.addTimer(self.mountDelay, function()
			if self.exited then
				return
			end

			self:onReachEnd()
		end)
	else
		self:onReachEnd()
	end
end

function RouteController:onReachEnd()
	local wayPoints = self.routeData.wayPoints or {}
	local wayPoint = wayPoints[self.index]

	if not wayPoint then
		self.vehicle:onVehicleMoveStateChanged(false)

		if self.controllerData.reachEndExit then
			self.vehicle:serverMsg("RPC_CS_RequestDestroy")
		end

		return
	end

	local featureVehicle = self.vehicle.featureVehicle

	if not featureVehicle then
		return
	end

	self.vehicle:onVehicleMoveStateChanged(true)
	featureVehicle:Move(wayPoint.position)

	self.index = self.index + 1
end

function RouteController:exit()
	if self.mountDelayTimer then
		TimerManager.removeTimer(self.mountDelayTimer)

		self.mountDelayTimer = nil
	end

	self.vehicle:onVehicleMoveStateChanged(false)
end

return RouteController
