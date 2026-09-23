-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\TrapBallContext.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local AddressDataConst = require("Const.AddressDataConst")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local TrapBallContext = Class.LightClass("TrapBallContext", ThrowBallContext)

function TrapBallContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)
end

function TrapBallContext:enter()
	self.player.eModel.ThrowAnimType = self.ballData.animType
	self.player.eModel.AlwaysLookForward = true

	self.player:addEModelComponent(CommonConst.COMPONENT_CATCH)
	self.player.eModel:LoadPointer(CommonConst.COMPONENT_CATCH, AddressDataConst.TRAP_BALL_POINTER)
	self:enableCatchMode(true)
	ThrowBallContext.enter(self)
	self.fsm:clear()
	pg.global.ui.hudV2:switchAimVisible(false)
end

function TrapBallContext:exit()
	self:exitCatchMode()

	return true
end

function TrapBallContext:throw()
	local info = self.player.eModel:GetTrapPointerInfo(CommonConst.COMPONENT_CATCH)

	if not info.valid then
		return
	end

	self:doThrow()
end

function TrapBallContext:throwEnd(breaked)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)
end

function TrapBallContext:switch()
	self:doSwitch()
end

function TrapBallContext:doThrow()
	ThrowBallContext.doThrow(self)
end

function TrapBallContext:fireBall()
	local info = self.player.eModel:GetTrapPointerInfo(CommonConst.COMPONENT_CATCH)

	if not info.valid then
		return
	end

	if self.ballEnt then
		self.ballEnt:fire(info.position, info.rotation)
	end

	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)
	ThrowBallContext.fireBall(self)
	self:exit()
end

function TrapBallContext:destroy()
	self.player.eModel.AlwaysLookForward = false

	self.player.eModel:UnloadPointer(CommonConst.COMPONENT_CATCH)
	ThrowBallContext.destroy(self)
end

return TrapBallContext
