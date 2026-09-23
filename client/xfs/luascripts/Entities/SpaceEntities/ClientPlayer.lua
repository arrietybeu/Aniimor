-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPlayer.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local TimerManager = require("Core.Timer.TimerManager")
local EntityManager = require("Core.Common.EntityManager")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ClientConst = require("Const.ClientConst")
local AvatarData = require("Data.avatar_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceData = require("Data.appearance_data")
local Const = require("Common.Const.Const")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientUtils = require("Utils.ClientUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local Time = require("Core.Common.Time")
local Bitset = require("Common.Bitset")
local NpcAvatarData = require("Data.npc_avatar_data")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local AudioConst = require("Const.AudioConst")
local SceneData = require("Data.scene_data")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local EventConst = require("Const.EventConst")
local lume = require("Core.Common.lume")
local ClientPlayer = class.Class("ClientPlayer", ClientPawnEntity)
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local Vector3 = Vector3
local pg = pg
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientCaptureComponent = require("Entities.SpaceEntities.PlayerComponent.ClientCaptureComponent")
local ClientPetsComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsComponent")
local ClientInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractComponent")
local ClientAppearanceComponent = require("Entities.SpaceEntities.CommonComponent.ClientAppearanceComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local ClientEntityCacheValComponent = require("Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent")
local ClientCombatComponent = require("Entities.SpaceEntities.PlayerComponent.ClientCombatComponent")
local PerceptibilityResponseComponent = require("Common.Components.PerceptibilityResponseComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientLiftComponent = require("Entities.SpaceEntities.CommonComponent.ClientLiftComponent")
local ClientPushComponent = require("Entities.SpaceEntities.CommonComponent.ClientPushComponent")
local ClientLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientLookAtComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientMiniGameCommonComponent = require("Entities.SpaceEntities.CommonComponent.ClientMiniGameCommonComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientPlayerSandboxComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerSandboxComponent")
local ClientAreaHandlerComponent = require("Entities.SpaceEntities.CommonComponent.ClientAreaHandlerComponent")
local ClientMapComponent = require("Entities.SpaceEntities.CommonComponent.ClientMapComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local AIGroupCombatComponent = require("Common.Components.AIGroupCombatComponent")
local ClientPlayerInteractComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerInteractComponent")
local ClientSubMagnesisComponent = require("Entities.SpaceEntities.CommonComponent.ClientSubMagnesisComponent")
local ClientPlayerHomeInteractComponent = require("Entities.SpaceEntities.Home.ClientPlayerHomeInteractComponent")
local ClientHomelandWorkComponent = require("Entities.SpaceEntities.Home.ClientHomelandWorkComponent")
local ClientEggModeComponent = require("Entities.SpaceEntities.CommonComponent.ClientEggModeComponent")
local ClientPlayerCarryComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerCarryComponent")
local ClientActionStateComponent = require("Entities.SpaceEntities.PlayerComponent.ClientActionStateComponent")
local ClientInteractionAnimationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientInteractionAnimationComponent")
local ClientTeamFollowComponent = require("Entities.SpaceEntities.CommonComponent.ClientTeamFollowComponent")
local ClientCafeGatheringComponent = require("Entities.SpaceEntities.PlayerComponent.ClientCafeGatheringComponent")
local ClientPetInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetInteractComponent")
local ClientTrapComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local AutoPathFindComponent = require("Common.Components.AutoPathFindComponent")
local CharacterController = require("Common.Components.CharacterController")
local ClientDyingComponent = require("Entities.SpaceEntities.CommonComponent.ClientDyingComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientVehicleOpComponent = require("Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local PlayerComponents = {
	AutoPathFindComponent,
	CharacterController,
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientDyingComponent,
	ClientVehicleOpComponent,
	ClientAuthorityComponent,
	ClientCaptureComponent,
	ClientPetsComponent,
	ClientInteractComponent,
	ClientAbilityComponent,
	ClientCombatEntityComponent,
	ClientAppearanceComponent,
	ClientCombatComponent,
	PerceptibilityResponseComponent,
	ClientTimeControlComponent,
	ClientHomelandWorkComponent,
	ClientTopLogoComponent,
	ClientPushComponent,
	ClientLookAtComponent,
	ClientSimpleLookAtComponent,
	ClientMiniGameCommonComponent,
	ClientLiftComponent,
	ClientRVOComponent,
	ClientPlayerSandboxComponent,
	ClientPlayerHomeInteractComponent,
	ClientAreaHandlerComponent,
	ClientMapComponent,
	ClientAttachComponent,
	ClientEntityCacheValComponent,
	AIGroupCombatComponent,
	ClientPlayerInteractComponent,
	ClientSubMagnesisComponent,
	ClientEggModeComponent,
	ClientPlayerCarryComponent,
	ClientActionStateComponent,
	ClientInteractionAnimationComponent,
	ClientTeamFollowComponent,
	ClientCafeGatheringComponent,
	ClientPetInteractComponent,
	ClientTrapComponent,
	ClientEcsComponent
}

if EnableBotTest then
	local BotClientAbilityComponent = require("Bot.BotEntities.Components.BotClientAbilityComponent")

	PlayerComponents = {
		ClientStateCheckComponent,
		ClientAuthorityComponent,
		ClientCaptureComponent,
		ClientPetsComponent,
		ClientInteractComponent,
		BotClientAbilityComponent,
		ClientCombatEntityComponent,
		ClientAppearanceComponent,
		ClientCombatComponent,
		PerceptibilityResponseComponent,
		ClientTimeControlComponent,
		ClientPushComponent,
		ClientLookAtComponent,
		ClientMiniGameCommonComponent,
		ClientLiftComponent,
		ClientPlayerSandboxComponent,
		ClientAreaHandlerComponent,
		ClientTopLogoComponent,
		ClientEggModeComponent,
		ClientCafeGatheringComponent
	}
end

class.AddComponents(ClientPlayer, PlayerComponents)

function ClientPlayer:ctor(entityId)
	ClientPlayer.super.ctor(self, entityId)

	self.isMainPlayer = false
	self.actorType = Const.ACTOR_TYPE_PLAYER
	self.isClientEnt = false
end

function ClientPlayer:init(bdict)
	ClientPlayer.super.init(self, bdict)

	self.uid = bdict.uid
	self.forbiddenTopLogo = false
	self.bodyMass = SysConfigData.avatarMass
	self.bodyWeight = SysConfigData.avatarWeight or 6
	self.topLogoType = ClientConst.TopLogoType.Player

	ClientUtils.updateMaxPreparedPetLevel(self)
	EntityManager.addUidEntity(self.uid, self)

	return true
end

function ClientPlayer:start()
	ClientPlayer.super.start(self)

	if pg.me then
		pg.me:syncPosThisFrame()
	end

	pg.game.effect:getTeamLinkController():updateFollowInfo(self, true)
end

function ClientPlayer:onEnterSpace()
	ClientPlayer.super.onEnterSpace(self)
	self:refreshSceneFootStepVolumeRTPC()
	self:refreshGhostFollow()
end

function ClientPlayer:destroy()
	EntityManager.removeUidEntity(self.uid)
	ClientPlayer.super.destroy(self)

	if not self.isMainPlayer then
		facade:SendMessageCommand(MessageName.ON_OTHER_PLAYER_LEAVE_SCENE, {
			ent = self
		})
	end
end

function ClientPlayer:preDestroy()
	if self.eModel then
		local modelView = self.eModel.modelModelView

		if modelView ~= nil then
			modelView.modelInfo:ClearCustomInfo()
			modelView.modelInfo:ClearPartInfo()
			modelView.modelInfo:ClearAttachInfo()
		end
	end

	if not self.isMainPlayer then
		pg.game.effect:getTeamLinkController():updateFollowInfo(self, nil, true)

		if self.uid == pg.me.followLeaderUid then
			pg.game.effect:getTeamLinkController():setFollowLinkEffectVisible(pg.me, false)
		end
	end

	ClientPlayer.super.preDestroy(self)
end

function ClientPlayer:onModelRefreshed()
	ClientPlayer.super.onModelRefreshed(self)

	if self.carryObjId then
		local carryEnt = pg.getEntity(self.carryObjId)

		if carryEnt and self.carryEnt ~= carryEnt then
			self:carryEntImp(carryEnt)
		end
	end
end

function ClientPlayer:repr()
	return string.format("ClientPlayer(entityId=%s, uid=%d)", self.id, self.uid or 0)
end

function ClientPlayer:onDeformed()
	ClientPlayer.super.onDeformed(self)
	self:calcAndRefreshModelScale(true)
end

function ClientPlayer:setModelLayer()
	if self.eModel then
		self.eModel:SetModelLayer(ClientConst.LayerDefine.LAYER_PLAYER)
	end
end

function ClientPlayer:onEModelCreate(eModel)
	ClientPlayer.super.onEModelCreate(self, eModel)

	if self.eModel and not self.isMainPlayer then
		self.eModel:SetClientReady(false)
	end

	facade:SendMessageCommand(MessageName.SYNC_TEAM_INFO)
	ClientUtils.tryWithLogError(function()
		if pg.me and pg.me.eModel then
			local followInfo = {
				pg.me.teamInfo and pg.me.teamInfo.followInfo
			} and pg.me.teamInfo.followInfo or {}

			pg.game.chat:onSpaceFollowUpdate(followInfo)
		end
	end)
end

function ClientPlayer:initializeComponents()
	ClientPlayer.super.initializeComponents(self)

	if self.eModel then
		self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	end
end

function ClientPlayer:postInitializeComponents()
	ClientPlayer.super.postInitializeComponents(self)

	if self.isMainPlayer then
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 1)
	else
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 0)
	end

	self:refreshSceneFootStepVolumeRTPC()
end

function ClientPlayer:refreshSceneFootStepVolumeRTPC()
	local sceneInfo = self.space and SceneData[self.space.sceneId]
	local footStepVolume = sceneInfo and sceneInfo.footStepVolume

	self:setSoundRTPCValue(AudioConst.RTPC_FOOTSTEP_QIANGDAN, footStepVolume and footStepVolume[1] or 0)
end

function ClientPlayer:refreshAppearanceByDefault()
	self.appearanceEffectInfo = {}

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local defaultPresetKey = configData.presetKey
	local extraData = ClientModelUtils.getModelExtraInfo(configData, self.label or 0, self.gender)

	self:attachBaseEffects(extraData.attachEffects)

	extraData.partItems = {}

	if defaultPresetKey then
		local modelRes = AvatarUtils.getModelResData(self, defaultPresetKey)

		for partId, info in pairs(modelRes) do
			if partId ~= GameConst.PART_FACE_HIGH_LIGHT then
				extraData.partItems[partId] = {
					resId = info.resId
				}

				AppearanceEffectUtils.setAppearance(self, partId, info.configId, info.resId)
			end
		end

		local suitId = pg.game.avatar:getAvatarPresetData(defaultPresetKey).defaultSuit
		local clothesIdList = AppearanceSuitData[suitId].appearanceList or {}

		for _, id in ipairs(clothesIdList) do
			local clothesData = AppearanceData[id]

			if clothesData then
				local partId = clothesData.points[1]

				extraData.partItems[partId] = {
					resId = clothesData.res
				}

				AppearanceEffectUtils.setAppearance(self, partId, id)
			end
		end
	end

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
end

function ClientPlayer:refreshAppearanceToPuppet(configData, forceRefreshPlayable)
	self.appearanceEffectInfo = {}

	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, 0, configData.gender or 0, true)

	ClientPlayer.super.onRefreshAppearance(self, configData, extraInfo, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView
	local result, realPrefabResID = AvatarUtils.refreshNPCModelData(configData)

	if result then
		extraInfo.prefabResID = realPrefabResID

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)
		ClientModelUtils.refreshModels(self, modelView)

		return
	end

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

	if configData.appearanceResID then
		local npcAvatarData = NpcAvatarData[configData.appearanceResID] or {}
		local presetKey = npcAvatarData.avatarId

		if presetKey then
			modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
			modelView.modelInfo:ParseToModelInfo()
		end
	end

	ClientModelUtils.refreshModels(self, modelView)
end

function ClientPlayer:refreshModel(configData, extraData)
	self.appearanceEffectInfo = {}

	if self:isDeformToPuppet() then
		self:refreshAppearanceToPuppet(self.deformData)

		return
	end

	if self:isDeformToPet() then
		ClientPlayer.super.refreshModel(self, configData, extraData)

		return
	end

	local modelView = self.eModel.modelModelView
	local presetKey = pg.game.avatar:getPresetKey(self)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}

	if presetData.templateId and presetData.templateId == self.templateId then
		if self.avatarConfig ~= "" then
			modelView.modelInfo:ParseCustomData(decompressFromStr(self.avatarConfig))
		end

		if presetKey ~= 0 then
			ClientModelUtils.initModelInfoByCustomData(self, presetKey, configData, extraData)
		else
			logger:error("@sxy invalid avatar presetKey == 0")
			self:refreshAppearanceByDefault()
		end
	else
		logger:info("@sxy templateId is changed:", presetData.templateId, self.templateId)
		self:refreshAppearanceByDefault()
	end

	if self.applyVehicleSeatAppearanceToModel then
		self:applyVehicleSeatAppearanceToModel(modelView.modelInfo)
	end

	ClientModelUtils.refreshModels(self, modelView)

	local bodySize = modelView.modelInfo:GetBodySize()

	self:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

function ClientPlayer:getCameraHeightInfo()
	return ClientPlayer.super.getCameraHeightInfo(self)
end

function ClientPlayer:getLockPosition()
	if self:isControllingEgg() then
		local eggEnt = self:getCurControllingEgg()

		if eggEnt and eggEnt.getLockPosition then
			return eggEnt:getLockPosition()
		end
	end

	return ClientPlayer.super.getLockPosition(self)
end

function ClientPlayer:onEnterScene()
	ClientPlayer.super.onEnterScene(self)

	if not self.isMainPlayer then
		facade:SendMessageCommand(MessageName.ON_OTHER_PLAYER_ENTER_SCENE, {
			ent = self
		})
	end

	AvatarUtils.refreshMakeUpInPeriod(self)
end

function ClientPlayer:getTemplateData()
	return AvatarData[self.templateId] or {}
end

function ClientPlayer:refreshVisible()
	ClientPlayer.super.refreshVisible(self)
	self:refreshSwitchPetVisible()
	self:refreshUISceneVisible()
end

function ClientPlayer:refreshSwitchPetVisible()
	local active = true

	if self:isControllingPet() then
		active = self.switchEndTime and Time.realSecondCache <= self.switchEndTime and true or false
	end

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.SWITCHING, active)
end

function ClientPlayer:refreshUISceneVisible()
	local active = true

	if pg.game.uiScene and pg.game.uiScene:checkNeedPawnHide() then
		active = false
	end

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, active)
end

function ClientPlayer:queryModelVisible()
	if self ~= pg.me and Bitset.any(ClientConst.PLAYER_VISIBLE_FLAG) then
		return true, false
	end

	return ClientPlayer.super.queryModelVisible(self)
end

function ClientPlayer:canBeLocked()
	if self:isControllingPet() then
		return false
	end

	return true
end

function ClientPlayer:RPC_SC_PuppetSpeciesInfo(actorId, speciesInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[RPC_SC_PuppetSpeciesInfo]")
	end

	if IsNil(self.puppetSpeciesCb) then
		return
	end

	self.puppetSpeciesCb(actorId, speciesInfo)
end

function ClientPlayer:canBeLookAt()
	return not self:isControllingPet() and self:getConfigData().canBeLookAt
end

function ClientPlayer:refreshGhostFollow()
	if EnableBotTest then
		return
	end

	if self.isGhostFollow then
		self:ghostFollow()
	elseif self.ghostRemove then
		self:ghostRemove()
	end
end

function ClientPlayer:on_isGhostFollow_changed(oldVal, newVal)
	self:refreshGhostFollow()
	self.logger:debug("on_isGhostFollow_changed oldVal:%s, newVal:%s", tostring(oldVal), tostring(newVal))
end

function ClientPlayer:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.PLAYER
end

function ClientPlayer:needLimitCount()
	return not self.isMainPlayer
end

function ClientPlayer:RPC_SC_NotifyFromTeleportPos()
	if self.isMainPlayer and self.forceDetachVehicleOnTeleport then
		self:forceDetachVehicleOnTeleport()
	end
end

function ClientPlayer:RPC_SC_PortalClaimPlayers(portalTeleportId)
	local ent = pg.me.space:getEntityByStaticId(portalTeleportId)

	if ent then
		local skeletonView = ent.eModel.skeletonView

		if skeletonView and skeletonView.skeletonRoot then
			local teleportPoint = skeletonView.skeletonRoot:GetComponent("ArkTeleportPoint")

			if teleportPoint then
				teleportPoint:PlayArriveVX()
			end
		end
	end
end

function ClientPlayer:RPC_SC_PortalPreparePlayers(entityId)
	local ent = pg.getEntity(entityId)

	if ent then
		local skeletonView = ent.eModel.skeletonView

		if skeletonView and skeletonView.skeletonRoot then
			local teleportPoint = skeletonView.skeletonRoot:GetComponent("ArkTeleportPoint")

			if teleportPoint then
				teleportPoint:PlayTeleportVX()
			end
		end
	end
end

function ClientPlayer:getTopLogoFollowStrategy()
	return ClientConst.TopLogoFollowStrategy.FxRoot
end

function ClientPlayer:on_curHp_changed(oldv, newv)
	if self.isMainPlayer then
		facade:SendMessageCommand(MessageName.MAIN_PLAYER_HP_CHANGE, {
			oldv = oldv,
			newv = newv
		})
	end

	facade:SendMessageCommand(MessageName.HEALTH_POINT_CHANGE, self)
	self.eventEmitter:emit(EventConst.TOPLOGO_HEALTH_POINT, oldv, newv)
end

function ClientPlayer:onGameVoteOpenCallback(old, new)
	if new == 1 then
		pg.global.ui:open(UIConst.UI_ID_VOTING_FEATURE)
	else
		pg.global.ui:close(UIConst.UI_ID_VOTING_FEATURE)
	end
end

function ClientPlayer:onFollowLeaderUid(old, new)
	if not string.isNilOrEmpty(old) and string.isNilOrEmpty(new) and self.detachToNormal then
		self:detachToNormal()

		if self.clearAwayState then
			self:clearAwayState(true)
		end
	end

	self:buildTeamFollowInfo(old, new)
	pg.game.effect:getTeamLinkController():updateFollowInfo(self)
end

function ClientPlayer:buildTeamFollowInfo(old, new)
	if not self.space then
		return
	end

	if not string.isNilOrEmpty(new) then
		if not self.space.followInfo[new] then
			self.space.followInfo[new] = {}
		end

		if not lume.findInList(self.space.followInfo[new], self.uid) then
			self.space.followInfo[new][#self.space.followInfo[new] + 1] = self.uid
		end
	elseif self.space.followInfo and self.space.followInfo[old] then
		for idx, uid in ipairs(self.space.followInfo[old]) do
			if self.uid == uid then
				table.remove(self.space.followInfo[old], idx)

				break
			end
		end

		if #self.space.followInfo[old] == 0 then
			self.space.followInfo[old] = nil
		end
	end
end

return ClientPlayer
