-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerRobEggComponent.lua

local Class = require("Core.Framework.Class")
local ClientPlayerRobEggComponent = Class.Component("ClientPlayerRobEggComponent")
local ItemConst = require("Common.Const.ItemConst")
local ClientConst = require("Const.ClientConst")
local PlayableEventConst = require("Const.PlayableEventConst")
local MessageName = require("Const.MessageName")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local AudioConst = require("Const.AudioConst")
local Const = require("Common.Const.Const")
local RobEggConst = require("Common.Const.RobEggConst")
local ConflictTypes = require("Common.ConflictTypes")
local InputCommand = require("GameApp.Input.InputCommand")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local AttributeGroupData = require("Data.attribute_group_data")
local SysConfigData = require("Data.sys_config_data")
local LIMIT_TIME_COUNTDOWN_ID = "RobEggLimitTimeChallenge"
local LIMIT_TIME_BGM_REASON = "RobEggLimitTimeChallengeBgm"
local LIMIT_TIME_BGM_LEVEL_PRIORITY = 1

function ClientPlayerRobEggComponent:ctor()
	self.isInFastCarryEggState = false

	if self.updateStateCache then
		self:updateStateCache("FAST_CARRY_EGG_ST")
	end

	function self.putDownEggHandler()
		self:onExitCarryEggState(true)
	end
end

function ClientPlayerRobEggComponent:start()
	return
end

function ClientPlayerRobEggComponent:foreachEquipSlot(cb)
	if not ItemUtils.getTypedBag(self, ItemConst.INV_TYPE_EQUIP_SLOTS) then
		return
	end

	for pos = ItemConst.ROB_EGG_EQUIP_SLOT.MIN, ItemConst.ROB_EGG_EQUIP_SLOT.MAX do
		if not cb(pos, self.equipSlotsInfo[pos].genId, ItemConst.INV_TYPE_EQUIP_SLOTS) then
			break
		end
	end
end

function ClientPlayerRobEggComponent:checkRobEggBagCanInstallEgg()
	return self:hasEggSpace()
end

function ClientPlayerRobEggComponent:hasEggSpace()
	for pos = ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN, self.eggCap do
		if self.slotsInfo[pos].genId == 0 then
			return true
		end
	end

	return false
end

function ClientPlayerRobEggComponent:onEnterCarryEggState()
	local eggEnt = pg.getEntity(self.carryEggEntId)

	if eggEnt then
		self:faceToPosition(eggEnt:getHitPosition())
		self:cancelAbility()
		pg.game:setModuleEnable("CARRY_EGG", ClientConst.ModuleKey.Skill, false)
	end
end

function ClientPlayerRobEggComponent:onExitCarryEggState(isAnimEvent)
	if self.carryEggEntId ~= nil then
		local ent = pg.getEntity(self.carryEggEntId)

		self.carryEggEntId = nil

		if not isAnimEvent and self.eModel then
			self.eModel.carrayItemInt = 0
		end

		if ent and ent.eModel then
			ent:detach()
			ent:beDetached()
			ent.eModel.itemModelView:SetForceColliderLayer(ClientConst.LayerDefine.LAYER_NOACROSS)
			ent:refreshInteractTriggerEvent()
		end

		local posX, posY, posZ = 0, 0, 0
		local rotX, rotY, rotZ, rotW = 0, 0, 0, 2

		if ent and ent.eModel then
			posX, posY, posZ = ent.eModel:GetPositionAgentPosEx()
			rotX, rotY, rotZ, rotW = ent.eModel:GetPositionAgentRotationEx()

			local playerPosition = self:getPositionAgentPosition()
			local success, legalX, legalY, legalZ = ent.eModel:TryGetFarthestLegalBodyPosition(Const.COMPONENT_IDX_PHYSX, playerPosition.x, playerPosition.y, playerPosition.z, posX, posY, posZ)

			if success then
				posX, posY, posZ = legalX, legalY, legalZ

				ent:forceSetPosEx(posX, posY, posZ, true)
			end
		end

		self:serverMsg("RPC_CS_PutOffMovedEgg", posX, posY, posZ, rotX, rotY, rotZ, rotW)
	end

	self:exitFastCarryEggState()
	self.eventEmitter:removeEventListener(PlayableEventConst.putDownEgg, self.putDownEggHandler)
	facade:SendMessageCommand(MessageName.GRAB_EGG_HUG_STATE_CHANGED)
	pg.game:setModuleEnable("CARRY_EGG", ClientConst.ModuleKey.Skill, true)
end

function ClientPlayerRobEggComponent:registerCarryEggAnimEvent(attachEntity, attachConfigId)
	self.eventEmitter:onceEventListener(PlayableEventConst.carryEgg, function()
		if attachEntity then
			attachEntity:attach(self.id, attachConfigId)
			attachEntity:beAttached()
			self:serverMsg("RPC_CS_NotifyAttachCarryEgg")
		end

		facade:SendMessageCommand(MessageName.GRAB_EGG_HUG_STATE_CHANGED)
	end)
	self:registerPutDownEggAnimEvent()
end

function ClientPlayerRobEggComponent:registerPutDownEggAnimEvent()
	self.eventEmitter:onceEventListener(PlayableEventConst.putDownEgg, self.putDownEggHandler)
end

function ClientPlayerRobEggComponent:exitCarryEgg(force)
	if not force and not self:checkStatus(ConflictTypes.CT_DROP_EGG) then
		return
	end

	self:exitFastCarryEggState()

	if self.eModel then
		self.eModel.dropItem = true
	else
		self:onExitCarryEggState()
	end
end

function ClientPlayerRobEggComponent:switchFastCarryEggState()
	local rawVal = self.isInFastCarryEggState

	self.isInFastCarryEggState = not self.isInFastCarryEggState

	if self.updateStateCache then
		self:updateStateCache("FAST_CARRY_EGG_ST")
	end

	if rawVal ~= self.isInFastCarryEggState then
		self:onMotionAttrChange()
		self:onFastCarryEggStateChange(self.isInFastCarryEggState)
	end
end

function ClientPlayerRobEggComponent:exitFastCarryEggState()
	if not self.isInFastCarryEggState then
		return
	end

	self.isInFastCarryEggState = false

	if self.updateStateCache then
		self:updateStateCache("FAST_CARRY_EGG_ST")
	end

	self:onMotionAttrChange()
	self:onFastCarryEggStateChange(false)
end

function ClientPlayerRobEggComponent:onFastCarryEggStateChange(isEnter)
	if self.setFastCarryEggStaminaState then
		self:setFastCarryEggStaminaState(isEnter)
	end

	if self.eModel then
		self.eModel.isInFastCarryEgg = isEnter
	end

	if isEnter then
		self.fastCarryStartTime = self:getGameTime()
	else
		self.fastCarryStartTime = nil
	end
end

function ClientPlayerRobEggComponent:isRamReady()
	if not self.isInFastCarryEggState or not ToBool(self.carryEggEntId) then
		return false
	end

	if not self.fastCarryStartTime then
		return false
	end

	local chargeTime = SysConfigData.ROB_EGG_RAM_CHARGE_TIME or 2

	return chargeTime <= self:getGameTime() - self.fastCarryStartTime
end

function ClientPlayerRobEggComponent:isRamValidTarget(target)
	return target ~= nil and Utils.isPuppet(target) and Utils.checkValidTarget(target, self)
end

function ClientPlayerRobEggComponent:tryRobEggRam(targetActorId, hitNormal)
	if self.authority ~= Const.AUTHORITY_MASTER then
		return
	end

	if not self:isRamReady() then
		return
	end

	local target = pg.getEntityByActorId(targetActorId)

	if not self:isRamValidTarget(target) then
		return
	end

	local now = self:getGameTime()
	local cd = SysConfigData.ROB_EGG_RAM_CD or 0.5

	if self.lastRamTime and cd > now - self.lastRamTime then
		return
	end

	self.lastRamTime = now

	local nx = hitNormal and hitNormal.x or 0
	local nz = hitNormal and hitNormal.z or 0

	self:serverMsgNoGC("RPC_CS_RobEggRamHit", targetActorId, nx, nz)
end

function ClientPlayerRobEggComponent:doFirstAid(aidTargetActorId, playerName)
	pg.me:serverMsgNoGC("RPC_CS_StartFallenAid", aidTargetActorId, function(ret)
		local aidTarget = pg.getEntityByActorId(aidTargetActorId)

		if not ret then
			if aidTarget then
				local toastId = Utils.isTargetInSelfRescue(aidTarget) and NoticeDef.TARGET_IN_SELF_RESCUING or NoticeDef.CANNOT_RESCUE_TARGET_BE_RESCUED_BY_OTHERS

				pg.global.showBubbleMessageById(toastId)
			end

			return
		end

		AnimationUtils.playAnimationState(self, CharacterStateConst.AID)
		facade:SendMessageCommand(MessageName.ENTER_FALLEN_AID)
		self:showAidToast(aidTarget, playerName)
	end)
end

function ClientPlayerRobEggComponent:showAidToast(fallenEnt, playerName)
	if not fallenEnt then
		return
	end

	local fallenAidDuration = fallenEnt.fallenAidEndTime - self:getGameTime()
	local aidToastText = self.lastFallenAidActorId == self.actorId and pg.getGameString("IN_SELF_RESCUE") or string.format(pg.getGameString("AID_FALLEN_PLAYER"), playerName)

	pg.global.ui.tips:showControlPanel(Time.realSecondCache + math.max(0, fallenAidDuration), aidToastText, 1)
end

function ClientPlayerRobEggComponent:isInFirstAid()
	return self.lastFallenAidActorId ~= 0
end

function ClientPlayerRobEggComponent:getMaxSelfRescueCnt()
	return 1
end

function ClientPlayerRobEggComponent:getCurSelfRescueCnt()
	return self.selfRescueCnt
end

function ClientPlayerRobEggComponent:checkSelfRescueCntValid()
	local maxSelfRescueCnt = self:getMaxSelfRescueCnt()

	if maxSelfRescueCnt <= self:getCurSelfRescueCnt() then
		return false
	end

	return true
end

function ClientPlayerRobEggComponent:canShowSelfRescueToast()
	local canUseSelfRescue = ToBool(self.actorCombatAttribute:getRawAttribValue(AttributeConst.can_fallen_self_help))

	if not canUseSelfRescue then
		return false
	end

	return self:checkSelfRescueCntValid()
end

function ClientPlayerRobEggComponent:startDigEgg(targetEggNestActorId)
	self.targetEggNestActorId = targetEggNestActorId

	pg.game.camera.digEggCamera:enableCameraByActorId(true, 0.5, pg.me.actorId, Vector3(0.5, 0.7, -0.5), Vector3(10, -15, 0), 45)

	local targetEggNestEnt = pg.getEntityByActorId(targetEggNestActorId)

	self:faceToTarget(targetEggNestEnt, nil, false)
	AnimationUtils.playAnimationState(self, CharacterStateConst.DIGEGG)
end

function ClientPlayerRobEggComponent:finishDigEgg()
	self:setInputCommandDigEgg()
	pg.game.qte:stopQte(self.actorId, "QTE_DIGEGG02")

	self.targetEggNestActorId = nil

	local delayExitCameraTime = SysConfigData.GRABEGG_CAMERA_EXIT_DELAY_TIME or 2

	self.delayExitDigEggCameraTimer = self:addTimer(delayExitCameraTime, function()
		pg.game.camera.digEggCamera:enableCamera(false)

		self.delayExitDigEggCameraTimer = nil
	end)
end

function ClientPlayerRobEggComponent:tryCancelDigEgg()
	if self:DIG_EGG_ST() then
		self:_backToDefault()
	end

	if pg.game.qte:isPlayingDigEggQte() then
		pg.game.qte:stopQteBySrc(self.actorId, Const.QTE_SRC.DigEgg)
	end

	if self.targetEggNestActorId then
		local eggNest = pg.getEntityByActorId(self.targetEggNestActorId)

		if eggNest then
			eggNest:onCancelDigEgg()
		end

		self.targetEggNestActorId = nil
	end

	if self.delayExitDigEggCameraTimer ~= nil then
		self:removeTimer(self.delayExitDigEggCameraTimer)

		self.delayExitDigEggCameraTimer = nil
	end

	pg.game.camera.digEggCamera:enableCamera(false)
end

function ClientPlayerRobEggComponent:notifyBuffTagChange(changelist, newVal)
	for _, tagId in ipairs(changelist) do
		if (tagId == AbilityConst.BUFF_TAG_STUN or tagId == AbilityConst.BUFF_TAG_SLEEP) and newVal then
			self:_cancel_CARRY_EGG_ST()
		end
	end
end

function ClientPlayerRobEggComponent:RPC_SC_NotifyEntityVisibleChangeInHighGrass(actorList, value)
	for _, actorId in ipairs(actorList) do
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.IN_HIGH_GRASS, value)
		end
	end
end

function ClientPlayerRobEggComponent:showLimitTimeChallengeCountDown(params)
	params = params or {}

	local endTime = params.endTime

	if not endTime then
		return
	end

	local duration = math.floor(endTime - Time.secondCache)

	if duration <= 0 then
		return
	end

	pg.global.ui.tips:hideCountDownLimitedTime(LIMIT_TIME_COUNTDOWN_ID)
	pg.global.ui.tips:showCountDownLimitedTime(duration, LIMIT_TIME_COUNTDOWN_ID)
end

function ClientPlayerRobEggComponent:hideLimitTimeChallengeCountDown()
	pg.global.ui.tips:hideCountDownLimitedTime(LIMIT_TIME_COUNTDOWN_ID)
end

function ClientPlayerRobEggComponent:showLimitTimeChallengeProgress(params)
	params = params or {}

	if params.endTime == nil or params.endTime <= Time.secondCache then
		return
	end

	pg.global.ui.tips:showGetEggLimitedTime(params)
end

function ClientPlayerRobEggComponent:refreshLimitTimeChallengeProgress(params)
	params = params or {}

	pg.global.ui.tips:refreshGetEggLimitedTime(params.killNum)
end

function ClientPlayerRobEggComponent:showLimitTimeChallengeWave(params)
	params = params or {}

	pg.global.ui.tips:showGetEggLimitedTimeWave(params.refreshIdx)
end

function ClientPlayerRobEggComponent:playLimitTimeChallengeBgm()
	if pg.game and pg.game.audio then
		pg.game.audio:playBgmByLevel(LIMIT_TIME_BGM_REASON, AudioConst.BGM_ROB_EGG_LIMIT_TIME_CHALLENGE, LIMIT_TIME_BGM_LEVEL_PRIORITY, false)
	end
end

function ClientPlayerRobEggComponent:stopLimitTimeChallengeBgm()
	if pg.game and pg.game.audio then
		pg.game.audio:stopBgmByLevel(LIMIT_TIME_BGM_REASON)
	end
end

function ClientPlayerRobEggComponent:showLimitTimeChallengeFinish(params)
	self:hideLimitTimeChallengeCountDown()
	pg.global.ui.tips:showGetEggLimitedTimeFinish(params)
end

function ClientPlayerRobEggComponent:showLimitTimeChallengeReward(params)
	params = params or {}

	if params.hasReward == false then
		self:clearLimitTimeChallengeUI()

		return
	end

	if self.clearLimitTimeChallengeUITimer then
		self:removeTimer(self.clearLimitTimeChallengeUITimer)

		self.clearLimitTimeChallengeUITimer = nil
	end

	local delayTime = RobEggConst.LIMIT_DURING_TIME.REWARDTELPORTTIME or 20

	self.clearLimitTimeChallengeUITimer = self:addTimer(delayTime, function()
		self.clearLimitTimeChallengeUITimer = nil

		self:clearLimitTimeChallengeUI()
	end)
end

function ClientPlayerRobEggComponent:clearLimitTimeChallengeUI()
	if self.clearLimitTimeChallengeUITimer then
		self:removeTimer(self.clearLimitTimeChallengeUITimer)

		self.clearLimitTimeChallengeUITimer = nil
	end

	self:stopLimitTimeChallengeBgm()
	self:hideLimitTimeChallengeCountDown()
	pg.global.ui.tips:hideGetEggLimitedTime()

	if pg.me and pg.me.space then
		pg.me.space.curStage = nil
	end
end

function ClientPlayerRobEggComponent:syncLimitTimePillar(params)
	if not params then
		return
	end

	local pillarEnt = params.pillarEntityId and pg.getEntity(params.pillarEntityId) or nil

	if not pillarEnt and params.pillarStaticId and pg.me and pg.me.space and pg.me.space.getEntityByStaticId then
		pillarEnt = pg.me.space:getEntityByStaticId(params.pillarStaticId)
	end

	if pillarEnt and pillarEnt.syncLimitPillarState then
		pillarEnt:syncLimitPillarState(params.pillarState or params.stage, params.isInitiative)

		self.limitTimePillarSyncParams = nil
	elseif params.pillarEntityId or params.pillarStaticId then
		self.limitTimePillarSyncParams = params
	end
end

function ClientPlayerRobEggComponent:syncLimitTimePillarEntity(pillarEnt)
	local params = self.limitTimePillarSyncParams

	if not params or not pillarEnt or not pillarEnt.syncLimitPillarState then
		return
	end

	if params.pillarEntityId ~= nil and params.pillarEntityId ~= pillarEnt.id then
		return
	end

	if params.pillarEntityId == nil and params.pillarStaticId ~= nil and params.pillarStaticId ~= pillarEnt.staticId then
		return
	end

	pillarEnt:syncLimitPillarState(params.pillarState or params.stage, params.isInitiative)

	self.limitTimePillarSyncParams = nil
end

function ClientPlayerRobEggComponent:syncLimitTimeStage(stage)
	if stage == nil or not pg.me or not pg.me.space then
		return
	end

	pg.me.space.curStage = stage

	local entities = pg.global.entityMgr.getAllEntities()

	for _, entity in pairs(entities) do
		if entity.isTimeLimitPortal and entity.refreshInteractTrigger then
			entity:refreshInteractTrigger()
		end
	end
end

function ClientPlayerRobEggComponent:RPC_SC_RobEggLimitTimeEvent(eventName, params)
	params = params or {}

	self:syncLimitTimeStage(params.stage)
	self:syncLimitTimePillar(params)

	if eventName == "ready" or params.stage == RobEggConst.LIMITTIME_STATE.READY then
		self:playLimitTimeChallengeBgm()
		self:showLimitTimeChallengeCountDown(params)
	elseif eventName == "begin" or params.stage == RobEggConst.LIMITTIME_STATE.BEGIN then
		self:playLimitTimeChallengeBgm()
		self:showLimitTimeChallengeProgress(params)
	elseif eventName == "killPuppetNum" then
		self:refreshLimitTimeChallengeProgress(params)
	elseif eventName == "refreshTimes" then
		self:showLimitTimeChallengeWave(params)
	elseif eventName == "reward" or params.stage == RobEggConst.LIMITTIME_STATE.REWARD then
		self:stopLimitTimeChallengeBgm()
		self:showLimitTimeChallengeReward(params)
	elseif eventName == "finish" or params.stage == RobEggConst.LIMITTIME_STATE.FINISH then
		self:stopLimitTimeChallengeBgm()
		self:showLimitTimeChallengeFinish(params)
	end
end

function ClientPlayerRobEggComponent:onLastFallenAidActorIdChange(ov, nv)
	if nv == 0 and self.isMainPlayer then
		if self:FIRST_AID_ST() then
			self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.FirstAid)
			facade:SendMessageCommand(MessageName.EXIT_FALLEN_AID)
			pg.global.ui.tips:hideControlPanel()
		elseif ov == self.actorId then
			facade:SendMessageCommand(MessageName.EXIT_FALLEN_AID)
			pg.global.ui.tips:hideControlPanel()
		end
	end
end

function ClientPlayerRobEggComponent:onForceControlEggChanged(ov, nv)
	pg.game:setModuleEnable("ForceControlEgg", ClientConst.ModuleKey.PetLink, not nv)
end

return ClientPlayerRobEggComponent
