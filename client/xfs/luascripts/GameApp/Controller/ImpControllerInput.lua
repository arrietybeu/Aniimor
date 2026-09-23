-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\ImpControllerInput.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ControllerSystem = require("GameApp.Controller.ControllerSystem")
local AbilityConst = require("Common.Const.AbilityConst")
local Mathf = require("Common.Math.Mathf")
local logger = LoggerManager.getLogger("ControllerSystem")
local NoticeDef = require("Common.NoticeDef")
local InputCommand = require("GameApp.Input.InputCommand")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local EventConst = require("Const.EventConst")
local HotkeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local pg = pg
local ToBool = ToBool

function ControllerSystem:lockTarget(actorId, partId)
	partId = partId or 0

	local target = pg.getEntityByActorId(actorId)

	if target and target.canBeLocked and target:canBeLocked() then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("MainPlayer:lockTarget", actorId, partId)
		end

		self.me:lockTarget(actorId, partId)
	end
end

function ControllerSystem:unlockTarget()
	self.lockHelper:cancelLockTarget()
end

function ControllerSystem:isInLockState()
	return self.me.lockedActorId and self.me.lockedActorId ~= 0
end

function ControllerSystem:switchTarget()
	local targetId, partId = self.lockHelper:tryLockTarget(self.me.lockedActorId)

	if ToBool(targetId) then
		self:lockTarget(targetId, partId)
	end
end

function ControllerSystem:onPawnHitTarget(targetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk: onPawnHitTarget", targetId)
	end

	if pg.space and pg.space.npcDuelLockForbidden and pg.space:npcDuelLockForbidden() then
		return
	end

	if pg.game.setting:getSkillAutoLock() and not self:isInLockState() and self.lockHelper:checkTargetValid(targetId) then
		self:lockTarget(targetId)
	end
end

function ControllerSystem:setCacheMoveAxis(x, y, z)
	self.moveAxis[1] = x
	self.moveAxis[2] = y
	self.moveAxis[3] = z
end

function ControllerSystem:tryHandleMultiPetFollowInput()
	local controller = self.curController

	if not controller or not controller.checkPawn or controller.isVehicle or controller.pawn ~= self.pawn then
		return false
	end

	local component = pg.game and pg.game.social.interactGestureComponent

	if not component or not component:tickMultiPetFollowInput(self.pawn) then
		return false
	end

	self:setCacheMoveAxis(0, 0, 0)

	return true
end

function ControllerSystem:checkInClimbState()
	if self.pawn ~= nil and self.pawn.eModel then
		return self.pawn:CLIMB_ST()
	end

	return false
end

function ControllerSystem:onHandleClimbJump(onlyOffWall)
	if self.pawn ~= nil and self.pawn.eModel and self.pawn:checkJump() then
		if onlyOffWall then
			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.ClimbJump)
		else
			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, self.pawn:CLIMB_ST() and InputCommand.ClimbJump or InputCommand.Jump)
		end
	end
end

function ControllerSystem:onHandleFastClimb(isPress)
	if self.pawn ~= nil and self.pawn.eModel then
		if isPress then
			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.FastClimb, isPress, 1)
		else
			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.FastClimb, isPress)
		end
	end
end

function ControllerSystem:onHandleSpecialAbility(isPress)
	if self.pawn ~= nil and self.pawn.eModel and isPress then
		self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.SpecialAbility)
	end
end
