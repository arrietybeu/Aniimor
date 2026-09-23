-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientFishingCaptureBall.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientCatchBall = require("Entities.SpaceEntities.BallEntities.ClientCatchBall")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ClientFishingCaptureBall")
local Vector3 = Vector3
local ClientFishingCaptureBall = class.Class("ClientFishingCaptureBall", ClientCatchBall)

function ClientFishingCaptureBall:hitEntityValid(hitEntityId)
	if self.destroyed or self.catching or not self.fired or self.clientDestroyed then
		if self.clientDestroyed and not self.catching and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@fishingCapture Ball:hitEntityValid failed, clientDestroyed", self.id, hitEntityId)
		end

		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity then
		return
	end

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local phase = activityData and activityData:getCurPhase()
	local cfg = phase and phase > 0 and FishingCaptureActivityData and FishingCaptureActivityData[phase]

	if not cfg or hitEntity.staticId ~= cfg.bossStaticId then
		return
	end

	return true
end

function ClientFishingCaptureBall:onLuaHitEntity(hitEntityId)
	if not self:hitEntityValid(hitEntityId) then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity or not self:checkEModel() then
		return
	end

	self:setCollisionTimeOut(false)

	if not self.hasHitList[hitEntityId] then
		self.hasHitList[hitEntityId] = true

		local lastHit = self.eModel:GetLastHit()
		local ballHitPos = lastHit ~= Vector3.constZero and lastHit or nil

		self.hitEntityActorId = hitEntity.actorId
		self.ballHitPos = ballHitPos

		self.eModel:OnHitEntity(hitEntity.eModel, true, 0, false, nil, ballHitPos)

		if self.captureSessionId then
			self.master:serverMsg("RPC_CS_BallHitEntity", self.captureSessionId, hitEntityId, false, function(code)
				if code ~= 0 then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("@fishingCapture BallHitEntity check failed, code=%s", code)
					end

					return
				end

				self.master.lastFCBallHitPos = ballHitPos

				self:sendEventMsg("onLuaHitEntity", {
					hitEntityId,
					false,
					0,
					false,
					[6] = ballHitPos
				})
				self:doCaptureStart()
			end)
		end
	end
end

function ClientFishingCaptureBall:onCaptureAnimStart(puppetInfos, clientParam)
	self.entityIds = {
		puppetInfos[1].entId
	}

	self:doCaptureEnd()
end

function ClientFishingCaptureBall:onCaptureSecondAnimStart(puppetInfos, clientParam)
	self:doCaptureEnd()
end

function ClientFishingCaptureBall:onCaptureAnimEnd(puppetInfos)
	self.entityIds = {
		puppetInfos[1].entId
	}
	self.results = {
		puppetInfos[1].captureSuccess
	}

	if self.results and self.results[1] ~= true then
		local puppetEnt = self.entityIds and self.entityIds[1] and pg.getEntity(self.entityIds[1])

		if puppetEnt then
			self:playTimeline(FishingCaptureConst.get("FAIL_TIME_ID"), puppetEnt, "onLuaNoticeFinished")
		else
			self:onLuaNoticeFinished()
		end
	else
		self:onLuaNoticeFinished()
	end
end

function ClientFishingCaptureBall:onLuaNoticeFinished()
	if self:checkEModel() then
		self.eModel:OnNoticeFinished()
	end

	self.entityIds = nil

	self:clientDestroy()
end

function ClientFishingCaptureBall:getProxyName()
	return "FishingCaptureBall"
end

return ClientFishingCaptureBall
