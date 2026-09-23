-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientCombatEntityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Bitset = require("Common.Bitset")
local PetConfigData = require("Data.pet_config_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local EffectConst = require("Const.EffectConst")
local UIConst = require("Const.UIConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local HotkeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AIUtils = require("Common.Utils.AIUtils")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local MessageName = require("Const.MessageName")
local LxGeometry = require("Common.Ability.LxGeometry")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SandboxConst = require("Common.Const.SandboxConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local AudioConst = require("Const.AudioConst")
local AiConst = require("Common.Const.AiConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local FishingCaptureTimeData = require("Data.fishing_capture_time_data")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Time = require("Core.Common.Time")
local ToBool = ToBool
local Vector3 = Vector3
local pg = pg
local ClientUtils = require("Utils.ClientUtils")
local EffectShaderViewComponent = CS.FunPlus.WorldX.Effect.EffectShaderViewComponent
local AirWallProgressDisengage = CS.FunPlus.WorldX.Physx.AirWallProgressDisengage
local DEAD_CAMERA_UI_WHITE_LIST = {
	[UIConst.UI_ID_DAMAGE_NUMBER] = true
}
local ClientCombatEntityComponent = class.Component("ClientCombatEntityComponent")

local function tryResetMaterialByRevive(ent)
	if ent.resetMaterialByRevive then
		ent:resetMaterialByRevive()
	end
end

function ClientCombatEntityComponent:ctor()
	self.processVoxelTime = Const.PROCESS_ACTOR_VOXEL_INTERVAL
end

function ClientCombatEntityComponent:init(dict)
	if self.actorCombatAttribute then
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.born_scale_rate_v, self.onBornScaleRateVChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.ep_temp_cur, self.onTempEpValueChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.ep_temp_max, self.onTempEpValueChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.ep_cost_reduce_ratio, self.onEpCostChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.ep_cost_reduce_fix, self.onEpCostChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.passive_energy_cur, self.onPassiveEnergyChange)
	end

	local lxCircle = LxGeometry.LxCircle3D.new()

	lxCircle.radius = 0.5
	lxCircle.heightUp = 0.5
	lxCircle.heightDown = 0.5
	self.bodyShape = lxCircle

	if Utils.isVirtualEntity(self) then
		VirtualEntUtils.setDefaultCombat(self, dict)
	end

	return true
end

function ClientCombatEntityComponent:start()
	if self.isVisibleByAbility ~= nil then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_ABILITY, ToBool(self.isVisibleByAbility), true)
	end

	if self.isInCapture then
		self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.CAPTURE)
	end
end

function ClientCombatEntityComponent:destroy()
	if self.delayReviveTimer ~= nil then
		self:removeTimer(self.delayReviveTimer)

		self.delayReviveTimer = nil
	end

	if self.clearCaptureRestoreFallback then
		self:clearCaptureRestoreFallback()
	end

	self:clearProgressDisengage()
	self:refreshBossAreaEffect(false)
end

function ClientCombatEntityComponent:onEnterSpace()
	if Utils.isPet(self) or Utils.isPuppet(self) or Utils.isPlayer(self) or Utils.isBotPlayer(self) then
		self:calcAndRefreshModelScale(true)
	elseif self.space then
		self:applyFixedScaleFromSceneData()
	end

	local inComabt = self:isInCombat()

	self:refreshBossAreaEffect(inComabt)

	if Utils.isSemanticallyBoss(self) then
		self:setLodTickEnable(Const.LOD_TICK_KEY.BOSS_COMBAT, not inComabt)
	end

	if self.life == Const.LIFE_DEAD then
		if pg.me.cacheBossCaptureActorId == self.actorId and self.needDoGroupReward then
			self:onLifeDead()
			pg.me:startBossCapture(self.actorId)
		elseif Utils.isSelfInSpaceFishingCaptureDungeon(pg.me, FishingCaptureConst.Phase.CAPTURE) then
			self:onLifeDead()
		else
			AnimationUtils.playAnimationState(self, CharacterStateConst.DEAD)
		end
	elseif self.life == Const.LIFE_FALLEN then
		self:onLifeFallen()
	end

	self:tryShowDeadPanelOnInit()

	if self.isMainPlayer then
		pg.game:setModuleEnable("Fallen", ClientConst.ModuleKey.Skill, not self:FALLEN_ST())
	end
end

function ClientCombatEntityComponent:applyFixedScaleFromSceneData()
	if not self.staticId or not self.space then
		return
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local data = sceneEntityData and sceneEntityData[self.staticId]

	if data and data.fixedScale and data.fixedScale ~= 0 and self.setModelScale then
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, data.fixedScale)
	end
end

function ClientCombatEntityComponent:clearProgressDisengage()
	if self.progressDisengage == nil then
		return
	end

	self.progressDisengage = nil

	facade:SendMessageCommand(MessageName.EXIT_PROGRESS_DISENGAGE, 0)
end

function ClientCombatEntityComponent:refreshBossAreaEffect(inCombat)
	if not self.space then
		return
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local entityData = sceneEntityData and sceneEntityData[self.staticId]

	if entityData and entityData.bossAreaEffect then
		if inCombat and not self.bossAreaEffect then
			local position = entityData.bossAreaEffectPosition
			local scale = self:getConfigData().followRadius / 30

			self:tryCreateAreaEffect(entityData.bossAreaEffect, position, scale, nil, entityData.canLeaveBossArea)
		else
			self:clearProgressDisengage()
			self:tryRemoveAreaEffect()
		end
	end
end

function ClientCombatEntityComponent:tryCreateAreaEffect(resId, position, scale, layer, canLeaveBossArea)
	if self.bossAreaEffectTaskId or NotNil(self.bossAreaEffect) then
		return
	end

	self.bossAreaEffectTaskId = pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(obj, customData)
		self.bossAreaEffectTaskId = nil
		self.bossAreaEffect = obj

		local effectShaderView = EffectShaderViewComponent.GetOrAddComponent(self.bossAreaEffect)

		effectShaderView:SetMaterialProperty("_VFXDistanceFadePluginModel_DistanceFadeEnable", 1)

		self.bossAreaEffect.transform.position = position or Vector3.constZero
		scale = scale or 1

		local rawScale = self.bossAreaEffect.transform.localScale

		self.bossAreaEffect.transform.localScale = Vector3(rawScale.x * scale, self.bossAreaEffect.transform.localScale.y, rawScale.z * scale)

		local progressDisengage = AirWallProgressDisengage.GetOrAddComponent(self.bossAreaEffect)

		AirWallProgressDisengage.AUTO_REDUCE_RATE = AbilitySettingGlobalConstData.disengageAutoReduceRate or 0.1
		progressDisengage.selfActorId = self.actorId
		progressDisengage.progressTime = AbilitySettingGlobalConstData.airWallProgressEngageTime or 1

		progressDisengage:SetModelLayer(layer or ClientConst.LayerDefine.LAYER_AIR_WALL)

		if canLeaveBossArea == nil then
			canLeaveBossArea = true
		end

		progressDisengage.canLeave = canLeaveBossArea
	end)
end

function ClientCombatEntityComponent:tryRemoveAreaEffect()
	self:clearProgressDisengage()

	if self.bossAreaEffectTaskId then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(self.bossAreaEffectTaskId)
	end

	if self.bossAreaEffect then
		pg.global.resMgr:RemoveInstanceToCache(self.bossAreaEffect, true)
	end

	self.bossAreaEffectTaskId = nil
	self.bossAreaEffect = nil
end

function ClientCombatEntityComponent:onExitProgressDisengage(progress, justClient)
	progress = math.min(progress, 1)

	local successExit = progress >= 1

	if successExit and self.space:isDittoSpace() then
		pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.EXIT)
		pg.global.ui.blackScreen:open({
			id = 168
		})
	end

	if successExit and not justClient and not self.space:isGrabEgg() then
		pg.me:serverMsg("RPC_CS_ExitProgressDisengage", self.actorId, pg.pawn.actorId)
	end

	facade:SendMessageCommand(MessageName.EXIT_PROGRESS_DISENGAGE, progress)
	pg.game.controller.lockHelper:resetLockDis()

	if successExit and self.space:isGrabEgg() then
		pg.me:serverMsg("RPC_CS_WillExitBecameArea")
		self:setBossAreaEffectColliderState(false)
	end

	self.progressDisengage = nil
end

function ClientCombatEntityComponent:setBossAreaEffectColliderState(enable)
	if self.space:isGrabEgg() and NotNil(self.bossAreaEffect) then
		enable = enable or false

		local progressDisengage = AirWallProgressDisengage.GetOrAddComponent(self.bossAreaEffect)

		progressDisengage:SetColliderEnable(enable)
	end
end

function ClientCombatEntityComponent:setBossAreaEffectLayer(layer)
	if self.space:isGrabEgg() and NotNil(self.bossAreaEffect) then
		enable = enable or false

		local progressDisengage = AirWallProgressDisengage.GetOrAddComponent(self.bossAreaEffect)

		progressDisengage:SetModelLayer(layer or 0)
	end
end

function ClientCombatEntityComponent:onUpdateProgressDisengage(progress)
	progress = math.min(progress, 1)

	local title

	if self.progressDisengage == nil then
		self.progressDisengage = {
			duration = 5,
			state = 1,
			progress = progress,
			title = title
		}
	else
		self.progressDisengage.progress = progress
	end

	facade:SendMessageCommand(MessageName.UPDATE_PROGRESS_DISENGAGE, self.progressDisengage)
end

function ClientCombatEntityComponent:setInSwitchAnimScale(isInSwitchAnim)
	if self.inSwitchAnimScale == isInSwitchAnim then
		return
	end

	self.inSwitchAnimScale = isInSwitchAnim

	self:calcAndRefreshModelScale()
end

function ClientCombatEntityComponent:calcAndRefreshModelScale(force)
	local scale = self:calcModelScale()

	if force or self.curModelScale ~= scale then
		self:applyModelScale(scale)
	end
end

function ClientCombatEntityComponent:calcModelScale()
	if self.overrideScale then
		return self.overrideScale
	end

	local scale = 1

	if Utils.isPet(self) then
		if self:checkPetInControl() and not self.inSwitchAnimScale then
			local entityConfigData = self:getConfigData()
			local scaleRange = entityConfigData.modelScaleRange

			scale = scaleRange and scaleRange[3] or 1
		else
			local scaleFixRatio = (self.actorCombatAttribute:getAttribValue(AttributeConst.born_scale_rate_v) or 0) + 1

			scale = self.bornScale * scaleFixRatio
		end
	else
		local fixedScale

		if self.staticId and self.space then
			local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
			local data = sceneEntityData and sceneEntityData[self.staticId]

			fixedScale = data and data.fixedScale
		end

		scale = fixedScale or self.bornScale or scale
	end

	return scale
end

function ClientCombatEntityComponent:applyModelScale(scale)
	local entityConfigData = self:getConfigData()

	self.bodySize = entityConfigData.bodySize * scale
	self.bodyHeight = entityConfigData.bodyHeight * scale

	local hitBoxHeightDown = 0

	if Utils.isPlayer(self) and self:isControllingEgg() then
		local curEggEnt = self:getCurControllingEgg()

		if curEggEnt and curEggEnt.getEggPhysxData then
			local radius, height, center = curEggEnt:getEggPhysxData()

			self.bodySize = radius
			self.bodyHeight = radius
			hitBoxHeightDown = radius
		end
	end

	if self.aoi then
		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			self.bodySize,
			self.bodyHeight,
			hitBoxHeightDown
		})
	end

	self.curModelScale = scale

	if self.setModelScale then
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, scale)
	end

	self.bodyWeight = (entityConfigData.weight or 1) * self.curModelScale

	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		self.eModel.weight = self.bodyWeight
	end

	if self.eventEmitter then
		self.eventEmitter:emit(EventConst.TOPLOGO_HEIGHT)
	end

	self.footprintSfxLevel = entityConfigData.footprintSfxLevel or 1
	self.footprintInterval = entityConfigData.footprintInterval or 0.1

	if self.rawMaxAttackDist then
		self.maxAttackDist = self.bodySize + (self.rawMaxAttackDist - self.bodySize) * 0.8
	end

	self:postComponentMethod("EVENT_OnModelScaleChanged", scale)
end

function ClientCombatEntityComponent:onExploreRevivePerChanged(old, new)
	facade:SendMessageCommand(MessageName.EXPLORE_PET_REVIVE_PERCENT_CHANGED, {
		old,
		new,
		self
	})
end

function ClientCombatEntityComponent:onBornScaleChange(old, new)
	self:calcAndRefreshModelScale()
end

function ClientCombatEntityComponent:onCurLoadLevelChange(old, new)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_BAG_WEIGHT_LEVEL_CHANGE)
end

function ClientCombatEntityComponent:on_combatStatus_changed(oldv, newv)
	if newv == Const.COMBAT_STATUS_IN_COMBAT then
		self:postComponentMethod("onEnterCombat")

		if self.subject then
			self.subject:notify(AbilityConst.COMBAT_EVENT_ENTER_COMBAT)
		end

		if Utils.isPlayer(self) then
			local petEntity = self:getCurPetEntity()

			if petEntity then
				petEntity.subject:notify(AbilityConst.COMBAT_EVENT_ENTER_COMBAT)
				petEntity:postComponentMethod("onEnterCombat")
			end

			facade:sendMsgToUI(MessageName.PLAYER_COMBAT_STATUS_UPDATE, newv)
		elseif Utils.isBotPlayer(self) then
			local petEntity = self:getCurPetEntity()

			if petEntity then
				petEntity.subject:notify(AbilityConst.COMBAT_EVENT_ENTER_COMBAT)
				petEntity:postComponentMethod("onEnterCombat")
			end
		end

		local enableBubbleInCombat = self:getConfigData().enableBubbleInCombat or self.forceShowBubbleInCombat

		if not ToBool(enableBubbleInCombat) then
			self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, false)
		end
	else
		if newv == Const.COMBAT_STATUS_NORMAL then
			self:postComponentMethod("onLeaveCombat")

			if self.subject then
				self.subject:notify(AbilityConst.COMBAT_EVENT_LEAVE_COMBAT)
			end

			if Utils.isPlayer(self) then
				local petEntity = self:getCurPetEntity()

				if petEntity then
					petEntity.subject:notify(AbilityConst.COMBAT_EVENT_LEAVE_COMBAT)
					petEntity:postComponentMethod("onLeaveCombat")
				end

				facade:sendMsgToUI(MessageName.PLAYER_COMBAT_STATUS_UPDATE, newv)
			elseif Utils.isBotPlayer(self) then
				local petEntity = self:getCurPetEntity()

				if petEntity then
					petEntity.subject:notify(AbilityConst.COMBAT_EVENT_LEAVE_COMBAT)
					petEntity:postComponentMethod("onLeaveCombat")
				end
			end
		end

		self.lockPet = false
	end

	if self.updateFollowingPhantomList then
		self:updateFollowingPhantomList()
	end
end

function ClientCombatEntityComponent:onEnterCombat()
	self:refreshBossAreaEffect(true)

	if Utils.isSemanticallyBoss(self) then
		self:setLodTickEnable(Const.LOD_TICK_KEY.BOSS_COMBAT, false)
	end
end

function ClientCombatEntityComponent:onLeaveCombat()
	self:refreshBossAreaEffect(false)

	if Utils.isSemanticallyBoss(self) then
		self:setLodTickEnable(Const.LOD_TICK_KEY.BOSS_COMBAT, true)
	end
end

function ClientCombatEntityComponent:onPetSummon()
	if Utils.isSupportPet(self) then
		local master = self:getMasterEntity()

		if master and master:isControllingExploreEnt() then
			return
		end

		self:playSupportPetFresnelEffect(true)
		AIUtils.pauseBt(self, AiConst.PauseBtReason.SupportPet)
	end
end

function ClientCombatEntityComponent:onPetUnSummon()
	if Utils.isSupportPet(self) then
		AIUtils.resumeBt(self, AiConst.PauseBtReason.SupportPet)
	end
end

function ClientCombatEntityComponent:getGroupActorId()
	return self.actorId
end

function ClientCombatEntityComponent:getMaxHp()
	return self.maxHp
end

function ClientCombatEntityComponent:getHp()
	return self.curHp
end

function ClientCombatEntityComponent:getMaxEp()
	return self.maxEp
end

function ClientCombatEntityComponent:getEp()
	return self.curEp
end

function ClientCombatEntityComponent:getMaxSp()
	return self.maxSp
end

function ClientCombatEntityComponent:getSp()
	return self.curSp
end

function ClientCombatEntityComponent:getStamina()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.stamina_cur)
end

function ClientCombatEntityComponent:getHatredValue(ent)
	local hatredInfo = self.hatredMap[ent:getGroupActorId()]

	if hatredInfo then
		return hatredInfo.hatredValue
	else
		return 0
	end
end

function ClientCombatEntityComponent:getHatred()
	local hatred = {}

	for actorId, hatredInfo in pairs(self.hatredMap) do
		hatred[actorId] = hatredInfo.hatredValue
	end

	return hatred
end

function ClientCombatEntityComponent:getBehatredMap()
	return self.behatredMap
end

function ClientCombatEntityComponent:isInCombat()
	return self.combatStatus == Const.COMBAT_STATUS_IN_COMBAT
end

function ClientCombatEntityComponent:isInCallHelp()
	local now = self:getGameTime()

	return now < self.callHelpEndTime
end

function ClientCombatEntityComponent:getHatredBossIds()
	local bossIds = {}

	for actorId, _ in pairs(self.behatredMap) do
		local ent = pg.getEntityByActorId(actorId)

		if ent and Utils.isBoss(ent) and ent.templateId then
			bossIds[#bossIds + 1] = ent.templateId
		end
	end

	return bossIds
end

function ClientCombatEntityComponent:doDieWithAutoRevive(reason, blackScreenId, resetPositionType, revivePos, reviveRot, bloodProportion)
	local isMainActor = self.isMainPlayer or self.isMainPet

	if not isMainActor or self:DEAD_ST() then
		return
	end

	local player

	if Utils.isPlayer(self) then
		player = self
	end

	if Utils.isPet(self) then
		player = self:getMasterEntity()
	end

	if player then
		player.reviveInfo = {
			autoRevive = true,
			blackScreenId = blackScreenId,
			resetPositionType = resetPositionType,
			revivePos = revivePos,
			reviveRot = reviveRot
		}
	end

	if resetPositionType == 4 then
		if player then
			player:serverMsg("RPC_CS_ResetPosition")
		end
	else
		if player and player.inRestartRacing then
			return
		end

		bloodProportion = bloodProportion and bloodProportion or 1

		self:serverMsg("RPC_CS_SpecialDamage", bloodProportion, reason)
	end
end

function ClientCombatEntityComponent:waitForRevive(reason, srcActorId)
	local isMainPlayer = self.isMainPlayer or false

	if not isMainPlayer then
		return
	end

	if self.space and self.space:isRogueEnv() then
		self:addTimer(2.5, function()
			facade:sendMsgToUI(MessageName.ROGUE_RESULT_CHANGE, {
				result = false
			})
		end)
		self:addTimer(3, function()
			self:doRevive()

			self.reviveInfo = nil
		end)

		return
	elseif self.space and self.space:isGrabEgg() then
		self:addTimer(3, function()
			self:doRevive()

			self.reviveInfo = nil
		end)

		return
	end

	local reviveInfo = Utils.getRegionReviveConfig(self)

	if ToBool(reason) then
		local _, _, blackScreenId = Utils.getPosResetInfoByReason(self, reason)

		reviveInfo.blackScreenId = blackScreenId or reviveInfo.blackScreenId
	end

	if ToBool(reviveInfo.blackScreenId) then
		local _, _, _, _, _, portalBlackScreenId = Utils.getNearbyPortalInfo(self)

		if ToBool(portalBlackScreenId) then
			reviveInfo.blackScreenId = portalBlackScreenId
		end
	end

	local blackScreenId = reviveInfo.blackScreenId

	if self.reviveInfo == nil then
		self.reviveInfo = reviveInfo
	end

	if ToBool(self.reviveInfo.autoRevive) then
		if ToBool(blackScreenId) then
			pg.global.ui.blackScreen:open({
				id = blackScreenId,
				finishCb = function()
					if self.life == Const.LIFE_DEAD then
						return
					end

					self:onLifeRevival()
				end
			}, function()
				self:startDelayReviveTimer(reason)
			end)
		else
			self:doRevive(reason)

			self.reviveInfo = nil
		end

		return
	end

	self.reviveInfo.reason = reason

	local entity = pg.getEntityByActorId(srcActorId)

	if Utils.isCreation(entity) or Utils.isPuppet(entity) then
		local masterEntity = entity:getMasterEntity()

		srcActorId = masterEntity and masterEntity.actorId or srcActorId
	end

	self.reviveInfo.srcActorId = srcActorId

	if self.space and self.space:isBossRushEnv() then
		self.reviveInfo.title = pg.getGameString("BOSS_RUSH_DEAD_TITLE")
		self.reviveInfo.tip = pg.getGameString("BOSS_RUSH_DEAD_TIP")
	end

	pg.global.ui.deadPanel:open(self.reviveInfo)

	self.reviveInfo = nil
end

function ClientCombatEntityComponent:doRevive(reason, reviveType)
	if not Utils.isPlayer(self) then
		return
	end

	if self.life == Const.LIFE_DEAD or self.life == Const.LIFE_FALLEN then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("@hyj doRevive dead")
		end

		reviveType = reviveType or Const.REVIVE_TYPE_NORMAL

		self:serverMsg("RPC_CS_StartRevive", reviveType, CallbackHandler(self, "clearDeadReason"))
	elseif self.life == Const.LIFE_ALIVE then
		local posType, posParam = Utils.getPosResetInfoByReason(self, reason)
		local reviveInfo = self.reviveInfo or {}
		local resetPositionType = reviveInfo.resetPositionType and reviveInfo.resetPositionType or posType
		local revivePos = reviveInfo.revivePos and reviveInfo.revivePos or posParam
		local reviveRot = reviveInfo.reviveRot
		local isBacktrackPos, pos, rotYawEuler = self:tryGetValidBacktrackData(reason, resetPositionType, revivePos, reviveRot)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("@hyj doRevive alive", reason, isBacktrackPos, inspect(pos), rotYawEuler)
		end

		if isBacktrackPos then
			self:serverMsg("RPC_CS_SetBacktrackPos")
		end

		self:serverMsg("RPC_CS_ResetPosByRecord", pos, rotYawEuler, CallbackHandler(self, "onLifeAliveRevival"))
	end
end

function ClientCombatEntityComponent:clearDeadReason()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@hyj onReviveCallback clearDeadReason")
	end

	self.willDeadReason = nil
end

function ClientCombatEntityComponent:on_elementType_change(ov, nv)
	facade:sendMsgToUI(MessageName.ENT_ELEMENT_CHANGE, {
		entId = self.id
	})
end

function ClientCombatEntityComponent:getTagMaterial()
	return self.tagMaterial
end

function ClientCombatEntityComponent:isAlive()
	return self.life == Const.LIFE_ALIVE
end

function ClientCombatEntityComponent:isFakeDead()
	return self.life == Const.LIFE_FAKE_DEAD
end

function ClientCombatEntityComponent:isDead()
	return self.life == Const.LIFE_DEAD
end

function ClientCombatEntityComponent:setTagMaterialIndex(tag, isSet)
	if isSet then
		self.tagMaterial = Bitset.bor(self.tagMaterial, tag)
	else
		self.tagMaterial = Bitset.band(self.tagMaterial, Bitset.bnot(tag))
	end
end

function ClientCombatEntityComponent:onLifeChange(oldValue, newValue)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLifeChange", self.actorId, oldValue, newValue)
	end

	if self.refreshTopLogoDeadState then
		self:refreshTopLogoDeadState()
	end

	if oldValue == Const.LIFE_FALLEN then
		self:leaveLifeFallen()
	end

	if newValue == Const.LIFE_DEAD then
		self:onLifeDead()
	elseif newValue == Const.LIFE_ALIVE then
		self:onLifeRevival(oldValue)
	elseif newValue == Const.LIFE_FAKE_DEAD or newValue == Const.LIFE_FAKE_DEAD_CAN_HIT then
		self:onLifeFakeDead()
	elseif newValue == Const.LIFE_FALLEN then
		self:onLifeFallen()
	elseif newValue == Const.LIFE_NEAR_DEAD then
		self:onLifeNearDead()
	end

	local _h = ClientCombatEntityComponent._platformHooks

	if _h and _h.onLifeChange then
		_h.onLifeChange(self, oldValue, newValue)
	end

	if oldValue == Const.LIFE_FALLEN or newValue == Const.LIFE_FALLEN then
		pg.global.eventEmitter:emit(EventConst.ON_ALLY_MARK_STATE_CHANGED, self.id)
	end

	if self.refreshLifeGroup then
		self:refreshLifeGroup(newValue)
	end

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.LIFE_NEAR_DEAD, newValue == Const.LIFE_NEAR_DEAD)
end

function ClientCombatEntityComponent:onSkeletonLoaded()
	local needBornGeomDissolve = self.space and self.space:isRogueEnv() and ToBool(self:getConfigData().isPlayMorphDissolve)

	if needBornGeomDissolve and self.eModel then
		self:playTeleportAppearEffect(1.5, nil, 1)
	end
end

function ClientCombatEntityComponent:getDeadAbilityId()
	return self:getConfigData()[AbilityConst.WEAPON_ABILITY_MAP[AbilityConst.DEAD_ABILITY]] or 0
end

function ClientCombatEntityComponent:playDeathBgm()
	local configData = self:getConfigData()

	if Utils.isBoss(self) or Utils.isElite(self) and configData.deathBgm then
		pg.game.audio:playBgm(configData.deathBgm, AudioConst.BgmPriority.BossDeath)
		pg.me:addTimer(configData.deathBgmDuration or 20, function()
			pg.game.audio:stopBgm(AudioConst.BgmPriority.BossDeath)
		end)
	end
end

function ClientCombatEntityComponent:onLifeDead()
	self.subject:notify(AbilityConst.COMBAT_EVENT_DEAD)
	self:checkDead()
	self:stopAllAnimation()
	self.actorTimeline:stopCombatActionTimeline()
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	self:postComponentMethod("EVENT_OnLifeDead")

	if self == pg.me then
		facade:SendMessageCommand(MessageName.PLAYER_HUB_LIFE_DEAD)
	end

	if Utils.isPuppet(self) then
		if not self.isDummyClone then
			if self.needDoGroupReward then
				local duration = SysConfigData.eliteDeadCatchDizzinessEffectDuration or 120

				self:playCfgAnimation({
					"StunStart",
					"StunLoop",
					"StunEnd",
					{
						false,
						duration
					}
				})
				AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
			elseif Utils.isSelfInSpaceFishingCaptureDungeon(pg.me) then
				local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
				local phase = activityData and activityData:getCurPhase()
				local config = FishingCaptureActivityData and FishingCaptureActivityData[phase]
				local captTime = config and config.captTime or 999
				local transTime = config and config.transTime or 10
				local bonusTime = 0

				bonusTime = FishingCaptureTimeData[#FishingCaptureTimeData].catchbonusTime or 15

				local duration = captTime + transTime + bonusTime

				self:refreshPhysxDataOnAnimation(CharacterStateConst.DEAD)

				local entityConfigData = self:getConfigData()
				local rigidBodyId = entityConfigData.rigidbodyForDead

				if rigidBodyId then
					self:refreshPuppetCapture(rigidBodyId)
				end

				self:playCfgAnimation({
					"Catch_Start",
					"Catch_Loop",
					"Catch_End",
					{
						false,
						duration
					}
				})
				AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
			else
				AnimationUtils.playAnimationState(self, CharacterStateConst.DEAD)
			end
		end

		local configData = self:getConfigData()
		local needDeadGeomDissolve = self.space and self.space:isRogueEnv() and ToBool(configData.isPlayMorphDissolve)

		if (configData.isDeadDissolve or needDeadGeomDissolve) and self:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
			local delayDieTime = Utils.getEntityConfigData(self).delayDestroy or 3

			if needDeadGeomDissolve then
				local dieAnimTime = AnimationUtils.getPlayableClipLength(self, PlayableConst.Die, 0)

				self:addTimer(dieAnimTime, function()
					self:playPetDeadDissolveEffect(delayDieTime + 0.5)
				end)
			else
				self.eModel.modelShaderView:PlayDissolve(delayDieTime + 0.5)
			end
		end

		if configData.deadPreset and self.eModel then
			local preset, duration, disableFinish = unpack(configData.deadPreset)

			ClientEffectUtils.PlayPreset(self, preset, duration, ToBool(disableFinish))
		end

		if self.staticId then
			local eventData = {
				id = self.staticId
			}

			facade:sendLuaEvent(self.staticId .. SandboxConst.COMMON_EVENT.DEAD, eventData)
		end

		self:playDeathBgm()

		if Utils.isSelfInSpaceFishingCaptureDungeon(pg.me) and self:isFishingCaptureBoss() then
			local component = pg.global.ui and pg.global.ui.tips and pg.global.ui.tips:getBossTitleItem()

			if component and component.onTargetDeadImmediately then
				component:onTargetDeadImmediately(self)
			end
		end
	elseif Utils.isPet(self) then
		AnimationUtils.forceChangeState(self, CharacterStateConst.DEAD)

		if self.eModel then
			local waitTime = self.space:isPvpEnv() and PetConfigData.DeathSwitchPVPWaitTime or PetConfigData.DeathSwitchWaitTime

			self.eModel.modelShaderView:PlayDissolve(waitTime + 0.5)
		end

		local master = self:getMasterEntity()

		if master then
			master:postComponentMethod("EVENT_OnPetLifeDead", self.actorId)
		end
	end

	self.eModel:AlwaysForceUnGround(Const.COMPONENT_MOTION, false)

	local deadAbilityId = self:getDeadAbilityId()

	if ToBool(deadAbilityId) then
		self:clientCastAbilityNoTarget(deadAbilityId)
	end
end

function ClientCombatEntityComponent:onLifeAliveRevival()
	if not Utils.isPlayer(self) then
		return
	end

	self:clearDeadReason()
	self:checkDead()
	self:stopAllAnimation()
	self:postComponentMethod("onLifeRevival")

	if self.isMainPlayer then
		pg.global.ui.deadPanel:close()
		pg.global.effectMgr:ForceRefreshEnv()
	end

	self:resetPetsStateOnPlayerRevive(true)
	tryResetMaterialByRevive(self)
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, true)
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
	self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setStateType", nil)

	if self == pg.me then
		facade:SendMessageCommand(MessageName.ENTER_LIFE_ALIVE)
		facade:SendMessageCommand(MessageName.PLAYER_HUB_LIFE_ALIVE)
	end
end

function ClientCombatEntityComponent:onLifeRevival(oldState)
	self:stopAllAnimation()

	if self.characterState == CharacterStateConst.IDLE and Utils.isAIEntity(self) and self.eModel then
		self.eModel:ReEnterStateSelf(Const.COMPONENT_AI_CONTROLLER)
	else
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE, nil, false)
	end

	self:postComponentMethod("onLifeRevival")

	if Utils.isPuppet(self) then
		self:removeFakeDeadTrigger()
	elseif Utils.isPlayer(self) then
		self:performPlayerRevivalPerformance(oldState)
	end

	if Utils.isPetPuppet(self) then
		self.eModel.modelShaderView:StopDissolve()
	end

	self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setStateType", nil)

	if self == pg.me then
		facade:SendMessageCommand(MessageName.ENTER_LIFE_ALIVE)
		facade:SendMessageCommand(MessageName.PLAYER_HUB_LIFE_ALIVE)
	end
end

function ClientCombatEntityComponent:performPlayerRevivalPerformance(oldState, ignoreBlackScreen)
	if self.forbidRevivalPerformance then
		self.forbidRevivalPerformance = nil

		return
	end

	if self.isMainPlayer then
		pg.global.ui.deadPanel:close()
		pg.global.effectMgr:ForceRefreshEnv()
	end

	self:resetPetsStateOnPlayerRevive()
	tryResetMaterialByRevive(self)
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, true)
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.DIE)

	if pg.global.ui.blackScreen:checkUIShow() and not ignoreBlackScreen then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)

		return
	end

	if self.overrideRebornPerformCb then
		self.overrideRebornPerformCb()

		self.overrideRebornPerformCb = nil
	elseif oldState == Const.LIFE_FALLEN then
		AnimationUtils.playAnimationState(self, CharacterStateConst.FALLENSTANDUP)
	else
		AnimationUtils.playAnimationState(self, CharacterStateConst.REVIVE)
		self:playSwitchAppearEffect(SysConfigData.playerReviveEffectDuration or 1.2)
	end

	if self.isMainPlayer then
		local groundPos = PhysicsUtils.getGroundPos(self:getPosition(), 2)

		EModelUtils.setMotionPositionByNumber(self, groundPos.x, groundPos.y, groundPos.z)
	end
end

function ClientCombatEntityComponent:onLifeFakeDead()
	if Utils.isPuppet(self) then
		self:addFakeDeadTrigger()
	end

	self:checkDead()
	self:stopAllAnimation()
	self.actorTimeline:stopCombatActionTimeline()
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	AnimationUtils.playAnimationState(self, CharacterStateConst.DEAD)
end

function ClientCombatEntityComponent:onLifeFallen()
	self:checkFallen()
	self:stopAllAnimation()

	if self.characterState == CharacterStateConst.FALLENSTANDUP then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
	end

	AnimationUtils.playAnimationState(self, CharacterStateConst.FALLEN)
	self:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setStateType", UIConst.TOPLOGO_TEAM_MATE_STATE.FALLEN)

	if self == pg.me then
		facade:SendMessageCommand(MessageName.ENTER_LIFE_FALLEN)
	end
end

function ClientCombatEntityComponent:leaveLifeFallen()
	AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
end

function ClientCombatEntityComponent:onLifeNearDead()
	AnimationUtils.playAnimationState(self, CharacterStateConst.NEARDEAD)
end

function ClientCombatEntityComponent:startDelayReviveTimer(reason, reviveType, delayTime)
	delayTime = delayTime or 0.5

	if self.delayReviveTimer ~= nil then
		self:removeTimer(self.delayReviveTimer)

		self.delayReviveTimer = nil
	end

	self.delayReviveTimer = self:addTimer(delayTime, function()
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, false)
		self:doRevive(reason, reviveType)

		self.reviveInfo = nil
	end)
end

function ClientCombatEntityComponent:resetPetsStateOnPlayerRevive(isPlayerAlive)
	if not self:isPrepareListEmpty() then
		for petIdx, pet in pairs(self.petPrepareList) do
			local petEnt = pg.getEntity(self.petPrepareList[petIdx])

			if petEnt ~= nil then
				petEnt.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
				petEnt:stopForceDisplacement()

				if not isPlayerAlive or not petEnt:DEAD_ST() then
					AnimationUtils.playAnimationState(petEnt, CharacterStateConst.IDLE)
				end

				tryResetMaterialByRevive(petEnt)
				petEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, true)
			end
		end
	end
end

function ClientCombatEntityComponent:hideAllPetOnPlayerDead()
	if not self:isPrepareListEmpty() then
		for petIdx, pet in pairs(self.petPrepareList) do
			local petEnt = pg.getEntity(self.petPrepareList[petIdx])

			if petEnt ~= nil then
				petEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, false)
			end
		end
	end
end

function ClientCombatEntityComponent:handleDeadCameraAnim(bossEntity, hasKilled)
	local deadCameraAnim = bossEntity:getConfigData().deadCameraAnim

	if deadCameraAnim then
		local pivotOffset = Vector3(0, bossEntity:getHeight() * 0.5, 0)
		local scale = 1
		local bossStaticId = bossEntity.staticId

		if bossEntity.getBaseModelScale then
			scale = bossEntity:getBaseModelScale()
		end

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PUPPET_DEATH_CAM_ANIM, DEAD_CAMERA_UI_WHITE_LIST, 10)
		pg.game.input:resetAllActions()
		pg.game.input:setAllInputMapEnabled(false, HotkeyConst.INPUT_BLOCK_FLAG.PuppetDeathCamAnim)
		pg.game.camera:playCameraAnimByEntity(self, deadCameraAnim, 0, 1, true, nil, pivotOffset, false, true, scale, function()
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PUPPET_DEATH_CAM_ANIM)
			pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.PuppetDeathCamAnim)

			if not hasKilled then
				self:showFirstKillBossToast(bossStaticId)
			end
		end, true)

		return true
	end

	return false
end

function ClientCombatEntityComponent:showFirstKillBossToast(bossStaticId)
	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)

	if sceneEntityData[bossStaticId] then
		local markId = sceneEntityData[bossStaticId].sandboxId
		local staticIdInfo = pg.game.map:getMarkInfo(markId)

		if staticIdInfo then
			pg.global.ui.tips:hideA1Tips("BossFirstKill", bossStaticId)
			pg.global.ui.tips:showA1Tips({
				priority = 10,
				id = "BossFirstKill",
				uniqueId = bossStaticId,
				icon = staticIdInfo.POIIcon,
				title = staticIdInfo.infoTitle
			})
		end
	end
end

function ClientCombatEntityComponent:handleKillBossPerformance(bossEntity, killerEntity, hasKilled, hitPos)
	local killBossFreezeScale = SysConfigData.killBossFreezeScale or 0.1
	local killBossFreezeDuration = SysConfigData.killBossFreezeDuration or 3
	local killBossCameraOffsetAngle = SysConfigData.killBossCameraOffsetAngle or 45
	local killBossCameraMaxDistance = SysConfigData.killBossCameraMaxDistance or 10

	self.space.timeScaleMgr:startGlobalFreeze(killBossFreezeScale, 0, 0, killBossFreezeDuration)

	local bossPos = bossEntity:getPositionAgentPosition()
	local killerPos = killerEntity:getPositionAgentPosition()
	local targetPos = hitPos or bossPos
	local midPoint = (killerPos + targetPos) * 0.5
	local playerHeight, _ = pg.me:getCameraHeightInfo()

	midPoint.y = midPoint.y + playerHeight

	local attackDir = targetPos - killerPos

	attackDir.y = 0

	local horizontalDis = attackDir:Magnitude()

	attackDir:SetNormalize()

	local focus2BossDir = bossPos - midPoint

	focus2BossDir:SetNormalize()

	local distance = 5

	if killBossCameraOffsetAngle == 0 then
		distance = math.max(5, horizontalDis * 0.5 + 1)
	else
		distance = math.max(5, horizontalDis / 0.8284272)
	end

	distance = math.min(distance, killBossCameraMaxDistance)

	local isRight = Vector3.Cross(attackDir, focus2BossDir).y < 0
	local rotSign = isRight and 1 or -1

	pg.game.camera.killBossCamera:enableCamera(true, midPoint, Quaternion.Euler(0, rotSign * killBossCameraOffsetAngle, 0) * Quaternion.LookRotation(attackDir, Vector3.up), distance, killBossFreezeDuration)

	local extInfo = {
		position = CombatActionTool.getHitPosition(bossEntity),
		rotation = bossEntity:getRotation():ToEulerAngles(),
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global
	}

	bossEntity:playEffect("Eff_Parmon_Common_FirstKill", extInfo)
	pg.game.audio:playEvent("SFX_Combat_Boss_FirstKill")

	if pg.space:isBossRushEnv() and pg.space.luckyPetRewardPlayers and pg.space.luckyPetRewardPlayers[pg.me.id] then
		bossEntity:playEffect(SysConfigData.BossRushLuckyPetTriggerEffect)
	end

	if not self:handleDeadCameraAnim(bossEntity, hasKilled) then
		local bossStaticId = bossEntity.staticId

		self:addTimer(killBossFreezeDuration, function()
			self.isKillBossFrameFreezing = nil

			pg.game.camera.killBossCamera:setActive(false)

			if not hasKilled then
				self:showFirstKillBossToast(bossStaticId)
			end
		end)
	end
end

function ClientCombatEntityComponent:onPuppetBossDead(bossEntity, killerEntity, hasKilled, hitPos)
	if not bossEntity then
		return
	end

	local killBossFreezeDelay = SysConfigData.killBossFreezeDelay or 0

	self.isKillBossFrameFreezing = true

	if killBossFreezeDelay <= 0 then
		self:handleKillBossPerformance(bossEntity, killerEntity, hasKilled, hitPos)
	else
		self:addTimer(killBossFreezeDelay, function()
			self:handleKillBossPerformance(bossEntity, killerEntity, hasKilled, hitPos)
		end)
	end
end

function ClientCombatEntityComponent:RPC_SC_OnPlayerNearDead(srcActorId, reason)
	if Utils.isPlayer(self) and self.isMainPlayer then
		pg.global.ui.deadPanel:open({
			isNearDead = true,
			srcActorId = srcActorId,
			reason = reason
		})
	end
end

function ClientCombatEntityComponent:RPC_SC_OnPlayerDead(life, srcActorId, reason)
	if Utils.isPlayer(self) then
		self:postComponentMethod("EVENT_OnPlayerDead")

		if self.isMainPlayer then
			if CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.FALLEN) then
				AnimationUtils.playAnimationState(self, CharacterStateConst.NEARDEAD)
			else
				AnimationUtils.playAnimationState(self, CharacterStateConst.DEAD)
			end

			self:waitForRevive(reason, srcActorId)

			if self:RIDING_ST() then
				self:dismountVehicle(self.onVehicleActorId)
			end

			pg.game.controller.lockHelper:cancelForceLockTarget()

			if self.cancelFollowTarget then
				self:cancelFollowTarget()
			end
		end

		self:hideAllPetOnPlayerDead()
	end
end

function ClientCombatEntityComponent:tryShowDeadPanelOnInit()
	if self.isMainPlayer and self.life == Const.LIFE_DEAD then
		self:playAnimation(PlayableConst.Die)
		self:waitForRevive()
	end
end

function ClientCombatEntityComponent:onIsInCaptureChange(oldValue, newValue)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onIsInCaptureChange", oldValue, newValue)
	end

	if newValue ~= oldValue then
		self:refreshEffectVisibleByCapture(newValue)

		if newValue then
			self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.CAPTURE)
		else
			self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.CAPTURE)

			if Utils.isPuppet(self) and self.scheduleCaptureRestoreFallback then
				self:scheduleCaptureRestoreFallback()
			end
		end

		AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_IN_CAPTURE, newValue == true)
		AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.IS_IN_CAPTURE, newValue == true)
	end
end

function ClientCombatEntityComponent:onImmuneDamageEndTimeChanged(oldValue, newValue)
	local duration = newValue - self:getGameTime()

	if duration > 0 then
		self.eModel.modelShaderView:SetMaterialProperty("_VFXFresnelPluginModel_FresnelEnable", 1)
		self:addTimer(duration, function()
			self.eModel.modelShaderView:SetMaterialProperty("_VFXFresnelPluginModel_FresnelEnable", 0)
		end)
	end
end

function ClientCombatEntityComponent:RPC_SC_TeammateShowReviveBlackScreen(uid, reason)
	if uid ~= pg.me.uid and pg.me.inTeammateView then
		ClientUtils.showBlackScreen(2000)
	end
end

function ClientCombatEntityComponent:RPC_SC_TeammateNotifyLifeStateChanged(uid, newv)
	facade:sendMsgToUI(MessageName.TEAM_PLAYER_STATE_CHANGED, {
		uid = uid,
		state = newv
	})
end

function ClientCombatEntityComponent:RPC_SC_TeammateNotifyMaxHpChange(uid, newv)
	facade:sendMsgToUI(MessageName.TEAM_PLAYER_MAX_HP_CHANGED, {
		uid = uid,
		maxHp = newv
	})
end

function ClientCombatEntityComponent:RPC_SC_TeammateNotifyHpChange(uid, newv)
	facade:sendMsgToUI(MessageName.TEAM_PLAYER_HP_CHANGED, {
		uid = uid,
		hp = newv
	})
end

function ClientCombatEntityComponent:RPC_SC_ShowReviveBlackScreen(reason, blackScreenId)
	if self:isDead() then
		return
	end

	self:hideAllPetOnPlayerDead()

	if self.reviveInfo ~= nil and self.reviveInfo.blackScreenId ~= nil then
		blackScreenId = self.reviveInfo.blackScreenId
	end

	if reason == Const.LIFE_DEAD_BY_WATER and not self.forceControl then
		AnimationUtils.playAnimationState(self, CharacterStateConst.STRUGGLE)

		if self.reviveInfo == nil then
			self.reviveInfo = {}
		end

		self.reviveInfo.blackScreenId = blackScreenId

		return
	end

	if ToBool(blackScreenId) then
		pg.global.ui.blackScreen:open({
			id = blackScreenId
		}, function()
			self:startDelayReviveTimer(reason)
		end)
	else
		self:doRevive(reason)

		self.reviveInfo = nil
	end
end

function ClientCombatEntityComponent:playSwitchDissolveVegEffect(duration, offset)
	offset = offset or 0

	local height = self:getHeight() + offset
	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.addNextFrameCb(function()
		if self.eModel then
			self:playEffect("Eff_VEG_Switch_Disappear")
		end
	end)
end

function ClientCombatEntityComponent:onBornScaleRateVChange(old, new)
	self:calcAndRefreshModelScale()
end

function ClientCombatEntityComponent:onTempEpValueChange(old, new)
	if pg.game.controller:isInControlMainPlayer() then
		facade:SendMessageCommand(MessageName.MAIN_PLAYER_EP_CHANGE)
	else
		facade:SendMessageCommand(MessageName.PET_EP_CHANGE, pg.me.curIndex)
	end
end

function ClientCombatEntityComponent:onEpCostChange(old, new)
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.ON_ABILITY_EP_COST_CHANGED)
	end
end

function ClientCombatEntityComponent:onPassiveEnergyChange(old, new)
	if self.isMainPlayer or self.isMainPet then
		if self.spEnergyInfo == nil then
			return false
		end

		if new == 0 then
			self.spEnergyInfo.triggeredFull = false
		elseif not self.spEnergyInfo.triggeredFull then
			local maxSpEnergy = self.actorCombatAttribute:getRawAttribValue(AttributeConst.passive_energy_max)

			if maxSpEnergy <= new then
				self.spEnergyInfo.triggeredFull = true
			end
		end

		facade:sendMsgToUI(MessageName.ON_PASSIVE_ENERGY_CHANGED)
	end
end

function ClientCombatEntityComponent:getLockedActorId()
	return self.lockedActorId
end

function ClientCombatEntityComponent:getAttackTargetActorId()
	if Utils.isPuppet(self) and Utils.checkHateModeEqual(self) then
		return self.attackTargetActorId or 0
	end

	return self:getLockedActorId() or 0
end

function ClientCombatEntityComponent:RPC_SC_OnForceTauntLockTarget(actorId)
	if self:isDead() then
		return
	end

	self:lockTarget(actorId)
end

function ClientCombatEntityComponent:RPC_SC_OnKillBoss(actorId, killerActorId, hasKilled, hitPos)
	hitPos = Vector3.Convert(hitPos)

	local bossEntity = pg.getEntityByActorId(actorId)
	local killerEntity = pg.getEntityByActorId(killerActorId)

	self:onPuppetBossDead(bossEntity, killerEntity, hasKilled, hitPos)
end

function ClientCombatEntityComponent:dumpHatredInfo()
	pg.me:serverMsg("RPC_CS_DumpHatredInfo", function(result)
		self.logger:error("hatredInfo", inspect(result, {
			depth = 10
		}))
	end)
end

function ClientCombatEntityComponent:getGMHatredInfo()
	local index = 1

	for actorId, hatredInfo in pairs(self.hatredMap) do
		CombatActionTool.TEMP_TABLE[index] = string.format("{%d, %.2f}", actorId, hatredInfo.hatredValue)
		index = index + 1
	end

	local hatredInfoStr = index > 1 and table.concat(CombatActionTool.TEMP_TABLE, ", ", 1, index - 1) or "null"

	index = 1

	for actorId, _ in pairs(self.behatredMap) do
		CombatActionTool.TEMP_TABLE[index] = actorId
		index = index + 1
	end

	local beHatredInfo = index > 1 and table.concat(CombatActionTool.TEMP_TABLE, ", ", 1, index - 1) or "null"

	index = 1

	if self.viewHatredMap then
		for actorId, value in pairs(self.viewHatredMap) do
			CombatActionTool.TEMP_TABLE[index] = string.format("{%d, %.2f}", actorId, value)
			index = index + 1
		end
	end

	local viewHatredInfo = index > 1 and table.concat(CombatActionTool.TEMP_TABLE, ", ", 1, index - 1) or "null"

	for i = #CombatActionTool.TEMP_TABLE, 1, -1 do
		CombatActionTool.TEMP_TABLE[i] = nil
	end

	return string.format("hatredInfo: %s\nbeHatredInfo: %s\nviewHatredInfo: %s", hatredInfoStr, beHatredInfo, viewHatredInfo)
end

function ClientCombatEntityComponent:restoreNormalState()
	pg.pawn.actorTimeline:stopCombatActionTimeline()
	pg.pawn.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	pg.pawn:stopForceDisplacement()
	pg.pawn:_backToDefault()
	pg.game.input:resetAllActions()
end

function ClientCombatEntityComponent:onAddScanEffect(camp, scanEffect)
	self:refreshCampScanEffect(camp, scanEffect)
end

function ClientCombatEntityComponent:onRemoveScanEffect(camp, scanEffect)
	self:refreshCampScanEffect(camp, scanEffect)
end

function ClientCombatEntityComponent:refreshCampScanEffect(camp)
	local mainPlayerCamp = pg.me.tempCamp

	if mainPlayerCamp == 0 then
		mainPlayerCamp = pg.me.camp
	end

	if self ~= pg.me and camp == mainPlayerCamp then
		if self.campScanMap[camp] then
			pg.global.cameraMgr:AddVolumeEffect(10, AddressDataConst.ABILITY_PARMON_FLUOROSCOPY_SCAN, -1)

			if Utils.isPlayer(self) or Utils.isPet(self) then
				self.eModel.shaderView:ChangeEffectMaterial(AddressDataConst.ABILITY_FLUOROSCOPY_SCAN_PLAYER)
			elseif Utils.isPuppet(self) then
				self.eModel.shaderView:ChangeEffectMaterial(AddressDataConst.ABILITY_FLUOROSCOPY_SCAN_WILD_PET)
			end
		else
			self.eModel.shaderView:ChangeEffectMaterial("")
		end
	end
end

function ClientCombatEntityComponent:EVENT_OnModelRefreshed()
	for camp, info in pairs(self.campScanMap or EMPTY_TABLE) do
		if type(info) == "table" and info.timerId then
			self:refreshCampScanEffect(camp, info)
		end
	end
end

function ClientCombatEntityComponent:EVENT_OnHit(srcActorId, abilityId)
	if self == pg.pawn and ClientUtils.isFullScreenUI() then
		facade:sendMsgToUI(MessageName.ON_HIT_WHEN_FULL_SCREEN_UI_SHOW, {})
	end

	local isMyHit = self == pg.me or Utils.isPet(self) and self:getMasterEntity() == pg.me

	if isMyHit and pg.space and pg.space:isGrabEgg() then
		facade:sendMsgToUI(MessageName.ON_HIT_WHEN_ROG_EGG)
	end
end

function ClientCombatEntityComponent:onFallenAidEndTimeChange(old, new)
	if self.updateStateCache then
		self:updateStateCache("FALLEN_AID_ST")
	end

	if new ~= 0 then
		self:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setStateType", UIConst.TOPLOGO_TEAM_MATE_STATE.AID)

		if self == pg.me then
			self:showAidToast(self, self.playerName)
		end
	else
		if self:FALLEN_ST() then
			self:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setStateType", UIConst.TOPLOGO_TEAM_MATE_STATE.FALLEN)
		end

		if self == pg.me then
			pg.global.ui.tips:hideControlPanel()
		end
	end

	pg.global.eventEmitter:emit(EventConst.ON_ALLY_MARK_STATE_CHANGED, self.id)
end

function ClientCombatEntityComponent:RPC_SC_CallHelp(uid, id)
	if uid ~= pg.me.uid then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_CALL_HELP)
		pg.game.audio:playEvent("SFX_UI_QTE_Fail")
	end

	local callHelpPlayerEnt = pg.getEntity(id)

	if callHelpPlayerEnt then
		callHelpPlayerEnt:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setIsCalling", true)
		pg.global.eventEmitter:emit(EventConst.ON_ALLY_MARK_STATE_CHANGED, id)

		if callHelpPlayerEnt.callHelpTimer then
			callHelpPlayerEnt:removeTimer(callHelpPlayerEnt.callHelpTimer)
		end

		callHelpPlayerEnt.callHelpTimer = callHelpPlayerEnt:addTimer(SysConfigData.callHelpDuration or 3, function()
			callHelpPlayerEnt.callHelpTimer = nil

			callHelpPlayerEnt:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.TEAM_MATE, "setIsCalling", false)
			pg.global.eventEmitter:emit(EventConst.ON_ALLY_MARK_STATE_CHANGED, id)
		end)
	end
end

function ClientCombatEntityComponent:on_gmMode_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_gmMode_changed", oldv, newv)
	end

	if self.updateStateCache then
		self:updateStateCache("GM_OBSERVE_ST")
	end

	if self == pg.me and pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:changeGmBtnVisible(self.gmMode == Const.SHOW_GM_PANEL)
	end

	if newv == Const.OBSERVE_MODE then
		self:postComponentMethod("onEnterGmObserveMode")
	elseif oldv == Const.OBSERVE_MODE then
		self:postComponentMethod("onExitGmObserveMode")
	end
end

function ClientCombatEntityComponent:onIsTransparentChange(old, new)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRANSPARENT, new == true)
	AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.IS_TRANSPARENT, new == true)

	if self.refreshTopLogoVisibleGate then
		self:refreshTopLogoVisibleGate()
	end
end

return ClientCombatEntityComponent
