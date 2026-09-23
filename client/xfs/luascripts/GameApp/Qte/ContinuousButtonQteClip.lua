-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\ContinuousButtonQteClip.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local QteClip = require("GameApp.Qte.QteClip")
local logger = LoggerManager.getLogger("ContinuousButtonQteClip")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ContinuousButtonQteClip = Class.LightClass("ContinuousButtonQteClip", QteClip)

ContinuousButtonQteClip.DEFAULT_HIT_EVENT_NAME = "qtePartHit"

function ContinuousButtonQteClip:onPrefabLoaded()
	ContinuousButtonQteClip.super.onPrefabLoaded(self)

	self.isStart = false
	self.hitCount = 0

	if self.gameObject then
		self.uComponent = self.gameObject:GetComponent("UComponent")
		self.keyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.gameObject, "continuousBtn")

		self:initButtonHotKey()
		self:refreshView()
		self:initPrefabPosition()
	end
end

function ContinuousButtonQteClip:initButtonHotKey()
	if self.keyBind then
		self.keyBind.priority = 100 - self.clipIndex

		function self.keyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self:onHit()
			end
		end

		self.keyBind.actionPath = self:getQteActionPath()
	end
end

function ContinuousButtonQteClip:refreshView()
	if not self.uComponent then
		return
	end

	local animSpeed = 1
	local canInteract = false
	local playFadeoutAnim = false

	if self.phase == QteDef.CLIP_PHASE.LOAD then
		-- block empty
	elseif self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		canInteract = true
	else
		playFadeoutAnim = self.phase == QteDef.CLIP_PHASE.RESULT_TIMEOUT and true or self.phase == QteDef.CLIP_PHASE.RESULT_GOOD and true or (self.phase ~= QteDef.CLIP_PHASE.DESTROY or true) and playFadeoutAnim
	end

	if canInteract and not self.isStart then
		self.isStart = true
	end

	if playFadeoutAnim then
		self:onFadeOut()
	end

	if canInteract then
		self.uComponent.visibility = CS.XGUI.EVisibility.Visible
	else
		self.uComponent.visibility = CS.XGUI.EVisibility.SelfHitTestInvisible
	end
end

function ContinuousButtonQteClip:onPhaseChange(oldPhase, phaseTime)
	if phaseTime == 0 then
		return
	end

	self:refreshView()
end

function ContinuousButtonQteClip:update(deltaTime)
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

function ContinuousButtonQteClip:onOperate()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj qteClip onOperate ", self:getDebugName(), " ", self.phase)
	end

	if self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		self.hitCount = self.hitCount + 1

		if ToBool(self.maxHitCount) and self.hitCount >= self.maxHitCount then
			self:changePhase(QteDef.CLIP_PHASE.RESULT_GOOD)
			self:pushResult(QteDef.QTE_CLIP_RESULT.GOOD, {
				clipHitCount = self.hitCount
			})
		end
	end
end

function ContinuousButtonQteClip:onStart()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("hyj qteClip onStart ", self:getDebugName())
	end

	self.maxHitCount = self.clipData.maxHitCount
end

function ContinuousButtonQteClip:onTimeout()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("hyj qteClip onTimeout ", self:getDebugName())
	end

	self:changePhase(QteDef.CLIP_PHASE.RESULT_TIMEOUT)
	self:pushResult(QteDef.QTE_CLIP_RESULT.TIMEOUT, {
		clipHitCount = self.hitCount
	})
end

function ContinuousButtonQteClip:onHit()
	self:operate()

	if self.uComponent then
		self.uComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	self:triggerEvent(self.clipData.hitEvent or self.DEFAULT_HIT_EVENT_NAME, {})

	local player = pg.pawn

	if player then
		player:postComponentMethod("onContinuousButtonQteHit")
	end
end

function ContinuousButtonQteClip:onFadeOut()
	if self.uComponent then
		self.uComponent:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

function ContinuousButtonQteClip:clickBySkillButton()
	if not self:canClickBySkillButton() then
		return false
	end

	self:onHit()

	return true
end

return ContinuousButtonQteClip
