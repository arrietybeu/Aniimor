-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\DriveBallContext.lua

local Class = require("Core.Framework.Class")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local ClientSwitch = require("Common.ClientSwitch")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local DriveBallContext = Class.LightClass("DriveBallContext", ThrowBallContext)

function DriveBallContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)

	function self.onPerformFinish()
		self:cancelControl()
	end

	self._inControl = false
end

function DriveBallContext:enter()
	self.throwed = false
	self.player.eModel.ThrowAnimType = self.ballData.animType
	self.player.eModel.AlwaysLookForward = true

	self:enableCatchMode(true)
	ThrowBallContext.enter(self)
	self.fsm:clear()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CAPTURE_BALL) then
		pg.global.ui.captureBall:switchAimVisible(false)
	end

	pg.global.eventEmitter:onceEventListener(EventConst.BALL_DRIVE_END, self.onPerformFinish)
end

function DriveBallContext:throw()
	local emptySlotNum = TriggerUtils.getStatusTriggerCurValue(self.player, TriggerConst.TRIGGER_PET_REMAINDER_NUM)

	if emptySlotNum < 10 then
		if not self.lastNoticeTs or Time.realSecondCache - self.lastNoticeTs >= 1.5 then
			pg.global.showBubbleMessageById(NoticeDef.PET_EMPTY_REMAIN_BIG_WHITE_BALL)

			self.lastNoticeTs = Time.realSecondCache
		end

		return
	end

	if self.throwed then
		return
	end

	self.throwed = true

	self:doThrow()
end

function DriveBallContext:throwEnd(breaked)
	if self.throwed then
		self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)

		if self._inControl then
			self.player:setVisible(ClientConst.MODEL_VISIBLE_KEY.BIG_WHITE_BALL, false, false, false)
		else
			self:exitCatchMode()
		end
	end
end

function DriveBallContext:switch()
	if self.throwed then
		return
	end

	self:doSwitch()
end

function DriveBallContext:doThrow()
	local function cb()
		ThrowBallContext.doThrow(self)
	end

	self:throwWithRpc(cb)
end

function DriveBallContext:fireBall()
	if self.ballEnt then
		self:takeControl()
		self.ballEnt:fire(self.ballData.maxV)
	end
end

function DriveBallContext:takeControl()
	if self._inControl then
		return
	end

	self._inControl = true

	pg.global.effectMgr:AttachInteractionField(self.ballEnt.eModel)
	pg.game.camera:enableBallDrive(true, self.ballEnt.ballGameObject.transform)
	pg.game.input:enableBallDriveInput(true)
	pg.global.ui:open(UIConst.UI_ID_BIG_WHITE_BALL, {
		ballEnt = self.ballEnt
	})
	pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "cancel", self.ballEnt)
end

function DriveBallContext:cancelControl()
	if not self._inControl then
		return
	end

	self:_releaseDriveControl()
	self:exitCatchMode()
end

function DriveBallContext:_releaseDriveControl()
	if not self._inControl then
		return
	end

	self._inControl = false

	local ent = pg.pawn and pg.pawn.eModel or nil

	pg.global.effectMgr:AttachInteractionField(ent)
	pg.game.camera:enableBallDrive(false)
	pg.game.input:enableBallDriveInput(false)
	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_END_UI)
end

function DriveBallContext:exit()
	if self.throwed then
		return false
	end

	return self:exitCatchMode()
end

function DriveBallContext:destroy()
	if self._inControl then
		self:_releaseDriveControl()
	end

	self.player:setVisible(ClientConst.MODEL_VISIBLE_KEY.BIG_WHITE_BALL, true, true, true)

	self.player.eModel.AlwaysLookForward = false

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CAPTURE_BALL) then
		pg.global.ui.captureBall:switchAimVisible(true)
	end

	pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_END, self.onPerformFinish)

	self.lastNoticeTs = nil
	self.onPerformFinish = nil
	self._inControl = nil

	ThrowBallContext.destroy(self)
end

return DriveBallContext
