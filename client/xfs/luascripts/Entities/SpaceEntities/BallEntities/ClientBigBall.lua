-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientBigBall.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local ClientMainAuthorityBall = require("Entities.SpaceEntities.BallEntities.ClientMainAuthorityBall")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local EventConst = require("Const.EventConst")
local BallDriverType = CS.FunPlus.WorldX.GameApp.Capture.BallDriver
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local CaptureConst = require("Common.Const.CaptureConst")
local ClientConst = require("Const.ClientConst")
local Vector3 = Vector3
local Quaternion = Quaternion
local TIME_LINE_TRANS_SPEED = 25
local BIG_BALL_ABSORB_DELAY = 0.15
local ClientBigBall = class.Class("ClientBigBall", ClientMainAuthorityBall)

function ClientBigBall:ctor(entityId)
	ClientBigBall.super.ctor(self, entityId)

	self.bigBallTimeLimit = SysConfigData.BIGWHITEBALL_TIMELIMIT_MAX - SysConfigData.BIGWHITEBALL_TIMELIMIT_INIT
	self.additionTime = 0
	self.startTime = 0
	self.endTime = 0
	self.curTime = 0
	self.timerId = nil
	self._airTimeoutTimer = nil
	self._settleTimeoutTimer = nil
end

function ClientBigBall:clientDestroy()
	self:_clearRuntimeCallbacks()
	self:setGuaranteeActive(false)
	self:_clearAirTimeout()
	self:_clearSettleTimeout()

	self.driver = nil

	ClientBigBall.super.clientDestroy(self)
end

function ClientBigBall:destroy()
	self:_clearRuntimeCallbacks()
	self:_clearAirTimeout()
	self:_clearSettleTimeout()

	self.driver = nil

	ClientBigBall.super.destroy(self)
end

function ClientBigBall:preDestroy()
	self:setGuaranteeActive(false)
	ClientBigBall.super.preDestroy(self)
end

function ClientBigBall:isBigBall()
	return true
end

function ClientBigBall:isValid()
	return self.fired and not self.catching and not self._hasNoticeFinish
end

function ClientBigBall:quickFire(velocity)
	self:fire(velocity)
end

function ClientBigBall:fire(velocity)
	if self.fired then
		return
	end

	if not self.ballComponent then
		if pg.logError() then
			self.logger:error("@capture BigBall fire: ballComponent nil, skip")
		end

		return
	end

	ClientBigBall.super.fire(self)
	self.ballComponent:FireByParabola(self.master:getRotation(), velocity, SysConfigData.BIGWHITEBALL_ANGLE_V)
	self:_startAirTimeout()
end

function ClientBigBall:setInScene(isInScene, isReset)
	if self.fired then
		self.isInScene = isInScene

		self.eModel:SetIsKinematic(false)

		return
	end

	ClientBigBall.super.setInScene(self, isInScene, isReset)
end

function ClientBigBall:onBallCreated()
	ClientBigBall.super.onBallCreated(self)

	self.max_count = self.ballData.maxCount
	self.driver = self.ballGameObject:GetComponent(typeof(BallDriverType))
	self._hasNoticeFinish = false
	self.absorbedEIds = {}
	self._absorbReady = false
	self.onDriveCallBack = CallbackHandlerNoGC.new(self, "onDrive")

	pg.global.eventEmitter:removeAllListeners(EventConst.BALL_DRIVE_MOVE)
	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_MOVE, self.onDriveCallBack)

	self.endDriveImmediate = CallbackHandlerNoGC.new(self, "doCaptureStart")

	pg.global.eventEmitter:addEventListener(EventConst.BALL_DRIVE_END_IMMEDIATE, self.endDriveImmediate)
end

function ClientBigBall:onLuaHitCollider()
	if not self:isValid() then
		return
	end

	self:_startDriveCountdown()
	ClientBigBall.super.onLuaHitCollider(self)
end

function ClientBigBall:onLuaHitWater()
	if not self:isValid() then
		return
	end

	self:_startDriveCountdown()
	ClientBigBall.super.onLuaHitWater(self)
end

function ClientBigBall:onLuaHitEntity(hitEntityId)
	if not self:isValid() then
		return
	end

	if not self._absorbReady then
		return
	end

	if table.contains(self.absorbedEIds, hitEntityId) then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity then
		if pg.logError() then
			self.logger:error("ClientBigBall:onLuaHitEntity entity not found! hitEntityId: %s", hitEntityId)
		end

		return
	end

	if hitEntity.needDoGroupReward then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientBigBall onHitEntity entity is bossCapture! ballId: %s hitEntityActorId: %s", self.id, hitEntity.actorId)
		end

		return
	end

	local context = CatchProbContext.clientGet(hitEntity, self.itemId)

	if not context.canCatch then
		self.eModel:OnHitEntity(hitEntity.eModel, false, 0, false, context.cantCatchReason, Vector3.constZero)

		return
	end

	if self.captureSessionId then
		local maxCount = self.ballData and self.ballData.maxCount or 10

		if maxCount <= #self.absorbedEIds then
			return
		end

		table.insert(self.absorbedEIds, hitEntityId)

		local function rollback()
			if self.absorbedEIds then
				lume.remove(self.absorbedEIds, hitEntityId)
			end

			self:_cancelPredictTrap(hitEntityId)
		end

		self:_beginPredictTrap(hitEntity, hitEntityId)
		self.master:serverMsg("RPC_CS_BallHitEntity", self.captureSessionId, hitEntityId, false, function(code)
			if self.destroyed then
				rollback()

				return
			end

			local entity = pg.getEntity(hitEntityId)

			if not entity or entity.destroyed then
				rollback()

				return
			end

			if code ~= 0 then
				rollback()

				return
			end

			if self.max_count > 0 then
				self.max_count = self.max_count - 1

				entity:trapped(true)
				self.eModel:OnHitEntity(entity.eModel, true, context.finalProb, false, context.cantCatchReason, Vector3.constZero)

				local totalCnt = self.ballData and self.ballData.maxCount or 10
				local curCnt = totalCnt - self.max_count

				pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_CATCH_NUM, curCnt)
			else
				rollback()
			end

			if self.max_count == 0 then
				self:doCaptureStart()
			end
		end)
	elseif pg.logError() then
		self.logger:error("ClientBigBall:onLuaHitEntity no captureSessionId found!!! hitEntityId: %s ballUid: %s", hitEntityId, self.ballUid)
	end
end

function ClientBigBall:onCaptureAnimStart(puppetInfos, clientArgs)
	ClientBigBall.super.onCaptureAnimStart(self, puppetInfos, clientArgs)

	local entityIds = lume.imap(puppetInfos, "entId")
	local entities = {}

	for i, entityId in ipairs(entityIds) do
		local ent = pg.getEntity(entityId)

		if ent then
			table.insert(entities, ent)
		end
	end

	self.entities = entities
	self.entityIds = entityIds
	self.eModel.rigidbody.constraints = 126

	local timelineId = CaptureConst.CAPTURE_BIG_BALL_STRUGGLE_TIMELINE

	if timelineId then
		local firstEnt = entities[1]

		self:playTimeline(timelineId, firstEnt, "onLuaCommonAniEnd")
		self:sendEventMsg("onCaptureAnimStart", {
			entityIds,
			timelineId
		})
	else
		self:onLuaCommonAniEnd()
	end
end

function ClientBigBall:onCaptureAnimEnd(puppetInfos, clientArgs)
	ClientBigBall.super.onCaptureAnimEnd(self, puppetInfos, clientArgs)
	self:_clearSettleTimeout()

	local entityIds = lume.imap(puppetInfos, "entId")
	local results = lume.imap(puppetInfos, "captureSuccess")
	local entities = {}
	local entityActorIds = {}

	for i, entityId in ipairs(entityIds) do
		local ent = pg.getEntity(entityId)

		if ent then
			table.insert(entities, ent)

			entityActorIds[i] = ent.actorId
		end
	end

	self.entities = entities
	self.entityActorIds = entityActorIds
	self.results = results
	self.entityIds = entityIds

	self:sendEventMsg("onCaptureAnimEnd", {
		entityIds,
		results,
		CaptureConst.CAPTURE_BIG_BALL_RESULT_TIMELINE,
		self.luckyResult,
		self.rainbowEnergyLevel
	})

	self.captureSuccess = false

	for _, captureRet in ipairs(results) do
		if captureRet then
			self.captureSuccess = true

			break
		end
	end

	self:setGuaranteeActive(true)
	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_END_UI)
	self:_playSettleTimeline()
end

function ClientBigBall:doCaptureStart()
	if not self:isValid() then
		return
	end

	if self.timerId then
		TimerManager.delFrameCb(self.timerId)

		self.timerId = nil
	end

	if #self.absorbedEIds > 0 then
		self.catching = true

		self:_startSettleTimeout()
		ClientBigBall.super.doCaptureStart(self)
	else
		self:onAllPerformFinish()
	end
end

function ClientBigBall:doCaptureEnd()
	if #self.absorbedEIds <= 0 then
		return
	end

	ClientBigBall.super.doCaptureEnd(self)
end

function ClientBigBall:onAllPerformFinish()
	if self._performFinished then
		return
	end

	self._performFinished = true

	if self.captureSuccess then
		self.master:postComponentMethod("OnPetProud")
	end

	self:_clearRuntimeCallbacks()
	self:_clearAirTimeout()
	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_END)
	self:clientDestroy()
end

function ClientBigBall:_clearRuntimeCallbacks()
	if self.onDriveCallBack then
		pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_MOVE, self.onDriveCallBack)

		self.onDriveCallBack = nil
	end

	if self.endDriveImmediate then
		pg.global.eventEmitter:removeEventListener(EventConst.BALL_DRIVE_END_IMMEDIATE, self.endDriveImmediate)

		self.endDriveImmediate = nil
	end

	if self.timerId then
		TimerManager.delFrameCb(self.timerId)

		self.timerId = nil
	end
end

function ClientBigBall:onDrive(x, y)
	if IsNil(self.driver) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("ClientBigBall driver is nil! id: %s _hasNoticeFinish:%s isDestroyed:%s", self.id, self._hasNoticeFinish, self.isDestroyed)
		end

		return
	end

	self.driver:Drive(x, y)
end

function ClientBigBall:_startDriveCountdown()
	if self.timerId then
		return false
	end

	self:_clearAirTimeout()

	self.startTime = Time.realSecondCache
	self.endTime = Time.realSecondCache + SysConfigData.BIGWHITEBALL_TIMELIMIT_MAX
	self.curTime = Time.realSecondCache + self.bigBallTimeLimit
	self.additionTime = 0
	self.timerId = TimerManager.addRepeatNextFrameCb(CallbackHandlerNoGC.new(self, "tickRemandTime"))
	self._absorbReady = false

	return true
end

function ClientBigBall:tickRemandTime()
	if self.catching then
		return
	end

	if not self._absorbReady and Time.realSecondCache - self.startTime >= BIG_BALL_ABSORB_DELAY then
		self:_openAbsorb()
	end

	self.curTime = Time.realSecondCache + self.bigBallTimeLimit

	if self.additionTime > 0 then
		local curAddTime = 0

		if self.additionTime - Time.deltaTime >= 0 then
			curAddTime = Time.deltaTime * TIME_LINE_TRANS_SPEED

			if self.additionTime - curAddTime < 0 then
				curAddTime = Time.deltaTime
			end

			self.additionTime = self.additionTime - curAddTime
		else
			curAddTime = self.additionTime
			self.additionTime = 0
		end

		self.startTime = self.startTime + curAddTime
		self.endTime = self.endTime + curAddTime
	end

	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_TIME, self.startTime, self.endTime, self.curTime, self.additionTime)

	if self.curTime >= self.endTime then
		self:doCaptureStart()
	end
end

function ClientBigBall:_openAbsorb()
	if self._absorbReady then
		return
	end

	self._absorbReady = true

	if self:checkEModel() then
		self.eModel:RescanPet()
	end
end

function ClientBigBall:getConfigData()
	ClientBigBall.super.getConfigData(self)

	return self.timelineInputConfig
end

function ClientBigBall:_playSettleTimeline()
	if pg.logDebug() then
		self.logger:debug("@capture BigBall debug playSettleTimeline ballId:%s session:%s hasEntities:%s entityCount:%s firstEnt:%s timeline:%s", self.id, self.captureSessionId, tostring(self.entities ~= nil), self.entities and #self.entities or 0, self.entities and self.entities[1] and self.entities[1].id, CaptureConst.CAPTURE_BIG_BALL_RESULT_TIMELINE)
	end

	if (not self.entities or #self.entities == 0) and LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("@capture BigBall settle timeline target missing, play with nil target. ballId:%s session:%s entityIds:%s absorbedEIds:%s results:%s", self.id, self.captureSessionId, inspect(self.entityIds), inspect(self.absorbedEIds), inspect(self.results))
	end

	local timelineId = CaptureConst.CAPTURE_BIG_BALL_RESULT_TIMELINE

	self:playTimeline(timelineId, self.entities and self.entities[1] or nil, "_onAllSettleFinished")
end

function ClientBigBall:_onAllSettleFinished()
	self._hasNoticeFinish = true

	local entities = self.entities or {}
	local entityActorIds = self.entityActorIds or {}
	local results = self.results or {}
	local entityIds = self.entityIds or {}

	if pg.logDebug() then
		self.logger:debug("@capture BigBall debug settleEnter ballId:%s session:%s entities:%s entityIds:%s results:%s hasFinalPosList:%s guaranteeTimer:%s performFinished:%s", self.id, self.captureSessionId, #entities, inspect(entityIds), inspect(results), tostring(self.timelineInputConfig and self.timelineInputConfig.FinalPosList ~= nil), tostring(self.guaranteeTimer), tostring(self._performFinished))
	end

	self.entities = nil
	self.entityActorIds = nil
	self.results = nil
	self.entityIds = nil

	local ok, err = pcall(function()
		self.eModel:OnNoticeFinished()
	end)

	if not ok and pg.logError() then
		self.logger:error("@capture BigBall:_onAllSettleFinished OnNoticeFinished error: %s", tostring(err))
	end

	local offset = Vector3(0, 0.5, 0)
	local finalPosList = self.timelineInputConfig.FinalPosList

	for originIndex, expectedEntityId in ipairs(entityIds) do
		if not results[originIndex] then
			local expectedActorId = entityActorIds[originIndex]
			local ent = expectedEntityId and pg.getEntity(expectedEntityId) or nil

			if ent and ent.id == expectedEntityId and ent.actorId == expectedActorId then
				if finalPosList[originIndex] then
					ent:forceSetPos(finalPosList[originIndex] + offset)
				end

				ent:cancelTrapped(self.master.actorId)
				self:resetFailedPuppetTransform(ent)
			elseif pg.logDebug() then
				self.logger:debug("@capture BigBall skip stale settle entity ballId:%s session:%s originIndex:%s expectedEntityId:%s expectedActorId:%s currentEntityId:%s currentActorId:%s", self.id, self.captureSessionId, originIndex, tostring(expectedEntityId), tostring(expectedActorId), ent and tostring(ent.id) or "nil", ent and tostring(ent.actorId) or "nil")
			end
		end
	end

	self:sendEventMsg("onLuaNoticeFinished", {
		entityIds
	})
	self:onAllPerformFinish()
end

function ClientBigBall:resetFailedPuppetTransform(ent)
	if not ent or ent.destroyed then
		return
	end

	if ent.getRotation and ent.forceSetRot then
		local rot = ent:getRotation()

		if rot then
			local yaw = rot.eulerAngles.y

			ent:forceSetRot(Quaternion.Euler(0, yaw, 0))
		end
	end

	if ent.resetMotorTempState then
		ent:resetMotorTempState()
	end
end

function ClientBigBall:setGuaranteeActive(active)
	if active then
		self:_clearGuaranteeTimer()

		self.guaranteeTimer = TimerManager.addTimer(15, function()
			self:_onAllSettleFinished()
		end)
	else
		self:_clearGuaranteeTimer()
	end
end

function ClientBigBall:_clearGuaranteeTimer()
	if self.guaranteeTimer then
		TimerManager.removeTimer(self.guaranteeTimer)

		self.guaranteeTimer = nil
	end
end

function ClientBigBall:_startAirTimeout()
	self:_clearAirTimeout()

	self._airTimeoutTimer = TimerManager.addTimer(CaptureConst.BIG_BALL_AIR_TIMEOUT, function()
		self:_onAirTimeout()
	end)
end

function ClientBigBall:_onAirTimeout()
	self._airTimeoutTimer = nil

	if not self:isValid() then
		return
	end

	self:_startDriveCountdown()

	if self:checkEModel() then
		self.eModel:OnAirTimeout()
	end
end

function ClientBigBall:_clearAirTimeout()
	if self._airTimeoutTimer then
		TimerManager.removeTimer(self._airTimeoutTimer)

		self._airTimeoutTimer = nil
	end
end

function ClientBigBall:_startSettleTimeout()
	self:_clearSettleTimeout()

	self._settleTimeoutTimer = TimerManager.addTimer(CaptureConst.BIG_BALL_SETTLE_TIMEOUT, function()
		self:_onSettleTimeout()
	end)
end

function ClientBigBall:_clearSettleTimeout()
	if self._settleTimeoutTimer then
		TimerManager.removeTimer(self._settleTimeoutTimer)

		self._settleTimeoutTimer = nil
	end
end

function ClientBigBall:_onSettleTimeout()
	self._settleTimeoutTimer = nil

	if self._performFinished or self._hasNoticeFinish or self.clientDestroyed then
		return
	end

	if pg.logError() then
		self.logger:error("@capture BigBall settle timeout! server no result, force fail finish. ballId:%s session:%s absorbedCount:%s", self.id, self.captureSessionId, self.absorbedEIds and #self.absorbedEIds or 0)
	end

	if self:checkEModel() then
		local ok, err = pcall(function()
			self.eModel:OnNoticeFinished()
		end)

		if not ok and pg.logError() then
			self.logger:error("@capture BigBall:_onSettleTimeout OnNoticeFinished error: %s", tostring(err))
		end
	end

	for _, entId in ipairs(self.absorbedEIds or EMPTY_TABLE) do
		local ent = pg.getEntity(entId)

		if ent and not ent.destroyed then
			ent:cancelTrapped(self.master.actorId)
			self:resetFailedPuppetTransform(ent)
		end
	end

	self.captureSuccess = false

	pg.global.eventEmitter:emit(EventConst.BALL_DRIVE_END_UI)
	self:onAllPerformFinish()
end

return ClientBigBall
