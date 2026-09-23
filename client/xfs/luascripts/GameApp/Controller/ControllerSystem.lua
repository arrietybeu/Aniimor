-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\ControllerSystem.lua

local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local LockHelper = require("GameApp.Controller.Utils.LockHelper")
local NextSkillAction = require("GameApp.Controller.Utils.NextSkillAction")
local SkillFollowTarget = require("GameApp.Controller.Utils.SkillFollowTarget")
local PawnController = require("GameApp.Controller.PawnController")
local PlayerController = require("GameApp.Controller.PlayerController")
local TempPlayerController = require("GameApp.Controller.TempPlayerController")
local AutoCastController = require("GameApp.Controller.Utils.AutoCastController")
local lume = require("Core.Common.lume")
local SwitchInfo = CS.FunPlus.WorldX.SpecialAbility.SwitchInfo
local ControllerSystem = Class.LightClass("ControllerSystem", SystemBase)

function ControllerSystem:getMessageBindMap()
	return {
		[MessageName.INPUT_DEVICE_CHANGED] = "onInputDeviceChange",
		[MessageName.UI_ON_CLOSE] = "onHandleOnCloseUI",
		[MessageName.LEAVE_CATCH_MODE_ST] = "onLeaveCatchMode"
	}
end

function ControllerSystem:onCtor()
	self.me = nil
	self.pawn = nil
	self.moveAxis = nil
	self.switchInfo = {}
	self.switchAbilityHintInfo = {}
	self.csSwitchInfo = SwitchInfo()
	self.lastFrameTickTime = Time.realSecondCache * 1000
	self.nextSkillAction = NextSkillAction.new(nil)
	self.autoCastController = AutoCastController()
	self.skillFollowTarget = SkillFollowTarget.new(nil)
	self.lockHelper = LockHelper.new()
	self.posEffect = nil
	self.moveAxis = {}
	self.longPressMap = {}
	self.curController = PawnController.new()
	self.enableSwitchController = true
end

function ControllerSystem:onInputDeviceChange()
	self.lockHelper:onInputDeviceChange()
end

function ControllerSystem:onInit()
	return
end

function ControllerSystem:onTick()
	local now = Time.realSecondCache * 1000

	self.lastFrameTickDuration = now - self.lastFrameTickTime
	self.lastFrameTickTime = now

	self.nextSkillAction:update()
	self.autoCastController:update()
	self.skillFollowTarget:update()
	self.lockHelper:update()
	self:checkAndCancelExploreSwitch()
end

function ControllerSystem:onPlayerInit(player)
	self:setPlayer(player)
end

function ControllerSystem:onPlayerDestroy(player)
	lume.clear(self.switchAbilityHintInfo)
	facade:SendMessageCommand(MessageName.CONTROLLER_SWITCH_UPDATE, self.switchAbilityHintInfo)
	self:setPlayer(nil)
end

function ControllerSystem:setPlayer(player, force)
	if self.me ~= player or force then
		self.me = player
		pg.me = player

		self:controlEntity(player)
	end
end

function ControllerSystem:isInControlEnt()
	return self.me ~= self.pawn and not self.pawn.isMainPlayer
end

function ControllerSystem:isInControlMainPlayer()
	return self.me == self.pawn or self.pawn.isMainPlayer
end

function ControllerSystem:controlEntity(ent, inputEvent, params, inheritMotion)
	if ent == nil then
		ent = self.me
	end

	if self.enableSwitchController == false then
		return
	end

	local changed = pg.pawn ~= ent

	self.pawn = ent
	pg.pawn = ent
	self.vehicle = nil

	self.nextSkillAction:setOwner(ent)
	self.skillFollowTarget:setOwner(ent)
	self.autoCastController:setOwner(ent)

	if ent == self.me then
		self:switchController(PlayerController.new(ent), inheritMotion)
	else
		self:switchController(PawnController.new(ent), inheritMotion)
	end

	if changed then
		facade:SendMessageCommand(MessageName.ON_CONTROL_ENT_CHANGED)
	end

	return true
end

function ControllerSystem:resetController()
	self:controlEntity(self.pawn, nil, nil, true)
end

function ControllerSystem:switchController(controller, inheritMotion)
	if not controller then
		return
	end

	local oldController = self.curController

	if oldController and oldController.isVehicle then
		oldController:exit()
	end

	self.curController = controller

	controller:enter(oldController, inheritMotion)
end

function ControllerSystem:onHandleOnCloseUI(uid)
	if self.me == nil then
		return
	end

	self.me:postComponentMethod("EVENT_OnCloseUI", uid)
end

function ControllerSystem:controlTempPlayer(ent)
	if ent == nil then
		ent = self.me
	end

	self.me = nil
	self.pawn = ent
	self.vehicle = nil

	self.nextSkillAction:setOwner(ent)
	self.skillFollowTarget:setOwner(ent)
	self.autoCastController:setOwner(ent)
	self:switchController(TempPlayerController.new(ent))
	self:setSwitchControllerEnable(false)

	return true
end

function ControllerSystem:setSwitchControllerEnable(value)
	self.enableSwitchController = value
end

function ControllerSystem:onLeaveCatchMode()
	local lockHelper = self.lockHelper

	if not lockHelper or not lockHelper.isUseLockOnExtendCamera then
		return
	end

	if lockHelper.forceLockActorId == 0 then
		return
	end

	local lockEnt = pg.getEntityByActorId(lockHelper.forceLockActorId)

	if lockEnt then
		pg.game.camera.playerCameraMode:setLockOnCameraTarget(lockEnt, lockHelper.forceLockPartId)
	end
end

return ControllerSystem
