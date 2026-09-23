-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BigWhiteBall\\BigWhiteBallCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetCharacterData = require("Data.pet_character_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventConst = require("Const.EventConst")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local CastItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local UIConst = require("Const.UIConst")
local JoyStickDragRelay = require("Guis.Helper.JoyStickDragRelay")
local BigWhiteBallCtrl = Class.LightClass("BigWhiteBallCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TEXT_EXIST_TIME = 3
local PRESS_MAX_TIME = 1.5
local CATCH_NUM_MIN_SCALE = 0.8
local CATCH_MAX_TIME = SysConfigData.BIGWHITEBALL_TIMELIMIT_MAX
local CATCH_INIT_TIME = SysConfigData.BIGWHITEBALL_TIMELIMIT_INIT
local KEY_BOARD_MAP = {
	[1] = "BallDrive/Cancel"
}

BigWhiteBallCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChange",
		true
	}
}

function BigWhiteBallCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_TIME, self.timeRemainAction)
	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_END_UI, self.exitCatchAction)
	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_CATCH_NUM, self.catchNumAction)
	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_ADD_TIME, self.addTimeAction)
end

function BigWhiteBallCtrl:onDestroy()
	UICtrl.onDestroy(self)
	JoyStickDragRelay.popJoyStick(self)

	local ui = pg.global.ui
	local hudV2 = ui and ui:tryGetCtrlByUid(UIConst.UI_ID_HUD_V2)

	if hudV2 then
		hudV2:clearBigDriveBallHideMark()
	end

	self.holdBallEnt = nil

	pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_END_UI, self.exitCatchAction)
	pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_TIME, self.timeRemainAction)
	pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_CATCH_NUM, self.catchNumAction)
	pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_ADD_TIME, self.addTimeAction)
end

function BigWhiteBallCtrl:addListener()
	local keyBinding = self.view.pressCancelBtn:GetComponent("KeyBindingPro")

	keyBinding.actionPath = KEY_BOARD_MAP[1]

	function self.view.pressCancelBtn.luaPress()
		self:startPress()
	end

	function self.view.pressCancelBtn.luaRelease()
		self:endPress()
	end

	self.holdBallEnt = nil
	self.inRangePuppets = {}
	self.isInCatch = false
	self.addTimeTxtCurTime = TEXT_EXIST_TIME
	self.catchDefaultScale = Vector3.one * self.view.boxNumAnim.transform.localScale.x

	function self.exitCatchAction()
		self:exitBigBallCatch()
	end

	function self.timeRemainAction(start, endTime, curTime, additionTime)
		self:updateRemainTime(start, endTime, curTime, additionTime)
	end

	function self.catchNumAction(num)
		self:refreshCatchNum(num)
	end

	function self.addTimeAction(addTime, overflow)
		self:triggerAddTime(addTime, overflow)
	end

	self.ballMoveBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "ballMove")
	self.ballMoveBind.isVirtual = true
	self.ballMoveBind.actionPath = "BallDrive/Move"

	function self.ballMoveBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:moveBall(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
		elseif inputInfo.phase == "Canceled" then
			self:moveBall(0, 0)
		end
	end

	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self:initMobileInteract()
	end

	self:setupKeyHintList()
end

function BigWhiteBallCtrl:moveBall(x, y)
	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_MOVE, x, y)
end

function BigWhiteBallCtrl:initMobileInteract()
	local operateUComponentRef = self.view.operateUComponent:GetComponent("ObjectReference")

	self.joystick = operateUComponentRef:GetRefValue("joyStickUJoyStick")
	self.cameraGestureGesture = operateUComponentRef:GetRefValue("cameraCtrlUWidget")

	function self.joystick.luaValueChanged(x, y, z)
		self:moveBall(x, y)
	end

	function self.cameraGestureGesture.luaDragUpdate(x, y)
		pg.game.input:setViewAxisByDeltaPixel(x, y)
	end

	function self.cameraGestureGesture.luaEndDrag()
		pg.game.input:setViewAxisByDeltaPixel(0, 0)
	end
end

function BigWhiteBallCtrl:setupKeyHintList()
	LuaUIUtils.setKeyHintList(self.view.keyHintList, "HudBigWhiteBall", true)
end

function BigWhiteBallCtrl:onOpen(info)
	if info and info.ballEnt then
		self.holdBallEnt = info.ballEnt

		self:enterBigBallCatch()
	end
end

function BigWhiteBallCtrl:onShow()
	self.view.rootController:TryChangePage("MultiTerminal", 1)
	self.view.rootController:TryChangePage("GuideLabel", 1)
	self:setShortCurKeyVisible(false)
end

function BigWhiteBallCtrl:onHide()
	self:setShortCurKeyVisible(true)

	if self.tickCatchTimer then
		self:killTimer(self.tickCatchTimer)

		self.tickCatchTimer = nil
	end
end

function BigWhiteBallCtrl:setShortCurKeyVisible(isShow)
	if pg.global.ui.tips then
		pg.global.ui.tips:setShortCurKeyVisible_BigWhiteBall(isShow)
	end
end

function BigWhiteBallCtrl:enterBigBallCatch()
	self:show()

	self.isInCatch = true

	self:_setDriveInteractionEnabled(false)
	LuaUIUtils.setUIViewVisible(self.view.cDFinishTs, false)
	LuaUIUtils.setUIViewVisible(self.view.barTime, true)
	self.view.barTime:TryChangePage("TimeMaxState", 0)
	self.view.rootController:TryChangePage("NumStage", 0)

	self.view.barTime.maxHp = CATCH_MAX_TIME
	self.view.barTime.hp = CATCH_INIT_TIME
	self.curCatchNum = 0

	if self.tickCatchTimer then
		self:killTimer(self.tickCatchTimer)

		self.tickCatchTimer = nil
	end

	self.tickCatchTimer = self:startTimer(function()
		self:tickCatchPuppet()
	end, 0.1, true)

	self.view.rootAnimation:Play("VX_Prefab_Hud_BigWhiteBallCtr_In")
	JoyStickDragRelay.pushJoyStick(self, self.joystick)
	pg.global.ui.hudV2:onSwitchBigDriveBallMode(true)
end

function BigWhiteBallCtrl:exitBigBallCatch()
	if not self.isInCatch then
		return
	end

	self.isInCatch = false

	JoyStickDragRelay.popJoyStick(self)

	if self.tickCatchTimer then
		self:killTimer(self.tickCatchTimer)

		self.tickCatchTimer = nil
	end

	self.holdBallEnt = nil

	self:clearTopLogo()
	self:hide()
	pg.global.ui.hudV2:onSwitchBigDriveBallMode(false)
	pg.global.ui:close(UIConst.UI_ID_BIG_WHITE_BALL)
end

function BigWhiteBallCtrl:startPress()
	if not self._driveInteractionEnabled then
		return
	end

	self.view.cDFinishProgress.value = 0

	LuaUIUtils.setUIViewVisible(self.view.cDFinishTs, true)

	self.pressTimer = self:startTimer(function()
		self:inPressing()
	end, 0, true)

	self.view.rootAnimation:Play("VX_Prefab_Hud_BigWhiteBallCtr_E")
end

function BigWhiteBallCtrl:inPressing()
	if self.view.cDFinishProgress.value >= PRESS_MAX_TIME then
		return
	end

	if self.view.cDFinishProgress.value < PRESS_MAX_TIME then
		self.view.cDFinishProgress.value = self.view.cDFinishProgress.value + Time.unscaledDeltaTime
	end

	if self.view.cDFinishProgress.value >= PRESS_MAX_TIME then
		pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_END_IMMEDIATE)
		self:endPress()
	end
end

function BigWhiteBallCtrl:endPress()
	if self.pressTimer == nil then
		return
	end

	self:killTimer(self.pressTimer)

	self.pressTimer = nil

	LuaUIUtils.setUIViewVisible(self.view.cDFinishTs, false)
	self.view.rootAnimation:Play("VX_Prefab_Hud_BigWhiteBallCtr_EOut")
end

function BigWhiteBallCtrl:updateRemainTime(start, endTime, curTime, additionTime)
	if IsNil(self.view.barTime) then
		return
	end

	if self.isInCatch and not self._driveInteractionEnabled then
		self:_setDriveInteractionEnabled(true)
	end

	local remainTime = math.max(0, endTime - curTime)

	self.view.barTime.hp = remainTime
	self.view.barTime.sp = additionTime

	if remainTime <= 0 then
		LuaUIUtils.setUIViewVisible(self.view.barTime, false)
	end

	if self.addTimeTxtCurTime <= 0 then
		return
	end

	self.addTimeTxtCurTime = self.addTimeTxtCurTime - Time.unscaledDeltaTime

	if self.addTimeTxtCurTime <= 0 then
		self.view.barTime:TryChangePage("TimeMaxState", 0)
	end
end

function BigWhiteBallCtrl:_setDriveInteractionEnabled(enabled)
	if self._driveInteractionEnabled == enabled then
		return
	end

	self._driveInteractionEnabled = enabled
	self.view.pressCancelBtn.interactable = enabled
end

function BigWhiteBallCtrl:refreshCatchNum(num)
	self.view.rootController:TryChangePage("NumStage", num)

	self.curCatchNum = num

	local maxCount = self.holdBallEnt and self.holdBallEnt.ballData and self.holdBallEnt.ballData.maxCount or 10

	if maxCount <= num then
		LuaUIUtils.setUIViewVisible(self.view.barTime, false)
	end

	if num >= 1 and num <= 9 then
		self.view.boxNumAnim:Play("VX_Prefab_Hud_BigWhiteBallCtr_Loop")
	else
		self.view.boxNumAnim:Play("VX_Prefab_Hud_BigWhiteBallCtr_Loop2")
	end

	self.view.catchNumParticle2g:Play()

	if num >= 4 then
		self.view.vxStarAnim:Play("VX_Prefab_Hud_VxStar_01")
		self.view.catchNumParticle2:Play()
	end

	if num >= 7 then
		self.view.catchNumParticle3:Play()
	end

	local rootAnimName

	rootAnimName = num >= 1 and num <= 3 and "VX_Prefab_Hud_BigWhiteBallCtr_In1" or num >= 4 and num <= 6 and "VX_Prefab_Hud_BigWhiteBallCtr_In2" or num >= 7 and num <= 9 and "VX_Prefab_Hud_BigWhiteBallCtr_In3" or "VX_Prefab_Hud_BigWhiteBallCtr_In4"
	self.view.boxNumAnim.transform.localScale = self.catchDefaultScale * (CATCH_NUM_MIN_SCALE + (num - 1) * 0.1)

	self.view.rootAnimation:Stop(rootAnimName)
	self.view.rootAnimation:Play(rootAnimName)
end

function BigWhiteBallCtrl:triggerAddTime(addTime, overflow)
	if addTime == 0 then
		return
	end

	self.addTimeTxtCurTime = 1

	if overflow then
		self.view.barTime:TryChangePage("TimeMaxState", 2)
		self.view.barTimeAnim:Play("VX_Prefab_Hud_BarTime_All")
	else
		self.view.barTime:TryChangePage("TimeMaxState", 1)
		self.view.barTimeAnim:Play("VX_Prefab_Hud_BarTime")
		ClientTextUtils.setText(self.view.additionTimeTxt, string.format("+%ds!", addTime))
	end
end

function BigWhiteBallCtrl:tickCatchPuppet()
	if not self.holdBallEnt or not self.holdBallEnt.eModel then
		return
	end

	local castBallId = pg.global.ui.hudV2:getCurSelectPropId()
	local distance1 = SysConfigData.CATCHCAMERALOCK_MAX_DISTANCE

	if ItemEffectData[castBallId] and ItemEffectData[castBallId].castItemId and CastItemData[ItemEffectData[castBallId].castItemId] and CastItemData[ItemEffectData[castBallId].castItemId].aimSwitchDistance then
		distance1 = CastItemData[ItemEffectData[castBallId].castItemId].aimSwitchDistance
	end

	for _, actorId in ipairs(self.inRangePuppets) do
		local entity = pg.getEntityByActorId(actorId)

		if entity and entity.eModel and pg.pawn:isEnemy(entity) then
			local _hx, _hy, _hz = self.holdBallEnt.eModel:GetPositionAgentPosEx()
			local _ex, _ey, _ez = entity.eModel:GetPositionAgentPosEx()

			Vector3.enableCreateFromCache()

			local distance = Vector3.Distance(Vector3.New(_hx, _hy, _hz), Vector3.New(_ex, _ey, _ez))

			Vector3.disableCreateFromCache()
			entity.eventEmitter:emit(EventConst.TOPLOGO_CATCH_LOCK, distance <= distance1)
		end
	end

	if not self.holdBallEnt.aoi then
		return
	end

	self.inRangePuppets = self.holdBallEnt:entitiesInRange(distance1, Const.SEARCH_USR_TYPE_MONSTER)
end

function BigWhiteBallCtrl:clearTopLogo()
	if not self.inRangePuppets then
		return
	end

	for _, actorId in ipairs(self.inRangePuppets) do
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			entity.eventEmitter:emit(EventConst.TOPLOGO_CATCH_LOCK, false)
		end
	end

	self.inRangePuppets = {}
end

function BigWhiteBallCtrl:onInputDeviceChange()
	self:setupKeyHintList()
end

return BigWhiteBallCtrl
