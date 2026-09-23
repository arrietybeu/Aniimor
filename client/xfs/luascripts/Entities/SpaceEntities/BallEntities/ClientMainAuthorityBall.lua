-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientMainAuthorityBall.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientBallBase = require("Entities.SpaceEntities.BallEntities.ClientBallBase")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientConst = require("Const.ClientConst")
local CaptureConst = require("Common.Const.CaptureConst")
local AttributeConst = require("Common.Const.AttributeConst")
local CaptureUtils = require("Common.Utils.CaptureUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientUtils = require("Utils.ClientUtils")
local class = require("Core.Framework.Class")
local ClientMainAuthorityBall = class.Class("ClientMainAuthorityBall", ClientBallBase)
local HIT_RPC_PENDING_TIMEOUT = CaptureConst.SESSION_LIFETIME + CaptureConst.SESSION_CLEAR_DELAY + 3
local Components = {
	ClientPhysicsComponent,
	ClientVoxelComponent
}

class.AddComponents(ClientMainAuthorityBall, Components)

function ClientMainAuthorityBall:ctor(entityId)
	ClientMainAuthorityBall.super.ctor(self, entityId)

	self.msgCache = {}
	self.hasHitList = {}
	self.catching = false
	self.fired = false
	self.clientDestroyed = false
	self.hitRpcPending = false
	self.hitReportCount = 0
	self.predictTrapMap = {}
end

function ClientMainAuthorityBall:destroy()
	local wasHitRpcPending = self.hitRpcPending

	self:_clearHitRpcPending()
	self:_cancelAllPredictTrap()

	if wasHitRpcPending then
		self.master:resolveLuckyPetTipDelay(self.captureSessionId, nil)
	end

	self.msgCache = nil
	self.hasHitList = nil
	self.catching = nil
	self.fired = nil
	self.clientDestroyed = nil
	self.hitRpcPending = nil
	self.hitRpcPendingTimer = nil
	self.hitReportCount = nil
	self.predictTrapMap = nil
	self.rainbowEnergyLevel = nil
	self.luckyItemDic = nil

	ClientMainAuthorityBall.super.destroy(self)
end

function ClientMainAuthorityBall:_updateLuckyCaptureArgs(args)
	if args == nil then
		return
	end

	if args.luckyResult ~= nil then
		self.luckyResult = args.luckyResult
	end

	if args.energyLevel ~= nil then
		self.rainbowEnergyLevel = args.energyLevel
	end

	if args.luckyRewardItems ~= nil then
		self.luckyItemDic = args.luckyRewardItems
	end
end

function ClientMainAuthorityBall:_tryPlayLuckyHitPresentation(hitEntityId)
	return false
end

function ClientMainAuthorityBall:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.MAIN_CATCH_BALL
end

function ClientMainAuthorityBall:getCaptureSessionState()
	local session = self.master.captureSessionMap[self.captureSessionId]

	return session and session.state or CaptureConst.SESSION_STATE_INIT
end

function ClientMainAuthorityBall:isConfigKinematic()
	return false
end

function ClientMainAuthorityBall:fire()
	self:onLuaFire()
end

function ClientMainAuthorityBall:quickFire()
	self:onLuaFire()
end

function ClientMainAuthorityBall:isBallReady()
	return true
end

function ClientMainAuthorityBall:clientDestroy()
	if self.clientDestroyed then
		if pg.logError() then
			self.logger:error("@capture clientDestroy failed!!! repeat destroy enter!!!", self.captureSessionId, self.ballUid, self.id, debug.traceback())
		end

		return
	end

	self.clientDestroyed = true

	self:sendEventMsg("clientDestroy", {})

	if self.captureSessionId and not self.catching then
		self.master:serverMsg("RPC_CS_NotifyCatchBallMissed", self.captureSessionId)

		if pg.logDebug() then
			self.logger:debug("@capture clientDestroy notify server catch ball missed", self.captureSessionId, self.ballUid)
		end
	end

	ClientMainAuthorityBall.super.clientDestroy(self)
end

function ClientMainAuthorityBall:isBigBall()
	return false
end

function ClientMainAuthorityBall:onBallCreated()
	ClientMainAuthorityBall.super.onBallCreated(self)

	local radiusExpand = self.master.actorCombatAttribute:getAttribRatioValue(AttributeConst.throw_ball_collision_radius_ratio_v)

	if self.ballData.probeRadius then
		local radius = self.ballData.probeRadius * (1 + radiusExpand)

		self.eModel:SetPetDetector(radius)
	end

	local waterDetectRadius, nearByRadius
end

function ClientMainAuthorityBall:onLuaFire()
	if self.fired then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ball has been fired")
		end

		return
	end

	self.fired = true

	self:detach()
	self.eModel:OnFire()

	local startPos = self:getPositionAgentPosition()

	self.ballStartPos = startPos and startPos:Clone()
end

function ClientMainAuthorityBall:onLuaHitEntity(hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
	local hitEntity = pg.getEntity(hitEntityId)

	if not self.hasHitList[hitEntityId] then
		self.hasHitList[hitEntityId] = true

		if not hitEntity.needDoGroupReward and not self:isBigBall() then
			if self.captureSessionId then
				if canCapture then
					local maxCaptureCount = CaptureUtils.getBallMaxCaptureCount(self.itemId)

					if maxCaptureCount <= self.hitReportCount then
						if pg.logDebug() then
							self.logger:debug("@capture client intercept BallHitEntity over maxCaptureCount, hitEntityId=%s, hitReportCount=%s, maxCaptureCount=%s", hitEntityId, self.hitReportCount, maxCaptureCount)
						end

						ClientMainAuthorityBall.super.onLuaHitEntity(self, hitEntityId, false, prob, fromBehind, reason, ballHitPos)
						self:sendEventMsg("onLuaHitEntity", {
							hitEntityId,
							false,
							prob,
							fromBehind,
							reason,
							ballHitPos
						})

						return
					end

					self.hitReportCount = self.hitReportCount + 1

					self.master:beginLuckyPetTipDelay(self.captureSessionId)
					self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.BALL_HIT_PENDING, false)
					self:_beginPredictTrap(hitEntity, hitEntityId)
					self:_startHitRpcPending()

					local ballUid = self.ballUid

					self.master:serverMsg("RPC_CS_BallHitEntity", self.captureSessionId, hitEntityId, fromBehind or false, function(code, noticeArgs)
						local ballEnt = pg.getEntityByGlobalId(ballUid)

						if not ballEnt or ballEnt.destroyed then
							return
						end

						ballEnt:_onHitEntityRpcResult(code, noticeArgs, hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
					end)
				else
					ClientMainAuthorityBall.super.onLuaHitEntity(self, hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
					self:sendEventMsg("onLuaHitEntity", {
						hitEntityId,
						canCapture,
						prob,
						fromBehind,
						reason,
						ballHitPos
					})
				end
			elseif pg.logError() then
				self.logger:error("ClientMainAuthorityBall:onHitEntity no captureSessionId found!!! hitEntityId: %s", hitEntityId)
			end
		end
	end
end

function ClientMainAuthorityBall:onLuaHitWater()
	ClientMainAuthorityBall.super.onLuaHitWater(self)
	self:sendEventMsg("onLuaHitWater", {})
end

function ClientMainAuthorityBall:onLuaHitCollider()
	if self:checkEModel() then
		self.eModel:OnHitCollider()
	end

	local px, py, pz = self.eModel:GetPositionAgentPosEx()

	self:sendEventMsg("onLuaHitCollider", {
		Vector3.New(px, py, pz)
	})
end

function ClientMainAuthorityBall:onLuaCommonAniEnd()
	if pg.logDebug() then
		self.logger:debug("@capture onLuaCommonAniEnd", self.captureSessionId, self.ballUid)
	end

	self:doCaptureEnd()
end

function ClientMainAuthorityBall:onLuaNoticeFinished(entId)
	self:sendEventMsg("onLuaNoticeFinished", {
		{
			entId
		}
	})
	ClientMainAuthorityBall.super.onLuaNoticeFinished(self, {
		entId
	})
end

function ClientMainAuthorityBall:_serverMsg(name, ...)
	if self.bossCaptureEnt then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture CatchBall _serverMsg msgName = %s parameter = %s", name, inspect({
			...
		}), self:repr())
	end

	if self.aoi then
		self:serverMsg(name, ...)
	elseif self.msgCache then
		self.msgCache[#self.msgCache + 1] = {
			name,
			...
		}
	end
end

function ClientMainAuthorityBall:_onHitEntityRpcRejected()
	return
end

function ClientMainAuthorityBall:_beginPredictTrap(hitEntity, hitEntityId)
	if not hitEntity or not hitEntity.beginCapturePredictTrap then
		return
	end

	self.predictTrapMap[hitEntityId] = true

	hitEntity:beginCapturePredictTrap(self.captureSessionId)
end

function ClientMainAuthorityBall:_cancelPredictTrap(hitEntityId)
	if not self.predictTrapMap or not self.predictTrapMap[hitEntityId] then
		return
	end

	self.predictTrapMap[hitEntityId] = nil

	local hitEntity = pg.getEntity(hitEntityId)

	if hitEntity and hitEntity.cancelCapturePredictTrap then
		hitEntity:cancelCapturePredictTrap(self.captureSessionId)
	end
end

function ClientMainAuthorityBall:_cancelAllPredictTrap()
	for hitEntityId in pairs(self.predictTrapMap or EMPTY_TABLE) do
		local hitEntity = pg.getEntity(hitEntityId)

		if hitEntity and hitEntity.cancelCapturePredictTrap then
			hitEntity:cancelCapturePredictTrap(self.captureSessionId)
		end
	end

	self.predictTrapMap = {}
end

function ClientMainAuthorityBall:_startHitRpcPending()
	self:_clearHitRpcPending()

	self.hitRpcPending = true
	self.hitRpcPendingTimer = self:addTimer(HIT_RPC_PENDING_TIMEOUT, CallbackHandler(self, "_onHitRpcPendingTimeout"))
end

function ClientMainAuthorityBall:_clearHitRpcPending()
	self.hitRpcPending = false

	if self.hitRpcPendingTimer then
		self:removeTimer(self.hitRpcPendingTimer)

		self.hitRpcPendingTimer = nil
	end
end

function ClientMainAuthorityBall:_onHitRpcPendingTimeout()
	self.hitRpcPendingTimer = nil

	if not self.hitRpcPending or self.destroyed or self.clientDestroyed then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("@capture BallHitEntity rpc timeout, safe destroy local ball, sessionId=%s, ballUid=%s", self.captureSessionId, self.ballUid)
	end

	ClientUtils.safeDestroy(self)
end

function ClientMainAuthorityBall:_onHitEntityRpcResult(code, noticeArgs, hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
	self:_clearHitRpcPending()

	if code ~= 0 then
		self.hitReportCount = math.max(0, (self.hitReportCount or 1) - 1)

		self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.BALL_HIT_PENDING, true)
		self:_cancelPredictTrap(hitEntityId)
		self:_onHitEntityRpcRejected()
		self.master:cancelLuckyPetTipDelay(self.captureSessionId)

		if pg.logWarn() then
			self.logger:warn("ClientMainAuthorityBall:onHitEntity check not pass!!! hitEntityId: %s code: %s", hitEntityId, code)
		end

		return
	end

	self:_updateLuckyCaptureArgs(noticeArgs)
	ClientMainAuthorityBall.super.onLuaHitEntity(self, hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
	self:sendEventMsg("onLuaHitEntity", {
		hitEntityId,
		canCapture,
		prob,
		fromBehind,
		reason,
		ballHitPos
	})

	if not self:_tryPlayLuckyHitPresentation(hitEntityId) then
		self:doCaptureStart()
	end
end

function ClientMainAuthorityBall:onAoiCreated()
	for _, msg in ipairs(self.msgCache or EMPTY_TABLE) do
		self:serverMsg(unpack(msg))
	end

	self.msgCache = {}
end

function ClientMainAuthorityBall:sendEventMsg(msgName, args)
	self:_serverMsg("RPC_CS_SendBallMsg", msgName, args)
end

function ClientMainAuthorityBall:receiveEventMsg(msg)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("CatchBall receiveEventMsg main ball should not receive msg")
	end
end

function ClientMainAuthorityBall:doCaptureStart()
	self.master:serverMsg("RPC_CS_NotifyCaptureAnimStart", self.captureSessionId, {})

	if pg.logDebug() then
		self.logger:debug("@capture doCaptureStart", self.captureSessionId, self.ballUid)
	end
end

function ClientMainAuthorityBall:RPC_SC_OnCaptureAnimStart(clientArgs)
	local session = self.master.captureSessionMap[self.captureSessionId]

	if not session then
		if pg.logError() then
			self.logger:error("@capture RPC_SC_OnCaptureAnimStart no session found!!! captureSessionId: %s", self.captureSessionId)
		end

		return
	end

	self:onCaptureAnimStart(session.puppetInfos, clientArgs)

	if pg.logDebug() then
		self.logger:debug("@capture RPC_SC_OnCaptureAnimStart", self.captureSessionId, self.ballUid)
	end
end

function ClientMainAuthorityBall:onCaptureAnimStart(puppetInfos, clientArgs)
	if pg.logDebug() then
		self.logger:debug("@capture onCaptureAnimStart", self.captureSessionId, self.ballUid)
	end
end

function ClientMainAuthorityBall:doCaptureEnd()
	self.master:serverMsg("RPC_CS_NotifyCaptureAnimEnd", self.captureSessionId, {})

	if pg.logDebug() then
		self.logger:debug("@capture doCaptureEnd", self.captureSessionId, self.ballUid)
	end
end

function ClientMainAuthorityBall:onCaptureSecondAnimStart(puppetInfos, clientArgs)
	if pg.logDebug() then
		self.logger:debug("@capture onCaptureSecondAnimStart", self.captureSessionId, self.ballUid)
	end
end

function ClientMainAuthorityBall:RPC_SC_OnCaptureAnimEnd(clientArgs)
	local session = self.master.captureSessionMap[self.captureSessionId]

	if not session then
		if pg.logError() then
			self.logger:error("@capture RPC_SC_OnCaptureAnimEnd no session found!!! captureSessionId: %s", self.captureSessionId)
		end

		return
	end

	self.captureResultType = clientArgs.captureResultType

	self:_updateLuckyCaptureArgs(clientArgs)

	if clientArgs.captureTimelineStage == CaptureConst.BASE_CAPTURE_TIMELINE_STAGE_STRUGGLE and clientArgs.captureResultType ~= CaptureConst.BASE_CAPTURE_RESULT_TYPE_DIRECT_FAIL then
		self:onCaptureSecondAnimStart(session.puppetInfos, clientArgs)

		return
	end

	self:onCaptureAnimEnd(session.puppetInfos, clientArgs)
	self:_cancelPuppetsCaptureRestoreFallback(session.puppetInfos)

	if pg.logDebug() then
		self.logger:debug("@capture RPC_SC_OnCaptureAnimEnd", self.captureSessionId, self.ballUid, inspect(clientArgs))
	end
end

function ClientMainAuthorityBall:onCaptureAnimEnd(puppetInfos, clientArgs)
	if pg.logDebug() then
		self.logger:debug("@capture onCaptureAnimEnd", self.captureSessionId, self.ballUid)
	end
end

return ClientMainAuthorityBall
