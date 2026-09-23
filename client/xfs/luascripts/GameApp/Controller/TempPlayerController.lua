-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\TempPlayerController.lua

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
local ControllerBase = require("GameApp.Controller.ControllerBase")
local TempPlayerController = Class.LightClass("TempPlayerController", ControllerBase)

function TempPlayerController:ctor(me)
	TempPlayerController.super.ctor(self, me)

	self.pawn = me
end

function TempPlayerController:enter(oldController, inheritMotion)
	local newEnt = self.pawn

	pg.game.camera:setTargetPlayer(newEnt, 0)
	pg.game.camera:onPlayerInit(newEnt)
	newEnt:setControllerMachine()
end

function TempPlayerController:onHandleMove(x, y, z)
	local pawn = self.pawn

	pg.game.controller:setCacheMoveAxis(x, y, z)

	if pawn and pawn.eModel then
		pawn.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, x, y, z)
	end
end

return TempPlayerController
