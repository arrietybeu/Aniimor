-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\CountDownQteClip.lua

local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteClip = require("GameApp.Qte.QteClip")
local TimerManager = require("Core.Timer.TimerManager")
local CountDownQteClip = Class.LightClass("CountDownQteClip", QteClip)

function CountDownQteClip:onPrefabLoaded()
	CountDownQteClip.super.onPrefabLoaded(self)

	if self.gameObject then
		self.isStart = false
		self.uComponent = self.gameObject:GetComponent("UComponent")
		self.countDown = self.gameObject.transform:Find("BtnWidget/CountDown"):GetComponent("UCountDown")
		self.keyBind = self.gameObject:GetComponent("KeyBindingPro")

		self:initButtonHotKey()
		self:refreshView()
		self:initPrefabPosition()
	end
end

function CountDownQteClip:onDestroy()
	CountDownQteClip.super.onDestroy(self)

	self.uComponent = nil
	self.countDown = nil
	self.keyBind = nil
end

function CountDownQteClip:initButtonHotKey()
	if self.keyBind then
		self.keyBind.priority = 100 - self.clipIndex

		function self.keyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self:operate()
			end
		end

		self.keyBind.actionPath = self:getQteActionPath()
	end
end

function CountDownQteClip:refreshView()
	if not self.uComponent then
		return
	end

	local phaseStr = ""
	local canInteract = false
	local fadeOut = false

	if self.phase == QteDef.CLIP_PHASE.LOAD then
		phaseStr = "load"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.FAIL_RANGE then
		canInteract = true
		phaseStr = "failRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.GOOD_RANGE or self.phase == QteDef.CLIP_PHASE.GOOD_RANGE2 then
		canInteract = true
		phaseStr = "goodRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.PERFECT_RANGE then
		canInteract = true
		phaseStr = "perfectRange"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_TIMEOUT then
		phaseStr = "timeout"

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_FAIL then
		phaseStr = "fail"
		fadeOut = true

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_GOOD then
		phaseStr = "good"
		fadeOut = true

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.RESULT_PERFECT then
		phaseStr = "perfect"
		fadeOut = true

		self.uComponent:TryChangePage("qteState", phaseStr)
	elseif self.phase == QteDef.CLIP_PHASE.DESTROY then
		phaseStr = "none"

		self.uComponent:TryChangePage("qteState", phaseStr)
	end

	if canInteract and not self.isStart then
		self.isStart = true

		local duration = self.operateTime

		self.countDown:Play(duration, duration)
	end

	if fadeOut then
		self.countDown:Stop()
	end

	if canInteract then
		self.uComponent.visibility = CS.XGUI.EVisibility.Visible
	else
		self.uComponent.visibility = CS.XGUI.EVisibility.SelfHitTestInvisible
	end
end

function CountDownQteClip:onPhaseChange(oldPhase, phaseTime)
	if phaseTime == 0 then
		return
	end

	self:refreshView()
end

return CountDownQteClip
