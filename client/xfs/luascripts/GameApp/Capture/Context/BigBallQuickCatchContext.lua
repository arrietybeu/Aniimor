-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\BigBallQuickCatchContext.lua

local Class = require("Core.Framework.Class")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local BigBallQuickCatchContext = Class.LightClass("BigBallQuickCatchContext", ThrowBallContext)

function BigBallQuickCatchContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)

	self.target = nil

	function self.onDriveEnd()
		if self.fromPet then
			if not self.player.beControlled then
				return
			end

			self.player.captureSwitchFlag = true

			self.player:requestSwitchToPet(Const.CLIENT_SWITCH_REASON.Catch)
		end

		self:exitCatchMode()
	end
end

function BigBallQuickCatchContext:enter()
	ThrowBallContext.enter(self)
	self.fsm:clear()
	pg.global.ui.hudV2:switchAimVisible(false)
	self.eventEmitter:onceEventListener(EventConst.BALL_DRIVE_END, self.onDriveEnd)
	self:doThrow()
end

function BigBallQuickCatchContext:setTarget(target, fromPet)
	self.target = target
	self.fromPet = fromPet
end

function BigBallQuickCatchContext:exit()
	return true
end

function BigBallQuickCatchContext:throw()
	return
end

function BigBallQuickCatchContext:switch()
	return
end

function BigBallQuickCatchContext:throwBreak()
	return
end

function BigBallQuickCatchContext:throwEnd(breaked)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)
end

function BigBallQuickCatchContext:hold(itemId)
	if not ThrowBallContext.hold(self, itemId) then
		return
	end

	self.player:faceToTarget(self.target)

	self.player.eModel.ThrowAnimType = self.ballData.animType

	if self.target then
		self.target.lastFastCaptureTime = Time.secondCache
	end

	return true
end

function BigBallQuickCatchContext:fireBall()
	if self.ballEnt then
		self.ballEnt:quickFire(self.ballData.maxV)
	end

	ThrowBallContext.fireBall(self)
end

function BigBallQuickCatchContext:destroy()
	self.target = nil

	self.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_END, self.onDriveEnd)
	ThrowBallContext.destroy(self)
end

return BigBallQuickCatchContext
