-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\QuickCatchContext.lua

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
local CallbackHandler = require("Core.Common.CallbackHandler")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local QuickCatchContext = Class.LightClass("QuickCatchContext", ThrowBallContext)

function QuickCatchContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)

	self.target = nil
end

function QuickCatchContext:enter()
	ThrowBallContext.enter(self)
end

function QuickCatchContext:setTarget(target, fromPet, alreadyHolding)
	self.target = target
	self.fromPet = fromPet
	self.alreadyHolding = alreadyHolding
end

function QuickCatchContext:exit()
	return true
end

function QuickCatchContext:throw()
	return
end

function QuickCatchContext:switch()
	return
end

function QuickCatchContext:throwBreak()
	return
end

function QuickCatchContext:throwEnd(breaked)
	local player = self.player
	local fromPet = self.fromPet

	self:exitCatchMode()

	if fromPet then
		if not player.beControlled then
			return
		end

		player.captureSwitchFlag = true

		player:requestSwitchToPet(Const.CLIENT_SWITCH_REASON.Default)
	end
end

function QuickCatchContext:hold(itemId)
	if not ThrowBallContext.hold(self, itemId) then
		return
	end

	self.player.eModel.alwaysLookForwardActorId = self.target.actorId

	self.player:faceToTarget(self.target)

	self.player.eModel.ThrowAnimType = self.ballData.animType

	if self.target then
		self.target.lastFastCaptureTime = Time.secondCache
	end

	self.player.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.THROWING)

	if self.alreadyHolding then
		self.waitThrowTimer = TimerManager.addTimer(0.01, CallbackHandler(self, "doThrow"))
	else
		self.waitThrowTimer = TimerManager.addTimer(0.5, CallbackHandler(self, "doThrow"))
	end

	return true
end

function QuickCatchContext:fireBall()
	if self.ballEnt then
		self.ballEnt:quickFire(self.target, SysConfigData.BREAKCATCH_INITSPEED)
	end

	ThrowBallContext.fireBall(self)
end

function QuickCatchContext:doThrow()
	local function cb()
		self.waitThrowTimer = nil

		ThrowBallContext.doThrow(self)
	end

	self:throwWithRpc(cb)
end

function QuickCatchContext:destroy()
	self.player.eModel.alwaysLookForwardActorId = 0

	if self.ballEnt and self.ballEnt.isModelLoaded then
		self:fireBall()
	end

	self.target = nil

	if self.waitThrowTimer then
		TimerManager.removeTimer(self.waitThrowTimer)

		self.waitThrowTimer = nil
	end

	ThrowBallContext.destroy(self)
end

return QuickCatchContext
