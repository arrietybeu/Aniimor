-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\ComboQteClip.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteClip = require("GameApp.Qte.QteClip")
local logger = LoggerManager.getLogger("ComboQteClip")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ComboQteClip = Class.LightClass("ComboQteClip", QteClip)

ComboQteClip.DEFAULT_HIT_EVENT_NAME = "qtePartHit"

function ComboQteClip:onPrefabLoaded()
	ComboQteClip.super.onPrefabLoaded(self)

	self.isStart = false

	self:initClipParams()

	if self.gameObject then
		self.objectReference = self.gameObject:GetComponent("ObjectReference")
		self.uComponent = self.objectReference:GetRefValue("rootUComponent")
		self.comboQteUButton = self.objectReference:GetRefValue("comboQteUButton")
		self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
		self.hintUWidget = self.objectReference:GetRefValue("hintUWidget")
		self.keyHotKeyContent = self.objectReference:GetRefValue("keyHotKeyContent")

		LuaUIUtils.setUIViewVisible(self.progressUProgress, self.isShowProgress)

		if self.comboQteUButton then
			self.comboQteUButton.enabledIntervalClick = self.intervalClickDuration > 0
			self.comboQteUButton.intervalClickDuration = self.intervalClickDuration
		end

		self.keyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.gameObject, "comboBtn")

		self:initButtonHotKey()
		self:refreshProgress(false)
		self:refreshView()
		self:initPrefabPosition()
	end
end

function ComboQteClip:initButtonHotKey()
	if self.comboQteUButton then
		function self.comboQteUButton.luaClick()
			self:onHit()
			self:operate()
			pg.game.audio:triggerEvent("SFX_UI_QTE_Click")
		end
	end

	if self.keyBind then
		self.keyBind.priority = 100 - self.clipIndex
		self.keyBind.luaTrigger = nil
		self.keyBind.actionPath = self:getQteActionPath()

		self.keyHotKeyContent:SetHotKeyPaths(self:getQteActionPath())
	end

	self:initExitHotKey()
end

function ComboQteClip:initExitHotKey()
	local context = self.timeline and self.timeline.context
	local exitFunc = context and context.exitFunc

	if not exitFunc or IsNil(self.gameObject) then
		return
	end

	self.exitKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.gameObject, "comboExitBtn")

	if self.exitKeyBind then
		self.exitKeyBind.isVirtual = true
		self.exitKeyBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

		function self.exitKeyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				exitFunc()
			end
		end
	end
end

function ComboQteClip:refreshView()
	if not self.uComponent then
		return
	end

	local canInteract = false
	local playFadeoutAnim = false

	if self.phase == QteDef.CLIP_PHASE.LOAD then
		self.uComponent:TryChangePage("State", 0)
		self.hintUWidget:SetActive(true)

		self.progressUProgress.value = 0
	elseif self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		canInteract = true
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_TIMEOUT then
		playFadeoutAnim = true

		self.hintUWidget:SetActive(false)

		self.progressUProgress.value = 1

		self.uComponent:TryChangePage("State", 2)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_GOOD then
		playFadeoutAnim = true

		self.hintUWidget:SetActive(false)
		self.uComponent:TryChangePage("State", 1)
	elseif self.phase == QteDef.CLIP_PHASE.DESTROY then
		-- block empty
	end

	if canInteract and not self.isStart then
		self.isStart = true
	end

	if playFadeoutAnim then
		-- block empty
	end

	if canInteract then
		self.uComponent.visibility = CS.XGUI.EVisibility.Visible
	else
		self.uComponent.visibility = CS.XGUI.EVisibility.SelfHitTestInvisible
	end
end

function ComboQteClip:onPhaseChange(oldPhase, phaseTime)
	if phaseTime == 0 then
		return
	end

	self:refreshView()
end

function ComboQteClip:update(deltaTime)
	if self.phase == QteDef.CLIP_PHASE.DESTROY or self.phase == QteDef.CLIP_PHASE.NONE then
		return false
	end

	self.curTime = self.curTime + deltaTime

	self:onUpdate(deltaTime)

	if self.phase == QteDef.CLIP_PHASE.LOAD and self.curTime >= self.loadTime then
		self:changePhase(QteDef.CLIP_PHASE.GOOD_RANGE)
	end

	if self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		if self.goodTime < 0 then
			return true
		end

		if self.curTime >= self.goodTime then
			self:onTimeout()
		end
	end

	if self:isUnloadPhase(self.phase) and self.curTime >= self.unloadTime then
		self:changePhase(QteDef.CLIP_PHASE.DESTROY)
	end

	return false
end

function ComboQteClip:onOperate()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@wkq qteClip onOperate ", self:getDebugName(), " ", self.phase)
	end

	if self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		self.hitCount = self.hitCount + 1

		self:refreshProgress(true)

		if ToBool(self.maxHitCount) and self.hitCount >= self.maxHitCount then
			self:changePhase(QteDef.CLIP_PHASE.RESULT_GOOD)
			self:pushResult(QteDef.QTE_CLIP_RESULT.GOOD, {
				clipHitCount = self.hitCount
			})
		end
	end
end

function ComboQteClip:initClipParams()
	self.hitCount = self.hitCount or 0
	self.maxHitCount = self.clipData.maxHitCount or 1
	self.isShowProgress = self.clipData.showProgress and self.clipData.showProgress > 0 or false
	self.intervalClickDuration = self.clipData.comboInterval and self.clipData.comboInterval > 0 and self.clipData.comboInterval or 0
end

function ComboQteClip:onStart()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("wkq qteClip onStart ", self:getDebugName())
	end

	self:initClipParams()

	if self.clipData.lostCount and self.lostCountPerSecTimer == nil then
		self.lostCountPerSecTimer = TimerManager.addRepeatTimer(1, function()
			self.hitCount = (self.hitCount or 0) - self.clipData.lostCount
			self.hitCount = math.max(self.hitCount, 0)

			self:refreshProgress(true)
		end)
	end
end

function ComboQteClip:refreshProgress(useTween)
	if not self.uComponent then
		return
	end

	if not self.isShowProgress or self.maxHitCount <= 0 then
		return
	end

	local progress = math.min(self.hitCount / self.maxHitCount, 1)

	if useTween then
		self.progressUProgress:ProgressToValue(progress, nil, 0.2)
	else
		self.progressUProgress.value = progress
	end
end

function ComboQteClip:onTimeout()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("wkq qteClip onTimeout ", self:getDebugName())
	end

	self:changePhase(QteDef.CLIP_PHASE.RESULT_TIMEOUT)
	self:pushResult(QteDef.QTE_CLIP_RESULT.TIMEOUT, {
		clipHitCount = self.hitCount
	})
end

function ComboQteClip:onHit()
	if self.uComponent then
		self.uComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	self:triggerEvent(self.clipData.hitEvent or self.DEFAULT_HIT_EVENT_NAME, {
		clipHitPercent = self.hitCount / self.maxHitCount
	})

	local player = pg.pawn

	if player then
		-- block empty
	end
end

function ComboQteClip:onFadeOut()
	if self.uComponent then
		self.uComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end
end

function ComboQteClip:onDestroy()
	if self.exitKeyBind then
		self.exitKeyBind.luaTrigger = nil
		self.exitKeyBind = nil
	end

	if self.lostCountPerSecTimer ~= nil then
		TimerManager.removeTimer(self.lostCountPerSecTimer)

		self.lostCountPerSecTimer = nil
	end
end

function ComboQteClip:clickBySkillButton()
	if not self:canClickBySkillButton() then
		return false
	end

	self:operate()
	pg.game.audio:triggerEvent("SFX_UI_QTE_Click")

	return true
end

return ComboQteClip
