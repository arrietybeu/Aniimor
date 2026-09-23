-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\VirtualCatchContext.lua

local Class = require("Core.Framework.Class")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local PlayableEventConst = require("Const.PlayableEventConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local VirtualCatchContext = Class.LightClass("VirtualCatchContext", ThrowBallContext)

function VirtualCatchContext:enter(fromContext)
	self.player.eModel.AlwaysLookForward = true
	self.player.eModel.ThrowAnimType = self.ballData.animType

	self:enableCatchMode(true)
	ThrowBallContext.enter(self, fromContext)
end

function VirtualCatchContext:destroy()
	if self.player and self.player.eModel then
		self.player.eModel.AlwaysLookForward = false
	end

	ThrowBallContext.destroy(self)
end

function VirtualCatchContext:createBall()
	self.envId = pg.game.envObj:genEnvId()
	self.ballEnt = self.player:SyncCaptureHoldVirtualBall(self.envId, self.itemId)
end

function VirtualCatchContext:throwWithRpc(cb)
	if cb then
		cb()
	end
end

function VirtualCatchContext:_clear()
	self.eventEmitter:removeAllListeners(PlayableEventConst.fireBall)

	if self.ballEnt then
		if not self.ballEnt.fired then
			ClientUtils.safeDestroy(self.ballEnt)
		end

		self.ballEnt = nil
	end

	if self.throwTimer then
		TimerManager.removeTimer(self.throwTimer)

		self.throwTimer = nil
	end
end

function VirtualCatchContext:hold()
	if self.ballEnt then
		return false
	end

	self:_clear()
	self:createBall()
	self.eventEmitter:onceEventListener(PlayableEventConst.fireBall, function()
		self:fireBall()
	end)

	return true
end

function VirtualCatchContext:checkBallCanThrow()
	return true
end

function VirtualCatchContext:fireBall()
	if self.ballEnt then
		local v = self.ballData.maxV

		self.ballEnt:virtualFire(v)
	end

	ThrowBallContext.fireBall(self)
end

return VirtualCatchContext
