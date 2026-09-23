-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientBallBase.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local castItemData = require("Data.cast_item_data")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local CTRPool = require("Common.AICt.CTRPool")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local SafeCallback = require("Core.Framework.SafeCallback")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientChestRewardAttractCtrl = require("GameApp.Sandbox.ClientChestRewardAttractCtrl")
local SysConfigData = require("Data.sys_config_data")
local CatchLuckyRewardDisplayData = require("Data.catch_lucky_reward_display_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientBallTimelineComponent = require("Entities.SpaceEntities.CommonComponent.ClientBallTimelineComponent")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local class = require("Core.Framework.Class")
local Vector3 = Vector3
local ClientBallBase = class.Class("ClientBallBase", ClientModelEntity)
local Components = {
	ClientActorComponent,
	ClientAuthorityComponent,
	ClientEffectComponent,
	ClientAttachComponent,
	ClientBallTimelineComponent
}

class.AddComponents(ClientBallBase, Components)

function ClientBallBase:ctor(entityId)
	self.clenUsrType = Const.CLEN_USR_TYPE_OTHER

	ClientBallBase.super.ctor(self, entityId)

	self.isClientEnt = false
end

function ClientBallBase:init(bdict)
	local ret = ClientBallBase.super.init(self, bdict)

	self.actorId = bdict.actorId or VirtualEntUtils.getNewVirtualEntActorId()
	self.ballUid = bdict.ballUid
	self.itemId = bdict.itemId
	self.authorityId = bdict.authorityId
	self.master = pg.getEntity(bdict.authorityId)
	self.castItemId = Utils.itemId2CastItemId(self.itemId)
	self.ballData = castItemData[self.castItemId]
	self.timelineInputConfig = {}

	return ret
end

function ClientBallBase:start()
	ClientBallBase.super.start(self)

	if not self.isModelLoaded then
		self.eModel:LoadBall(self.ballData.model, self.master.eModel, self.ballUid)
	end
end

function ClientBallBase:postInitializeComponents()
	ClientBallBase.super.postInitializeComponents(self)
	self:attachCastItem(self.master.id, self.castItemId)
end

function ClientBallBase:destroy()
	if self.master and self.master.onCaptureBallDestroyed then
		self.master:onCaptureBallDestroyed(self)
	end

	self:_clearBossTitleTrapInvisible()

	self.ballGameObject = nil
	self.ballComponent = nil
	self.timelineInputConfig = nil

	ClientBallBase.super.destroy(self)
end

function ClientBallBase:preDestroy()
	if self.entityIds then
		self:onLuaNoticeFinished(self.entityIds)
	end

	ClientBallBase.super.preDestroy(self)
end

function ClientBallBase:getGlobalId()
	return self.ballUid
end

function ClientBallBase:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.CATCH_BALL
end

function ClientBallBase:isMainPlayerBall()
	return self.master and Utils.isMainPlayer(self.master)
end

function ClientBallBase:getProxyName()
	return self.ballData and self.ballData.proxy or "BallBase"
end

function ClientBallBase:clientDestroy()
	if self:checkEModel() then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.BALL_LIFETIME, false, false)

		local isFromCatch = self.catching == true

		self.eModel:OnClientDestroy(isFromCatch)
	end
end

function ClientBallBase:getConfigData()
	self.timelineInputConfig = self.timelineInputConfig or {}
	self.timelineInputConfig.LuckyResult = self.luckyResult
	self.timelineInputConfig.EnergyLevel = self.rainbowEnergyLevel

	local proxyName = self:getProxyName()

	if proxyName == "BigBall" then
		if self.entityIds and not self.timelineInputConfig.FinalPosList then
			self.timelineInputConfig.TotalCount = #self.entityIds
			self.timelineInputConfig.FinalPosList = ClientCaptureUtils.getEvenlyDistributedPoints(self:getPositionAgentPosition(), 2.2, #self.entityIds)
			self.timelineInputConfig.EntActorList = {}
			self.timelineInputConfig.PlayerActorId = self.master.actorId

			for i = 1, #self.entityIds do
				local ent = pg.getEntity(self.entityIds[i])

				if ent then
					table.insert(self.timelineInputConfig.EntActorList, ent.actorId)
				end
			end
		end

		if self.results and not self.timelineInputConfig.SuccessCount then
			local successCount = 0

			for i = 1, #self.results do
				local result = self.results[i]

				if result then
					successCount = successCount + 1
				end
			end

			self.timelineInputConfig.SuccessCount = successCount
			self.timelineInputConfig.CaptureResultList = self.results
		end

		return self.timelineInputConfig
	elseif proxyName == "CatchBall" or proxyName == "FishingCaptureBall" then
		ClientCaptureUtils.fillCatchBallHitConfig(self.timelineInputConfig, self)

		self.timelineInputConfig.CaptureResult = self.results and self.results[1]
		self.timelineInputConfig.ReplaceEffectKeys = self.ballData.replaceEffectKeys

		return self.timelineInputConfig
	end
end

function ClientBallBase:onBallCreated()
	self.isModelLoaded = true
	self.ballGameObject = self.eModel.ballObj
	self.ballComponent = self.eModel.ballComp

	self:setModelLoaded(true)
end

function ClientBallBase:onLuaFire()
	self:detach()
	self.eModel:OnFire()

	local startPos = self:getPositionAgentPosition()

	self.ballStartPos = startPos and startPos:Clone()
end

function ClientBallBase:onLuaHitEntity(hitEntityId, canCapture, prob, fromBehind, reason, ballHitPos)
	local hitEntity = pg.getEntity(hitEntityId)

	if not hitEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("can't find hit entity", hitEntityId)
		end

		return
	end

	if not self:checkEModel() then
		return
	end

	if canCapture then
		hitEntity:trapped()
		self:_setBossTitleTrapInvisible(true, hitEntity)

		self.hitEntityActorId = hitEntity.actorId
		self.finalProb = prob
	else
		local context = CTRPool.getContext()

		context.tBallMasterId = self.master.actorId

		AIControllerUtils.sendAIEvent(hitEntity, "ForbidCatchOnBallHitTrigger", context)
	end

	self.ballHitPos = ballHitPos

	self.eModel:OnHitEntity(hitEntity.eModel, canCapture, prob, fromBehind, reason, ballHitPos or Vector3.constZero)
end

function ClientBallBase:onLuaHitWater()
	if self:checkEModel() then
		self.eModel:OnHitWater()
	end
end

function ClientBallBase:onLuaHitCollider(position)
	if self:checkEModel() then
		EModelUtils.setAgentPosition(self, position)
		self.eModel:OnHitCollider()
	end
end

function ClientBallBase:onCaptureAnimStart(entityIds, timelineId, timelineInputConfig)
	if self:checkEModel() then
		self.entityIds = entityIds

		for k, v in pairs(timelineInputConfig or EMPTY_TABLE) do
			self.timelineInputConfig[k] = v
		end

		self:playTimeline(timelineId, pg.getEntity(self.entityIds and self.entityIds[1]))
	end
end

function ClientBallBase:onCaptureSecondAnimStart(entityIds, timelineId, timelineInputConfig)
	if self:checkEModel() then
		for k, v in pairs(timelineInputConfig or EMPTY_TABLE) do
			self.timelineInputConfig[k] = v
		end

		self:playTimeline(timelineId, pg.getEntity(self.entityIds and self.entityIds[1]))
	end
end

function ClientBallBase:onCaptureAnimEnd(entityIds, results, timelineId, luckyResult, rainbowEnergyLevel)
	if self:checkEModel() then
		self.entityIds = entityIds
		self.results = results
		self.luckyResult = luckyResult
		self.rainbowEnergyLevel = rainbowEnergyLevel

		self:_logLuckyGuestPresentationReceived(entityIds, timelineId, luckyResult)
		self:playTimeline(timelineId, pg.getEntity(self.entityIds and self.entityIds[1]))
		self:_cancelPuppetsCaptureRestoreFallback(entityIds)
	end
end

function ClientBallBase:_cancelPuppetsCaptureRestoreFallback(puppets)
	if not puppets then
		return
	end

	for _, p in ipairs(puppets) do
		local entId = p.entId or p
		local ent = entId and pg.getEntity(entId)

		if ent and ent.clearCaptureRestoreFallback then
			ent:clearCaptureRestoreFallback()
		end
	end
end

function ClientBallBase:onLuaNoticeFinished(entIds)
	if entIds then
		for i, entId in ipairs(entIds) do
			local ent = pg.getEntity(entId)

			if ent then
				local result = self.results and self.results[i]

				if not result then
					ent:cancelTrapped(self.master.actorId)
				end
			end
		end
	end

	self:_clearBossTitleTrapInvisible()
	self.eModel:OnNoticeFinished()

	self.entityIds = nil

	self:clientDestroy()
end

function ClientBallBase:RPC_SC_OnReceiveEventMsg(msgName, args)
	self:receiveEventMsg(msgName, args)
end

function ClientBallBase:receiveEventMsg(msgName, args)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture CatchBall receiveEventMsg", msgName, inspect(args), self:repr())
	end

	if self[msgName] then
		SafeCallback(self[msgName], self, unpack(args))
	end
end

function ClientBallBase:_logLuckyGuestPresentationReceived(entityIds, timelineId, luckyResult)
	local luckyEventResult = LeylineFlowerConst.LUCKY_EVENT_RESULT

	if (luckyResult == luckyEventResult.Success or luckyResult == luckyEventResult.SuperSucess) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("@capture lucky guest timeline received, captureSessionId=%s, ballUid=%s, hitEntityId=%s, timelineId=%s, luckyResult=%s", self.captureSessionId, self.ballUid, entityIds and entityIds[1], timelineId, luckyResult)
	end
end

function ClientBallBase:_getLuckyPresentationTiming(luckyResult, energyLevel)
	local luckyData = luckyResult ~= nil and CatchLuckyRewardDisplayData[tostring(luckyResult)]
	local config = luckyData and luckyData[energyLevel]

	if config ~= nil then
		return config.delaySeconds, config.waveInterval, config.totalDuration, config.tipDelay
	end

	local timing = SysConfigData.CATCH_LUCKY_REWARD_DISPLAY_PARAM

	if timing == nil then
		return nil, nil, nil, nil
	end

	return timing[1], timing[2], timing[3], timing[4]
end

function ClientBallBase:_buildLuckyRewardEffectPlayData(effectPlan)
	if effectPlan == nil then
		return nil
	end

	local itemList = {}
	local qualityList = {}
	local rewardNumList = {}
	local tipQualityList = {}

	for i, waveData in ipairs(effectPlan) do
		itemList[i] = waveData[2]
		qualityList[i] = {}

		for j, quality in ipairs(waveData[4]) do
			qualityList[i][j] = quality
		end

		rewardNumList[i] = waveData[3]
		tipQualityList[i] = waveData[1]
	end

	return itemList, qualityList, rewardNumList, tipQualityList
end

function ClientBallBase:_getLuckyRewardEffectStartPos()
	local config = self:getConfigData()

	return config and config.FinalPos
end

function ClientBallBase:_playLuckyRewardEffect(effectPlan, showTips, targetEntityId)
	local _, waveInterval, _, tipDelay = self:_getLuckyPresentationTiming(self.luckyResult, self.rainbowEnergyLevel)
	local startPos = self:_getLuckyRewardEffectStartPos()
	local cfg = SysConfigData.CATCH_LUCKY_REWARD_EFFECT_CFG

	if effectPlan == nil or waveInterval == nil or startPos == nil or tipDelay == nil or cfg == nil then
		return nil
	end

	local itemList, qualityList, rewardNumList, tipQualityList = self:_buildLuckyRewardEffectPlayData(effectPlan)

	return ClientChestRewardAttractCtrl.playChestRewardBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, tipDelay, cfg, showTips == true, true)
end

function ClientBallBase:checkEModel()
	if not self.eModel then
		self.logger:warn("CatchBall eModel is NIL!", self:repr())

		return
	end

	return true
end

function ClientBallBase:_setBossTitleTrapInvisible(invisible, target)
	if invisible == true then
		self._bossTitleTrapInvisible = BossTitleTrapInvisibleOwner.acquire(self, target)
	else
		self:_clearBossTitleTrapInvisible()
	end
end

function ClientBallBase:_clearBossTitleTrapInvisible()
	if not self._bossTitleTrapInvisible and not BossTitleTrapInvisibleOwner.hasOwner(self) then
		return
	end

	self._bossTitleTrapInvisible = false

	BossTitleTrapInvisibleOwner.release(self)
end

return ClientBallBase
