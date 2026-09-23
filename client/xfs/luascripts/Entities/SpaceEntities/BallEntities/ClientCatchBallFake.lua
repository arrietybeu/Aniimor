-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientCatchBallFake.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientCatchBallFake")
local castItemData = require("Data.cast_item_data")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local AttributeConst = require("Common.Const.AttributeConst")
local CTRPool = require("Common.AICt.CTRPool")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local CaptureWizard = require("GameApp.Capture.CaptureWizard")
local NoticeDef = require("Common.NoticeDef")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientBallTimelineComponent = require("Entities.SpaceEntities.CommonComponent.ClientBallTimelineComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ActorManager = require("Core.Common.ActorManager")
local CaptureConst = require("Common.Const.CaptureConst")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local class = require("Core.Framework.Class")
local Vector3 = Vector3
local ClientCatchBallFake = class.Class("ClientCatchBallFake", ClientModelEntity)
local Components = {
	ClientEffectComponent,
	ClientAttachComponent,
	ClientPhysicsComponent,
	ClientVoxelComponent,
	ClientBallTimelineComponent
}

class.AddComponents(ClientCatchBallFake, Components)

function ClientCatchBallFake:ctor(entityId)
	ClientCatchBallFake.super.ctor(self, entityId)

	self.catching = false
	self.fired = false
	self.clientDestroyed = false
	self._bossSettled = false
	self.isClientEnt = true
end

function ClientCatchBallFake:init(bdict)
	local ret = ClientCatchBallFake.super.init(self, bdict)

	self.ballUid = bdict.ballUid
	self.itemId = bdict.itemId
	self.authorityId = bdict.authorityId
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()

	ActorManager.addEntity(self.actorId, self)

	self.master = pg.getEntity(bdict.authorityId)
	self.castItemId = Utils.itemId2CastItemId(self.itemId)
	self.ballData = castItemData[self.castItemId]
	self.timelineInputConfig = {}

	return ret
end

function ClientCatchBallFake:start()
	ClientCatchBallFake.super.start(self)

	if not self.isModelLoaded then
		self.eModel:LoadBall(self.ballData.model, self.master.eModel, self.ballUid)
	end
end

function ClientCatchBallFake:postInitializeComponents()
	ClientCatchBallFake.super.postInitializeComponents(self)
	self:attachCastItem(self.master.id, self.castItemId)
end

function ClientCatchBallFake:enterSpace(space)
	self.space = space

	self.space:onEntityJoin(self)
	self:onEnterSpace()
end

function ClientCatchBallFake:destroy()
	if self.master and self.master.onCaptureBallDestroyed then
		self.master:onCaptureBallDestroyed(self)
	end

	if self.bossRpcTimeoutTimer then
		self:removeTimer(self.bossRpcTimeoutTimer)

		self.bossRpcTimeoutTimer = nil
	end

	if self._bossMaxLifetimeTimer then
		self:removeTimer(self._bossMaxLifetimeTimer)

		self._bossMaxLifetimeTimer = nil
	end

	self:clearBossTitleTrapInvisible()

	self.ballGameObject = nil
	self.ballComponent = nil
	self.timelineInputConfig = nil

	if self.space then
		self.space:onEntityLeave(self)
	end

	ClientCatchBallFake.super.destroy(self)
	ActorManager.removeEntity(self.actorId, self)
end

function ClientCatchBallFake:preDestroy()
	if self.space then
		self:onLeaveSpace()
	end

	if self.entIdInBall then
		self:onLuaNoticeFinished(self.entIdInBall)
	end

	ClientCatchBallFake.super.preDestroy(self)
end

function ClientCatchBallFake:getGlobalId()
	return self.ballUid
end

function ClientCatchBallFake:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.MAIN_CATCH_BALL
end

function ClientCatchBallFake:clientDestroy()
	if self.clientDestroyed then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientCatchBallFake:clientDestroy failed!!! clientDestroy repeat enter!!!", self:repr(), debug.traceback())
		end

		return
	end

	self.clientDestroyed = true

	if self._bossMaxLifetimeTimer then
		self:removeTimer(self._bossMaxLifetimeTimer)

		self._bossMaxLifetimeTimer = nil
	end

	if self:checkEModel() then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.BALL_LIFETIME, false, false)

		local isFromCatch = self.catching == true

		self.eModel:OnClientDestroy(isFromCatch)
	end

	if self.master and self.master.onBossCatchBallClear then
		self.master:onBossCatchBallClear(self)
	end

	TimerManager.addNextFrameCb(function()
		if self.destroyed then
			return
		end

		ClientUtils.safeDestroy(self)
	end)
end

function ClientCatchBallFake:isConfigKinematic()
	return false
end

function ClientCatchBallFake:fire()
	if self.fired then
		return
	end

	self:onLuaFire()
end

function ClientCatchBallFake:quickFire(target, speed)
	if self.fired then
		return
	end

	self:onLuaFire()
	self.ballComponent:FlyTo(target.eModel, speed)
end

function ClientCatchBallFake:isBallReady()
	return true
end

function ClientCatchBallFake:getProxyName()
	return self.ballData and self.ballData.proxy or "CatchBall"
end

function ClientCatchBallFake:getConfigData()
	self.timelineInputConfig = self.timelineInputConfig or {}

	ClientCaptureUtils.fillCatchBallHitConfig(self.timelineInputConfig, self)

	self.timelineInputConfig.CaptureResult = self.result
	self.timelineInputConfig.ReplaceEffectKeys = self.ballData.replaceEffectKeys

	return self.timelineInputConfig
end

function ClientCatchBallFake:setupFakeHitContext(params)
	params = params or {}

	local hitEntity = params.hitEntity

	if not hitEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientCatchBallFake:setupFakeHitContext hitEntity is nil")
		end

		return
	end

	local master = params.master or self.master
	local startPos = params.startPos

	if not startPos then
		if master and master.getPositionAgentPosition then
			local masterPos = master:getPositionAgentPosition()
			local height = master.eModel and master.eModel.height or 1.5

			startPos = masterPos + Vector3(0, height, 0)
		else
			startPos = hitEntity:getPositionAgentPosition()
		end
	end

	local hitPos = params.hitPos

	if not hitPos then
		local eModel = hitEntity.eModel
		local bodyCollider = eModel and eModel.bodyCollider

		if NotNil(bodyCollider) then
			local csPos = bodyCollider:ClosestPoint(startPos)

			hitPos = Vector3.New(csPos.x, csPos.y, csPos.z)
		end

		hitPos = hitPos or hitEntity:getPositionAgentPosition()
	end

	self.fired = true
	self.catching = true
	self.master = master
	self.ballStartPos = startPos:Clone()
	self.ballHitPos = hitPos:Clone()
	self.hitEntityActorId = hitEntity.actorId
	self.entIdInBall = hitEntity.id
	self.prob = params.finalProb or 1
	self.finalProb = self.prob

	if params.result == nil then
		self.result = true
	else
		self.result = params.result
	end

	self.finalPosOffset = params.finalPosOffset
	self.timelineInputConfig = {}
end

function ClientCatchBallFake:bossQuickFire(target, speed, itemId, isFree)
	if self._bossCaptureCancelled then
		self:clearBossTitleTrapInvisible()

		return
	end

	if self.fired then
		return
	end

	self.bossTarget = target
	self.bossItemId = itemId
	self.bossIsFree = isFree == true
	self.isBossCapture = true
	self.entIdInBall = target.id

	self:onLuaFire()
	self.ballComponent:FlyTo(target.eModel, speed)

	if self._bossMaxLifetimeTimer then
		self:removeTimer(self._bossMaxLifetimeTimer)
	end

	self._bossMaxLifetimeTimer = self:addTimer(SysConfigData.BOSS_CATCH_BALL_MAX_LIFETIME or 30, function()
		self._bossMaxLifetimeTimer = nil

		if not self.clientDestroyed and not self.destroyed then
			self.logger:warn("@bossCapture ClientCatchBallFake max lifetime timeout, force clientDestroy, ballUid=%s", tostring(self.ballUid))
			self:clientDestroy()
		end
	end)
end

function ClientCatchBallFake:cancelBossCapturePerformance()
	self._bossCaptureCancelled = true

	if self.bossRpcTimeoutTimer then
		self:removeTimer(self.bossRpcTimeoutTimer)

		self.bossRpcTimeoutTimer = nil
	end

	self:clearBossTitleTrapInvisible()
end

function ClientCatchBallFake:isBossCapturePerformanceCancelled()
	return self._bossCaptureCancelled == true
end

function ClientCatchBallFake:onBallCreated()
	self.isModelLoaded = true
	self.ballGameObject = self.eModel.ballObj
	self.ballComponent = self.eModel.ballComp
	self.remainColl = self.ballData.maxColl
	self.createTime = Time.realSecondCache

	self:setModelLoaded(true)

	local radiusExpand = self.master.actorCombatAttribute:getAttribRatioValue(AttributeConst.throw_ball_collision_radius_ratio_v)

	if self.ballData.probeRadius then
		local radius = self.ballData.probeRadius * (1 + radiusExpand)

		self.eModel:SetPetDetector(radius)
	end

	local waterDetectRadius, nearByRadius
end

function ClientCatchBallFake:onLuaFire()
	if self.fired then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientCatchBallFake ball has been fired")
		end

		return
	end

	self.fired = true

	self:detach()

	self.ballStartPos = self:getPositionAgentPosition()

	self.eModel:OnFire()
end

function ClientCatchBallFake:onLuaHitEntity(hitEntityId)
	if self.entIdInBall ~= hitEntityId then
		return
	end

	if self._bossCaptureCancelled then
		self:clearBossTitleTrapInvisible()

		return
	end

	if not self:hitEntityValid(hitEntityId) or not self:checkEModel() then
		return
	end

	local hitEntity = pg.getEntity(hitEntityId)
	local context = CatchProbContext.clientGet(hitEntity, self.itemId)

	self.prob = context.finalProb
	self.hitEntityActorId = hitEntity.actorId
	self.ballHitPos = self.eModel:GetLastHit()
	self.finalProb = self.prob

	if self.isBossCapture then
		self.fromBehind = context.fromBehind
		self.catching = true

		hitEntity:trapped()
		self:_setBossTitleTrapInvisible(true, hitEntity)
		self.eModel:OnHitEntity(hitEntity.eModel, true, self.prob, self.fromBehind, nil, self.ballHitPos)
		self:_playBossPreSettleTimeline(hitEntity)
	else
		local canCapture = context.canCatch
		local reason = context.cantCatchReason
		local fromBehind = context.fromBehind

		if canCapture then
			self.catching = true

			hitEntity:trapped()
			self:_setBossTitleTrapInvisible(true, hitEntity)
		else
			local aiContext = CTRPool.getContext()

			aiContext.tBallMasterId = self.master.actorId

			AIControllerUtils.sendAIEvent(hitEntity, "ForbidCatchOnBallHitTrigger", aiContext)
		end

		self.eModel:OnHitEntity(hitEntity.eModel, canCapture, self.prob, fromBehind, reason, self.ballHitPos)
	end
end

function ClientCatchBallFake:_playBossPreSettleTimeline(hitEntity)
	local timelineId = self:_getBossPreSettleTimelineId()

	if timelineId and hitEntity then
		self:playTimeline(timelineId, hitEntity, "_onBossPreSettleTimelineEnd")
	else
		self:_onBossPreSettleTimelineEnd()
	end
end

function ClientCatchBallFake:_getBossPreSettleTimelineId()
	return CaptureConst.CAPTURE_NORMAL_BALL_PRE_TIMELINE
end

function ClientCatchBallFake:_onBossPreSettleTimelineEnd()
	if self._bossCaptureCancelled then
		self:clearBossTitleTrapInvisible()

		return
	end

	if self._bossRpcSent then
		return
	end

	self._bossRpcSent = true

	local target = self.bossTarget

	if not target or target.destroyed then
		self.logger:warn("@bossCapture ClientCatchBallFake _onBossPreSettleTimelineEnd: bossTarget invalid, fallback to fail")
		self:onBossSettleResult(false)

		return
	end

	self.master:serverMsg("RPC_CS_CaptureBossMonster", target.id, self.bossItemId, self.bossIsFree == true, function(res)
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_CS_CaptureBossMonster rpc resultCode =  %s", res)
		end
	end)

	self.bossRpcTimeoutTimer = self:addTimer(10, function()
		self.bossRpcTimeoutTimer = nil

		self.logger:warn("@bossCapture ClientCatchBallFake bossCapture RPC timeout, fallback to fail")
		self:onBossSettleResult(false)
	end)
end

function ClientCatchBallFake:isBossSettlePending()
	return self._bossRpcSent == true and not self._bossSettled and not self._bossCaptureCancelled and not self.clientDestroyed and not self.destroyed
end

function ClientCatchBallFake:onBossSettleResult(result)
	if self._bossCaptureCancelled then
		self:clearBossTitleTrapInvisible()

		return
	end

	if self._bossSettled then
		return
	end

	self._bossSettled = true

	if self.destroyed or self.clientDestroyed then
		return
	end

	if self.bossRpcTimeoutTimer then
		self:removeTimer(self.bossRpcTimeoutTimer)

		self.bossRpcTimeoutTimer = nil
	end

	self.result = result

	self:_playBossSettleTimeline(result)
end

function ClientCatchBallFake:_playBossSettleTimeline(result)
	local timelineId = self:_getBossSettleTimelineId(result)

	if timelineId then
		self:playTimeline(timelineId, nil, "onLuaNoticeFinished")
	else
		self:onLuaNoticeFinished()
	end
end

function ClientCatchBallFake:_getBossSettleTimelineId(result)
	return CaptureConst.CAPTURE_NORMAL_BALL_RESULT_TIMELINE
end

function ClientCatchBallFake:onLuaHitWater()
	if self:checkEModel() then
		self.eModel:OnHitWater()
	end
end

function ClientCatchBallFake:onLuaHitCollider(position)
	if self:checkEModel() then
		EModelUtils.setAgentPosition(self, position)
		self.eModel:OnHitCollider()
	end
end

function ClientCatchBallFake:onLuaNoticeFinished()
	self:clearBossTitleTrapInvisible()

	if not self.entIdInBall then
		return
	end

	local entId = self.entIdInBall

	self.entIdInBall = nil

	local capturedEntity = pg.getEntity(entId)
	local masterValid = self.master and not self.master.destroyed

	if self._bossCaptureCancelled then
		-- block empty
	elseif not self.result then
		CaptureWizard.advise(self.prob or 0)
	elseif masterValid then
		self.master:postComponentMethod("OnPetProud")

		if self.ballData.forceShiny == 1 then
			pg.global.showBubbleMessageById(NoticeDef.CATCH_BALL_SHINY, LuaUIUtils.getNameByItemId(self.itemId))
		end
	end

	if capturedEntity and masterValid then
		capturedEntity:cancelTrapped(self.master.actorId)
	end

	if self:checkEModel() then
		self.eModel:OnNoticeFinished()
	end

	self:clientDestroy()
end

function ClientCatchBallFake:checkEModel()
	if not self.eModel then
		self.logger:warn("ClientCatchBallFake eModel is NIL!", self:repr())

		return
	end

	return true
end

function ClientCatchBallFake:_setBossTitleTrapInvisible(invisible, target)
	if invisible == true then
		self._bossTitleTrapInvisible = BossTitleTrapInvisibleOwner.acquire(self, target)
	else
		self:clearBossTitleTrapInvisible()
	end
end

function ClientCatchBallFake:clearBossTitleTrapInvisible()
	if not self._bossTitleTrapInvisible and not BossTitleTrapInvisibleOwner.hasOwner(self) then
		return
	end

	self._bossTitleTrapInvisible = false

	BossTitleTrapInvisibleOwner.release(self)
end

function ClientCatchBallFake:hitEntityValid(hitEntityId)
	if self.destroyed or self.catching or not self.fired or self.clientDestroyed then
		if self.clientDestroyed and not self.catching and LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientCatchBallFake:onHitEntity failed!!! clientDestroyed is true!!!", self.id, hitEntityId)
		end

		return
	end

	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity or hitEntity.className ~= "ClientPuppet" and hitEntity.className ~= "ClientPuppetGhost" then
		return
	end

	return true
end

return ClientCatchBallFake
