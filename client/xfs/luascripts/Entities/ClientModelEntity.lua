-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientModelEntity.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientEntity = require("Core.Client.ClientEntity")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local EventConst = require("Const.EventConst")
local SysConfigData = require("Data.sys_config_data")
local EntityTagData = require("Data.entity_tag_data")
local SceneData = require("Data.scene_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local TimerManager = require("Core.Timer.TimerManager")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local Events = require("Common.Container.Events")
local ClientModelEntity = Class.Class("ClientModelEntity", ClientEntity)
local ClientDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDebugComponent")
local ClientVisibleComponent = require("Entities.SpaceEntities.CommonComponent.ClientVisibleComponent")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientEModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientEModelComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local ClientModelComponents = {
	ClientPosRotComponent,
	ClientLODComponent,
	ClientEModelComponent,
	ClientVisibleComponent,
	ClientDebugComponent
}

if EnableBotTest then
	local BotClientComponent = require("Bot.BotEntities.Components.BotClientComponent")

	ClientModelComponents = {
		ClientPosRotComponent,
		ClientLODComponent,
		BotClientComponent,
		ClientDebugComponent
	}
end

Class.AddComponents(ClientModelEntity, ClientModelComponents)

local entityManager = appFacade.entityManager

function ClientModelEntity:ctor(entityId)
	ClientModelEntity.super.ctor(self, entityId)

	self.isDestroyed = false
	self.entityCanMove = true
	self.isInScene = false
	self.eventEmitter = Events.new()
	self.CsEventMap = {}
	self.LuaActionMap = {}
	self.isModelLoaded = false
end

function ClientModelEntity:init(dict)
	local result = ClientModelEntity.super.init(self, dict)

	self.sandboxId = dict.sandboxId
	self.sandboxType = dict.sandboxType

	if dict.isGhost then
		self.isGhost = dict.isGhost
	end

	self.isInScene = false
	self.syncEntityRole = dict.syncEntityRole

	return result
end

function ClientModelEntity:postInit(dict)
	ClientModelEntity.super.postInit(self, dict)

	if not EnableBotTest then
		self:createEModel()
	end
end

function ClientModelEntity:onEnterSpace()
	local staticId = self.staticId

	if staticId ~= nil and staticId > 0 then
		self.staticSceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)[staticId]
	end

	if self.syncEntityRole == 1 and self.space.ownerPlayerId ~= pg.me.id then
		self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.SYNC_ENTITY_ROLE, false)
		AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.SYNC_ENTITY_ROLE, true)
	end

	self:postComponentMethod("onEnterSpace")
	self:checkSceneLoaded()

	if Utils.fromSandbox(self) then
		local sandboxId = self.sandboxId

		self.sandboxReady = false

		self.space:registerSandboxEntity(sandboxId, self)
	else
		self.sandboxReady = true
	end
end

function ClientModelEntity:onLeaveSpace()
	self:postComponentMethod("onLeaveSpace")

	self.staticSceneEntityData = nil

	if Utils.fromSandbox(self) then
		local sandboxId = self.sandboxId

		self.space:unregisterSandboxEntity(sandboxId, self)
	end
end

function ClientModelEntity:onEnterTrap(tgtId, eventId)
	return
end

function ClientModelEntity:onLeaveTrap(tgtId, eventId)
	return
end

function ClientModelEntity:beAttached()
	self.isTrapped = true

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, true)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self:stopTick()
	self:closeTopLogo()
	self:postComponentMethod("EVENT_OnEntityBeAttached")
end

function ClientModelEntity:beDetached()
	if self:isDead() then
		return
	end

	self.isTrapped = false

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, false)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self:startTick()
	self:openTopLogo()
	self:postComponentMethod("EVENT_OnEntityBeDetached")
end

function ClientModelEntity:preDestroy()
	self:setInScene(false)

	if pg.me and ToBool(self.actorId) and self.actorId == pg.me.lockedActorId then
		pg.game.controller.lockHelper:cancelLockTarget()
	end

	ClientModelEntity.super.preDestroy(self)
end

function ClientModelEntity:destroy()
	self.isDestroyed = true
	self.staticSceneEntityData = nil

	ClientModelEntity.super.destroy(self)
end

function ClientModelEntity:refreshAppearance(forceRefreshPlayable)
	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local extraData = self:getModelExtraData(configData)

	self:postComponentMethod("EVENT_OnMergeAppearanceData", configData, extraData)
	self:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	self:refreshModel(configData, extraData)
end

function ClientModelEntity:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	self:setModelLayer()
	self.eModel:SetClientReady(true)
end

function ClientModelEntity:refreshModel(configData, extraData)
	return
end

function ClientModelEntity:getModelExtraData(configData)
	return nil
end

function ClientModelEntity:onModelRefreshed()
	self:postComponentMethod("EVENT_OnModelRefreshed")

	if (self.isMainPlayer or self.isMainPet) and self.setRendererLod then
		self:setRendererLod(0)
	end
end

function ClientModelEntity:setModelLayer(layer)
	if layer == nil then
		layer = self:getConfigData().layer or ClientConst.LayerDefine.LAYER_ENTITY
	end

	if self.eModel then
		self.eModel:SetModelLayer(layer)
	end
end

function ClientModelEntity:getBaseAttachEffects()
	return {}
end

function ClientModelEntity:setModelLoaded(isLoaded)
	if self.eModel == nil then
		return
	end

	self.eModel.isModelLoaded = isLoaded
end

function ClientModelEntity:refreshVisible()
	self:postComponentMethod("EVENT_RefreshVisible")
end

function ClientModelEntity:onActiveChange(active)
	self:postComponentMethod("EVENT_OnActiveChange", active)
	self:postComponentMethod("NPCINFO_OnAciveChange", active)
	self.eventEmitter:emit(EventConst.ENTITY_ACTIVE_CHANGED, false)
end

function ClientModelEntity:onModelVisibleChange(visible)
	self:postComponentMethod("EVENT_OnModelVisibleChange", visible)
	self.eventEmitter:emit(EventConst.ENTITY_VISIBLE_CHANGED, visible)
end

function ClientModelEntity:getHeight()
	return self:getConfigData().modelHeight or 1.65
end

function ClientModelEntity:getPrecheckAfkParams()
	local ret = Vector3.zero
	local data = self:getConfigData()

	ret.x = data.afkPitch or 5
	ret.y = data.afkCameraNearHeight or data.overrideCameraNearHeight or self:getEyeHeight()
	ret.z = data.minDistanceAfk or data.minDistance or 1

	return ret
end

function ClientModelEntity:getDofGameObject(key)
	return pg.game.camera:getDof(key)
end

function ClientModelEntity:getEyeHeight()
	return self:getConfigData().eyeHeight or 1.65
end

function ClientModelEntity:getCameraHeightInfo()
	local configData = self:getConfigData()
	local nearHeight = 0
	local farHeight = 0

	if configData.overrideCameraNearHeight then
		nearHeight = configData.overrideCameraNearHeight
	else
		nearHeight = self:getEyeHeight()
	end

	if configData.overrideCameraFarHeight then
		farHeight = configData.overrideCameraFarHeight
	else
		local entHeight = self:getHeight()
		local halfHeight = entHeight * 1 / 2

		farHeight = halfHeight
	end

	return nearHeight, farHeight, 0
end

function ClientModelEntity:getCrouchCameraHeightInfo()
	local configData = self:getConfigData()
	local nearHeight = 0
	local farHeight = 0

	if configData.overrideCameraNearHeightInCrouch then
		nearHeight = configData.overrideCameraNearHeightInCrouch
	else
		nearHeight = self:getEyeHeight()
	end

	if configData.overrideCameraFarHeightInCrouch then
		farHeight = configData.overrideCameraFarHeightInCrouch
	else
		local entHeight = self:getHeight()
		local halfHeight = entHeight * 1 / 2

		farHeight = halfHeight
	end

	return nearHeight, farHeight
end

function ClientModelEntity:getCameraClimbHeightInfo()
	local configData = self:getConfigData()

	if configData.overrideCameraHeightClimb then
		return configData.overrideCameraHeightClimb
	end

	return configData.overrideCameraNearHeight or self:getEyeHeight()
end

function ClientModelEntity:canBeLocked()
	return false
end

function ClientModelEntity:isPartEnt()
	return false
end

local _up = Vector3(0, 1, 0)

function ClientModelEntity:getLockPosition()
	local entityConfigData = self:getConfigData()
	local position

	if entityConfigData.lockBoneName then
		local mountData = ClientEffectUtils.getBestFitCommonMount(self, entityConfigData.lockBoneName)

		if mountData then
			position = self:getCommonMountPosition(mountData)
		else
			local valid, pos = self.eModel.skeletonView:TryGetBonePos(entityConfigData.lockBoneName)

			position = valid and pos or self:getPosition()
		end
	end

	if not position then
		local height = self.eModel and self.eModel.height * 0.5 or 0

		if math.Approximately(height, 0) then
			height = (self.bodyHeight or 0) * 0.5
		end

		_up.y = height
		position = self:getLockPartPosition(pg.me.lockedPartId) + _up
	end

	return position
end

function ClientModelEntity:getLockPartPosition(partId)
	return self:getPosition()
end

function ClientModelEntity:getLockParts()
	return {}
end

function ClientModelEntity:queryModelVisible()
	return true, true, true
end

function ClientModelEntity:setInScene(isInScene, isReset, extraInfo)
	if self.isInScene ~= isInScene then
		self.isInScene = isInScene

		if isInScene then
			self:onEnterScene(extraInfo)
		else
			self:onLeaveScene(extraInfo)
		end
	elseif self.isInScene and isReset then
		self:onResetScene(extraInfo)
	end

	self:_cancelWaitGroundReady()

	if isInScene and self.space and (self.space:isRogueEnv() or self.space:isBossRushEnv()) and self.space.rogueGroundReady ~= true then
		self:_waitGroundReady()

		return
	end

	self:_setKccAndKinematic(isInScene)
end

function ClientModelEntity:_waitGroundReady()
	if self.space.registerWaitGroundReady then
		self.space:registerWaitGroundReady(self)

		self._waitingGroundSpace = self.space
	end

	local WAIT_GROUND_MAX_FRAME = 100

	self._waitGroundFrameCb = TimerManager.addSpecificFrameCb(WAIT_GROUND_MAX_FRAME, false, function()
		self._waitGroundFrameCb = nil

		if not self.eModel or not self.isInScene then
			self:_cancelWaitGroundReady()

			return
		end

		self:_cancelWaitGroundReady()
		self:_setKccAndKinematic(true)
	end)
end

function ClientModelEntity:onRogueGroundReady()
	self:_cancelWaitGroundReady()

	if self.isInScene and self.eModel then
		self:_setKccAndKinematic(true)
	end
end

function ClientModelEntity:_cancelWaitGroundReady()
	if self._waitGroundFrameCb then
		TimerManager.delFrameCb(self._waitGroundFrameCb)

		self._waitGroundFrameCb = nil
	end

	if self._waitingGroundSpace then
		if NotNil(self._waitingGroundSpace) and self._waitingGroundSpace.unregisterWaitGroundReady then
			self._waitingGroundSpace:unregisterWaitGroundReady(self)
		end

		self._waitingGroundSpace = nil
	end
end

function ClientModelEntity:_setKccAndKinematic(isInScene)
	self:SetKccEnable(isInScene, Const.KccDisableReason.SceneLoading)

	if self.setIsKinematic then
		self:setIsKinematic(not isInScene, ClientConst.IsKinematicKey.SceneLoading)
	end
end

function ClientModelEntity:SetKccEnable(enabled, reason)
	if self.eModel then
		self.eModel:SetKccEnableEx(enabled, reason)
	end
end

function ClientModelEntity:onEnterScene()
	self:postComponentMethod("EVENT_EnterScene")
	self:postComponentMethod("EVENT_RefreshPhysx")
end

function ClientModelEntity:onLeaveScene()
	self:postComponentMethod("EVENT_LeaveScene")
end

function ClientModelEntity:onResetScene()
	self:postComponentMethod("EVENT_ResetScene")
end

function ClientModelEntity:checkSceneLoaded()
	local sceneValid = pg.global.scene:isSceneValid()

	self:setInScene(sceneValid)
end

function ClientModelEntity:onTimePeriodChange()
	return
end

function ClientModelEntity:onEModelCreateEffect()
	self:refreshVisible()
end

function ClientModelEntity:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
end

function ClientModelEntity:postInitializeComponents()
	self.eModel:PostInitialize()

	local st, err = xpcall(self.refreshAppearance, debug.traceback, self)

	if not st and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s safeDestroy failed, %s", self:repr(), err)
	end
end

function ClientModelEntity:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.ENTITY
end

function ClientModelEntity:getEModelResId()
	return AddressDataConst.Ent_Entity
end

function ClientModelEntity:isEnemy(target)
	return Utils.isEnemy(self, target)
end

function ClientModelEntity:canAim()
	local isInCapture = self.isInCapture

	if isInCapture then
		local space = pg.me and pg.me.space

		if space and Utils.isSpaceFishingCaptureDungeon(space.spaceType) then
			isInCapture = false
		end
	end

	local isPuppet = Utils.isPuppet(self) and not isInCapture and not self.isTrapped
	local npc = not Utils.isNpc(self) or Utils.isNpc(self) and Utils.npcShowForbidCatchReason(self)
	local isPet = Utils.isPet(self)

	return isPuppet and npc or isPet
end

function ClientModelEntity:canAbsorb()
	local isInCapture = self.isInCapture

	if isInCapture then
		local space = pg.me and pg.me.space

		if space and Utils.isSpaceFishingCaptureDungeon(space.spaceType) then
			isInCapture = false
		end
	end

	local isPuppet = Utils.isPuppet(self) and not isInCapture and not self.isTrapped
	local isNpc = Utils.isNpc(self)
	local allEntityTags = Utils.getEntityTags(self)
	local hasEntityTag = false

	for _, tagName in ipairs(allEntityTags) do
		if EntityTagData[tagName] and EntityTagData[tagName].ignoreCatchAbsorbAndDump then
			hasEntityTag = true

			break
		end
	end

	return isPuppet and not isNpc and not hasEntityTag
end

function ClientModelEntity:isConfigKinematic()
	return true
end

function ClientModelEntity:getConfigData()
	return {}
end

function ClientModelEntity:getTemplateId()
	return self.templateId or 0
end

function ClientModelEntity:getSceneEntityCfg(cfgName)
	if self.staticSceneEntityData then
		local sceneEntityDataValue = self.staticSceneEntityData[cfgName]

		if sceneEntityDataValue ~= nil then
			return sceneEntityDataValue
		end
	end

	return self:getConfigData()[cfgName]
end

function ClientModelEntity:csRequireConfigData(dataName, sysCfgName)
	local ret = dataName and self:getSceneEntityCfg(dataName) or nil

	if ret == nil and sysCfgName then
		ret = SysConfigData[sysCfgName]
	end

	return ret
end

function ClientModelEntity:csRequireHasConfigData(dataName)
	local ret = self:getSceneEntityCfg(dataName)

	return ret ~= nil
end

function ClientModelEntity:csRequireSpaceData(dataName, sysCfgName)
	local data = SceneData[self.space.sceneId]

	return data[dataName]
end

function ClientModelEntity:csRequireHasSpaceData(dataName)
	if self.space and self.space.sceneId then
		return true
	end

	return false
end

function ClientModelEntity:isMatchRule(ruleId)
	return Utils.isEntityMatchRule(self, ruleId)
end

function ClientModelEntity:faceToTarget(target, partId, useTurnAnim)
	if target then
		local targetDir = target:getLockPartPosition(partId) - self:getPosition()

		targetDir.y = 0

		if Vector3.SqrMagnitude(targetDir) < 0.1 then
			return
		end

		local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

		if useTurnAnim then
			self:turnToRotation(targetRotation)
		else
			self:faceToRotation(targetRotation)
		end
	end
end

function ClientModelEntity:faceToPosition(pos)
	local targetDir = pos - self:getPosition()

	targetDir.y = 0

	if Vector3.SqrMagnitude(targetDir) < 0.1 then
		return
	end

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	self:faceToRotation(targetRotation)
end

function ClientModelEntity:faceToRotation(rotation)
	EModelUtils.setAgentRotation(self, rotation, true)
end

function ClientModelEntity:turnToRotation(rotation)
	AnimationUtils.playTurnAnimation(self, rotation)
end

function ClientModelEntity:canBeLookAt()
	return self:getSceneEntityCfg("canBeLookAt")
end

function ClientModelEntity:hasEntityTag(tag)
	return Utils.hasEntityTag(self, tag)
end

function ClientModelEntity:onTriggerEnter(userData)
	self:postComponentMethod("onTriggerEnter", userData)
end

function ClientModelEntity:onTriggerExit(userData)
	self:postComponentMethod("onTriggerExit", userData)
end

function ClientModelEntity:needLimitCount()
	return false
end

function ClientModelEntity:getTopLogoFollowStrategy()
	return ClientConst.TopLogoFollowStrategy.FxRoot
end

function ClientModelEntity:getTopLogoHeight()
	local configData = self:getConfigData()
	local scale = self.curModelScale or 1
	local modelHeight = self:getHeight()

	if configData and configData.topLogoHeight and configData.topLogoHeight > 0 then
		return configData.topLogoHeight * scale
	end

	if configData and configData.topLogoOffsetNoScale then
		return configData.topLogoOffsetNoScale
	end

	if configData and configData.topLogoOffset then
		return configData.topLogoOffset * scale
	end

	return modelHeight * scale + 0.2
end

function ClientModelEntity:getModelBodyRadius()
	local configData = self:getConfigData()
	local scale = self.curModelScale or 1

	if configData.bodySize then
		return configData.bodySize * scale
	end

	return 0
end

function ClientModelEntity:getTopLogoHeightToRoot()
	local topLogoHeight = self:getTopLogoHeight()
	local scale = self.curModelScale or 1

	if self.topLogoData.strategy == 3 then
		local success, y = self.eModel:TryGetHeadY(Const.COMPONENT_INDEX_MODEL)

		if success then
			topLogoHeight = (y - self:getPosition().y) * scale + 0.4
		end
	end

	return topLogoHeight
end

function ClientModelEntity:playDestroyEffect()
	local destroyEffect = self:getConfigData().destroyEffect

	if destroyEffect then
		local px, py, pz = self.eModel:GetPositionAgentPosEx()

		pg.game.effect:playEffectAt(0, destroyEffect, Vector3.New(px, py, pz), self:getRotation():ToEulerAngles(), self)
	end
end

return ClientModelEntity
