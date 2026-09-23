-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientInteractComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local InteractData = require("Data.interact_data")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientConst = require("Const.ClientConst")
local BuffConfigData = require("Data.buff_config_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local ClientInteractComponent = class.Component("ClientInteractComponent")

function ClientInteractComponent:start()
	self.startInteractTimer = nil
	self.startInteractCallback = nil
end

function ClientInteractComponent:refreshInteractInfoByEntity(interactEntity)
	interactEntity:refreshInteractTrigger()
end

function ClientInteractComponent:startInteract(interactType, entityId, interactId, interactParams, callback)
	local execEntity = self
	local iadd = InteractData[interactId]

	if iadd and iadd.changeToPlayer == 1 and self.getMasterEntity and self:checkCanChangeModelBeforeInteract(iadd.isModelConflictByCancel) then
		if InteractData[interactId].demandModelChange then
			return
		end

		execEntity = self:getMasterEntity() or self
	end

	if iadd and iadd.changeToPlayer == 1 and Utils.isPlayer(execEntity) and pg.pawn and Utils.isPet(pg.pawn) and pg.pawn.stopFly then
		pg.pawn:stopFly()
	end

	execEntity:serverMsg("RPC_CS_StartInteract", interactType, entityId, interactId, interactParams or {})

	local actionTime

	if pg.game.controller:isInControlMainPlayer() then
		actionTime = InteractData[interactId] and InteractData[interactId].actionTime or 0
	else
		actionTime = InteractData[interactId] and InteractData[interactId].actionTimeByPet or 0
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("startInteract", actionTime)
	end

	if actionTime <= 0 then
		self:actualInteract(interactType, entityId, interactId, interactParams, callback)
	else
		self.startInteractCallback = CallbackHandler(self, "actualInteract", interactType, entityId, interactId, interactParams, callback)
		self.startInteractTimer = self:addTimer(actionTime, self.startInteractCallback)
	end
end

function ClientInteractComponent:actualInteract(interactType, entityId, interactId, interactParams, callback)
	local execEntity = self
	local iadd = InteractData[interactId]

	if iadd and iadd.changeToPlayer == 1 and self.getMasterEntity and self:checkCanChangeModelBeforeInteract(iadd.isModelConflictByCancel) then
		if InteractData[interactId].demandModelChange then
			return
		end

		execEntity = self:getMasterEntity() or self
	end

	execEntity:serverMsg("RPC_CS_Interact", interactType, entityId, interactId, interactParams or {}, function(ret, retArgs)
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("RPC_SC_Interact", ret)
		end

		if NoticeDef.SUCCESS ~= ret then
			if ret >= NoticeDef.ERROR_1 and ret <= NoticeDef.ERROR_9 then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					self.logger:warn("RPC_SC_Interact ", ret, inspect(retArgs))
				end
			else
				ClientUtils.showBubbleMessage(ret, unpack(retArgs or {}))
			end
		end

		if callback ~= nil then
			callback(ret, retArgs)
		end
	end)
end

function ClientInteractComponent:clearInteractTimer(forceCb)
	if self.startInteractTimer then
		self:removeTimer(self.startInteractTimer)

		self.startInteractTimer = nil

		local tmpCb = self.startInteractCallback

		self.startInteractCallback = nil

		if forceCb then
			tmpCb()
		end
	end
end

function ClientInteractComponent:cancelInteract()
	self:clearInteractTimer()
	self:serverMsg("RPC_CS_InterruptInteract")
end

function ClientInteractComponent:stopInteractAnim()
	if self.interactAnim then
		self:stopAnimation(self.interactAnim)

		self.interactAnim = nil
	end

	if self.eModel then
		self.eModel.InSocialAnim = false
	end

	self:stopTargetInteractLoopEffect()
end

function ClientInteractComponent:playTargetInteractLoopEffect(interactId, targetEntId)
	self:stopTargetInteractLoopEffect()

	local loopEffect = InteractData[interactId].loopEffect
	local targetEnt = pg.getEntity(targetEntId)

	if loopEffect and targetEnt then
		targetEnt:playEffect(loopEffect)

		self.interactLoopEffect = loopEffect
		self.interactLoopEffectEntId = targetEntId
	end
end

function ClientInteractComponent:stopTargetInteractLoopEffect()
	if self.interactLoopEffect then
		local targetEntId = self.interactLoopEffectEntId
		local targetEnt = pg.getEntity(targetEntId)

		if targetEnt then
			targetEnt:stopEffect(self.interactLoopEffect)
		end
	end

	self.interactLoopEffect = nil
	self.interactLoopEffectEntId = nil
end

function ClientInteractComponent:playStartInteractAnim(interactId, targetEntId)
	self:stopInteractAnim()

	if interactId ~= 0 then
		local startAnim = InteractData[interactId].startAnim
		local startEffect = InteractData[interactId].startEffect
		local loopAnim = InteractData[interactId].loopAnim
		local isAnimConflictByCancel = InteractData[interactId].isAnimConflictByCancel
		local targetEnt = pg.getEntity(targetEntId)

		if not self:checkCanPlayInteractAnim(isAnimConflictByCancel) then
			if InteractData[interactId].demandAnim then
				self:cancelInteract()
			else
				self:clearInteractTimer(true)
			end

			return
		end

		if startAnim then
			if self.eModel then
				self.eModel.InSocialAnim = true
			end

			local interactAnimState = self:playAnimation(startAnim, true)

			self.interactAnim = startAnim

			if targetEnt and startEffect then
				targetEnt:playEffect(startEffect)
			end

			interactAnimState:AddEndCallback(function(reason)
				if reason == PlayableConst.END_REASON.PLAYBACK and loopAnim then
					self:playAnimation(loopAnim)

					self.interactAnim = loopAnim

					self:playTargetInteractLoopEffect(interactId, targetEntId)
				end
			end)
		elseif loopAnim then
			if self.eModel then
				self.eModel.InSocialAnim = true
			end

			self:playAnimation(loopAnim)

			self.interactAnim = loopAnim

			self:playTargetInteractLoopEffect(interactId, targetEntId)
		end
	end
end

function ClientInteractComponent:playFinishInteractAnim(interactId, targetEntId)
	self:stopInteractAnim()

	if interactId ~= 0 then
		local endAnim = InteractData[interactId].endAnim
		local endEffect = InteractData[interactId].endEffect
		local isAnimConflictByCancel = InteractData[interactId].isAnimConflictByCancel
		local targetEnt = pg.getEntity(targetEntId)

		if not self:checkCanPlayInteractAnim(isAnimConflictByCancel) then
			if InteractData[interactId].demandAnim then
				self:cancelInteract()
			else
				self:clearInteractTimer(true)
			end

			return
		end

		self:playTrivialAnimation(endAnim, true, 1, 0)

		if targetEnt then
			endEffect = endEffect and targetEnt:playEffect(endEffect, {})
		end
	end
end

function ClientInteractComponent:on_interactActionInteractId_changed(ov, nv)
	local action = self.interactAction

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_interactActionInteractId_changed playerId:%s", self.id, ov, nv, action.entityId)
	end

	if nv ~= 0 then
		self:playStartInteractAnim(action.interactId, action.entityId)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("interactAction start interactId=%d", nv, inspect(action:getRawTable()))
		end
	elseif ov ~= 0 and not action.interrupt then
		self:playFinishInteractAnim(action.interactId, action.entityId)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("interactAction stop  interactId=%d", ov, inspect(action:getRawTable()))
		end
	elseif ov ~= 0 and action.interrupt then
		self:stopInteractAnim()

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("interactAction interrupt interactId=%d", nv, inspect(action:getRawTable()))
		end
	end

	if self == pg.me then
		if nv == 0 then
			pg.game.interaction:refreshInteraction(true)
		else
			facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VISIBLE, {})
		end
	end
end

function ClientInteractComponent:RPC_SC_OnInteractStart(interactType, targetEntId, interactId, interactParams)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnInteractStart", self.id, interactType, targetEntId, interactId, inspect(interactParams), self:repr())
	end

	if targetEntId then
		local ent = pg.getEntity(targetEntId)

		if ent and ent.onInteractStart then
			ent:onInteractStart(self.id, interactType, interactId, interactParams)
		end
	end
end

function ClientInteractComponent:RPC_SC_OnInteractInterrupt(interactType, targetEntId, interactId, interactParams)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnInteractInterrupt", self.id, interactType, targetEntId, interactId, inspect(interactParams), self:repr())
	end

	self:clearInteractTimer()

	if targetEntId then
		local ent = pg.getEntity(targetEntId)

		if ent and ent.onInteractInterrupt then
			ent:onInteractInterrupt(self.id, interactType, interactId, interactParams)
		end
	end
end

function ClientInteractComponent:RPC_SC_OnInteractSuccess(targetEntId, interactId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnInteractSuccess", self.id, targetEntId, interactId, self:repr())
	end

	self:clearInteractTimer()

	if targetEntId then
		local ent = pg.getEntity(targetEntId)

		if ent and ent.onInteractResult then
			ent:onInteractResult(self, interactId)
		end
	end
end

function ClientInteractComponent:setInLevelItemInteract(inLevelInteract)
	self.inLevelInteract = inLevelInteract

	if self.updateStateCache then
		self:updateStateCache("LEVEL_INTERACT_ST")
	end
end

function ClientInteractComponent:refreshTopLogoChatInfoByStaticId(staticId)
	local chatInfos = QuestUtils.getChatInteractInfosByStaticId(staticId)

	if chatInfos == nil then
		return
	end

	for _, chatInfo in ipairs(chatInfos) do
		local toplogoStaticId = QuestUtils.getChatToplogoStaticId(staticId, chatInfo)
		local entity = pg.me.space and pg.me.space:getEntityByStaticId(toplogoStaticId)

		if entity and entity.refreshTopLogoChatInfo then
			entity:refreshTopLogoChatInfo()
		end
	end
end

function ClientInteractComponent:refreshInteractionSignByStaticId(staticId)
	local entity = pg.me.space and pg.me.space:getEntityByStaticId(staticId)

	if entity and entity.refreshInteractTrigger then
		entity:refreshInteractTrigger()
	end

	if entity then
		facade:sendMsgToSystem(MessageName.REFRESH_INTERACT_SIGN_DYNAMIC, {
			ent = entity
		})
	end

	self:refreshTopLogoChatInfoByStaticId(staticId)
end

function ClientInteractComponent:on_npcSpecialInteractsMapEntry_added(staticId, eventIds)
	self:refreshInteractionSignByStaticId(staticId)
end

function ClientInteractComponent:on_npcSpecialInteractsMapEntry_deleted(staticId, eventIds)
	self:refreshInteractionSignByStaticId(staticId)
end

function ClientInteractComponent:on_npcSpecialInteractsMapValue_changed(ov, nv, staticId)
	self:refreshInteractionSignByStaticId(staticId)
end

function ClientInteractComponent:on_arkChestActivedEntry_added(staticId, state)
	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent and ent.refreshChestValid then
		ent:refreshChestValid()
	end
end

function ClientInteractComponent:on_arkChestActivedEntry_deleted(staticId, state)
	local ent = pg.me.space:getEntityByStaticId(staticId)

	if ent and ent.refreshChestValid then
		ent:refreshChestValid()
	end
end

function ClientInteractComponent:RPC_SC_AppearanceActionRecommend(actionCfgId)
	pg.game.social.interactGestureComponent:recommendGesture(actionCfgId)
end

function ClientInteractComponent:RPC_SC_PlayAppearanceActionResult(ret, playerName, retArgs)
	if ret == NoticeDef.SUCCESS then
		if BuffConfigData[retArgs] then
			local buffName = pg.getLocalizationText(BuffConfigData[retArgs].buffName)

			pg.global.showBubbleMessageRaw(string.format(pg.getGameString("ACTION_SEND_BUFF_TOAST"), playerName, buffName or "empty name"))
		end
	elseif ret == NoticeDef.ERROR_BUFF_EXCEED_NUM then
		pg.global.showBubbleMessageRaw(pg.getGameString("ACTION_GET_BUFF_MAX"))
	end
end

function ClientInteractComponent:RPC_SC_NotifyRewardByOtherOpenChest(playerName)
	local msg = pg.getFormatText(pg.getGameString("SANDBOX_SHARECHEST_NOTICE"), playerName)

	pg.global.showBubbleMessageRaw(msg)
end

return ClientInteractComponent
