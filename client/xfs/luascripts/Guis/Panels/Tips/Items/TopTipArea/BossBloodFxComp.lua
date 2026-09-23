-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossBloodFxComp.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local RectUtil = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleRectUtil")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Prof = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleProfiler")
local logger = LoggerManager.getLogger("BossBloodFxComp")
local DoTweenAnimMgr = DoTweenAnimMgr
local HP_FX_RETRACT_TWEEN_ID = "bossHpFxRetract"
local BLOOD_FX_POOL_SIZE = 4
local UNLOCK_FX_TWEEN_SECOND = 0.3
local BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT = 15
local SHAKE_FXVX_ANI_INVOKE_INDEX = CS.XGUI.EInvokeTime.Custom2
local BLOOD_FXVX_CUSTOM2 = CS.XGUI.EInvokeTime.Custom2
local BLOOD_FXVX_CUSTOM3 = CS.XGUI.EInvokeTime.Custom3
local BLOOD_FXVX_CUSTOM4 = CS.XGUI.EInvokeTime.Custom4
local BLOOD_FXVX_CUSTOM5 = CS.XGUI.EInvokeTime.Custom5
local BLOOD_BREAK_FXVX_ANI_DURATION = 0.2
local BLOOD_BREAK_FXVX_ANI_INVOKE_INDEX = CS.XGUI.EInvokeTime.Custom1
local STATE_BREAK = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
local STATE_BREAK_RECOVER = UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER
local BossBloodFxComp = Class.LightClass("BossBloodFxComp")

function BossBloodFxComp:ctor(owner)
	self.owner = owner
	self.timers = {}
	self.poolVersion = 0
	self.needRetractTime = 0

	function self.delayRetract()
		if Time.realSecondCache >= self.needRetractTime then
			self.timers.m_unlockBloodFxVxTimer = nil

			if self.m_bloodFxActive then
				self:retract(math.clamp(self.owner.hpState.curRatio, 0, 1), UNLOCK_FX_TWEEN_SECOND)
			end
		else
			local limitSecond = math.max(0, self.needRetractTime - Time.realSecondCache)

			self.timers.m_unlockBloodFxVxTimer = TimerManager.addTimer(limitSecond, self.delayRetract)
		end
	end
end

function BossBloodFxComp:onBind(bloodObjectReference)
	local bloodNewRectTransform = bloodObjectReference:GetRefValue("bloodNewRectTransform")

	self.fxVXRectTransform = bloodObjectReference:GetRefValue("fxVXRectTransform")
	self.vXBloodHandleUWidget = bloodObjectReference:GetRefValue("vXBloodHandleUWidget")
	self.allHpWidth = (bloodNewRectTransform and bloodNewRectTransform.sizeDelta and bloodNewRectTransform.sizeDelta.x or 0.1) - 8
	self.fxVXRectSizeY = self.fxVXRectTransform and self.fxVXRectTransform.sizeDelta and self.fxVXRectTransform.sizeDelta.y or 0

	if self.vXBloodHandleUWidget then
		self.vXBloodHandleUWidget:SetActive(true)
	end
end

function BossBloodFxComp:init()
	if not self.fxVXRectTransform then
		return
	end

	if self.m_bloodFxList then
		self:resetAll()

		return
	end

	self.m_bloodFxList = {}
	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0
	self.poolVersion = self.poolVersion + 1

	local poolVersion = self.poolVersion
	local originFx = self:newBloodFx(self.fxVXRectTransform)

	table.insert(self.m_bloodFxList, originFx)

	local parent = self.fxVXRectTransform.parent
	local pos = self.fxVXRectTransform.position

	for i = 1, BLOOD_FX_POOL_SIZE - 1 do
		pg.global.resMgr:ResInstantiateAsync(self.fxVXRectTransform.gameObject, function(gameObj)
			if self.poolVersion ~= poolVersion or self.m_bloodFxList == nil then
				if NotNil(gameObj) then
					pg.global.resMgr:ResDestroyObject(gameObj)
				end

				return
			end

			local rect = gameObj.transform:GetComponent("RectTransform")
			local fx = self:newBloodFx(rect)

			table.insert(self.m_bloodFxList, fx)
		end, pos, Quaternion.identity, parent)
	end
end

function BossBloodFxComp:destroy()
	self.poolVersion = self.poolVersion + 1

	if self.m_bloodFxList then
		for _, fx in ipairs(self.m_bloodFxList) do
			DoTweenAnimMgr.Kill(fx.rect.gameObject, LuaUIUtils.TweenId(HP_FX_RETRACT_TWEEN_ID), false)
		end

		self.m_bloodFxList = nil
	end

	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0
	self.isBreakingFx = nil

	self:clearUnlockTimer()
end

function BossBloodFxComp:reset()
	self:resetAll()
	self:clearUnlockTimer()

	self.isBreakingFx = nil
end

function BossBloodFxComp:onHpDisplayChanged(preRawHp, preStage)
	local owner = self.owner
	local state = owner.hpState
	local rawDelta = preRawHp - state.rawCurHp
	local isHpReduced = rawDelta > 0
	local bottomRatio = math.clamp(state.curRatio, 0, 1)
	local anchorRatio = math.clamp(bottomRatio + rawDelta / state.barSize, 0, 1)
	local isBreakHpFx = owner.breakState == STATE_BREAK or owner.breakState == STATE_BREAK_RECOVER

	if not isHpReduced then
		return
	end

	local isCrossBar = preStage ~= nil and state.curStage ~= nil and preStage > state.curStage

	if isCrossBar then
		local lastAnchor = (bottomRatio + rawDelta / state.barSize - (preStage - state.curStage)) % 1

		self:accumulate(lastAnchor, 0)
		self:retract(0, UNLOCK_FX_TWEEN_SECOND)
		self:accumulate(1, bottomRatio)
		owner.rootComponent:InvokeCallback(SHAKE_FXVX_ANI_INVOKE_INDEX)
	end

	self:accumulate(anchorRatio, bottomRatio)

	if isBreakHpFx then
		owner.rootComponent:InvokeCallback(BLOOD_FXVX_CUSTOM2)
	else
		self:setUnlockDelayTimer()
	end
end

function BossBloodFxComp:onBreakStarted(entity, isIgnoreHpLock)
	if isIgnoreHpLock then
		return
	end

	self.isBreakingFx = true

	self.owner:refreshHpDisplay(entity)
	self:retract(math.clamp(self.owner.hpState.curRatio, 0, 1), UNLOCK_FX_TWEEN_SECOND)
end

function BossBloodFxComp:onBreakEnded(entity, isIgnoreHpLock)
	local owner = self.owner

	owner.rootComponent:InvokeCallback(BLOOD_BREAK_FXVX_ANI_INVOKE_INDEX)

	self.isBreakingFx = nil

	if self.timers.m_unlockBreakFxVxTimer then
		return
	end

	self.timers.m_unlockBreakFxVxTimer = TimerManager.addTimer(BLOOD_BREAK_FXVX_ANI_DURATION, function()
		self.timers.m_unlockBreakFxVxTimer = nil

		owner:refreshHpDisplay(entity)

		local duration = isIgnoreHpLock and 0 or UNLOCK_FX_TWEEN_SECOND

		self:retract(math.clamp(owner.hpState.curRatio, 0, 1), duration)
	end)
end

function BossBloodFxComp:clearUnlockTimer()
	if self.timers.m_unlockBloodFxVxTimer then
		TimerManager.removeTimer(self.timers.m_unlockBloodFxVxTimer)

		self.timers.m_unlockBloodFxVxTimer = nil
	end

	if self.timers.m_unlockBreakFxVxTimer then
		TimerManager.removeTimer(self.timers.m_unlockBreakFxVxTimer)

		self.timers.m_unlockBreakFxVxTimer = nil
	end
end

function BossBloodFxComp:setUnlockDelayTimer()
	self.needRetractTime = Time.realSecondCache + SysConfigData.BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT

	if self.timers.m_unlockBloodFxVxTimer then
		return
	end

	local limitSecond = SysConfigData.BOSS_HP_HUD_BLOOD_VX_TIME_LIMIT

	self.timers.m_unlockBloodFxVxTimer = TimerManager.addTimer(limitSecond, self.delayRetract)
end

function BossBloodFxComp:newBloodFx(rect)
	local go = rect.gameObject
	local _, posY = rect:GetAnchoredPositionEx()

	return {
		topRatio = 0,
		alive = false,
		rect = rect,
		go = go,
		uWidget = go:GetComponent("UImage"),
		vxLine = rect:Find("VxLine"),
		vxLine2 = rect:Find("VxLine2"),
		posY = posY
	}
end

function BossBloodFxComp:applyByRatio(fx, topRatio, bottomRatio)
	RectUtil.applyRectByRatio(fx.rect, self.allHpWidth, self.fxVXRectSizeY, topRatio, bottomRatio, fx.posY)
end

function BossBloodFxComp:acquire(anchorRatio)
	local count = #self.m_bloodFxList

	if (count == 0 or count < self.m_bloodFxCursor) and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("BossBloodFxComp: acquire error")
	end

	local fx = self.m_bloodFxList[self.m_bloodFxCursor]

	self:resetFx(fx)

	self.m_bloodFxCursor = self.m_bloodFxCursor % count + 1
	fx.topRatio = anchorRatio
	fx.alive = true

	self:setActiveFast(fx.rect, true)

	self.m_bloodFxActive = fx

	return fx
end

function BossBloodFxComp:accumulate(anchorRatio, bottomRatio)
	Prof.count("fxAccumulate")

	if not self.owner.hp or not self.owner.hp:isBound() then
		return
	end

	local fx = self.m_bloodFxActive

	if not self.m_bloodFxActive then
		self:acquire(anchorRatio)

		fx = self.m_bloodFxActive

		fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM5)
	end

	self:applyByRatio(fx, math.clamp(fx.topRatio, 0, 1), math.clamp(bottomRatio, 0, 1))
	self:refreshLines(true)
end

function BossBloodFxComp:retract(frozenBottom, duration)
	local fx = self.m_bloodFxActive

	if not fx then
		return
	end

	Prof.count("fxRetract")

	self.m_bloodFxActive = nil

	fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM4)

	local fromTop = math.clamp(fx.topRatio, 0, 1)
	local bottom = math.clamp(frozenBottom, 0, 1)
	local delay = math.max(0, self.m_nextRetractTime - Time.time)

	self.m_nextRetractTime = math.max(Time.time, self.m_nextRetractTime) + duration

	RectUtil.startRetractTween(fx.rect, HP_FX_RETRACT_TWEEN_ID, fromTop, bottom, duration, delay, function(t)
		Prof.count("fxTweenUpdate")
		self:applyByRatio(fx, t, bottom)
	end, function()
		self:recycle(fx)
	end)
	self:refreshLines()
end

function BossBloodFxComp:recycle(fx)
	self:resetFx(fx)
	self:refreshLines()
end

function BossBloodFxComp:setActiveFast(trans, isActive)
	if isActive then
		trans:SetLocalScaleEx(1, 1, 1)
	else
		trans:SetLocalScaleEx(0, 0, 0)
	end
end

function BossBloodFxComp:resetFx(fx)
	DoTweenAnimMgr.Kill(fx.rect.gameObject, LuaUIUtils.TweenId(HP_FX_RETRACT_TWEEN_ID), false)

	fx.alive = false
	fx.topRatio = 0

	self:applyByRatio(fx, 0, 0)
	self:setActiveFast(fx.vxLine, false)
	self:setActiveFast(fx.vxLine2, false)
	self:setActiveFast(fx.rect, false)
end

function BossBloodFxComp:resetAll()
	if not self.m_bloodFxList then
		return
	end

	for _, fx in ipairs(self.m_bloodFxList) do
		self:resetFx(fx)
	end

	self.m_bloodFxActive = nil
	self.m_bloodFxCursor = 1
	self.m_nextRetractTime = 0
end

function BossBloodFxComp:refreshLines(isAttack)
	Prof.count("fxRefreshLines")

	if isAttack == nil then
		isAttack = false
	end

	local count = #self.m_bloodFxList
	local activeIndex = (self.m_bloodFxCursor - 2) % count + 1

	for i = 1, count do
		local curIndex = (activeIndex - i) % count + 1
		local preIndex = (activeIndex - 1 - i) % count + 1
		local fx = self.m_bloodFxList[curIndex]

		if fx.alive == false then
			return
		else
			fx.uWidget:InvokeCallback(BLOOD_FXVX_CUSTOM3)
		end

		self:setActiveFast(fx.vxLine, self.m_bloodFxList[preIndex].alive == false or preIndex == activeIndex)
		self:setActiveFast(fx.vxLine2, curIndex == activeIndex)
	end
end

return BossBloodFxComp
