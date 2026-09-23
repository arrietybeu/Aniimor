-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossBreakComp.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local AttributeConst = require("Common.Const.AttributeConst")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local RectUtil = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleRectUtil")
local DoTweenAnimMgr = DoTweenAnimMgr
local LuaUIUtils = require("Utils.LuaUIUtils")
local Prof = require("Guis.Panels.Tips.Items.TopTipArea.BossTitleProfiler")
local BREAK_FX_RETRACT_TWEEN_ID = "bossBreakFxRetract"
local BREAK_FXVX_USER1 = CS.XGUI.EInvokeTime.User1
local BREAK_FXVX_USER2 = CS.XGUI.EInvokeTime.User2
local BREAK_FXVX_CUSTOM1 = CS.XGUI.EInvokeTime.Custom1
local BREAK_FXVX_CUSTOM6 = CS.XGUI.EInvokeTime.Custom6
local BREAK_FXVX_TWEEN_SECOND = 0.5
local BREAK_FXVX_BIG_DMG_THRESHOLD = 5
local DMG_BREAK_COUNT_DOWN_END_INDEX = CS.XGUI.EInvokeTime.Custom1
local DMG_BREAK_RECOVER_END_INDEX = CS.XGUI.EInvokeTime.Custom2

local function getOrderedCutoffs(config)
	local first = config and config[1] or 0
	local second = config and config[2] or 1

	if first < second then
		return first, second
	end

	return second, first
end

local function setWidgetActive(self, widget, cacheKey, active, force)
	if not widget or not force and self[cacheKey] == active then
		return
	end

	self[cacheKey] = active

	widget:SetActive(active)
end

local BossBreakComp = Class.LightClass("BossBreakComp")

function BossBreakComp:ctor(owner)
	self.owner = owner
	self.breakInfo = {}
	self.breakStateCutoffLower, self.breakStateCutoffUpper = getOrderedCutoffs(SysConfigData.BREAK_STATE_CUTOFF)
	self.breakVibrationCutoffLower, self.breakVibrationCutoffUpper = getOrderedCutoffs(SysConfigData.BREAK_VIBRATION_CUTOFF)
	self.breakBigDmgRatio = (SysConfigData.BREAK_FXVX_BIG_DMG_THRESHOLD or BREAK_FXVX_BIG_DMG_THRESHOLD) / 100

	function self.breakFxTweenUpdate(t)
		Prof.count("breakTweenUpdate")
		RectUtil.applyRectByRatio(self.breakFxVXUImage, self.allHpWidth, self.breakFxVXRectSizeY, t, self.breakFxCurrentRatio, self.breakFxVXRectPosY)
	end

	function self.breakFxTweenComplete()
		self.vXBreakHandleUWidget:SetActiveFastest(false)
	end

	function self.revertBreakState()
		self.revertBreakStateTimer = nil

		self.owner.rootComponent:TryChangePage("Break", 0)
		setWidgetActive(self, self.hpUWidget, "hpVisible", true)
	end
end

function BossBreakComp:onBind(objectReference, bloodObjectReference)
	self.barBreak = objectReference:GetRefValue("barBreak")
	self.barBreakCountdown = objectReference:GetRefValue("barBreakCountdown")
	self.imgHandleUWidget = objectReference:GetRefValue("imgHandleUWidget")
	self.bloodUComponent = objectReference:GetRefValue("bloodUComponent")
	self.breakingCountDownUCountDown = bloodObjectReference:GetRefValue("breakingCountDownUCountDown")
	self.vxCountdownAnimation = bloodObjectReference:GetRefValue("vxCountdownAnimation")
	self.breakCountDownBarBreak = bloodObjectReference:GetRefValue("breakCountDownBarBreak")
	self.dmgBoostUWidget = bloodObjectReference:GetRefValue("dmgBoostUWidget")
	self.breakTxtUSDFText = bloodObjectReference:GetRefValue("breakTxtUSDFText")
	self.vXBreakHandleUWidget = bloodObjectReference:GetRefValue("vXBreakHandleUWidget")
	self.hpUWidget = bloodObjectReference:GetRefValue("hpUWidget")

	local bloodNewRectTransform = bloodObjectReference:GetRefValue("bloodNewRectTransform")

	self.breakFxRectTransform = bloodObjectReference:GetRefValue("breakFxVXRectTransform")
	self.breakFxVXUImage = self.breakFxRectTransform:GetComponent("UImage")

	local sizeX, _ = bloodNewRectTransform:GetSizeDeltaEx()

	self.allHpWidth = sizeX - 8

	local _, sizeY = self.breakFxRectTransform:GetSizeDeltaEx()

	self.breakFxVXRectSizeY = sizeY

	local _, posY = self.breakFxRectTransform:GetAnchoredPositionEx()

	self.breakFxVXRectPosY = posY

	self.dmgBoostUWidget:SetActive(true)

	self.dmgBoostUWidget.renderOpacity = 0
	self.imgHandleVisible = nil
	self.hpVisible = nil
	self.breakingCountDownVisible = nil
end

function BossBreakComp:cancelRevertBreakStateTimer()
	if self.revertBreakStateTimer then
		TimerManager.removeTimer(self.revertBreakStateTimer)

		self.revertBreakStateTimer = nil
	end
end

function BossBreakComp:refreshBreakBar(data, isIgnoreHpLock)
	Prof.count("breakMsg")

	if not self.owner.m_isCreated then
		return
	end

	if not data or not data.entity or not self.owner.curTarget or self.owner.curTarget.id ~= data.entity.id then
		return
	end

	local entity = data.entity
	local deltaBp = data.deltaBp or 0
	local info = Utils.getEntityBreakInfo(entity, self.breakInfo)

	Prof.beginSample("BossTitle.refreshBreak")

	local wasInBreak = self.owner.isPreInBreak == true

	self.owner.isCurInBreak = info.inBreakStatus and true or false

	if self.owner.isCurInBreak then
		if not wasInBreak then
			pg.game.audio:triggerEvent("ui_sfx_parmon_break")
			self.owner.rootComponent:TryChangePage("Break", 1)
		end

		self.dmgBoostUWidget.renderOpacity = 1

		local dmgBoostRatio = (1 + self.owner.curTarget.actorCombatAttribute:getAttribValue(AttributeConst.break_base_dmg_ratio)) * 100

		self.breakTxtUSDFText.text = string.format("%d%%", dmgBoostRatio)

		setWidgetActive(self, self.imgHandleUWidget, "imgHandleVisible", false)

		if not wasInBreak and not isIgnoreHpLock then
			self.owner.bloodFx:onBreakStarted(entity, isIgnoreHpLock)
		end

		if info.breakBuffFreezeTime ~= 0 then
			setWidgetActive(self, self.breakingCountDownUCountDown, "breakingCountDownVisible", true)
			self.breakingCountDownUCountDown:Play(math.max(info.breakEndTime - info.breakBuffFreezeTime, 0.01))
			self.breakingCountDownUCountDown:Stop()

			self.owner.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
			self.breakCountDownBarBreak.hp = 0
		else
			local now = pg.me:getGameTime()

			if ToBool(info.breakRecoverEndTime) then
				if self.owner.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop_Disappear")
					self.dmgBoostUWidget:InvokeCallback(DMG_BREAK_COUNT_DOWN_END_INDEX)
				end

				self.owner.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER

				local startTime = info.breakRecoverEndTime - info.breakRecoverTime
				local curVale = math.max(0.01, now - startTime)

				self:setBp(0, 0, info.breakRecoverTime)

				if info.breakRecoverFreezeTime == 0 then
					self.barBreakCountdown:Play(curVale, math.max(info.breakRecoverTime, 0.01))
				else
					self.barBreakCountdown:Play(math.max(info.breakRecoverEndTime - info.breakRecoverFreezeTime, 0.01), math.max(info.breakRecoverTime, 0.01))
					self.breakingCountDownUCountDown:Stop()
				end
			else
				setWidgetActive(self, self.breakingCountDownUCountDown, "breakingCountDownVisible", true)

				if self.owner.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop")
				end

				self:setBp(0, 0, info.breakTime)

				local countDownTime = math.max(math.min(info.breakTime, info.breakEndTime - now), 0.01)

				self.breakingCountDownUCountDown:Play(countDownTime)

				self.owner.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
				self.breakCountDownBarBreak.hp = 0
			end
		end
	elseif self.owner.breakState then
		self.owner.breakState = nil

		self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Recover")
		setWidgetActive(self, self.hpUWidget, "hpVisible", false)
		self.barBreakCountdown:Stop()
		self:cancelRevertBreakStateTimer()

		self.revertBreakStateTimer = TimerManager.addTimer(0.8, self.revertBreakState)

		self.dmgBoostUWidget:InvokeCallback(DMG_BREAK_RECOVER_END_INDEX)
		setWidgetActive(self, self.imgHandleUWidget, "imgHandleVisible", true)
		self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp, false)
		setWidgetActive(self, self.breakingCountDownUCountDown, "breakingCountDownVisible", false)
		self.owner.bloodFx:onBreakEnded(entity, isIgnoreHpLock)
	else
		self.dmgBoostUWidget.renderOpacity = 0

		self.barBreakCountdown:Stop()
		self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp)

		self.owner.breakState = nil

		setWidgetActive(self, self.breakingCountDownUCountDown, "breakingCountDownVisible", false)
	end

	self.owner.isPreInBreak = self.owner.isCurInBreak

	Prof.endSample()
end

function BossBreakComp:setBp(curValue, deltaValue, maxValue)
	if not self.owner.m_isCreated then
		return
	end

	self.barBreak:SetActive(true)

	curValue = curValue * 100
	deltaValue = deltaValue * 100
	maxValue = maxValue * 100

	local preValue = self.barBreak.hp or curValue

	self.barBreak.maxHp = maxValue
	self.barBreak.hp = curValue

	self:refreshBreakState(curValue, maxValue)
	self:refreshBreakShake(curValue, deltaValue, maxValue)

	if self.owner.isBpInit then
		self.owner.isBpInit = nil
	else
		self:onBreakBarDamage(preValue, curValue, maxValue)
	end
end

function BossBreakComp:refreshBreakState(curValue, maxValue)
	if not self.owner.m_isCreated then
		return
	end

	local page = "High"

	if maxValue > 0 then
		local percent = curValue / maxValue

		if percent >= 0 and percent < self.breakStateCutoffLower then
			page = "Low"
		elseif percent >= self.breakStateCutoffLower and percent < self.breakStateCutoffUpper then
			page = "Middle"
		end
	end

	self.owner.rootComponent:TryChangePage("BreakState", page)
end

function BossBreakComp:refreshBreakShake(curValue, deltaValue, maxValue)
	if not self.owner.m_isCreated then
		return
	end

	if deltaValue <= 0 or maxValue <= 0 then
		return
	end

	local percent = curValue / maxValue

	if percent < self.breakVibrationCutoffLower then
		self.bloodUComponent:InvokeCallback(BREAK_FXVX_USER2)
	elseif percent < self.breakVibrationCutoffUpper then
		self.bloodUComponent:InvokeCallback(BREAK_FXVX_USER1)
	end
end

function BossBreakComp:getBreakBigDmgRatio()
	return self.breakBigDmgRatio
end

function BossBreakComp:onBreakBarDamage(preValue, curValue, maxValue)
	if maxValue <= 0 then
		return
	end

	local delta = preValue - curValue

	if delta <= 0 then
		return
	end

	local topRatio = math.clamp(preValue / maxValue, 0, 1)
	local curRatio = math.clamp(curValue / maxValue, 0, 1)

	Prof.beginSample("BossTitle.breakDamage")
	self.vXBreakHandleUWidget:SetActiveFastest(true, true)
	self.owner.rootComponent:InvokeCallback(BREAK_FXVX_CUSTOM1)

	if delta / maxValue >= self.breakBigDmgRatio then
		self.owner.rootComponent:InvokeCallback(BREAK_FXVX_CUSTOM6)
	end

	self.breakFxCurrentRatio = curRatio

	RectUtil.startRetractTween(self.breakFxVXUImage, BREAK_FX_RETRACT_TWEEN_ID, topRatio, curRatio, BREAK_FXVX_TWEEN_SECOND, 0, self.breakFxTweenUpdate, self.breakFxTweenComplete)
	Prof.endSample()
end

function BossBreakComp:resetBreakBarFx()
	if IsNil(self.breakFxVXUImage) then
		return
	end

	DoTweenAnimMgr.Kill(self.breakFxVXUImage.gameObject, LuaUIUtils.TweenId(BREAK_FX_RETRACT_TWEEN_ID), false)
	self.vXBreakHandleUWidget:SetActiveFastest(false)
	RectUtil.applyRectByRatio(self.breakFxVXUImage, self.allHpWidth, self.breakFxVXRectSizeY, 0, 0, self.breakFxVXRectPosY)
end

function BossBreakComp:reset()
	self:cancelRevertBreakStateTimer()
	self:resetBreakBarFx()

	if self.barBreakCountdown then
		self.barBreakCountdown:Stop()
	end

	if self.breakingCountDownUCountDown then
		self.breakingCountDownUCountDown:Stop()
	end

	self.owner.isBpInit = true
	self.owner.isPreInBreak = false
	self.owner.isCurInBreak = false
	self.owner.breakState = nil

	if self.owner.rootComponent then
		self.owner.rootComponent:TryChangePage("Break", 0)
	end

	setWidgetActive(self, self.imgHandleUWidget, "imgHandleVisible", true, true)
	setWidgetActive(self, self.hpUWidget, "hpVisible", true, true)
	setWidgetActive(self, self.breakingCountDownUCountDown, "breakingCountDownVisible", false, true)

	self.breakFxCurrentRatio = nil
end

function BossBreakComp:destroy()
	self:reset()
end

return BossBreakComp
