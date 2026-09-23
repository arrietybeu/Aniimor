-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\PlayerController.lua

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
local pg = pg
local PawnController = require("GameApp.Controller.PawnController")
local PlayerController = Class.LightClass("PlayerController", PawnController)

function PlayerController:ctor(me)
	PlayerController.super.ctor(self, me)

	self.me = me
end

function PlayerController:onHandleThrow()
	if not self:checkPawn() then
		return
	end

	if not self.me:isInCatchMode() then
		return
	end

	self.me:captureThrow()
end

function PlayerController:onHandleContinuousThrow(isStart)
	if not isStart then
		if self.me and self.me.setContinuousCaptureThrow then
			self.me:setContinuousCaptureThrow(false)
		end

		return
	end

	if not self:checkPawn() then
		return
	end

	if not self.me:isInCatchMode() then
		return
	end

	local continuousStarted

	if self.me.setContinuousCaptureThrow then
		continuousStarted = self.me:setContinuousCaptureThrow(true)
	end

	if continuousStarted ~= false then
		self.me:captureThrow()
	end
end

function PlayerController:onHandleSwitchProp()
	if not self:checkPawn() then
		return
	end

	self.me:switchProp()
	pg.game.camera.playerCameraMode.catchCamera:onBallChanged()
end

return PlayerController
