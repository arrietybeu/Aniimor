-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientCatchBall.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SysConfigData = require("Data.sys_config_data")
local FormulaData = require("Data.formula_data")
local catch_config_data = require("Data.catch_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local CaptureWizard = require("GameApp.Capture.CaptureWizard")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local AbilityConst = require("Common.Const.AbilityConst")
local CaptureConst = require("Common.Const.CaptureConst")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientMainAuthorityBall = require("Entities.SpaceEntities.BallEntities.ClientMainAuthorityBall")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local GmToolUtils = require("Utils.GmToolUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Vector3 = Vector3
local Quaternion = CS.UnityEngine.Quaternion
local ClientCatchBall = class.Class("ClientCatchBall", ClientMainAuthorityBall)

function ClientCatchBall:onBallCreated()
	ClientCatchBall.super.onBallCreated(self)

	self.remainColl = self.ballData.maxColl
	self.createTime = Time.realSecondCache
end

function ClientCatchBall:destroy()
	self.remainColl = nil
	self.createTime = nil

	local hasPendingLuckyRewardEffect = self.luckyRewardEffectTimer ~= nil

	self:_clearLuckyRewardEffectTimer()

	if hasPendingLuckyRewardEffect then
		self.master:resolveLuckyPetTipDelay(self.captureSessionId, 0)
	end

	self:_stopCaptureCloseup()
	ClientCatchBall.super.destroy(self)
end

function ClientCatchBall:_startCaptureCloseup(puppetEnt)
	if self._closeupActive then
		return
	end

	if not GmToolUtils.getCaptureCloseupEnable() then
		return
	end

	if Utils.isSelfInSpaceFishingCaptureDungeon(pg.me) then
		return
	end

	if not puppetEnt or not puppetEnt.eModel or not puppetEnt.eModel:CheckPositionAgent() then
		return
	end

	local cfg = CaptureConst.CLOSEUP_CAMERA
	local distance = GmToolUtils.getCaptureCloseupDistance()
	local cameraPos = pg.game.camera:getCameraPosition()
	local px, py, pz = puppetEnt.eModel:GetPositionAgentPosEx()
	local puppetPos = Vector3.New(px, py + puppetEnt:getHeight() * 0.5, pz)

	if Vector3.Distance(puppetPos, cameraPos) < 0.01 then
		return
	end

	local dir = (puppetPos - cameraPos).normalized
	local cameraWorldPos = cameraPos + dir * distance
	local cameraWorldRot = Quaternion.LookRotation(puppetPos - cameraWorldPos)

	pg.game.camera:cameraBlendToFixed(cameraWorldPos, cameraWorldRot, cfg.FOV, cfg.BLEND_IN)

	self._closeupActive = true
end

function ClientCatchBall:_stopCaptureCloseup()
	if not self._closeupActive then
		return
	end

	self._closeupActive = false

	pg.game.camera:cancelBlendToFixed(CaptureConst.CLOSEUP_CAMERA.BLEND_OUT)
end

function ClientCatchBall:isBallReady()
	if not self.createTime then
		return false
	end

	local cdTime
	local isFastThrowMode = false

	isFastThrowMode = pg.global.ui.hudV2:checkFastThrowMode()
	cdTime = isFastThrowMode and 0 or catch_config_data.CATCH_BALL_READY_TIME or 0.3

	return cdTime < Time.realSecondCache - self.createTime
end

function ClientCatchBall:fire(velocity)
	if self.fired then
		return
	end

	if not self.ballComponent then
		if pg.logError() then
			self.logger:error("@capture CatchBall fire: ballComponent nil, skip")
		end

		return
	end

	ClientCatchBall.super.fire(self)
	self.ballComponent:FireByCamera(pg.game.camera.playerCameraMode.catchCamera.cameraMode, SysConfigData.THROWBALL_STARTPOINT_DISTANCE, SysConfigData.THROWBALL_CAMERA_ANGLE, self.ballData.maxV * (1 + self.master.actorCombatAttribute:getAttribRatioValue(AttributeConst.throw_init_ball_speed_ratio_v)), self.ballData.antiGTime or 0, SysConfigData.THROWBALL_STARTPOINT_ANGLE, self.ballData.extraGCurve)
end

function ClientCatchBall:quickFire(target, speed)
	if self.fired then
		return
	end

	ClientCatchBall.super.quickFire(self)
	self.ballComponent:FlyTo(target.eModel, speed)
end

function ClientCatchBall:getConfigData()
	ClientCatchBall.super.getConfigData(self)

	self.timelineInputConfig.CatchBallShowIdx = self.catchBallShowIdx
	self.timelineInputConfig.CaptureResultType = self.captureResultType

	return self.timelineInputConfig
end

function ClientCatchBall:onLuaHitCollider()
	if self.clientDestroyed or self.catching or self.hitRpcPending or not self.ballGameObject then
		return
	end

	ClientCatchBall.super.onLuaHitCollider(self)

	self.remainColl = self.remainColl - 1

	self:setCollisionTimeOut(false)

	if self.remainColl == 0 then
		self:clientDestroy()
	else
		self:setCollisionTimeOut(true, SysConfigData.CATCH_BALL_CLIENT_DESTROY_DELAY_TIME)
	end
end

function ClientCatchBall:onLuaHitEntity(hitEntityId)
	if not self:hitEntityValid(hitEntityId) then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if hitEntity.listenBallHitInteractEvent ~= nil then
		local interactId = hitEntity.listenBallHitInteractEvent.interactId
		local sandBoxId = hitEntity.listenBallHitInteractEvent.sandboxId
		local doOnce = hitEntity.listenBallHitInteractEvent.doOnce

		pg.me:serverMsg("RPC_CS_InteractNpcSandboxCustomEvent", interactId, sandBoxId, doOnce)
		hitEntity.listenBallHitInteractEvent.callback()

		if doOnce then
			hitEntity:enableListenBallHitEvent(interactId, false)
		end
	end

	pg.me:serverSpaceMsg("RPC_CS_HitPuppet", {
		hitEntityId
	})

	local context = CatchProbContext.clientGet(hitEntity, self.itemId)
	local lastHit = self.eModel:GetLastHit()
	local ballHitPos = lastHit ~= Vector3.constZero and lastHit or nil

	if not context.canCatch then
		local reason = context.cantCatchReason

		ClientCatchBall.super.onLuaHitEntity(self, hitEntityId, false, nil, nil, reason, ballHitPos)

		return
	end

	self:setCollisionTimeOut(false)

	self.prob = context.finalProb

	ClientCatchBall.super.onLuaHitEntity(self, hitEntityId, true, self.prob, context.fromBehind, nil, ballHitPos)

	self.catchBallShowIdx = ClientCaptureUtils.getCaptureTimelineShowIdx(self.prob)
end

function ClientCatchBall:onLuaNoticeFinished()
	self:_stopCaptureCloseup()

	local entId = self.entityIds and self.entityIds[1]

	if not entId then
		return
	end

	local result = self.results and self.results[1]

	self:_logLuckyPresentationFinished(entId, result)

	if not result then
		CaptureWizard.advise(self.prob)
	else
		self.master:postComponentMethod("OnPetProud")

		if self.ballData.forceShiny == 1 then
			pg.global.showBubbleMessageById(NoticeDef.CATCH_BALL_SHINY, LuaUIUtils.getNameByItemId(self.itemId))
		end
	end

	ClientCatchBall.super.onLuaNoticeFinished(self, entId)
end

function ClientCatchBall:_enterCatchingState()
	if self.catching or not self.fired then
		return false
	end

	self.catching = true

	self:setCollisionTimeOut(false)

	return true
end

function ClientCatchBall:doCaptureStart()
	if not self:_enterCatchingState() then
		return
	end

	ClientCatchBall.super.doCaptureStart(self)
end

function ClientCatchBall:onCaptureAnimStart(puppetInfos, clientParam)
	ClientCatchBall.super.onCaptureAnimStart(self, puppetInfos, clientParam)

	local entityId = puppetInfos[1].entId
	local puppetEnt = pg.getEntity(entityId)
	local timelineId = CaptureConst.CAPTURE_NORMAL_BALL_ABSORB_TIMELINE

	self.entityIds = {
		entityId
	}

	self:playTimeline(timelineId, puppetEnt, "onLuaCommonAniEnd")
	self:sendEventMsg("onCaptureAnimStart", {
		{
			entityId
		},
		timelineId,
		{}
	})
	self:_startCaptureCloseup(puppetEnt)
end

function ClientCatchBall:onCaptureSecondAnimStart(puppetInfos, clientParam)
	ClientCatchBall.super.onCaptureSecondAnimStart(self, puppetInfos, clientParam)

	local entityId = puppetInfos[1].entId
	local puppetEnt = pg.getEntity(entityId)
	local timelineId = CaptureConst.CAPTURE_NORMAL_BALL_STRUGGLE_TIMELINE

	self:playTimeline(timelineId, puppetEnt, "onLuaCommonAniEnd")
	self:sendEventMsg("onCaptureSecondAnimStart", {
		{
			entityId
		},
		timelineId,
		{
			CatchBallShowIdx = self.catchBallShowIdx
		}
	})
end

function ClientCatchBall:onCaptureAnimEnd(puppetInfos, clientArgs)
	ClientCatchBall.super.onCaptureAnimEnd(self, puppetInfos, clientArgs)

	local entityId = puppetInfos[1].entId
	local result = puppetInfos[1].captureSuccess

	self:_playCaptureResultPresentation(entityId, result)
end

function ClientCatchBall:_tryPlayLuckyHitPresentation(hitEntityId)
	if not self:_isLuckyRewardEffect() then
		self.master:resolveLuckyPetTipDelay(self.captureSessionId, nil)

		return false
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture lucky hit rpc result, captureSessionId=%s, ballUid=%s, hitEntityId=%s, luckyResult=%s, rainbowEnergyLevel=%s, luckyItemDic=%s", self.captureSessionId, self.ballUid, hitEntityId, self.luckyResult, self.rainbowEnergyLevel, inspect(self.luckyItemDic))
	end

	if not self:_enterCatchingState() then
		self.master:resolveLuckyPetTipDelay(self.captureSessionId, nil)

		return true
	end

	self:_playCaptureResultPresentation(hitEntityId, true)
	self:_cancelPuppetsCaptureRestoreFallback(self.entityIds)

	return true
end

function ClientCatchBall:_clearLuckyRewardEffectTimer()
	if self.luckyRewardEffectTimer == nil then
		return
	end

	self:removeTimer(self.luckyRewardEffectTimer)

	self.luckyRewardEffectTimer = nil
end

function ClientCatchBall:_onLuckyRewardEffectDelayEnd(effectPlan, targetEntityId)
	self.luckyRewardEffectTimer = nil

	local batchId = self:_playLuckyRewardEffect(effectPlan, true, targetEntityId)
	local _, _, totalDuration = self:_getLuckyPresentationTiming(self.luckyResult, self.rainbowEnergyLevel)
	local petTipDelay = batchId ~= nil and totalDuration or 0

	self.master:resolveLuckyPetTipDelay(self.captureSessionId, petTipDelay)
end

function ClientCatchBall:_scheduleLuckyRewardEffect(effectPlan, targetEntityId, delaySeconds)
	if effectPlan == nil then
		return
	end

	self:_clearLuckyRewardEffectTimer()

	self.luckyRewardEffectTimer = self:addTimer(delaySeconds or 0, CallbackHandler(self, "_onLuckyRewardEffectDelayEnd", effectPlan, targetEntityId))
end

function ClientCatchBall:_isLuckyRewardEffect()
	local result = LeylineFlowerConst.LUCKY_EVENT_RESULT

	return self.luckyResult == result.Success or self.luckyResult == result.SuperSucess
end

function ClientCatchBall:_getCaptureResultTimelineId()
	if not self:_isLuckyRewardEffect() then
		return CaptureConst.CAPTURE_NORMAL_BALL_RESULT_TIMELINE
	end

	return CaptureConst.CAPTURE_NORMAL_BALL_LUCKY_RESULT_TIMELINE
end

function ClientCatchBall:_getLuckyEffectPlan()
	if not self:_isLuckyRewardEffect() then
		return nil
	end

	return self:_buildLuckyEffectPlan(self.luckyResult, self.rainbowEnergyLevel, self.luckyItemDic)
end

function ClientCatchBall:_logLuckyOwnerPresentationStart(entityId, timelineId, effectPlan)
	if self:_isLuckyRewardEffect() and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture lucky owner presentation start, captureSessionId=%s, ballUid=%s, hitEntityId=%s, timelineId=%s, effectPlan=%s, showTips=true", self.captureSessionId, self.ballUid, entityId, timelineId, inspect(effectPlan))
	end
end

function ClientCatchBall:_logLuckyPresentationFinished(entityId, result)
	if self:_isLuckyRewardEffect() and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture lucky presentation finished, captureSessionId=%s, ballUid=%s, hitEntityId=%s, result=%s", self.captureSessionId, self.ballUid, entityId, result)
	end
end

function ClientCatchBall:_buildLuckyEffectPlan(luckyResult, rainbowEnergyLevel, luckyItemDic)
	if luckyResult == nil or rainbowEnergyLevel == nil or luckyItemDic == nil then
		return nil
	end

	local formulaData = FormulaData[SysConfigData.CATCH_LUCKY_REWARD_DISPLAY_FORMULA]

	if not formulaData or formulaData.formula == nil then
		return nil
	end

	local itemCountMap = {}

	for itemId, itemNum in pairs(luckyItemDic) do
		if type(itemId) == "number" then
			itemCountMap[itemId] = itemNum
		end
	end

	local rawPlan = formulaData.formula(luckyResult, rainbowEnergyLevel, itemCountMap)

	if rawPlan == nil then
		return nil
	end

	local effectPlan = {}

	for _, waveData in ipairs(rawPlan) do
		if waveData[1] ~= nil and waveData[2] ~= nil and waveData[3] ~= nil and waveData[4] ~= nil then
			local lightQualities = {}

			for i, quality in ipairs(waveData[4]) do
				lightQualities[i] = quality
			end

			effectPlan[#effectPlan + 1] = {
				waveData[1],
				waveData[2],
				waveData[3],
				lightQualities
			}
		end
	end

	return #effectPlan > 0 and effectPlan or nil
end

function ClientCatchBall:_onHitEntityRpcRejected()
	if self.destroyed or self.clientDestroyed or self.catching then
		return
	end

	self:setCollisionTimeOut(true, SysConfigData.CATCH_BALL_CLIENT_DESTROY_DELAY_TIME)
end

function ClientCatchBall:_playCaptureResultPresentation(entityId, result)
	self.entityIds = {
		entityId
	}
	self.results = {
		result
	}

	local effectPlan = self:_getLuckyEffectPlan()
	local timelineId = self:_getCaptureResultTimelineId()

	self:_logLuckyOwnerPresentationStart(entityId, timelineId, effectPlan)
	self:playTimeline(timelineId, pg.getEntity(entityId), "onLuaNoticeFinished")

	if effectPlan ~= nil then
		local delaySeconds = self:_getLuckyPresentationTiming(self.luckyResult, self.rainbowEnergyLevel)

		self:_scheduleLuckyRewardEffect(effectPlan, entityId, delaySeconds)
	elseif self:_isLuckyRewardEffect() then
		self.master:resolveLuckyPetTipDelay(self.captureSessionId, 0)
	end

	self:sendEventMsg("onCaptureAnimEnd", {
		{
			entityId
		},
		{
			result
		},
		timelineId,
		self.luckyResult,
		self.rainbowEnergyLevel
	})
end

function ClientCatchBall:setCollisionTimeOut(enable, delay)
	if pg.logInfo() then
		self.logger:info("@capture setCollisionTimeOut", enable, self.catching, self.remainColl, self.ballUid, self.captureSessionId, debug.traceback())
	end

	if self.collideTimeoutTimer then
		self:removeTimer(self.collideTimeoutTimer)

		self.collideTimeoutTimer = nil
	end

	if enable then
		self.collideTimeoutTimer = self:addTimer(delay, CallbackHandler(self, "clientDestroy"))
	end
end

function ClientCatchBall:hitEntityValid(hitEntityId)
	if self.destroyed or self.catching or not self.fired or self.clientDestroyed then
		if self.clientDestroyed and not self.catching and LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("@capture CatchBall:onHitEntity failed!!! clientDestroyed is true!!!", self.id, hitEntityId)
		end

		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity or hitEntity.destroyed or hitEntity.className ~= "ClientPuppet" and hitEntity.className ~= "ClientPuppetGhost" then
		return
	end

	return true
end

return ClientCatchBall
