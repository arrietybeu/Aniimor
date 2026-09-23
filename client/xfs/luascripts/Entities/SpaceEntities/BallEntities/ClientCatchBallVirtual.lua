-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientCatchBallVirtual.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientCatchBallFake = require("Entities.SpaceEntities.BallEntities.ClientCatchBallFake")
local ClientModelEntity = require("Entities.ClientModelEntity")
local CaptureConst = require("Common.Const.CaptureConst")
local VirtualCatchProbContext = require("Common.Utils.VirtualCatchProbContext")
local AttributeConst = require("Common.Const.AttributeConst")
local SysConfigData = require("Data.sys_config_data")
local CaptureWizard = require("GameApp.Capture.CaptureWizard")
local NoticeDef = require("Common.NoticeDef")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local PetData = require("Data.pet_data")
local PuppetData = require("Data.puppet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Vector3 = Vector3
local ActorManager = require("Core.Common.ActorManager")
local logger = LoggerManager.getLogger("ClientCatchBallVirtual")
local ClientCatchBallVirtual = class.Class("ClientCatchBallVirtual", ClientCatchBallFake)

function ClientCatchBallVirtual:enterSpace(space)
	space = space or self.master and self.master.space

	if not space then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture enterSpace: no space available, skip join")
		end

		return
	end

	ClientCatchBallVirtual.super.enterSpace(self, space)
end

function ClientCatchBallVirtual:virtualFire(velocity)
	if self.fired then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture virtualFire: already fired, skip")
		end

		return false
	end

	if not self.ballComponent then
		if pg.logError() then
			logger:error("@virtualCapture virtualFire: ballComponent nil, skip")
		end

		return false
	end

	self:onLuaFire()

	if not self.isInScene then
		self:setInScene(true)
	end

	self.remainColl = self.ballData.maxColl

	local ballData = self.ballData
	local masterAttr = self.master.actorCombatAttribute
	local v = velocity * (1 + masterAttr:getAttribRatioValue(AttributeConst.throw_init_ball_speed_ratio_v))

	self.ballComponent:FireByCamera(pg.game.camera.playerCameraMode.catchCamera.cameraMode, SysConfigData.THROWBALL_STARTPOINT_DISTANCE, SysConfigData.THROWBALL_CAMERA_ANGLE, v, ballData.antiGTime or 0, SysConfigData.THROWBALL_STARTPOINT_ANGLE, ballData.extraGCurve)

	self._maxLifetimeTimer = TimerManager.addTimer(SysConfigData.VIRTUAL_BALL_MAX_LIFETIME or 30, function()
		self._maxLifetimeTimer = nil

		if not self.clientDestroyed and not self.catching then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("@virtualCapture max lifetime timeout, force clientDestroy ballUid=%s", tostring(self.ballUid))
			end

			self:clientDestroy()
		end
	end)

	return true
end

function ClientCatchBallVirtual:setCollisionTimeOut(enable, delay)
	if self._collisionTimeoutTimer then
		TimerManager.removeTimer(self._collisionTimeoutTimer)

		self._collisionTimeoutTimer = nil
	end

	if enable then
		local d = delay or SysConfigData.CATCH_BALL_CLIENT_DESTROY_DELAY_TIME

		self._collisionTimeoutTimer = TimerManager.addTimer(d, function()
			self._collisionTimeoutTimer = nil

			if self.clientDestroyed or self.catching then
				return
			end

			self:clientDestroy()
		end)
	end
end

function ClientCatchBallVirtual:_consumeOneCollision()
	self.remainColl = (self.remainColl or 0) - 1

	self:setCollisionTimeOut(false)

	if self.remainColl <= 0 then
		self:clientDestroy()
	else
		self:setCollisionTimeOut(true, SysConfigData.CATCH_BALL_CLIENT_DESTROY_DELAY_TIME)
	end
end

function ClientCatchBallVirtual:onLuaHitEntity(hitEntityId)
	if self.destroyed or self.catching or not self.fired or self.clientDestroyed then
		return
	end

	if not self:checkEModel() then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity or hitEntity.className ~= "ClientPuppet" and hitEntity.className ~= "ClientPuppetGhost" and hitEntity.className ~= "ClientOfflinePuppet" then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture onLuaHitEntity: non-puppet hit (id=%s), consume collision", tostring(hitEntityId))
		end

		self:_consumeOneCollision()

		return
	end

	if not hitEntity.eModel then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture onLuaHitEntity: hitEntity.eModel is nil, fallback to consume one collision")
		end

		self:_consumeOneCollision()

		return
	end

	if hitEntity.isTrapped then
		self:_consumeOneCollision()

		return
	end

	local probCtx = VirtualCatchProbContext.compute(self.master, hitEntity, self.itemId)

	if not probCtx.canCatch then
		local reason = probCtx.cantCatchReason
		local hitPos = self.eModel:GetLastHit()

		self.eModel:OnHitEntity(hitEntity.eModel, false, nil, probCtx.fromBehind, reason, hitPos)
		self:_consumeOneCollision()

		return
	end

	self:setCollisionTimeOut(false)

	if self._maxLifetimeTimer then
		TimerManager.removeTimer(self._maxLifetimeTimer)

		self._maxLifetimeTimer = nil
	end

	self.prob = probCtx.finalProb or 0
	self.finalProb = self.prob
	self.catchBallShowIdx = ClientCaptureUtils.getCaptureTimelineShowIdx(self.prob)
	self._presetResult = math.random() < self.prob
	self.entIdInBall = hitEntityId
	self._virtualTarget = hitEntity
	self.hitEntityActorId = hitEntity.actorId
	self.ballHitPos = self.eModel:GetLastHit()
	self.catching = true

	hitEntity:trapped()
	self.eModel:OnHitEntity(hitEntity.eModel, true, self.prob, probCtx.fromBehind, nil, self.ballHitPos)
	self:_startVirtualCaptureTimeline(hitEntity)
end

function ClientCatchBallVirtual:getConfigData()
	local cfg = ClientCatchBallVirtual.super.getConfigData(self)

	if cfg then
		cfg.CatchBallShowIdx = self.catchBallShowIdx
	end

	return cfg
end

function ClientCatchBallVirtual:_playStageTimeline(timelineId, hitEntity, nextStageMethod)
	function self.onTimelineEnd(_comp, endedId)
		if endedId ~= timelineId then
			return
		end

		self.onTimelineEnd = nil

		if self.clientDestroyed or self.destroyed then
			return
		end

		self[nextStageMethod](self)
	end

	self:playTimeline(timelineId, hitEntity)
end

function ClientCatchBallVirtual:_startVirtualCaptureTimeline(hitEntity)
	local absorbId = CaptureConst.CAPTURE_NORMAL_BALL_PRE_TIMELINE

	if absorbId and hitEntity then
		self:_playStageTimeline(absorbId, hitEntity, "_onVirtualStruggleEnd")
	else
		self:_onVirtualStruggleEnd()
	end
end

function ClientCatchBallVirtual:_onVirtualAbsorbEnd()
	local hitEntity = self.entIdInBall and pg.getEntity(self.entIdInBall)
	local struggleId = CaptureConst.CAPTURE_NORMAL_BALL_STRUGGLE_TIMELINE

	if struggleId and hitEntity then
		self:_playStageTimeline(struggleId, hitEntity, "_onVirtualStruggleEnd")
	else
		self:_onVirtualStruggleEnd()
	end
end

function ClientCatchBallVirtual:_onVirtualStruggleEnd()
	local target = self._virtualTarget

	if not target or target.destroyed then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture _onVirtualStruggleEnd: target invalid, fallback to fail")
		end

		self._virtualSettlementStarted = true
		self.result = false

		self:_playVirtualResultTimeline(nil, false)

		return
	end

	self._virtualSettlementStarted = true
	self.result = self._presetResult == true

	self:_playVirtualResultTimeline(target, self.result)
end

function ClientCatchBallVirtual:_playVirtualResultTimeline(hitEntity, result)
	local resultId = CaptureConst.CAPTURE_NORMAL_BALL_RESULT_TIMELINE

	if resultId and hitEntity then
		self:_playStageTimeline(resultId, hitEntity, "_onVirtualResultEnd")
	else
		self:_onVirtualResultEnd()
	end
end

function ClientCatchBallVirtual:_onVirtualResultEnd()
	if self._virtualResultEnding then
		return
	end

	self._virtualResultEnding = true

	local hasSettled = self._virtualSettlementStarted == true
	local result = self.result == true
	local targetId = self.entIdInBall
	local target = targetId and pg.getEntity(targetId)
	local ballUid = self.ballUid
	local itemId = self.itemId
	local probValue = self.prob
	local masterValid = self.master and not self.master.destroyed

	if not result then
		CaptureWizard.advise(self.prob or 0)
	elseif masterValid then
		self.master:postComponentMethod("OnPetProud")

		if self.ballData.forceShiny == 1 then
			pg.global.showBubbleMessageById(NoticeDef.CATCH_BALL_SHINY, LuaUIUtils.getNameByItemId(self.itemId))
		end
	end

	local capturedEntity = targetId and pg.getEntity(targetId)

	if capturedEntity and masterValid then
		capturedEntity:cancelTrapped(self.master.actorId)
	end

	if self:checkEModel() then
		self.eModel:OnNoticeFinished()
	end

	self.entIdInBall = nil

	self:clientDestroy()

	if result and capturedEntity and not capturedEntity.destroyed and capturedEntity.className == "ClientOfflinePuppet" then
		self:_pushOfflineCatchPetGot(capturedEntity.templateId)

		local master = self.master

		if master and master.markOfflinePuppetCaptured then
			master:markOfflinePuppetCaptured(capturedEntity.staticId)
		end

		ClientUtils.safeDestroy(capturedEntity)
	end

	if not hasSettled then
		return
	end

	if self._notifiedSettled then
		return
	end

	self._notifiedSettled = true

	local reason, successForPayload

	if not target then
		reason = "target_destroyed"
		successForPayload = false
	elseif result then
		reason = "success"
		successForPayload = true
	else
		reason = "prob_fail"
		successForPayload = false
	end

	pg.global.eventEmitter:emit(MessageName.VIRTUAL_CAPTURE_FINISHED, {
		success = successForPayload,
		reason = reason,
		target = target,
		targetId = targetId,
		itemId = itemId,
		ballUid = ballUid,
		finalProb = probValue
	})
end

function ClientCatchBallVirtual:_pushOfflineCatchPetGot(puppetTemplateId)
	if not puppetTemplateId then
		return
	end

	if not pg.global.ui or not pg.global.ui.tips then
		return
	end

	local puppetCfg = PuppetData[puppetTemplateId]
	local petTemplateId = puppetCfg and puppetCfg.spriteIdAfterCatch

	if not petTemplateId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@virtualCapture _pushOfflineCatchPetGot: no spriteIdAfterCatch for puppet=%s", tostring(puppetTemplateId))
		end

		return
	end

	local pData = PetData[petTemplateId] or {}
	local petInfo = {
		isNew = true,
		id = "",
		lv = 1,
		templateId = petTemplateId,
		name = pData.name,
		headIconName = pData.iconName,
		label = pData.label or 0,
		gender = pData.gender or 0
	}

	pg.global.ui.tips:pushPetGot({
		petInfo
	})
end

function ClientCatchBallVirtual:onLuaHitCollider(position)
	if self.clientDestroyed or self.catching or not self.ballGameObject then
		return
	end

	if self:checkEModel() then
		if position then
			self:setPosition(position)
		end

		self.eModel:OnHitCollider()
	end

	self:_consumeOneCollision()
end

function ClientCatchBallVirtual:onLuaHitWater()
	if self.clientDestroyed or self.catching then
		return
	end

	ClientCatchBallVirtual.super.onLuaHitWater(self)
	self:clientDestroy()
end

function ClientCatchBallVirtual:onLuaNoticeFinished()
	local hasSettled = self._virtualSettlementStarted == true
	local targetId = self.entIdInBall
	local target = targetId and pg.getEntity(targetId)
	local ballUid = self.ballUid
	local itemId = self.itemId
	local probValue = self.prob

	if hasSettled then
		if not self.entIdInBall then
			return
		end

		self.entIdInBall = nil

		local capturedEntity = targetId and pg.getEntity(targetId)
		local masterValid = self.master and not self.master.destroyed

		if capturedEntity and masterValid then
			capturedEntity:cancelTrapped(self.master.actorId)
		end

		if self:checkEModel() then
			self.eModel:OnNoticeFinished()
		end

		self:clientDestroy()
	else
		ClientCatchBallVirtual.super.onLuaNoticeFinished(self)
	end

	if not hasSettled then
		return
	end

	if self._notifiedSettled then
		return
	end

	self._notifiedSettled = true

	pg.global.eventEmitter:emit(MessageName.VIRTUAL_CAPTURE_FINISHED, {
		success = false,
		reason = "interrupted",
		target = target,
		targetId = targetId,
		itemId = itemId,
		ballUid = ballUid,
		finalProb = probValue
	})
end

function ClientCatchBallVirtual:clientDestroy()
	if self.clientDestroyed then
		return
	end

	ClientCatchBallVirtual.super.clientDestroy(self)
	TimerManager.addNextFrameCb(function()
		if self.destroyed then
			return
		end

		ClientUtils.safeDestroy(self)
	end)
end

function ClientCatchBallVirtual:destroy()
	if self._collisionTimeoutTimer then
		TimerManager.removeTimer(self._collisionTimeoutTimer)

		self._collisionTimeoutTimer = nil
	end

	if self._maxLifetimeTimer then
		TimerManager.removeTimer(self._maxLifetimeTimer)

		self._maxLifetimeTimer = nil
	end

	self.onTimelineEnd = nil
	self.ballGameObject = nil
	self.ballComponent = nil
	self.timelineInputConfig = nil

	if self.space then
		self.space:onEntityLeave(self)
	end

	ClientModelEntity.destroy(self)
	ActorManager.removeEntity(self.actorId, self)
end

return ClientCatchBallVirtual
