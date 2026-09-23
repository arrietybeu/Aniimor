-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientMainPlayer.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientPlayer = require("Entities.SpaceEntities.ClientPlayer")
local ClientCache = require("Entities.SpaceEntities.ClientCache")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local GlobalData = require("Core.Client.GlobalData")
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local AudioConst = require("Const.AudioConst")
local HotkeyConst = require("Const.HotkeyConst")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local phonestcore = require("phonestcore")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Utils = require("Common.Utils.Utils")
local getProtoCodec = Utils.protoCodec
local CommonSwitch = require("Common.CommonSwitch")
local ClientSwitch = require("Common.ClientSwitch")
local SkillHitDisplacementControl = require("GameApp.Controller.Utils.SkillHitDisplacementControl")
local GmToolUtils = require("Utils.GmToolUtils")
local PlayerLevelData = require("Data.player_level_data")
local EntityManager = require("Core.Common.EntityManager")
local TriggerConst = require("Common.Const.TriggerConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local AppearancePointEnum = require("Data.appearance_point_enum")
local SysConfigData = require("Data.sys_config_data")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local BLOCKED_HOMELAND_ENTRY_WAIT_INTERVAL = 0.5
local BLOCKED_HOMELAND_ENTRY_WAIT_MAX_COUNT = 10
local PET_EXPLORE_WATER_RUNTIME_KEY = "__exploreCurWater"
local PetBasePrototypeData = require("Data.pet_base_prototype_data")

local function clientCacheVerifyLog(category, event, detail)
	return
end

local ClientMainPlayer = class.Class("ClientMainPlayer", ClientPlayer)
local ClientAvatarMsCommon = require("Core.Client.Components.ClientAvatarMsCommon")
local ClientDispatcherComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDispatcherComponent")
local ClientPetBallComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetBallComponent")
local ClientGuidanceComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGuidanceComponent")
local ClientFunctionUnlockComponent = require("Entities.SpaceEntities.PlayerComponent.ClientFunctionUnlockComponent")
local ClientStaminaComponent = require("Entities.SpaceEntities.CommonComponent.ClientStaminaComponent")
local ClientPlayerInteractNpcComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerInteractNpcComponent")
local ClientChatComponent = require("Entities.SpaceEntities.PlayerComponent.ClientChatComponent")
local ClientMailComponent = require("Entities.SpaceEntities.PlayerComponent.ClientMailComponent")
local ClientFriendComponent = require("Entities.SpaceEntities.PlayerComponent.ClientFriendComponent")
local ClientCaptureMainComponent = require("Entities.SpaceEntities.PlayerComponent.ClientCaptureMainComponent")
local ClientQuestComponent = require("Entities.SpaceEntities.PlayerComponent.ClientQuestComponent")
local ClientPlayerTargetComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerTargetComponent")
local ClientDialogueComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDialogueComponent")
local ClientShopComponent = require("Entities.SpaceEntities.PlayerComponent.ClientShopComponent")
local ClientSpaceSpawnerEntityComponent = require("Entities.SpaceEntities.PlayerComponent.ClientSpaceSpawnerEntityComponent")
local ClientGhostEyeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeComponent")
local ClientAIHelperComponent = require("Entities.SpaceEntities.PlayerComponent.ClientAIHelperComponent")
local ClientActiveComponent = require("Entities.SpaceEntities.PlayerComponent.ClientActiveComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientInventoryComponent = require("Entities.SpaceEntities.PlayerComponent.ClientInventoryComponent")
local ClientKnowledgeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientKnowledgeComponent")
local ClientPetsFormationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsFormationComponent")
local ClientPetsExchangeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsExchangeComponent")
local ClientPetsVariantInteractComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsVariantInteractComponent")
local ClientSocialComponent = require("Entities.SpaceEntities.PlayerComponent.ClientSocialComponent")
local ClientEventComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEventComponent")
local ClientTriggerComponent = require("Entities.SpaceEntities.PlayerComponent.ClientTriggerComponent")
local ClientChestComponent = require("Entities.SpaceEntities.PlayerComponent.ClientChestComponent")
local ClientPetsEducationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsEducationComponent")
local ClientPetHandbookComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetHandbookComponent")
local ClientEducationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEducationComponent")
local ClientPhotoComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhotoComponent")
local ClientMatchComponent = require("Entities.SpaceEntities.PlayerComponent.ClientMatchComponent")
local ClientRoomComponent = require("Entities.SpaceEntities.PlayerComponent.ClientRoomComponent")
local ClientChainAttackComponent = require("Entities.SpaceEntities.PlayerComponent.ClientChainAttackComponent")
local ClientPersonalDisplayComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPersonalDisplayComponent")
local ClientMagnesisComponent = require("Entities.SpaceEntities.PlayerComponent.ClientMagnesisComponent")
local ClientPlayerVehicleComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerVehicleComponent")
local ClientPlayerRogueComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerRogueComponent")
local ClientPlayerBossRushComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerBossRushComponent")
local ClientPlayerNpcDuelComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerNpcDuelComponent")
local ClientPlayerCatchRogueComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerCatchRogueComponent")
local ClientPlayerFishingCaptureComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerFishingCaptureComponent")
local ClientMediaMarkerComponent = require("Entities.SpaceEntities.PlayerComponent.ClientMediaMarkerComponent")
local ClientScentTrackingComponent = require("Entities.SpaceEntities.PlayerComponent.ClientScentTrackingComponent")
local ClientLeylineTreeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientLeylineTreeComponent")
local ClientLeylineFlowerComponent = require("Entities.SpaceEntities.PlayerComponent.ClientLeylineFlowerComponent")
local ClientTotemComponent = require("Entities.SpaceEntities.PlayerComponent.ClientTotemComponent")
local ClientScreenComponent = require("Entities.SpaceEntities.PlayerComponent.ClientScreenComponent")
local ClientPlayerSlotMachineComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerSlotMachineComponent")
local ClientPlayerCommonExchangeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerCommonExchangeComponent")
local ClientSpecialTrainComponent = require("Entities.SpaceEntities.PlayerComponent.ClientSpecialTrainComponent")
local ClientGlobalSurveyComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGlobalSurveyComponent")
local ClientSpaceSeamlessComponent = require("Entities.SpaceEntities.PlayerComponent.ClientSpaceSeamlessComponent")
local ClientTeamComponent = require("Entities.SpaceEntities.PlayerComponent.ClientTeamComponent")
local ClientPlayerHomeCampComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeCampComponent")
local ClientPlayerHomelandComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomelandComponent")
local ClientWeatherComponent = require("Entities.SpaceEntities.PlayerComponent.ClientWeatherComponent")
local ClientHornComponent = require("Entities.SpaceEntities.PlayerComponent.ClientHornComponent")
local ClientFluteComponent = require("Entities.SpaceEntities.PlayerComponent.ClientFluteComponent")
local ClientPlayerActivityComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerActivityComponent")
local ClientPlayerActivityPlatformComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerActivityPlatformComponent")
local ClientPlayerQuizComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerQuizComponent")
local ClientPlayerRobEggComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerRobEggComponent")
local ClientGrabEggComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGrabEggComponent")
local ClientDangerBgmComponent = require("Entities.SpaceEntities.CommonComponent.ClientDangerBgmComponent")
local ClientListenerComponent = require("Entities.SpaceEntities.CommonComponent.ClientListenerComponent")
local ClientPlayerPipelineComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerPipelineComponent")
local ClientPhotoStudioComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPhotoStudioComponent")
local ClientPhotographyStudioComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPhotographyStudioComponent")
local ClientPlayerBadgeCollectionComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerBadgeCollectionComponent")
local ClientPlayerHomeOrderComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeOrderComponent")
local ClientPlayerHomeHandbookComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeHandbookComponent")
local ClientPlayerHomeSeasonComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeSeasonComponent")
local ClientMapTagComponent = require("Entities.SpaceEntities.CommonComponent.ClientMapTagComponent")
local ClientPlayerHomeSeasonMutationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeSeasonMutationComponent")
local ClientPlayerObComponent = require("Entities.SpaceEntities.CommonComponent.ClientPlayerObComponent")
local ClientPayComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPayComponent")
local ClientMonthCardComponent = require("Entities.SpaceEntities.PlayerComponent.ClientMonthCardComponent")
local ClientRankComponent = require("Entities.SpaceEntities.PlayerComponent.ClientRankComponent")
local ClientPlayerBadgeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerBadgeComponent")
local ClientPetTransmogComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetTransmogComponent")
local ClientPlayerRiftComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerRiftComponent")
local ClientPlayerMmoItemComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerMmoItemComponent")
local ClientPlayerTradeComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerTradeComponent")
local ClientAbilityDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientAbilityDebugComponent")
local PlayerComponents = {
	ClientAvatarMsCommon,
	ClientDispatcherComponent,
	ClientInventoryComponent,
	ClientKnowledgeComponent,
	ClientPetsFormationComponent,
	ClientPetsExchangeComponent,
	ClientPetsVariantInteractComponent,
	ClientSocialComponent,
	ClientEventComponent,
	ClientTriggerComponent,
	ClientChestComponent,
	ClientPetsEducationComponent,
	ClientPetHandbookComponent,
	ClientEducationComponent,
	ClientPhotoComponent,
	ClientStaminaComponent,
	ClientPlayerInteractNpcComponent,
	ClientPetBallComponent,
	ClientGuidanceComponent,
	ClientFunctionUnlockComponent,
	ClientGhostEyeComponent,
	ClientAIHelperComponent,
	ClientActiveComponent,
	ClientChatComponent,
	ClientMailComponent,
	ClientFriendComponent,
	ClientCaptureMainComponent,
	ClientQuestComponent,
	ClientPlayerTargetComponent,
	ClientDialogueComponent,
	ClientShopComponent,
	ClientWeatherComponent,
	ClientSpaceSpawnerEntityComponent,
	ClientMatchComponent,
	ClientRoomComponent,
	ClientMotionComponent,
	ClientChainAttackComponent,
	ClientPersonalDisplayComponent,
	ClientMagnesisComponent,
	ClientPlayerVehicleComponent,
	ClientPlayerRogueComponent,
	ClientPlayerBossRushComponent,
	ClientPlayerNpcDuelComponent,
	ClientPlayerCatchRogueComponent,
	ClientPlayerFishingCaptureComponent,
	ClientMediaMarkerComponent,
	ClientScentTrackingComponent,
	ClientLeylineTreeComponent,
	ClientLeylineFlowerComponent,
	ClientTotemComponent,
	ClientScreenComponent,
	ClientPlayerSlotMachineComponent,
	ClientPlayerCommonExchangeComponent,
	ClientSpecialTrainComponent,
	ClientGlobalSurveyComponent,
	ClientSpaceSeamlessComponent,
	ClientTeamComponent,
	ClientPlayerHomeCampComponent,
	ClientPlayerHomelandComponent,
	ClientHornComponent,
	ClientPlayerActivityComponent,
	ClientPlayerActivityPlatformComponent,
	ClientPlayerQuizComponent,
	ClientPlayerRobEggComponent,
	ClientGrabEggComponent,
	ClientDangerBgmComponent,
	ClientListenerComponent,
	ClientFluteComponent,
	ClientPlayerPipelineComponent,
	ClientPhotoStudioComponent,
	ClientPhotographyStudioComponent,
	ClientPlayerBadgeCollectionComponent,
	ClientPlayerHomeOrderComponent,
	ClientPlayerHomeHandbookComponent,
	ClientPlayerHomeSeasonComponent,
	ClientMapTagComponent,
	ClientPlayerHomeSeasonMutationComponent,
	ClientPlayerObComponent,
	ClientPayComponent,
	ClientMonthCardComponent,
	ClientRankComponent,
	ClientPlayerBadgeComponent,
	ClientPetTransmogComponent,
	ClientPlayerRiftComponent,
	ClientPlayerMmoItemComponent,
	ClientPlayerTradeComponent,
	ClientAbilityDebugComponent
}

class.AddComponents(ClientMainPlayer, PlayerComponents)

function ClientMainPlayer:ctor(entityId)
	ClientMainPlayer.super.ctor(self, entityId)

	pg.me = self
	pg.pawn = self
	self.isMainPlayer = true
	self.photoEntInRange = {}
	self.petCurWaterRuntimeCache = {}
	self.statData = {}

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMainPlayer ctor")
	end

	self.skillHitDisplacementCtrl = SkillHitDisplacementControl(self)
	self.scrollingtext = {}
	self.INTERP_DELAY = 5

	pg.global.ui.commonConfirm:close()

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.stopPullServerList()

	self.smokeEntityCnt = 0
	self.pveHeartbeatCount = 0
end

function ClientMainPlayer:init(bdict)
	local ret = ClientMainPlayer.super.init(self, bdict)

	ClientCache.attach(self)

	GlobalData.Player = self
	GlobalData.ZoneTime = self.zoneTime

	self:clearMethodOrIndex()
	self:resetCommonSwitch(bdict.commonSwitch or {})

	Time.ServerOpenTime = bdict.ServerOpenTime
	self.customCheckStates = bdict.customCheckStates or {}
	self.scrollingtext = bdict.scrollingtext or {}

	pg.game.marquee:updateMarqueeInfo(self.scrollingtext)

	return ret
end

function ClientMainPlayer:postInit(bdict)
	ClientMainPlayer.super.postInit(self, bdict)
end

function ClientMainPlayer:onSyncPos(x, y, z, playerDistance)
	ClientMainPlayer.super.onSyncPos(self, x, y, z, playerDistance)

	pg.playerPos = self.posRef
end

function ClientMainPlayer:onSyncRot(x, y, z, w)
	ClientMainPlayer.super.onSyncRot(self, x, y, z, w)

	pg.playerRot = self.rotRef
end

function ClientMainPlayer:isFromCopy()
	return not string.isNilOrEmpty(self.copySrc) or not string.isNilOrEmpty(self.copySrcUid)
end

function ClientMainPlayer:getCopyPlayerUid()
	if self.copyType == 0 or self.copyType == Const.COPY_PLAYER_PYTHON then
		return self.uid
	end

	return string.format("%s|%s,%s", self.uid, self.copySrc, self.copySrcUid)
end

function ClientMainPlayer:onPlayerFirstInit()
	local disableFirstInit = GmToolUtils.checkDisablePlayerFirstInit()

	if disableFirstInit then
		return
	end

	if not self.clientPlayerCreateInited then
		local AvatarUtils = require("Guis.Utils.AvatarUtils")

		if Utils.isEmptyTable(pg.game.avatar.hairSelection) then
			local autoSaveData = AvatarUtils.loadCustomDataFromDisk()

			if autoSaveData and autoSaveData.hairSelection and autoSaveData.hairCustomData then
				pg.game.avatar.hairSelection = Utils.deepCopyTable(autoSaveData.hairSelection)
				pg.game.avatar.hairCustomData = Utils.deepCopyTable(autoSaveData.hairCustomData)
			end
		end

		local actions = {}

		for partId, configId in pairs(pg.game.avatar.hairSelection) do
			table.insert(actions, {
				configId,
				true,
				partId
			})
		end

		self:serverMsg("RPC_CS_MultiSetAppearanceShow", actions)

		if pg.game.avatar.createPlayerSceneBgId then
			AvatarUtils.setBgRes(Const.APPEARANCE_BACKGROUND_TYPE.Player, pg.game.avatar.createPlayerSceneBgId)
		end

		if pg.game.avatar.hairCustomData then
			local hairCustomData = {}

			for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
				local configId = pg.game.avatar.hairSelection[partId]

				if configId then
					hairCustomData[partId] = {
						configId = configId,
						hairInfo = pg.game.avatar.hairCustomData[partId]
					}
				end
			end

			local hairSuitId = LuaUIUtils.tryGetHairSuitId(pg.game.avatar.hairSelection)

			self:serverMsg("RPC_CS_SaveHairCustom", hairSuitId, 1, hairCustomData, pg.getGameString("DESIGN_DEFAULT"), pg.game.avatar:getHairSnapshotKey())
			self:serverMsg("RPC_CS_SetHairCustom", hairSuitId, 1)

			pg.game.avatar.hairCustomData = nil
		end

		self:serverMsg("RPC_CS_ClientPlayerCreateInitSuccess")
		pg.global.sdkManager:createRole(self.uid, self.playerName, self.level, 0, GlobalData.ServerId, "unknown", 0)
		pg.global.sdkManager:reportAdFunnel("ad_create_role")
	end
end

function ClientMainPlayer:RPC_SC_OnPlayerException()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnPlayerException...")
	end

	ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.PlayerException)
end

function ClientMainPlayer:notifyPhotoDistance(ent, dist)
	self.photoEntInRange[ent.id] = dist
end

function ClientMainPlayer:removePhotoDistance(entId)
	self.photoEntInRange[entId] = nil
end

function ClientMainPlayer:setFogMaskRadius(fogMaskRadius)
	self.fogMaskRadius = fogMaskRadius

	self.eventEmitter:emit(EventConst.ON_FOR_RADIUS_CHANGE, fogMaskRadius)
end

function ClientMainPlayer:RPC_SC_OnTeleportSpaceIn(spaceClass, spaceDict, fromReconnect, gameTime, isFullSync)
	self:onTeleportSpaceIn(spaceClass, spaceDict, fromReconnect, gameTime, isFullSync)
end

function ClientMainPlayer:createTeleportSpaceEntity(spaceClass, spaceDict, fromReconnect, gameTime)
	local space = ClientUtils.createClientEntity(spaceClass, spaceDict.id, spaceDict)

	space.gameTime = gameTime

	self:enterSpace(space)

	if fromReconnect then
		pg.game.markShare:refreshAroundInfoStamp()
	end
end

function ClientMainPlayer:queryHomelandOwnerInfoBeforeCreate(ownerUid)
	if self.blockedHomelandOwnerInfoRequestedUid == ownerUid then
		return
	end

	if pg == nil or pg.game == nil or pg.game.chat == nil then
		return
	end

	if type(self.queryPlayerInfoList) ~= "function" then
		return
	end

	self.blockedHomelandOwnerInfoRequestedUid = ownerUid

	self:queryPlayerInfoList({
		ownerUid
	}, pg.game.chat.queryPlayerInfoType and pg.game.chat.queryPlayerInfoType.ShowPlayerInfo or nil, true, nil, nil)
end

function ClientMainPlayer:evaluateHomelandEntryBeforeCreate(spaceDict)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.PlayStation then
		return true, nil
	end

	local _, ownerUid = HomeLandUtils.parseHomelandKey(spaceDict.id)

	if ownerUid == nil or tostring(ownerUid) == "" then
		return true, ownerUid
	end

	if tostring(ownerUid) == tostring(self.uid or "") then
		return true, ownerUid
	end

	local chat = pg and pg.game and pg.game.chat or nil
	local playerInfo = chat and chat.getPlayerInfo and chat:getPlayerInfo(ownerUid) or nil
	local allowed, _, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(ownerUid, playerInfo)
	local blockPending = context and context.blockReason == PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING
	local platformUserId = playerInfo and playerInfo.platformUserId or ""
	local shouldWait = allowed and (playerInfo == nil or context and context.reason == PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_POLICY_MISSING or context and context.blockReason == PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE and tostring(platformUserId or "") == "")

	if shouldWait then
		self:queryHomelandOwnerInfoBeforeCreate(ownerUid)

		return nil, ownerUid
	end

	if allowed and not blockPending then
		return true, ownerUid
	end

	return false, ownerUid
end

function ClientMainPlayer:returnToHomelandOwnerHomeCampBeforeCreate(ownerUid)
	if ownerUid == nil or tostring(ownerUid) == "" then
		return false
	end

	self:queryHomeBasicInfo(ownerUid, function(_, _, _, homeCampKey)
		if self.destroyed then
			return
		end

		if homeCampKey == nil or tostring(homeCampKey) == "" then
			return
		end

		self:serverMsg("RPC_CS_ReqEnterHomeCamp", homeCampKey, tostring(ownerUid or ""))
	end)

	return true
end

function ClientMainPlayer:clearBlockedHomelandEntryTimer()
	if self.blockedHomelandEntryWaitTimer then
		TimerManager.removeTimer(self.blockedHomelandEntryWaitTimer)

		self.blockedHomelandEntryWaitTimer = nil
	end
end

function ClientMainPlayer:continueTeleportSpaceInAfterHomelandEntryCheck()
	local pending = self.blockedHomelandEntryPendingTeleport

	if pending == nil then
		return
	end

	self:clearBlockedHomelandEntryTimer()

	self.blockedHomelandEntryPendingTeleport = nil
	self.blockedHomelandEntryWaitCount = nil

	self:createTeleportSpaceEntity(pending.spaceClass, pending.spaceDict, pending.fromReconnect, pending.gameTime)
	self:postComponentMethod("replayBlockedHomelandEntryDelayedClientEntities")
end

function ClientMainPlayer:scheduleHomelandEntryBeforeCreateRetry()
	if self.blockedHomelandEntryWaitTimer then
		return
	end

	self.blockedHomelandEntryWaitTimer = TimerManager.addTimer(BLOCKED_HOMELAND_ENTRY_WAIT_INTERVAL, function()
		self.blockedHomelandEntryWaitTimer = nil

		local pending = self.blockedHomelandEntryPendingTeleport

		if self.destroyed or pending == nil then
			return
		end

		self.blockedHomelandEntryWaitCount = (self.blockedHomelandEntryWaitCount or 0) + 1

		local canEnter, ownerUid = self:evaluateHomelandEntryBeforeCreate(pending.spaceDict)

		if canEnter == true then
			self:continueTeleportSpaceInAfterHomelandEntryCheck()

			return
		end

		if canEnter == false then
			self:clearBlockedHomelandEntryTimer()

			self.blockedHomelandEntryPendingTeleport = nil
			self.blockedHomelandEntryWaitCount = nil

			self:postComponentMethod("discardBlockedHomelandEntryDelayedClientEntities")
			self:returnToHomelandOwnerHomeCampBeforeCreate(ownerUid)

			return
		end

		if self.blockedHomelandEntryWaitCount >= BLOCKED_HOMELAND_ENTRY_WAIT_MAX_COUNT then
			self:continueTeleportSpaceInAfterHomelandEntryCheck()

			return
		end

		self:scheduleHomelandEntryBeforeCreateRetry()
	end)
end

function ClientMainPlayer:waitHomelandEntryBeforeCreate(spaceClass, spaceDict, fromReconnect, gameTime)
	self.blockedHomelandEntryPendingTeleport = {
		spaceClass = spaceClass,
		spaceDict = spaceDict,
		fromReconnect = fromReconnect,
		gameTime = gameTime
	}
	self.blockedHomelandEntryWaitCount = self.blockedHomelandEntryWaitCount or 0

	self:scheduleHomelandEntryBeforeCreateRetry()
end

function ClientMainPlayer:tryHandleHomelandEntryBeforeCreate(spaceClass, spaceDict, fromReconnect, gameTime)
	if spaceClass ~= "ClientHomeland" or spaceDict == nil then
		return false
	end

	local canEnter, ownerUid = self:evaluateHomelandEntryBeforeCreate(spaceDict)

	if canEnter == true then
		return false
	end

	if canEnter == false then
		self:postComponentMethod("discardBlockedHomelandEntryDelayedClientEntities")
		self:returnToHomelandOwnerHomeCampBeforeCreate(ownerUid)

		return true
	end

	self:waitHomelandEntryBeforeCreate(spaceClass, spaceDict, fromReconnect, gameTime)

	return true
end

function ClientMainPlayer:onTeleportSpaceIn(spaceClass, spaceDict, fromReconnect, gameTime, isFullSync)
	if isFullSync == nil then
		isFullSync = true
	end

	if self.space and pg.global.scene:isSceneValid() then
		pg.global.scene:hideLoadingPanel()
	end

	if fromReconnect and pg.space and pg.space.id == spaceDict.id then
		if isFullSync then
			if pg.space.destroyMarks then
				pg.space:destroyMarks()
			end

			local entity = EntityManager.getEntity(spaceDict.id)
			local space = ClientUtils.replaceClientEntity(entity, spaceDict.id, spaceDict)

			space.gameTime = gameTime

			self:enterSpace(space)
		end

		pg.game.markShare:refreshAroundInfoStamp()

		return
	end

	local oldSpace = pg.space

	if oldSpace and oldSpace.id ~= spaceDict.id and not oldSpace.destroyed then
		if self.space == oldSpace then
			oldSpace:onLocalPlayerTeleportSpaceOut(self)
			self:leaveSpace()
		end

		ClientUtils.safeDestroy(oldSpace)
	end

	if self:tryHandleHomelandEntryBeforeCreate(spaceClass, spaceDict, fromReconnect, gameTime) then
		return
	end

	self:createTeleportSpaceEntity(spaceClass, spaceDict, fromReconnect, gameTime)
end

function ClientMainPlayer:RPC_SC_OnTeleportSpaceOut(loadingInfo)
	if self.space == nil then
		return
	end

	local space = self.space

	space:onLocalPlayerTeleportSpaceOut(self)
	self:leaveSpace()
	ClientUtils.safeDestroy(space)

	if pg.global.scene:checkNeedSeamlessLoadNewScene(loadingInfo.sceneId, loadingInfo.portalPos) and not pg.global.scene:isSameSceneFile(loadingInfo.sceneId) then
		pg.global.scene:showLoadingPanel(loadingInfo.sceneId)
	end
end

function ClientMainPlayer:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.MAIN_PLAYER
end

function ClientMainPlayer:getEModelResId()
	return AddressDataConst.Ent_MainPlayer
end

function ClientMainPlayer:onBecomePlayer()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		-- block empty
	end

	ClientMainPlayer.super.onBecomePlayer(self)
	self:startHeartbeat()
	pg.game.chat:initPlayerData(true)
	pg.game.setting:initAfterLogin()

	if pg.game.platform then
		pg.game.platform:initAfterLogin()
	end

	PetJewelryOssCache.ensureLoaded()
	self:setInScene(false)
end

function ClientMainPlayer:onLoseServer()
	ClientUtils.tryWithLogError(function()
		ClientCache.flush(self)
	end)

	if self.aoi and self.space then
		self.aoi:onLoseServer()
	end

	local _h = ClientMainPlayer._platformHooks

	if _h and _h.onLoseServer then
		_h.onLoseServer(self)
	end
end

function ClientMainPlayer:onFirstCreated()
	pg.game:onPlayerInit(self)
	pg.global.abilityMgr:loadCutSceneLocalTod()
end

function ClientMainPlayer:start()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		-- block empty
	end

	ClientMainPlayer.super.start(self)
	pg.global.sdkManager:enterGame(self.uid, self.playerName, self.level, 0, pg.me and pg.me.serverArea or GlobalData.ServerId, "unknown", 0)

	if UNITY_IOS then
		pg.global.sdkManager:loginGameCenter()
	end

	if ClientConfigGameChannelName == "vietnam" and pg.global.sdkManager:isClientIPCountry("VN") then
		pg.global.sdkManager:funtapCheckUser()
	end

	self:refreshSyncFpsRange()

	pg.global.abilityMgr.indicatorManger = nil

	facade:SendMessageCommand(MessageName.MAIN_PLAYER_HP_CHANGE)
	self:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
end

function ClientMainPlayer:tick(deltaTime)
	ClientMainPlayer.super.tick(self, deltaTime)
	ClientCache.update()
end

function ClientMainPlayer:destroy()
	self:clearBlockedHomelandEntryTimer()

	self.blockedHomelandEntryPendingTeleport = nil

	self:postComponentMethod("discardBlockedHomelandEntryDelayedClientEntities")

	if not pg.game.seamless:seam_sys_isSwitchSeamless() then
		LuaUIUtils.onPlayerDestroy()
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMainPlayer destroy")
	end

	ClientCache.detach(self)
	ClientMainPlayer.super.destroy(self)

	self.movingEntitiesPosData = nil

	self:onDestroy()
	pg.game.camera.playerCameraMode:lockOnTargetThirdPerson()
end

function ClientMainPlayer:onDestroy()
	pg.game:onPlayerDestroy(self)
end

function ClientMainPlayer:repr()
	return string.format("ClientMainPlayer(entityId=%s, uid=%s)", self.id, self.uid or "")
end

function ClientMainPlayer:initializeComponents()
	ClientMainPlayer.super.initializeComponents(self)

	if self.eModel then
		self:addEModelComponent(Const.COMPONENT_INDEX_MAIN_PLAYER)
		self:addEModelComponent(Const.COMPONENT_MOTION)
		self:addEModelComponent(Const.COMPONENT_MAGNESIS_CONTROLLER)
		self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
		self:addEModelComponent(Const.COMPONENT_FOLLOW_OTHER)
	end
end

function ClientMainPlayer:doGmCmd(cmdName, ...)
	local tParam = {
		...
	}
	local hookByXPart = self:CallGMWithParamCB(cmdName, tParam, function()
		pg.me:_privateDoGmCmd(cmdName, tParam)
	end)

	if hookByXPart == true then
		return
	end

	self:_privateDoGmCmd(cmdName, tParam)
end

function ClientMainPlayer:_privateDoGmCmd(cmdName, tParam)
	self:serverMsg("RPC_CS_DoGmCmd", cmdName, tParam)
end

function ClientMainPlayer:doGmCmd2(cmdName, params, callback)
	local tParam = params
	local hookByXPart = self:CallGMWithParamCB(cmdName, tParam, function()
		pg.me:_privateDoGmCmd2(cmdName, tParam, callback)
	end)

	if hookByXPart == true then
		return
	end

	self:_privateDoGmCmd2(cmdName, params, callback)
end

function ClientMainPlayer:_privateDoGmCmd2(cmdName, params, callback)
	if callback then
		self:serverMsg("RPC_CS_DoGmCmd", cmdName, params, callback)
	else
		self:serverMsg("RPC_CS_DoGmCmd", cmdName, params)
	end
end

function ClientMainPlayer:RPC_SC_DoGmCmdRet(result, info)
	GmToolUtils.recvGmCmdExecRes(result, info)
end

function ClientMainPlayer:getGmCmdList(cb)
	self:serverMsg("RPC_CS_RequestPlayerGmList", cb)
end

function ClientMainPlayer:RPC_SC_ReceivePlayerGmList(gmList)
	GmToolUtils.recvGmList(gmList)
end

function ClientMainPlayer:RPC_SC_GmModifyClientDesignTable(contents)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("gmModifyClientDesignTableData start, content =  %s", contents)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("client hotfix content decompress: %s", contents)
	end

	if #contents ~= 3 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("gmModifyClientDesignTableData failed, content decompress: %s, paramNum ~= 3", contents)
		end

		return
	end

	local isSucc, log, nullTable = Utils.gmModifyDesignData(contents[1], contents[2], contents[3])

	if not nullTable and LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("find Table :" .. contents[1] .. ",  " .. log)
	end
end

function ClientMainPlayer:onBeControlled(oldEnt)
	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	self.eModel:SetEnable(Const.COMPONENT_INDEX_IK, true)

	local oldEModel = oldEnt and oldEnt.eModel

	if oldEModel then
		local collider = oldEModel:GetCollider(Const.COMPONENT_IDX_PHYSX)

		if collider then
			self.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)
		end
	end

	self.eModel.controllerData.canClimb = false
	self.eModel.controllerData.canSwimDash = false

	ClientMainPlayer.super.onBeControlled(self, oldEnt)

	local curPosition = self:getPosition():Clone()

	curPosition.x = curPosition.x + 0.011

	self:forceSetPos(curPosition)
end

function ClientMainPlayer:OthersPlayerSelectPet(extrg)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("RPC_SC_OthersPlayerSelectPet for %s, player =  %s", self:repr(), unpack(extrg))
	end
end

function ClientMainPlayer:refreshClimbAcrossConfig()
	local height = self.eModel.height
	local stepUpHeightMin = SysConfigData.stepUpHeightRatioRange[1] * height - 0.01
	local climbAcrossLLHeightMin = SysConfigData.climbToTopLowHeightRatioRange[1] * height
	local climbAcrossLHeightMin = SysConfigData.climbToTopHighHeightRatioRange[1] * height
	local climbAcrossHHeightMin = SysConfigData.jumpOnWallHeightRatio * height
	local climbAcrossMaxHeight = climbAcrossHHeightMin + SysConfigData.jumpOnWallToTopHighHeightRange[2]

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		-- block empty
	end

	if self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		self.eModel:SetClimbAcrossHeight(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, stepUpHeightMin, climbAcrossLLHeightMin, climbAcrossLHeightMin, climbAcrossHHeightMin, climbAcrossMaxHeight)
		self.eModel:SetClimbAcrossAngle(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, SysConfigData.stepUpAngleLimit, SysConfigData.climbToTopAngleLimit, SysConfigData.jumpOnWallAngleLimit)
	end
end

function ClientMainPlayer:onEnterSpace()
	self.isLeavingSpace = false

	local clientGameFlowUtil = require("Utils.ClientGameFlowUtil")

	clientGameFlowUtil.onMainPlayerEnterSpace(self)

	if self.space.loadPendingInitialSandbox then
		self.space:loadPendingInitialSandbox()
	end

	ClientMainPlayer.super.onEnterSpace(self)
	self:onPlayerFirstInit()

	if self.onEnterSpaceInner then
		self.onEnterSpaceInner(self)
	end

	self:startTick()
	LuaUIUtils.onPlayerCreate()

	local csLayerDefine = CS.FunPlus.WorldX.Const.LayerDefine
	local topLogoManager = CS.FunPlus.WorldX.GUIS.Panels.TopLogo.TopLogoManager.Instance

	if topLogoManager then
		if Utils.isHomeland(self.space and self.space.spaceType) then
			topLogoManager:SetRaycastLayerMask(csLayerDefine.TOPLOGO_HOMELAND_BLOCK_MASK)
		else
			topLogoManager:SetRaycastLayerMask(csLayerDefine.TOPLOGO_DEFAULT_BLOCK_MASK)
		end
	end

	if not self.space:isMultiPlayerEnv() then
		self.fpsRangeHandle = self:addRangeEvent(Const.TRAP_EVENT_ID_SYNC_FPS_RANGE, 20, 20)
	end

	if pg.global.physicsMgr then
		local isBeginnerScene = self.space.sceneId == Const.SCENE_ID.BEGINNER

		pg.global.physicsMgr.enableFloatingConstraints = not isBeginnerScene
	end

	self:tryClientTrigger(TriggerConst.TRIGGER_TARGET_SPACE_TYPE, 0)
	self:checkTopLogoRobEgg()

	self.topLogoPlayerHandle = self:addRangeEvent(Const.TRAP_EVENT_ID_TOPLOGO_PLAYER, UIConst.TopLogoEnterRange, UIConst.TopLogoEnterRange, false, false)
	self.topLogoOtherHandle = self:addRangeEvent(Const.TRAP_EVENT_ID_TOPLOGO_OTHER, UIConst.TopLogoLodNearRange, UIConst.TopLogoLodNearRange, true, false)

	facade:SendMessageCommand(MessageName.ON_PLAYER_ENTER_SPACE)
end

function ClientMainPlayer:onLeaveSpace()
	self.isLeavingSpace = true

	local clientGameFlowUtil = require("Utils.ClientGameFlowUtil")

	clientGameFlowUtil.onMainPlayerLeaveSpace(self)
	ClientMainPlayer.super.onLeaveSpace(self)
	pg.game.controller:unlockTarget()
	self:stopTick()

	if self.fpsRangeHandle ~= nil then
		self:removeRangeEvent(self.fpsRangeHandle, false)

		self.fpsRangeHandle = nil
	end

	if self.topLogoPlayerHandle ~= nil then
		self:removeRangeEvent(self.topLogoPlayerHandle, false)

		self.topLogoPlayerHandle = nil
	end

	if self.topLogoOtherHandle ~= nil then
		self:removeRangeEvent(self.topLogoOtherHandle, false)

		self.topLogoOtherHandle = nil
	end

	facade:SendMessageCommand(MessageName.ON_PLAYER_LEAVE_SPACE)

	local _h = ClientMainPlayer._platformHooks

	if _h and _h.onLeaveSpace then
		_h.onLeaveSpace(self)
	end
end

function ClientMainPlayer:onEnterScene(extraInfo)
	ClientMainPlayer.super.onEnterScene(self)

	local isSwitchSeamless = false

	if extraInfo and extraInfo.isSeamlessScene then
		isSwitchSeamless = true
	end

	if not pg.global.scene:checkDittoSceneLoad() and not pg.game.seamless:seam_sys_isSwitchSeamless() and not isSwitchSeamless then
		pg.game.camera.playerCameraMode:resetCamera()
	end

	self:triggerPlayerTeleportAppear()
	pg.game:onPlayerEnterScene()
	facade:SendMessageCommand(MessageName.ON_PLAYER_ENTER_SCENE)
	self:tryRepairAreaFirstInData()
end

function ClientMainPlayer:onLeaveScene(extraInfo)
	self.pendingTeleportAppear = nil

	ClientMainPlayer.super.onLeaveScene(self)
	pg.game:onPlayerLeaveScene()
	facade:SendMessageCommand(MessageName.ON_PLAYER_LEAVE_SCENE)
end

function ClientMainPlayer:beAttached()
	ClientMainPlayer.super.beAttached(self)
	AnimationUtils.playAnimationState(self, CharacterStateConst.BEATTACHED)

	local attachToEntity = pg.getEntity(self.attachTargetEntId)

	if attachToEntity then
		pg.game.camera:setTargetPlayer(attachToEntity, 0)
	end
end

function ClientMainPlayer:beDetached()
	ClientMainPlayer.super.beDetached(self)

	if self:FALLEN_ST() then
		AnimationUtils.playAnimationState(self, CharacterStateConst.FALLEN)
	end

	if self:isControllingMaster() then
		pg.game.camera:setTargetPlayer(self, 0)
	end
end

function ClientMainPlayer:RPC_SC_Portal_Success()
	local reloadScene = appFacade.streamManager:CheckNeedLoad(pg.playerPos)

	if not reloadScene then
		self:triggerPlayerTeleportAppear()
	end
end

function ClientMainPlayer:triggerPlayerTeleportAppear()
	if not pg.me or not pg.me.isInScene then
		self.pendingTeleportAppear = nil

		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)

		return
	end

	if pg.global.ui.loadProgress:checkUIShow() then
		self.pendingTeleportAppear = true

		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)

		return
	end

	self.pendingTeleportAppear = nil

	if not pg.global.firstEnterGame then
		pg.global.firstEnterGame = true

		return
	end

	if pg.game.effect.recoverTeleportDissolveTimer ~= nil then
		TimerManager.removeTimer(pg.game.effect.recoverTeleportDissolveTimer)
	end

	self:playTeleportAnim()
end

function ClientMainPlayer:tryTriggerPendingTeleportAppear()
	if self.pendingTeleportAppear then
		self:triggerPlayerTeleportAppear()
	end
end

function ClientMainPlayer:canPlayTeleportReviveAnim()
	if pg.game.forceBanPlayerReviveAnim then
		return false
	end

	if pg.game.seamless:seam_sys_isSwitchSeamless() then
		return false
	end

	if self:RIDING_ST() then
		return false
	end

	if self:FALLEN_ST() then
		return false
	end

	if pg.pawn and pg.pawn:SPECIAL_DEFENSE_ST() then
		return false
	end

	return true
end

function ClientMainPlayer:playTeleportAnim()
	self.inTeleportFinding = false

	local delayTime = 0
	local canTriggerReviveAnim = self:canPlayTeleportReviveAnim()

	pg.game.forceBanPlayerReviveAnim = nil

	if pg.me.portalTeleportId then
		local entPoint = pg.me.space:getEntityByStaticId(pg.me.portalTeleportId)

		if entPoint then
			local skeletonView = entPoint.eModel.skeletonView

			if skeletonView and skeletonView.skeletonRoot then
				local teleportPoint = skeletonView.skeletonRoot:GetComponent("ArkTeleportPoint")

				if teleportPoint then
					delayTime = 0.5

					teleportPoint:PlayArriveVX()

					canTriggerReviveAnim = false
				end
			end
		end
	end

	local function innerPlayFunc()
		self.delayTeleportAppearTimer = nil

		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Teleport)
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
		self:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)

		if pg.me.space and pg.me.space:isRogueEnv() then
			AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)

			return
		end

		if pg.me.space and pg.me.space:isNpcDuel() then
			AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)

			return
		end

		if canTriggerReviveAnim then
			local triggerAnimEnt = self:isControllingPet() and self:getCurPetEntity() or self

			if triggerAnimEnt ~= self then
				AnimationUtils.playAnimationState(triggerAnimEnt, CharacterStateConst.IDLE)
			else
				if self.characterState == CharacterStateConst.REVIVE then
					AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
				end

				AnimationUtils.playAnimationState(self, CharacterStateConst.REVIVE)
			end
		end

		pg.pawn:playTeleportAppearEffect(SysConfigData.playerReviveEffectDuration or 1.2)
	end

	if self.delayTeleportAppearTimer ~= nil then
		self:removeTimer(self.delayTeleportAppearTimer)

		self.delayTeleportAppearTimer = nil
	end

	if delayTime > 0 then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)
		self:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, false)

		self.delayTeleportAppearTimer = self:addTimer(delayTime, innerPlayFunc)
	else
		innerPlayFunc()
	end
end

function ClientMainPlayer:showDeadConfirmMsg()
	if pg.global.ui:checkUIVisible(UIConst.UI_ID_PHOTO) then
		pg.global.ui:close(UIConst.UI_ID_PHOTO)
	end

	pg.global.ui.hudV2.mutePhoto = true

	pg.global.showConfirmMsg(nil, NoticeDef.BATTLE_FAILED_CONFIRM, function()
		pg.me:serverMsg("RPC_CS_StartRevive", Const.REVIVE_TYPE_NORMAL)

		pg.global.ui.hudV2.mutePhoto = false
	end, true)
end

function ClientMainPlayer:startHeartbeat(isSkipHeartbeat)
	if not isSkipHeartbeat then
		self:heartbeat()
	end

	if self.heartbeatTimer ~= nil then
		self:removeTimer(self.heartbeatTimer)
	end

	self.heartbeatTimer = self:addRepeatTimer(5, function()
		self:heartbeat()
	end)
end

function ClientMainPlayer:heartbeat()
	local data = self.statData

	self.statData = {}

	self:serverMsg("RPC_CS_Heartbeat", phonestcore.getMillisecondUTC(), data)
end

function ClientMainPlayer:RPC_SC_Heartbeat(servertime, clienttime, gametime, gameTimeScale)
	self:_dealWithHeartbeat(servertime, clienttime, gametime, gameTimeScale)
end

function ClientMainPlayer:_dealWithHeartbeat(servertime, clienttime, gametime, gameTimeScale)
	local now = phonestcore.getMillisecondUTC()
	local offset = now - clienttime

	self._rtt = offset * (1 - Const.NETWORK_SMOOTH_RTT_ALPHA) + Const.NETWORK_SMOOTH_RTT_ALPHA * (self._rtt or 0)

	self:_setTimeDelta(servertime - now)

	if self.space then
		self.space:syncGameTime(offset / 2 / 1000, gametime, gameTimeScale)
	end
end

function ClientMainPlayer:RPC_SC_SetServerTime(servertime)
	local now = phonestcore.getMillisecondUTC()

	self:_setTimeDelta(servertime - now)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientMainPlayer:_setTimeDelta(delta)
	local oldOffset = Time.getServerDelta()

	Time.setServerDelta(delta)

	local correctOffset = (oldOffset - delta) * 0.001
	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.shiftAllTimer(correctOffset)
	pg.game:resetRepeatTimer()
end

function ClientMainPlayer:RPC_SC_PveHeartbeat(servertime, offset, gametime, gameTimeScale)
	self:startHeartbeat(true)

	local data

	if self.pveHeartbeatCount > 5 then
		self.pveHeartbeatCount = 0
		data = self.statData
		self.statData = {}
	else
		self.pveHeartbeatCount = self.pveHeartbeatCount + 1
		data = {}
	end

	local now = phonestcore.getMillisecondUTC()

	self:serverMsg("RPC_CS_PveHeartbeat", servertime, now, data)
	self:_dealWithHeartbeat(servertime, now - offset, gametime, gameTimeScale)
end

function ClientMainPlayer:RPC_SC_WarnClient(msg)
	pg.global.showBubbleMessageRaw(msg)
end

function ClientMainPlayer:RPC_SC_WarnClientMessage(title, msg)
	pg.global.showConfirmMsgRaw(title, msg, function()
		return
	end, false, function()
		return
	end)
end

function ClientMainPlayer:RPC_SC_Notify_Hotfix_Content(content)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("client hotfix content len: %s", #content)
	end

	content = decompress(content)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("client hotfix content decompress: %s", content)
	end

	pg.isRuningScript = true

	local bddDataMgr = require("Core.Framework.BddDataMgr").GetInstance()

	bddDataMgr:beginPatch()
	ClientUtils.tryWithLogError(function()
		loadstring(content)()
	end)
	bddDataMgr:endPatch()

	pg.isRuningScript = false
end

function ClientMainPlayer:RPC_SC_BindLocalPlayer(mb, auth, gates)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_BindLocalPlayer mb:%s auth:%s", mb, auth)
	end

	ClientUtils.destroyAllExcludeNet()

	local soulInfo = {
		auth = auth,
		soulMbBin = mb,
		gates = ClientRepo.protoCodec:decode(gates)
	}

	ClientRepo.netHandler:_bindSoul(soulInfo)
end

function ClientMainPlayer:resetCommonSwitch(switch)
	for switchName, isOpen in pairs(switch or EMPTY_TABLE) do
		if switchName == "ClientSwitch" then
			for name, open in pairs(isOpen) do
				local old = ClientSwitch[name]

				ClientSwitch[name] = open

				if old ~= open and pg.global and pg.global.eventEmitter then
					pg.global.eventEmitter:emit(EventConst.CLIENT_SWITCH_CHANGED, name, open)
				end

				if LoggerManager.checkLogger(LoggerConst.INFO) then
					-- block empty
				end
			end
		else
			CommonSwitch[switchName] = isOpen

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				-- block empty
			end
		end
	end
end

function ClientMainPlayer:RPC_SC_Notify_CommonSwitch(switch)
	self:resetCommonSwitch(switch)

	if switch and switch.ENABLE_CLIENT_GM ~= nil then
		self:refreshGmStatus()
	end

	facade:sendMsgToUI(MessageName.COMMON_SWITCH_STATE_CHANGED)
	self:postComponentMethod("EVENT_CommonSwitchStateChanged")
end

function ClientMainPlayer:RPC_SC_Notify_ChangeServerOpenTime(openTime)
	Time.ServerOpenTime = openTime
end

function ClientMainPlayer:on_nourishCount_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_NOURISH_COUNT_CHANGED, {
		oldValue = oldv,
		newValue = newv
	})
end

function ClientMainPlayer:on_dailyNourishCount_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_DAILY_NOURISH_COUNT_CHANGED, {
		oldValue = oldv,
		newValue = newv
	})
end

function ClientMainPlayer:on_curEp_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.MAIN_PLAYER_EP_CHANGE)
end

function ClientMainPlayer:on_maxEp_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.MAIN_PLAYER_EP_CHANGE)
end

function ClientMainPlayer:on_maxHp_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.MAIN_PLAYER_HP_CHANGE)
end

function ClientMainPlayer:on_maxStamina_changed(oldv, newv)
	facade:sendMsgToUI(MessageName.PLAYER_ENDURANCE_CHANGE, {
		oldv = oldv,
		newv = newv
	})
end

function ClientMainPlayer:on_curSp_changed(oldV, newV)
	facade:SendMessageCommand(MessageName.MAIN_PLAYER_SP_CHANGE, {
		oldV,
		newV
	})
end

function ClientMainPlayer:on_petInfoCurHp_change(ov, nv, idx)
	facade:SendMessageCommand(MessageName.PET_HP_CHANGE, idx, ov, nv)
end

function ClientMainPlayer:on_petInfoCurMaxHp_change(ov, nv, idx)
	facade:SendMessageCommand(MessageName.PET_HP_CHANGE, idx, ov, nv)
end

function ClientMainPlayer:notifyChatGroupIdChanged(oldGroupId, groupId)
	if pg.game.chat then
		pg.game.chat:queueChannelHistoryPreload(groupId)
	end

	facade:SendMessageCommand(MessageName.CHAT_CHANNEL_LINE_CHANGE, {
		oldGroupId = oldGroupId,
		groupId = groupId
	})
end

function ClientMainPlayer:on_worldChatGroupId_changed(oldV, newV)
	self:notifyChatGroupIdChanged(oldV, newV)
end

function ClientMainPlayer:on_classChatGroupId_changed(oldV, newV)
	self:notifyChatGroupIdChanged(oldV, newV)
end

function ClientMainPlayer:on_languageChatGroupId_changed(oldV, newV)
	self:notifyChatGroupIdChanged(oldV, newV)
end

function ClientMainPlayer:on_isInFluteMatch_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_isInFluteMatch_changed>> cur", oldV, newV)
	end

	if newV == false then
		facade:SendMessageCommand(MessageName.STOP_FLUTE_MATCH)
	end
end

function ClientMainPlayer:onPetInfoShieldChange(ov, nv, idx)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onPetInfoShieldChange", idx, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_SHIELD_CHANGE, idx)
	self.eventEmitter:emit(EventConst.TOPLOGO_PET_SHIELD)
end

function ClientMainPlayer:onPetInfoAliveChange(ov, nv, idx)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetInfoAliveChange", idx, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_ALIVE_CHANGE, idx)
end

function ClientMainPlayer:onBeHatredMapAdd(k, v)
	facade:sendMsgToUI(MessageName.PLAYER_BE_HATRED_LIST_CHANGE)
end

function ClientMainPlayer:onBeHatredMapDelete(k, v)
	facade:sendMsgToUI(MessageName.PLAYER_BE_HATRED_LIST_CHANGE)
end

function ClientMainPlayer:onPvp2RevealByTargetAdd(actorId, expireTime)
	self:_notifyPvp2RevealMapChanged(actorId)
end

function ClientMainPlayer:onPvp2RevealByTargetChange(oldExpireTime, newExpireTime, actorId)
	self:_notifyPvp2RevealMapChanged(actorId)
end

function ClientMainPlayer:onPvp2RevealByTargetDelete(actorId, expireTime)
	self:_notifyPvp2RevealMapChanged(actorId)
end

function ClientMainPlayer:_notifyPvp2RevealMapChanged(actorId)
	if actorId == nil then
		return
	end

	local entity = pg.getEntityByActorId(actorId)

	if entity and entity.space == self.space and entity._isPvp2Scene and entity._updatePvp2RevealState then
		entity:_updatePvp2RevealState()
	end
end

function ClientMainPlayer:onIsSpecialTrainOpenChange(isSpecialTrainOpen)
	if pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:checkSpecialTrainValidState()

		if not isSpecialTrainOpen then
			pg.global.ui:close(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL)
		end
	end

	if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.quest then
		pg.global.ui.tips.quest:resetPageTabList()
		pg.global.ui.tips.quest:refreshSwitchKeyVisible()
	end
end

function ClientMainPlayer:RPC_SC_OnWorldFurniturePlaced(furnitureInfo)
	pg.me.placedHomeTemplateId = furnitureInfo.homeTemplateId or 0

	facade:SendMessageCommand(MessageName.INTERACT_GESTURE_UNLOCK_CHANGED)
end

function ClientMainPlayer:onTeleport(pos)
	if not pg.game.controller:restoreAutoSwitch(CharacterStateConst.IDLE) then
		-- block empty
	end

	local reloadScene = appFacade.streamManager:CheckNeedLoad(pos)

	if reloadScene then
		pg.global.scene:reloadCurrentScene(pos)
	end

	self:postComponentMethod("EVENT_OnTeleport", pos, reloadScene)
	clientUtils.exitAfkMode()
	facade:SendMessageCommand(MessageName.PLAYER_ONTELEPORT)
end

function ClientMainPlayer:addStatData(data)
	return
end

function ClientMainPlayer:setControllerMachine(fromState)
	ClientMainPlayer.super.setControllerMachine(self, fromState)
	self:refreshClimbAcrossConfig()
end

function ClientMainPlayer:getStepHeightUp()
	return SysConfigData.stepUpHeightRatioRange[1] * self.eModel.height
end

function ClientMainPlayer:getPlayerNeedExp()
	local needExp = 0
	local cData = PlayerLevelData[self.level]

	if self.level == 10 and self.rank == 1 then
		needExp = cData.needExp
	else
		cData = PlayerLevelData[self.level + 1]
		cData = cData or PlayerLevelData[self.level]
		needExp = cData.needExp
	end

	return needExp
end

function ClientMainPlayer:RPC_SC_BpAttack(targetActorId, bpValue)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		-- block empty
	end

	facade:sendMsgToUI(MessageName.SHOW_BREAK_NUMBER, {
		targetActorId = targetActorId,
		value = bpValue
	})
end

function ClientMainPlayer:RPC_SC_OnBugReportReply(err, header, body)
	ClientUtils.showBubbleMessageRaw(err ~= 0 and pg.getGameString("FAILED") or pg.getGameString("SUCCEED"))

	local status, bodyJson = pcall(require("json").decode, body)

	if status and bodyJson and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnBugReportReply", bodyJson.code, bodyJson.data.url)
	end
end

function ClientMainPlayer:RPC_SC_receiveNotice(noticeId, noticeArgs)
	if noticeId == nil or noticeId == 0 then
		return
	end

	local _h = ClientMainPlayer._platformHooks

	noticeArgs = _h and _h.replaceNoticeArgs and _h.replaceNoticeArgs(self, noticeId, noticeArgs) or noticeArgs

	if noticeId == NoticeDef.TEAM_MSG_MAX_PLAYER then
		pg.global.ui.tips:showTextTip(pg.getGameString("OTHER_TEAM_FULL"))
	elseif noticeId == NoticeDef.PLATFORM_SHELL_INVITE_NOT_TEAM_LEADER then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAMP_MEMBER_MEET_INVITE_TIP"))
	elseif noticeId == NoticeDef.REWARD_LIMIT_TOAST then
		ClientUtils.showRewardLimitToast(Utils.safeUnpack(noticeArgs))
	elseif noticeId == NoticeDef.STATE_CONFLICT_MSG then
		local stateName, eventName = Utils.safeUnpack(noticeArgs)

		stateName = pg.getGameString("SC_" .. stateName)
		eventName = pg.getGameString("SC_" .. eventName)

		ClientUtils.showBubbleMessageById(noticeId, stateName, eventName)
	elseif noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_START or noticeId == NoticeDef.SOCIAL_PARTY_FOLLOW_START or noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST1 or noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST2 or noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST3 or noticeId == NoticeDef.SOCIAL_PARTY_FOLLOW_DROP_TOAST or noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_PET_PROP or noticeId == NoticeDef.SOCIAL_PARTY_FOLLOW_PET_PROP then
		local handled = pg.game.social:tryShowCafePetNotice(noticeId, noticeArgs)

		if handled ~= true then
			if noticeId == NoticeDef.SOCIAL_PARTY_SNUGGLE_PET_PROP or noticeId == NoticeDef.SOCIAL_PARTY_FOLLOW_PET_PROP then
				pg.game.social:onCafePetIvUpNotice(noticeId, noticeArgs)
			end

			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
		end
	elseif noticeId == NoticeDef.MAP_PUPPET_LEVEL_NOTICE then
		pg.me.mapPuppetLevelDict = noticeArgs

		pg.global.eventEmitter:emit(MessageName.MAP_PUPPET_LEVEL_UPDATE, noticeArgs)

		return
	elseif noticeId == NoticeDef.MULTI_ACTION_WITHOUT_PET then
		local petPrototypeId = Utils.safeUnpack(noticeArgs)

		if petPrototypeId and PetBasePrototypeData[petPrototypeId] and PetBasePrototypeData[petPrototypeId].name then
			ClientUtils.showBubbleMessageById(noticeId, pg.getLocalizationText(PetBasePrototypeData[petPrototypeId].name))
		end
	elseif noticeId == NoticeDef.TID_MEDIA_MARKER_ALWAYS_LIKED or noticeId == NoticeDef.TID_MARKER_NOT_EXSIT then
		ClientUtils.showBubbleMessageById(noticeId)

		local markerId = noticeArgs and noticeArgs[1]

		if markerId and self.mediaMarkerOp and self.mediaMarkerOp[markerId] then
			facade:SendMessageCommand(MessageName.ON_INFO_STAMP_BE_LIKED, {
				onlyChangeLikeState = true,
				markerId = markerId
			})
		end
	else
		ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArgs))
	end

	if noticeId >= NoticeDef.PHOTOGRAPHY_STUDIO_SYNC_SUCCESS and noticeId <= NoticeDef.PHOTOGRAPHY_STUDIO_MEMBER_OVER then
		self:onStudioNotice(noticeId, noticeArgs)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_receiveNotice %s", NoticeDef.getRepr(noticeId, noticeArgs))
	end

	if _h and _h.RPC_SC_receiveNotice then
		_h.RPC_SC_receiveNotice(self, noticeId, noticeArgs)
	end
end

function ClientMainPlayer:setInScene(isInScene, isReset, extraInfo)
	ClientMainPlayer.super.setInScene(self, isInScene, isReset, extraInfo)

	if isInScene then
		if self.space.flushLogicTimeMainScene then
			self.space:flushLogicTimeMainScene()
		end

		self.space:onRenderTimePeriodChange()
	end
end

function ClientMainPlayer:RPC_SC_ResetAllStateByEscape()
	pg.global.ui:closeAllUIPanel({
		[UIConst.UI_ID_TIPS] = true,
		[UIConst.UI_ID_TOPLOGO] = true,
		[UIConst.UI_ID_RACING_DUNGEON] = true
	}, true)
	LuaUIUtils.onPlayerCreate()
	pg.global.ui.topLogo:open()
	pg.global.ui.blackChange:open()
	pg.global.ui.blackBg:open()
	self:stopAllAnimation()

	if pg.me:isControllingExploreEnt() then
		pg.pawn:forceUngrounded(false)
		pg.game.controller:restoreAutoSwitch(CharacterStateConst.IDLE)
	elseif self:FALLEN_ST() then
		self:onLifeFallen()
	else
		AnimationUtils.playAnimationState(self, CharacterStateConst.REVIVE)
	end

	pg.game.input:resetAllActions()
	self:postComponentMethod("EVENT_ResetAllStateByEscape")
	pg.global.eventEmitter:emit(EventConst.ON_MAP_RELOADED, {})
end

function ClientMainPlayer:postInitializeComponents()
	ClientMainPlayer.super.postInitializeComponents(self)
	self:applyMotionProp()
	self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 1)
end

function ClientMainPlayer:onBindSoulSucceed()
	self:updateMsGateInfo(true)
end

function ClientMainPlayer:updateMsGateInfo(firstSet)
	if self.isGuidancePlayer then
		return
	end

	if GlobalData.GlobalGateSessionId == nil or GlobalData.GlobalGateId == nil then
		return
	end

	self:serverMsg("RPC_CS_UpdateMsGateInfo", GlobalData.GlobalGateSessionId, GlobalData.GlobalGateId, firstSet)
end

function ClientMainPlayer:callService(serviceName, methodName, args, callback, options)
	if self.isGuidancePlayer and serviceName ~= "NavmeshService" then
		return
	end

	ClientMainPlayer.super.callService(self, serviceName, methodName, args, callback, options)
end

local function getGlobalMsSession()
	if ClientRepo.globalMsProxy == nil or ClientRepo.globalMsProxy.getClient == nil then
		return nil
	end

	local msClient = ClientRepo.globalMsProxy:getClient()

	if msClient == nil then
		return nil
	end

	return msClient.session
end

local function disconnectSession(session, connType)
	if session == nil then
		return false
	end

	session:onDisconnect(connType)

	return true
end

function ClientMainPlayer:RPC_SC_LoseConnectTest(second, isFullSync)
	if self.isInLoseConnectTest then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("--------- loseConnectTest start, wait %d second, isFullSync %s --------------", second, isFullSync)
	end

	local ProtobufConst = require("Core.Common.ProtobufConst")
	local connType = ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN

	ClientRepo.isLoseConnectTestNetworkBlocked = true

	local hasSoulDisconnected = false

	if ClientRepo.netHandler then
		ClientRepo.netHandler:setLoseConnectTestFullSync(isFullSync)

		local soulSession = ClientRepo.netHandler.gateClientSoul and ClientRepo.netHandler.gateClientSoul.session

		hasSoulDisconnected = disconnectSession(soulSession, connType)

		if not hasSoulDisconnected then
			ClientRepo.netHandler:setLoseConnectTestFullSync(false)
		end
	end

	disconnectSession(getGlobalMsSession(), connType)

	self.isInLoseConnectTest = true

	ClientUtils.showBubbleMessageRaw("开始断线测试" .. (isFullSync and "-全量同步" or "-增量同步"), 3)
	self:addTimer(second, function()
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("--------- loseConnectTest end --------------", second)
		end

		ClientUtils.showBubbleMessageRaw("恢复连接" .. (isFullSync and "-全量同步" or "-增量同步"), 3)

		ClientRepo.isLoseConnectTestNetworkBlocked = false
		self.isInLoseConnectTest = false
	end)
end

function ClientMainPlayer:RPC_SC_BanTeleportEffect()
	pg.game.map.banTeleportEffectFlag = true
end

function ClientMainPlayer:reportProcessStuckDebug()
	self:serverMsg("RPC_CS_ReportProcessStuckDebug", function(noticeId, noticeArg)
		local messageStr = noticeId == NoticeDef.SUCCESS and pg.getGameString("SUCCEED") or pg.getGameString("FAILED")

		pg.global.showBubbleMessageRaw(messageStr)
	end)
end

function ClientMainPlayer:RPC_SC_OpenTelnetDebug()
	local ConsoleUtils = require("Utils.ConsoleUtils")
	local globalDeclare = require("Core.Framework.Global")

	globalDeclare("ConsoleUtils", ConsoleUtils)
end

function ClientMainPlayer:pullExclusiveLine(sceneId)
	assert(false, "not support")
end

function ClientMainPlayer:switchExclusiveLine(lineNo)
	assert(false, "not support")
end

local CLIENT_CACHE_META_KEY = Const.CLIENT_KEY.CLIENT_CACHE_META

function ClientMainPlayer:getClientMetaVersion()
	return self.clientVersion[CLIENT_CACHE_META_KEY]
end

function ClientMainPlayer:setClientMetaVersion(version)
	self.clientVersion[CLIENT_CACHE_META_KEY] = version

	self:serverMsg("RPC_CS_UpdateClientVersion", CLIENT_CACHE_META_KEY, version)

	return true
end

local function getBusinessClientInfoDef(clientKey, key)
	return Const.CLIENT_DEF[clientKey][key]
end

function ClientMainPlayer:getClientInfo(clientKey, key)
	local value = ClientCache.get(clientKey, key)

	if value ~= nil then
		return value
	end

	local fieldDef = getBusinessClientInfoDef(clientKey, key)

	if fieldDef[1] == "table" then
		return ClientCache.getOrCreateTable(clientKey, key)
	end

	return fieldDef[2]
end

function ClientMainPlayer:updateClientInfo(clientKey, key, value)
	local fieldDef = getBusinessClientInfoDef(clientKey, key)

	if value == Const.NIL then
		value = nil
	end

	local success = ClientCache.set(clientKey, key, value, value ~= nil and fieldDef[1] == "table")

	return success
end

function ClientMainPlayer:sendClientInfo(clientKey)
	return true
end

function ClientMainPlayer:setClientInfo(clientKey, key, value)
	return self:updateClientInfo(clientKey, key, value)
end

function ClientMainPlayer:replaceClientInfo(clientKey, clientRecords)
	return ClientCache.replace(clientKey, clientRecords)
end

function ClientMainPlayer:getCommonSetting(key)
	local dict = self:getClientInfo(Const.CLIENT_KEY.SETTING, "common")

	return dict and dict[key]
end

function ClientMainPlayer:setCommonSetting(key, value)
	local dict = self:getClientInfo(Const.CLIENT_KEY.SETTING, "common")

	dict = dict or {}
	dict[key] = value

	return self:setClientInfo(Const.CLIENT_KEY.SETTING, "common", dict)
end

local function sendPetRedDotRecordUpdate(clientKey)
	if clientKey == Const.CLIENT_KEY.PET_NEW_RED_DOT then
		facade:SendMessageCommand(MessageName.PET_NEW_RED_DOT_RECORD_UPDATE)
	elseif clientKey == Const.CLIENT_KEY.PET_EVOLVE_RED_DOT then
		facade:SendMessageCommand(MessageName.PET_EVOLVE_RED_DOT_RECORD_UPDATE)
	elseif clientKey == Const.CLIENT_KEY.PET_TAG_ANIM_RECORD then
		facade:SendMessageCommand(MessageName.PET_TAG_ANIM_RECORD_UPDATE)
	end
end

function ClientMainPlayer:tryRepairAreaFirstInData()
	if not self.areaFirstInRepairPending or not self.isInScene or not self.space then
		return
	end

	self:repairAreaFirstInData()

	self.areaFirstInRepairPending = nil
end

function ClientMainPlayer:onClientCacheReady()
	self.areaFirstInRepairPending = true

	self:tryRepairAreaFirstInData()
	sendPetRedDotRecordUpdate(Const.CLIENT_KEY.PET_NEW_RED_DOT)
	sendPetRedDotRecordUpdate(Const.CLIENT_KEY.PET_EVOLVE_RED_DOT)
	sendPetRedDotRecordUpdate(Const.CLIENT_KEY.PET_TAG_ANIM_RECORD)

	if self.eventEmitter ~= nil then
		self.eventEmitter:emit(EventConst.CLIENT_INFO_READY, true)
	end
end

function ClientMainPlayer:getRedDotRecord(clientKey, key, defaultValue)
	return ClientCache.get(clientKey, key, defaultValue)
end

function ClientMainPlayer:setRedDotRecord(clientKey, key, value)
	local success, changed = ClientCache.set(clientKey, key, value)

	if success and changed then
		sendPetRedDotRecordUpdate(clientKey)
	end

	return success
end

function ClientMainPlayer:deletePetRedDotRecords(clientKey, keys)
	local hasChanges = false

	for index = 1, #keys do
		local success, changed = ClientCache.delete(clientKey, keys[index])

		if not success then
			return false
		end

		hasChanges = hasChanges or changed
	end

	if hasChanges then
		sendPetRedDotRecordUpdate(clientKey)
	end

	return true
end

function ClientMainPlayer:getPetCurWater(key, defaultValue)
	local petInfo = self.pets and self.pets[key]

	if petInfo ~= nil and petInfo[PET_EXPLORE_WATER_RUNTIME_KEY] ~= nil then
		return petInfo[PET_EXPLORE_WATER_RUNTIME_KEY]
	end

	local runtimeDict = self.petCurWaterRuntimeCache

	if runtimeDict == nil then
		return defaultValue
	end

	if runtimeDict[key] == nil then
		return defaultValue
	end

	return runtimeDict[key]
end

function ClientMainPlayer:setPetCurWater(key, value)
	local petInfo = self.pets and self.pets[key]

	if petInfo ~= nil then
		petInfo[PET_EXPLORE_WATER_RUNTIME_KEY] = value

		return
	end

	self.petCurWaterRuntimeCache[key] = value
end

function ClientMainPlayer:onEnterTrap(actorId, eventId)
	if eventId == Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY then
		local curPet = self:getCurPetEntity()

		if curPet then
			curPet:onPerceptibilityEnterTrap(actorId)
		end
	end

	if eventId == Const.TRAP_EVENT_ID_SYNC_FPS_RANGE then
		local ent = pg.getEntityByActorId(actorId)

		if not self.space:isMultiPlayerEnv() and ent ~= nil and ent.aoi ~= nil then
			ent.inMainPlayerTrap = true

			ent:refreshSyncFpsRange()
		end
	elseif eventId == Const.TRAP_EVENT_ID_TOPLOGO_PLAYER or eventId == Const.TRAP_EVENT_ID_TOPLOGO_OTHER then
		local ent = pg.getEntityByActorId(actorId)

		if ent ~= nil and ent.onTopLogoLodRangeChanged ~= nil then
			ent:onTopLogoLodRangeChanged(eventId == Const.TRAP_EVENT_ID_TOPLOGO_PLAYER, true)
		end
	end
end

function ClientMainPlayer:onLeaveTrap(actorId, eventId)
	if eventId == Const.TRAP_EVENT_ID_AI_PERCEPTIBILITY then
		local curPet = self:getCurPetEntity()

		if curPet then
			curPet:onPerceptibilityLeaveTrap(actorId)
		end
	end

	if eventId == Const.TRAP_EVENT_ID_SYNC_FPS_RANGE then
		local ent = pg.getEntityByActorId(actorId)

		if not self.space:isMultiPlayerEnv() and ent ~= nil and ent.aoi ~= nil then
			ent.inMainPlayerTrap = false

			ent:refreshSyncFpsRange()
		end
	elseif eventId == Const.TRAP_EVENT_ID_TOPLOGO_PLAYER or eventId == Const.TRAP_EVENT_ID_TOPLOGO_OTHER then
		local ent = pg.getEntityByActorId(actorId)

		if ent ~= nil and ent.onTopLogoLodRangeChanged ~= nil then
			ent:onTopLogoLodRangeChanged(eventId == Const.TRAP_EVENT_ID_TOPLOGO_PLAYER, false)
		end
	end
end

function ClientMainPlayer:RPC_SC_NotifyResetPositionInfo(resetPosType, pointId, markType)
	self.logger:debug("RPC_SC_NotifyResetPositionInfo", resetPosType, pointId, markType, self.space.sceneId)

	if resetPosType == Const.RESET_POS_TYPE.REVIVE and (markType == Const.MAP_MARK_CAMP or markType == Const.MAP_MARK_BONFIRE) then
		GlobalData.RespawnBonfirePointId = pointId
	end
end

function ClientMainPlayer:RPC_SC_ChangePlayerNameRet(code)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CREATE_PLAYER_RENAME) then
		pg.global.ui.createPlayerRename:createNameResult(code)
	elseif pg.global.ui:checkUIOpen(UIConst.UI_ID_CHANGE_NAME) then
		pg.global.ui.changeName:createNameResult(code)
	end
end

function ClientMainPlayer:RPC_SC_EnterLeaderSpace(enterType, sceneId, portalId)
	local message = ""
	local ok = ""
	local cancel = ""

	if enterType == Const.FOLLOW_ENTER_TYPE.ENTER_LINE then
		message = pg.getGameString("FOLLOW_TEAM_LEADER")
		ok = pg.getGameString("ENSURE")
		cancel = pg.getGameString("GOTO_MY_WORLD")
	elseif enterType == Const.FOLLOW_ENTER_TYPE.ENTER_SINGLEWORLD_NOT or enterType == Const.FOLLOW_ENTER_TYPE.ENTER_SINGLEWORLD_DYC_NOT or enterType == Const.FOLLOW_ENTER_TYPE.ENTER_SINGLEWORLD_QUITE_NOT then
		message = pg.getGameString("CANT_GOTO_TEAM_LEADERS_WORLD")
		ok = pg.getGameString("STAY_HERE")
		cancel = pg.getGameString("GOTO_MY_WORLD")
	end

	self:seamless_setEnableCheck(false)
	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), message, function()
		self:serverMsg("RPC_CS_EnterLeaderSpaceRet", true, enterType, sceneId, portalId)
		self:seamless_setEnableCheck(true)
		pg.game.seamless:seam_sys_setSwitchState(false)
		self:playTeleportAnim()
	end, false, function()
		self:serverMsg("RPC_CS_EnterLeaderSpaceRet", false, enterType, sceneId, portalId)
		self:seamless_setEnableCheck(true)
		pg.game.seamless:seam_sys_setSwitchState(false)
	end, nil, nil, {
		okBtnDesc = ok,
		cancelBtnDesc = cancel
	})
end

function ClientMainPlayer:pullScrollingtext()
	self:serverMsg("RPC_CS_PullScrollingtext")
end

function ClientMainPlayer:RPC_SC_NotifyScrollingtext(data)
	self.scrollingtext = data

	pg.game.marquee:updateMarqueeInfo(self.scrollingtext)
end

function ClientMainPlayer:RPC_SC_SyncTeamEntityData(posData)
	if not self.movingEntitiesPosData then
		self.movingEntitiesPosData = {}
	end

	self.movingEntitiesPosData.updateTime = Time.realSecondCache

	local temp = {}

	for entityId, posD in pairs(posData) do
		local data = self.movingEntitiesPosData[entityId]

		if not data then
			self.movingEntitiesPosData[entityId] = {
				position = {
					posD.position[1],
					posD.position[2],
					posD.position[3]
				},
				lastPosition = {
					posD.position[1],
					posD.position[2],
					posD.position[3]
				}
			}
		else
			data.lastPosition = {
				data.position[1],
				data.position[2],
				data.position[3]
			}
			data.position = {
				posD.position[1],
				posD.position[2],
				posD.position[3]
			}
		end

		if posD.subType and pg.game.grabEgg then
			pg.game.grabEgg:syncEggDynamicMark(entityId, posD)
		elseif pg.game.grabEgg and pg.game.grabEgg:isSupportedDynamicMarkSyncData(posD) then
			pg.game.grabEgg:syncDynamicMark(entityId, posD)
		elseif posD.markID and posD.ownerUid == self.id then
			pg.game.map:tryBindEntityPosToMapMark(posD.markID, entityId)
		end

		temp[entityId] = true
	end

	for entityId, _ in pairs(self.movingEntitiesPosData) do
		if entityId ~= "updateTime" and not temp[entityId] then
			if pg.game.grabEgg and pg.game.grabEgg:getEggSyncData(entityId) then
				pg.game.grabEgg:removeEggDynamicMark(entityId)
			end

			if pg.game.grabEgg and pg.game.grabEgg:getDynamicMarkSyncData(entityId) then
				pg.game.grabEgg:removeDynamicMark(entityId)
			end

			self.movingEntitiesPosData[entityId] = nil
		end
	end
end

function ClientMainPlayer:hasMovingEntityPosData(entityId)
	local movingData = self.movingEntitiesPosData

	return entityId ~= nil and movingData ~= nil and movingData[entityId] ~= nil or false
end

function ClientMainPlayer:getMovingEntityPosData(entityId, outPos)
	if not entityId then
		return nil
	end

	local data = self.movingEntitiesPosData and self.movingEntitiesPosData[entityId]

	if not data then
		return nil
	end

	local curTime = Time.realSecondCache
	local dt = curTime - self.movingEntitiesPosData.updateTime
	local t = dt / self.INTERP_DELAY

	if t < 0 then
		t = 0
	end

	if t > 1 then
		t = 1
	end

	outPos = outPos or Vector3.zero
	outPos.x = data.lastPosition[1] + (data.position[1] - data.lastPosition[1]) * t
	outPos.y = data.lastPosition[2] + (data.position[2] - data.lastPosition[2]) * t
	outPos.z = data.lastPosition[3] + (data.position[3] - data.lastPosition[3]) * t

	return outPos
end

function ClientMainPlayer:CallServerMsgTeleportToScene(sceneId, portalId, ignoreCheck)
	print(string.format("@fjs TrackTele TeleportToScene scene[%d], port[%d], stk[%s]", sceneId, portalId, debug.traceback()))

	local function cbFunc()
		pg.me:serverMsg("RPC_CS_TeleportToScene", sceneId, portalId, ignoreCheck)
	end

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local sceneID = sceneId

	if sceneID == nil then
		sceneID = 0
	end

	local arg = {
		KeyFrom = luaCSConst.XPartConst.KeyTeleToScene,
		ToScene = sceneID,
		portalId = portalId,
		ignoreCheck = ignoreCheck
	}

	clientXPartUtil.hookMainPlayerTeleportToScene(arg, cbFunc)
end

function ClientMainPlayer:CallServerMsgTeleportToPhase(sceneId, pos)
	print(string.format("@fjs TrackTele TeleportToPhase scene[%d], pos[%f, %f, %f], stk[%s]", sceneId, pos.x, pos.y, pos.z, debug.traceback()))

	local function cbFunc()
		pg.me:serverMsg("RPC_CS_TeleportToDynamicPhase", sceneId, pos)
	end

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local sceneID = sceneId

	if sceneID == nil then
		sceneID = 0
	end

	local arg = {
		KeyFrom = luaCSConst.XPartConst.KeyTeleToPhase,
		ToScene = sceneID,
		pos = pos
	}

	clientXPartUtil.hookMainPlayerTeleportToPhase(arg, cbFunc)
end

function ClientMainPlayer:CallGMWithParamCB(cmdName, params, cbFunc)
	if EnableBotTest then
		return false
	end

	local hookGM = false

	if cmdName == "teleportToScene" then
		hookGM = true
	end

	if hookGM == false then
		return false
	end

	print(string.format("@fjs TrackTele CallGMWithParamCB cmd[%s], param[%s], stk[%s]", cmdName, table.val_to_str(params), debug.traceback()))

	local sceneID = 0

	if params ~= nil then
		sceneID = params[1]
	end

	if sceneID == nil then
		sceneID = 0
	end

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local arg = {
		KeyFrom = luaCSConst.XPartConst.KeyTeleToScene,
		ToScene = sceneID
	}

	clientXPartUtil.hookMainPlayerTeleportToScene(arg, cbFunc)

	return true
end

function ClientMainPlayer:CheckAndCallServerTeleport(sceneId, funcCB)
	print(string.format("@fjs TrackTele CheckAndCallServerMsgTeleport scene[%d], stk[%s]", sceneId, debug.traceback()))

	local luaCSConst = require("Common.Const.LuaCSConst")
	local clientXPartUtil = require("Utils.ClientXPartUtil")
	local sceneID = sceneId

	if sceneID == nil then
		sceneID = 0
	end

	local arg = {
		KeyFrom = luaCSConst.XPartConst.KeyTeleToScene,
		ToScene = sceneID
	}

	clientXPartUtil.hookMainPlayerTeleportToScene(arg, funcCB)
end

return ClientMainPlayer
