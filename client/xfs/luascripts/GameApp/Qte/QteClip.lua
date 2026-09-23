-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Qte\\QteClip.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local QteDef = require("GameApp.Qte.QteDef")
local logger = LoggerManager.getLogger("QteClip")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local QteClip = Class.LightClass("QteClip")

function QteClip:ctor(timeline, clipData)
	self.timeline = timeline
	self.clipData = clipData or {}
	self.phase = QteDef.CLIP_PHASE.NONE
	self.clipIndex = 0

	self:onCtor()
end

function QteClip:start(curTime)
	self.failTime = self.clipData.failTime or 0
	self.goodTime = self.clipData.goodTime or 0
	self.perfectTime = self.clipData.perfectTime or 0
	self.goodTime2 = self.clipData.goodTime2 or 0
	self.loadTime = self.clipData.loadTime or 0.3
	self.operateTime = self.failTime + self.goodTime + self.perfectTime + self.goodTime2
	self.unloadTime = self.clipData.unloadTime or 0.3
	self.curTime = curTime

	self:calcDuration()
	self:loadPrefab(self.clipData.prefabResID)
	self:onStart()
	self:changePhase(QteDef.CLIP_PHASE.LOAD)
end

function QteClip:calcDuration()
	self.duration = self.failTime + self.loadTime + self.unloadTime + self.perfectTime + self.goodTime2

	if self.goodTime > 0 then
		self.duration = self.duration + self.goodTime
	end
end

function QteClip:getQteActionPath()
	if self.clipData.keyType == QteDef.QTE_KEY_TYPE.BY_SKILL then
		local context = self.timeline.context

		if context and context.abilityId then
			local actionPath = LuaUIUtils.getSkillActionPath(context.abilityId)

			if actionPath then
				return actionPath
			end
		end
	end

	return self.clipData.actionPath or ""
end

function QteClip:getQteIcon()
	if self.clipData.keyType == QteDef.QTE_KEY_TYPE.BY_SKILL then
		local context = self.timeline.context

		if context and context.abilityId then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(context.abilityId)
			local skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon)

			if skillIcon then
				return skillIcon
			end
		end
	end

	return nil
end

function QteClip:getQteElementType()
	if self.clipData.keyType == QteDef.QTE_KEY_TYPE.BY_SKILL then
		local context = self.timeline.context

		if context and context.abilityId then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(context.abilityId)

			return abilityParamData.elementType
		end
	end

	return nil
end

function QteClip:update(deltaTime)
	if self.phase == QteDef.CLIP_PHASE.DESTROY or self.phase == QteDef.CLIP_PHASE.NONE then
		return false
	end

	self.curTime = self.curTime + deltaTime

	self:onUpdate(deltaTime)

	if self.phase == QteDef.CLIP_PHASE.LOAD and self.curTime >= self.loadTime then
		self:changePhase(QteDef.CLIP_PHASE.FAIL_RANGE)
	end

	if self.phase == QteDef.CLIP_PHASE.FAIL_RANGE and self.curTime >= self.failTime then
		self:changePhase(QteDef.CLIP_PHASE.GOOD_RANGE, self.goodTime)
	end

	if self.phase == QteDef.CLIP_PHASE.GOOD_RANGE then
		if self.goodTime < 0 then
			return true
		end

		if self.curTime >= self.goodTime then
			self:changePhase(QteDef.CLIP_PHASE.PERFECT_RANGE, self.perfectTime)
		end
	end

	if self.phase == QteDef.CLIP_PHASE.PERFECT_RANGE and self.curTime >= self.perfectTime then
		self:changePhase(QteDef.CLIP_PHASE.GOOD_RANGE2, self.goodTime2)
	end

	if self.phase == QteDef.CLIP_PHASE.GOOD_RANGE2 and self.curTime >= self.goodTime2 then
		self:onTimeout()
	end

	if self:isUnloadPhase(self.phase) and self.curTime >= self.unloadTime then
		self:changePhase(QteDef.CLIP_PHASE.DESTROY)
	end

	return false
end

function QteClip:operate()
	self:onOperate()
end

function QteClip:destroy()
	self:changePhase(QteDef.CLIP_PHASE.DESTROY)
	self:onDestroy()
	self:destroyPrefab()

	self.timeline = nil
end

function QteClip:isFinish()
	return self.phase == QteDef.CLIP_PHASE.DESTROY
end

function QteClip:changePhase(phase, phaseTime)
	if self.phase ~= phase then
		local oldPhase = self.phase

		self.phase = phase
		self.curTime = 0

		self:onPhaseChange(oldPhase, phaseTime)
	end
end

function QteClip:isUnloadPhase(phase)
	return phase == QteDef.CLIP_PHASE.RESULT_TIMEOUT or phase == QteDef.CLIP_PHASE.RESULT_FAIL or phase == QteDef.CLIP_PHASE.RESULT_GOOD or phase == QteDef.CLIP_PHASE.RESULT_PERFECT
end

function QteClip:onOperate()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onOperate ", self:getDebugName(), " ", self.phase)
	end

	if self.phase == QteDef.CLIP_PHASE.FAIL_RANGE then
		self:changePhase(QteDef.CLIP_PHASE.RESULT_FAIL)
		self:pushResult(QteDef.QTE_CLIP_RESULT.FAIL)
	elseif self.phase == QteDef.CLIP_PHASE.GOOD_RANGE or self.phase == QteDef.CLIP_PHASE.GOOD_RANGE2 then
		self:changePhase(QteDef.CLIP_PHASE.RESULT_GOOD)
		self:pushResult(QteDef.QTE_CLIP_RESULT.GOOD)
	elseif self.phase == QteDef.CLIP_PHASE.PERFECT_RANGE then
		self:changePhase(QteDef.CLIP_PHASE.RESULT_PERFECT)
		self:pushResult(QteDef.QTE_CLIP_RESULT.PERFECT)
	end
end

function QteClip:onTimeout()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onTimeout ", self:getDebugName())
	end

	self:changePhase(QteDef.CLIP_PHASE.RESULT_TIMEOUT)
	self:pushResult(QteDef.QTE_CLIP_RESULT.TIMEOUT)
end

function QteClip:pushResult(resultType, customData)
	self:onResult(resultType, customData)

	if self.timeline then
		self.timeline:onClipResult(self, resultType)
	end
end

function QteClip:onResult(resultType, customData)
	if resultType == QteDef.QTE_CLIP_RESULT.FAIL then
		pg.game.audio:playEvent(self.clipData.failSound)
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.QTE_CLIP, self.clipData.failRumble)
		self:triggerEvent(self.clipData.failEvent, customData)
	elseif resultType == QteDef.QTE_CLIP_RESULT.TIMEOUT then
		pg.game.audio:playEvent(self.clipData.timeoutSound)
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.QTE_CLIP, self.clipData.timeoutRumble)
		self:triggerEvent(self.clipData.timeoutEvent, customData)
	elseif resultType == QteDef.QTE_CLIP_RESULT.GOOD then
		pg.game.audio:playEvent(self.clipData.goodSound)
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.QTE_CLIP, self.clipData.goodRumble)
		self:triggerEvent(self.clipData.goodEvent, customData)
	elseif resultType == QteDef.QTE_CLIP_RESULT.PERFECT then
		pg.game.audio:playEvent(self.clipData.perfectSound)
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.QTE_CLIP, self.clipData.perfectRumble)
		self:triggerEvent(self.clipData.perfectEvent, customData)
	end
end

function QteClip:triggerEvent(eventName, customData)
	if string.isNilOrEmpty(eventName) then
		return
	end

	self.timeline:triggerEvent(eventName, customData)
end

function QteClip:loadPrefab(resId)
	pg.global.ui.qte:instanceQtePrefab(self, resId)
end

function QteClip:destroyPrefab()
	if self.gameObject then
		pg.global.ui.qte:destroyQtePrefab(self.gameObject)

		self.gameObject = nil
	end
end

function QteClip:prefabLoaded(gameObject)
	self.gameObject = gameObject

	self:onPrefabLoaded()
end

function QteClip:initPrefabPosition()
	return
end

function QteClip:getDebugName()
	return "qteClip/" .. tostring(self.timeline.groupId) .. "/" .. tostring(self.clipData.clipIndex)
end

function QteClip:onCtor()
	return
end

function QteClip:onStart()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onStart ", self:getDebugName())
	end
end

function QteClip:onDestroy()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onDestroy ", self:getDebugName())
	end
end

function QteClip:onPhaseChange(oldPhase, phaseTime)
	return
end

function QteClip:onUpdate(deltaTime)
	return
end

function QteClip:onPrefabLoaded()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("dxk qteClip onPrefabLoaded ", self:getDebugName())
	end
end

function QteClip:canClickBySkillButton()
	return self.phase == QteDef.CLIP_PHASE.FAIL_RANGE or self.phase == QteDef.CLIP_PHASE.GOOD_RANGE or self.phase == QteDef.CLIP_PHASE.PERFECT_RANGE or self.phase == QteDef.CLIP_PHASE.GOOD_RANGE2
end

function QteClip:clickBySkillButton()
	if not self:canClickBySkillButton() then
		return false
	end

	self:operate()

	return true
end

return QteClip
