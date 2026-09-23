-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\MagicCatchContext.lua

local Class = require("Core.Framework.Class")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local InputCommand = require("GameApp.Input.InputCommand")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local PlayableEventConst = require("Const.PlayableEventConst")
local InputFsm = require("GameApp.Input.InputFsm")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local MagicCatchContext = Class.LightClass("MagicCatchContext", ThrowBallContext)

function MagicCatchContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)
end

function MagicCatchContext:enter(fromContext)
	self.player.eModel.AlwaysLookForward = true
	self.player.eModel.ThrowAnimType = self.ballData.animType

	self:enableCatchMode(true)
	ThrowBallContext.enter(self, fromContext)
	pg.global.ui.hudV2:switchAimVisible(true)
end

function MagicCatchContext:throw()
	if not self.ballEnt then
		return
	end

	if not self.ballEnt:isBallReady() then
		return
	end

	ThrowBallContext.throw(self)
end

function MagicCatchContext:doThrow()
	ThrowBallContext.doThrow(self)
	self.eventEmitter:onceEventListener(PlayableEventConst.holdBall, function()
		self:hold()
	end)
end

function MagicCatchContext:fireBall()
	if self.ballEnt then
		local v = self.ballData.maxV

		self.ballEnt:fire(v)
	end

	ThrowBallContext.fireBall(self)
end

function MagicCatchContext:_clear()
	self.eventEmitter:removeAllListeners(PlayableEventConst.holdBall)
	ThrowBallContext._clear(self)
end

function MagicCatchContext:destroy()
	self.player.eModel.AlwaysLookForward = false

	pg.global.ui.hudV2:switchAimVisible(false)
	ThrowBallContext.destroy(self)
end

return MagicCatchContext
