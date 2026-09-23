-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientSpace.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local ClientSpaceBase = require("Core.Client.ClientSpaceBase")
local Time = require("Core.Common.Time")
local ProjectileManager = require("Common.Ability.Projectile.ProjectileManager")
local AbilityTimerManager = require("Common.Ability.AbilityTimerManager")
local AIManager = require("Common.AI.AIManager")
local EditorProjectileManager = require("Common.Ability.Projectile.EditorProjectileManager")
local TimeScaleManager = require("Common.Ability.TimeScale.TimeScaleManager")
local SceneData = require("Data.scene_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EntityManager = require("Core.Common.EntityManager")
local phonestcore = require("phonestcore")
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local ClientProjectile = require("GameApp.Ability.ClientProjectile")
local EditorProjectile = require("GameApp.Ability.EditorProjectile")
local ClientSpaceLogicTimeComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceLogicTimeComponent")
local ClientSpaceTileComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceTileComponent")
local ClientSpaceWeatherComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceWeatherComponent")
local ClientSpaceGraphComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceGraphComponent")
local ClientSpaceSandboxComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceSandboxComponent")
local ClientSpaceAreaComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceAreaComponent")
local ClientSpaceLeylineTreeComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceLeylineTreeComponent")
local ClientSpaceLeylineFlowerComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceLeylineFlowerComponent")
local ClientSpaceMediaMarkerComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceMediaMarkerComponent")
local ClientSpaceBattleModeComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceBattleModeComponent")
local ClientSpaceArkScreenComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceArkScreenComponent")
local ClientSpaceFollowComponent = require("Entities.SpaceEntities.SpaceComponent.ClientSpaceFollowComponent")
local ClientDynamicVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicVoxelComponent")
local SafeCallback = require("Core.Framework.SafeCallback")
local LevelData = require("Data.level_data")
local lume = require("Core.Common.lume")
local paramCache = {}
local entityManager = appFacade.entityManager
local ClientSpace = Class.Class("ClientSpace", ClientSpaceBase)
local ClientSpaceComponents = {
	ClientSpaceLogicTimeComponent,
	ClientSpaceTileComponent,
	ClientSpaceWeatherComponent,
	ClientSpaceGraphComponent,
	ClientSpaceSandboxComponent,
	ClientSpaceAreaComponent,
	ClientSpaceLeylineTreeComponent,
	ClientSpaceLeylineFlowerComponent,
	ClientSpaceMediaMarkerComponent,
	ClientSpaceBattleModeComponent,
	ClientSpaceArkScreenComponent,
	ClientSpaceFollowComponent,
	ClientDynamicVoxelComponent
}

if EnableBotTest then
	ClientSpaceComponents = {
		ClientSpaceSandboxComponent,
		ClientSpaceLeylineTreeComponent,
		ClientSpaceAreaComponent,
		ClientSpaceLogicTimeComponent,
		ClientSpaceArkScreenComponent
	}
end

Class.AddComponents(ClientSpace, ClientSpaceComponents)

local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")

local function isSelfInTeam()
	local me = pg and pg.me

	if me and type(me.isInTeam) == "function" then
		return me:isInTeam() == true
	end

	return false
end

function ClientSpace.syncMultiplayerActiveToBridge(multiPlayerEnv)
	local selfInTeam = isSelfInTeam()

	if multiPlayerEnv or selfInTeam then
		PlatformPremiumFeatureService:beginSession("cross_play")
	elseif not selfInTeam and not multiPlayerEnv then
		PlatformPremiumFeatureService:endSession()
	end
end

function ClientSpace:ctor(entityId)
	ClientSpace.super.ctor(self, entityId)

	self.staticId2Id = {}
	self._globalId2Entity = {}
	self.dungeonTeamInfo = nil
	self.projectileMgr = ProjectileManager(self, function()
		return ClientProjectile()
	end)
	self.timeScaleMgr = TimeScaleManager(self)
	self.aiMgr = AIManager(self)
	self.pauseData = {}
	self.levelGameTimePauseData = {}
	self.explicitGameTimeScaleRequests = {}
	self.gameTimeScaleRequestSuspensions = {}
	self.gameTime = 0
	self.gameTimeScale = 1
	self.gameTimeDeltaScale = 1
	self.gameTimeDeltaCount = 0
	self.lastRequestedGameTimeScale = 1
	self.lastRequestedGameTimeScaleType = Const.GameTimeScaleType.DEFAULT
	self.gameTimeScaleRequestCheckTimer = nil
	self.escLastUpdateTime = 0
	self.projLastTickTime = self:getGameTime()
	self.aiLastTickTime = self:getGameTime()
	self.projectileMgrFrameId = TimerManager.addRepeatNextFrameCb(function()
		local curTime = self:getGameTime()
		local deltaTime = curTime - self.projLastTickTime

		if deltaTime < 0 then
			self.projLastTickTime = curTime

			return
		end

		self.projectileMgr:tick(deltaTime)

		self.projLastTickTime = curTime
	end)
	self.aiMgrFrameId = TimerManager.addRepeatNextFrameCb(function()
		local curTime = self:getGameTime()
		local deltaTime = curTime - self.aiLastTickTime

		if deltaTime < 0 then
			self.aiLastTickTime = curTime

			return
		end

		self.aiMgr:tick(deltaTime)

		self.aiLastTickTime = curTime
	end)
end

function ClientSpace:serverMsg(name, parameters)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("invalid call of serverMsg, use pg.me:serverSpaceMsg instead", name, self:repr())
	end
end

function ClientSpace:hasAuth()
	local player = pg.me

	if player then
		return self.authorityId == player.id
	end

	return false
end

function ClientSpace:isMultiPlayerEnv()
	return self.multiPlayerEnv
end

function ClientSpace:isDungeon()
	return self.spaceType == Const.SPACE_TYPE_DUNGEON
end

function ClientSpace:isPVEDungeon()
	return self.spaceType == Const.SPACE_TYPE_PVE_DUNGEON or self.spaceType == Const.SPACE_TYPE_TEAM_PVE_DUNGEON
end

function ClientSpace:isBossDungeon()
	return self.spaceType == Const.SPACE_TYPE_BOSS_DUNGEON
end

function ClientSpace:isPhase()
	return self.spaceType == Const.SPACE_TYPE_PHASE
end

function ClientSpace:isPvpEnv()
	return self.spaceType == Const.SPACE_TYPE_PVP_DUNGEON or self.spaceType == Const.SPACE_TYPE_SOUDACHE_PVP_DUNGEON
end

function ClientSpace:isRogueEnv()
	return self.spaceType == Const.SPACE_TYPE_ROGUE_DUNGEON
end

function ClientSpace:isBossRushEnv()
	return self.spaceType == Const.SPACE_TYPE_BOSS_RUSH
end

function ClientSpace:isNpcDuel()
	return self.spaceType == Const.SPACE_TYPE_NPC_DUEL
end

function ClientSpace:isCatchRogue()
	return self.spaceType == Const.SPACE_TYPE_CATCH_ROGUE_DUNGEON
end

function ClientSpace:isHomeland()
	return Utils.isHomeland(self.spaceType)
end

function ClientSpace:isHomeCamp()
	return Utils.isHomeCamp(self.spaceType)
end

function ClientSpace:isBigWorld()
	return self.spaceType == Const.SPACE_TYPE_SINGLEWORLD or self.spaceType == Const.SPACE_TYPE_MULTIWORLD
end

function ClientSpace:isTown()
	return self.spaceType == Const.SPACE_TYPE_TOWN
end

function ClientSpace:isGrabEgg()
	return self.spaceType == Const.SPACE_TYPE_ROBEGG or self.spaceType == Const.SPACE_TYPE_ROBEGG_UNDERGROUND
end

function ClientSpace:isTemple()
	local levelInfo = LevelData[self.sceneId] or {}

	return levelInfo.isTemple
end

function ClientSpace:isDittoSpace()
	return self.spaceType == Const.SPACE_TYPE_DITTO_DUNGEON
end

function ClientSpace:isSupportPetMode()
	return self.supportPetMode > 0
end

function ClientSpace:canEnterAfk()
	local type = self.spaceType

	return type == Const.SPACE_TYPE_TOWN or type == Const.SPACE_TYPE_SINGLEWORLD or type == Const.SPACE_TYPE_HOMELAND
end

function ClientSpace:getGameTime()
	return self.gameTime
end

function ClientSpace:syncGameTime(offset, gameTime, gameTimeScale)
	local delta = offset + gameTime - self.gameTime
	local absDelta = math.abs(delta)

	if absDelta > 1 then
		self.gameTime = offset + gameTime
	elseif absDelta > 0.2 then
		self.gameTimeDeltaCount = math.floor(1 / Time.unscaledDeltaTime)
		self.gameTimeDeltaScale = 1 + delta
	end

	if absDelta > 0.2 then
		self.gameTime = offset + gameTime

		self:correctLastTickTime(self.gameTime)
	end

	self:setGameTimeScale(gameTimeScale)
end

function ClientSpace:correctLastTickTime(gameTime)
	self.projLastTickTime = gameTime
	self.aiLastTickTime = gameTime
end

function ClientSpace:pauseGameByType(timeScaleType, maxPauseTime)
	if type(timeScaleType) ~= "number" then
		return
	end

	maxPauseTime = maxPauseTime or -1

	local oldPauseInfo = self.pauseData[timeScaleType]

	if oldPauseInfo and oldPauseInfo.timerId then
		self:removeTimer(oldPauseInfo.timerId)
	end

	local pauseInfo = {
		maxPauseTime = maxPauseTime,
		startTime = Time.secondCache,
		timeScaleType = timeScaleType
	}

	if maxPauseTime > 0 then
		pauseInfo.timerId = self:addTimer(maxPauseTime, function()
			self:resumeGameByType(timeScaleType)
		end)
	end

	self.pauseData[timeScaleType] = pauseInfo

	self:CheckAndSetGameTimeStatus()
end

function ClientSpace:resumeGameByType(timeScaleType)
	if type(timeScaleType) ~= "number" then
		return
	end

	local pauseInfo = self.pauseData[timeScaleType]

	if not pauseInfo then
		return
	end

	local timerId = pauseInfo.timerId

	if timerId then
		self:removeTimer(timerId)
	end

	self.pauseData[timeScaleType] = nil

	self:CheckAndSetGameTimeStatus()
end

function ClientSpace:refreshGameTimePauseByLevel()
	if next(self.levelGameTimePauseData) then
		self:pauseGameByType(Const.GameTimeScaleType.LEVEL_SCRIPT, -1)
	else
		self:resumeGameByType(Const.GameTimeScaleType.LEVEL_SCRIPT)
	end
end

function ClientSpace:pauseGameByLevel(pauseName, pauseTime)
	pauseName = pauseName or "Default"

	local oldPauseInfo = self.levelGameTimePauseData[pauseName]

	if oldPauseInfo and oldPauseInfo.timerId then
		self:removeTimer(oldPauseInfo.timerId)
	end

	local pauseInfo = {}

	self.levelGameTimePauseData[pauseName] = pauseInfo

	if type(pauseTime) == "number" and pauseTime > 0 then
		pauseInfo.timerId = self:addTimer(pauseTime, function()
			if self.levelGameTimePauseData[pauseName] ~= pauseInfo then
				return
			end

			self.levelGameTimePauseData[pauseName] = nil

			self:refreshGameTimePauseByLevel()
		end)
	end

	self:refreshGameTimePauseByLevel()
end

function ClientSpace:resumeGameByLevel(pauseName)
	pauseName = pauseName or "Default"

	local pauseInfo = self.levelGameTimePauseData[pauseName]

	if pauseInfo and pauseInfo.timerId then
		self:removeTimer(pauseInfo.timerId)
	end

	self.levelGameTimePauseData[pauseName] = nil

	self:refreshGameTimePauseByLevel()
end

function ClientSpace:clearGameTimePauseByLevel()
	for _, pauseInfo in pairs(self.levelGameTimePauseData) do
		if pauseInfo.timerId then
			self:removeTimer(pauseInfo.timerId)
		end
	end

	self.levelGameTimePauseData = {}

	local typePauseInfo = self.pauseData[Const.GameTimeScaleType.LEVEL_SCRIPT]

	if typePauseInfo and typePauseInfo.timerId then
		self:removeTimer(typePauseInfo.timerId)
	end

	self.pauseData[Const.GameTimeScaleType.LEVEL_SCRIPT] = nil
end

function ClientSpace:evaluateGameTimeStopStatus()
	local stopGameTime = false
	local timeScaleType = Const.GameTimeScaleType.DEFAULT
	local sourceUI
	local restoreUIByCutScene = false

	if not pg.game.dialogue:isPlayingDialogueGraph() and not pg.global.abilityMgr.isPlayingCutScene then
		for _, ui in ipairs(UIConst.StopGameTimeUI) do
			if pg.global.ui:checkGameTimeStopActive(ui) then
				stopGameTime = true
				timeScaleType = Const.GameTimeScaleType.UI
				sourceUI = ui
				restoreUIByCutScene = true

				break
			end
		end
	end

	if not stopGameTime and not Utils.tableIsEmptyOrNil(self.pauseData) then
		stopGameTime = true

		for _, pauseInfo in pairs(self.pauseData) do
			if pauseInfo.timeScaleType ~= nil and pauseInfo.timeScaleType ~= Const.GameTimeScaleType.DEFAULT then
				timeScaleType = pauseInfo.timeScaleType

				break
			end
		end
	end

	return stopGameTime, timeScaleType, sourceUI, restoreUIByCutScene
end

function ClientSpace:_addGameTimeScaleRequest(requests, timeScaleType, timeScale)
	if type(timeScaleType) ~= "number" or type(timeScale) ~= "number" or timeScale ~= timeScale or timeScale < 0 or timeScale > Const.GAME_TIME_SCALE_MAX_VALUE then
		return
	end

	local oldTimeScale = requests[timeScaleType]

	if oldTimeScale == nil or timeScale < oldTimeScale then
		requests[timeScaleType] = timeScale
	end
end

function ClientSpace:collectGameTimeScaleRequests(ignoreSuspensions)
	local requests = {}
	local dialogue = pg.game and pg.game.dialogue
	local abilityMgr = pg.global and pg.global.abilityMgr
	local uiManager = pg.global and pg.global.ui

	if dialogue and abilityMgr and uiManager and not dialogue:isPlayingDialogueGraph() and not abilityMgr.isPlayingCutScene then
		for _, ui in ipairs(UIConst.StopGameTimeUI) do
			if uiManager:checkGameTimeStopActive(ui) then
				self:_addGameTimeScaleRequest(requests, Const.GameTimeScaleType.UI, 0)

				break
			end
		end
	end

	for timeScaleType, _ in pairs(self.pauseData) do
		self:_addGameTimeScaleRequest(requests, timeScaleType, 0)
	end

	for timeScaleType, timeScale in pairs(self.explicitGameTimeScaleRequests) do
		self:_addGameTimeScaleRequest(requests, timeScaleType, timeScale)
	end

	if not ignoreSuspensions then
		for _, suspendedTypes in pairs(self.gameTimeScaleRequestSuspensions) do
			for timeScaleType, _ in pairs(suspendedTypes) do
				requests[timeScaleType] = nil
			end
		end
	end

	return requests
end

function ClientSpace:getEffectiveGameTimeScaleRequest(requests)
	local effectiveTimeScale
	local effectiveTimeScaleType = Const.GameTimeScaleType.DEFAULT

	for timeScaleType, timeScale in pairs(requests) do
		if effectiveTimeScale == nil or timeScale < effectiveTimeScale or timeScale == effectiveTimeScale and timeScaleType < effectiveTimeScaleType then
			effectiveTimeScale = timeScale
			effectiveTimeScaleType = timeScaleType
		end
	end

	return effectiveTimeScale or 1, effectiveTimeScaleType
end

function ClientSpace:suspendGameTimeScaleRequestsByType(ownerType, requests)
	if type(ownerType) ~= "number" then
		return
	end

	requests = requests or self:collectGameTimeScaleRequests(true)

	local suspendedTypes = {}

	for timeScaleType, _ in pairs(requests) do
		suspendedTypes[timeScaleType] = true
	end

	self.gameTimeScaleRequestSuspensions[ownerType] = suspendedTypes

	self:_syncGameTimeScaleRequest(false, false)
end

function ClientSpace:resumeGameTimeScaleRequestsByType(ownerType)
	if type(ownerType) ~= "number" or not self.gameTimeScaleRequestSuspensions[ownerType] then
		return
	end

	self.gameTimeScaleRequestSuspensions[ownerType] = nil

	self:_syncGameTimeScaleRequest(false, false)
end

function ClientSpace:CheckAndSetGameTimeStatus()
	local _, _, _, restoreUIByCutScene = self:evaluateGameTimeStopStatus()

	self:_syncGameTimeScaleRequest(false, false)

	if restoreUIByCutScene then
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CUTSCENE)
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.ULTIMATE)
	end
end

function ClientSpace:setGameTimeScale(gameTimeScale)
	if self.gameTimeScale ~= gameTimeScale then
		self.gameTimeScale = gameTimeScale

		self:onGameTimeScaleChange()
	end
end

function ClientSpace:startGameTime(timeScale, key)
	timeScale = math.min(timeScale or 1, 1)

	if self:isMultiPlayerEnv() then
		timeScale = 1
	end

	key = type(key) == "number" and key or Const.GameTimeScaleType.DEFAULT

	if timeScale == 1 then
		self.explicitGameTimeScaleRequests[key] = nil
	else
		self.explicitGameTimeScaleRequests[key] = timeScale
	end

	self:_syncGameTimeScaleRequest(false, false)
end

function ClientSpace:_isSameGameTimeScale(left, right)
	return math.abs((left or 1) - (right or 1)) < 0.0001
end

function ClientSpace:_syncGameTimeScaleRequest(forceSync, renewLease, serverGameTimeScale)
	if not pg or pg.space ~= self or not pg.me then
		return
	end

	local requests = self:collectGameTimeScaleRequests()
	local requestedTimeScale, requestedTimeScaleType = self:getEffectiveGameTimeScaleRequest(requests)

	if self:isMultiPlayerEnv() or pg.me:GM_OBSERVE_ST() then
		requestedTimeScale = 1
		requestedTimeScaleType = Const.GameTimeScaleType.DEFAULT
	end

	local localRequestChanged = not self:_isSameGameTimeScale(requestedTimeScale, self.lastRequestedGameTimeScale) or requestedTimeScaleType ~= self.lastRequestedGameTimeScaleType

	self.lastRequestedGameTimeScale = requestedTimeScale
	self.lastRequestedGameTimeScaleType = requestedTimeScaleType

	local serverRequestedTimeScale = self.requestedGameTimeScale or 1
	local requestDiverged = not self:_isSameGameTimeScale(requestedTimeScale, serverRequestedTimeScale)
	local actualDiverged = serverGameTimeScale ~= nil and not self:_isSameGameTimeScale(requestedTimeScale, serverGameTimeScale)

	if forceSync or localRequestChanged or requestDiverged or actualDiverged or renewLease and requestedTimeScale ~= 1 then
		pg.me:serverSpaceMsg("RPC_CS_SyncGameTimeScaleRequest", {
			phonestcore.getMillisecondUTC(),
			requestedTimeScale,
			requestedTimeScaleType
		})
	end

	self:setGameTimeScale(requestedTimeScale)
end

function ClientSpace:stopGameTime(timeScaleType, sourceUI)
	if self:isMultiPlayerEnv() or pg.me:GM_OBSERVE_ST() then
		return
	end

	timeScaleType = type(timeScaleType) == "number" and timeScaleType or Const.GameTimeScaleType.DEFAULT
	self.explicitGameTimeScaleRequests[timeScaleType] = 0

	self:_syncGameTimeScaleRequest(false, false)
end

function ClientSpace:RPC_SC_OnGameTimeScaleChange(gameTimeScale, serverTime, clientTime, gameTime)
	local now = phonestcore.getMillisecondUTC()
	local offset = now - clientTime

	Time.setServerDelta(serverTime - now)
	self:syncGameTime(offset / 2 / 1000, gameTime, gameTimeScale)
	self:_syncGameTimeScaleRequest(false, false, gameTimeScale)
end

function ClientSpace:onDungeonIdChanged(old, new)
	if self:isRogueEnv() or self:isBossRushEnv() then
		local sceneConfig = {}

		table.merge(sceneConfig, SceneData[self.sceneId] or {})

		sceneConfig.file = SceneUtils.getSceneName(sceneConfig.file or "")

		local voxelPath = SceneUtils.getVoxelPath(sceneConfig, self)

		pg.world.clearVoxelSpanState()
		pg.global.voxelMgr:ClearAllEffects()
		pg.game.voxel:updateVoxelPath(voxelPath)
	end
end

function ClientSpace:on_observerList_changed(oldVal, newVal)
	facade:sendMsgToUI(MessageName.ON_OBSERVE_NUM_CHANGED, newVal)
end

function ClientSpace:on_requestedGameTimeScale_changed(oldVal, newVal)
	self:_syncGameTimeScaleRequest(false, false)
end

function ClientSpace:onGameTimeScaleChange()
	if self.timeScaleMgr then
		self.timeScaleMgr:onGameTimeScaleChange()
	end

	if self.projectileMgr then
		self.projectileMgr:onGameTimeScaleChange()
	end
end

function ClientSpace:getGameTimeScaleTypeName(timeScaleType)
	for name, value in pairs(Const.GameTimeScaleType) do
		if value == timeScaleType then
			return name
		end
	end

	return "UNKNOWN"
end

function ClientSpace:collectGameTimeStopInfo()
	local _, _, verdictSourceUI = self:evaluateGameTimeStopStatus()
	local requests = self:collectGameTimeScaleRequests()
	local requestedTimeScale, verdictType = self:getEffectiveGameTimeScaleRequest(requests)
	local info = {
		gameTimeScale = self.gameTimeScale,
		serverRequestedGameTimeScale = self.requestedGameTimeScale or 1,
		requestedGameTimeScale = requestedTimeScale,
		leaseActive = requestedTimeScale ~= 1,
		lastStopType = self.lastRequestedGameTimeScaleType,
		lastStopTypeName = self:getGameTimeScaleTypeName(self.lastRequestedGameTimeScaleType),
		verdictShouldStop = requestedTimeScale == 0,
		verdictType = verdictType,
		verdictTypeName = self:getGameTimeScaleTypeName(verdictType),
		verdictSourceUI = verdictSourceUI,
		isPlayingDialogueGraph = pg.game.dialogue:isPlayingDialogueGraph() == true,
		isPlayingCutScene = pg.global.abilityMgr.isPlayingCutScene == true,
		isMultiPlayerEnv = self:isMultiPlayerEnv() == true,
		gmObserve = pg.me:GM_OBSERVE_ST() == true,
		pauseSources = {},
		levelPauseSources = {},
		uiSources = {}
	}

	info.diverged = not self:_isSameGameTimeScale(info.requestedGameTimeScale, info.serverRequestedGameTimeScale) or not self:_isSameGameTimeScale(info.requestedGameTimeScale, info.gameTimeScale)

	local now = Time.secondCache

	for timeScaleType, pauseInfo in pairs(self.pauseData) do
		table.insert(info.pauseSources, {
			timeScaleType = timeScaleType,
			timeScaleTypeName = self:getGameTimeScaleTypeName(timeScaleType),
			maxPauseTime = pauseInfo.maxPauseTime,
			heldSeconds = pauseInfo.startTime and now - pauseInfo.startTime or -1,
			hasTimeoutTimer = pauseInfo.timerId ~= nil
		})
	end

	for pauseName, pauseInfo in pairs(self.levelGameTimePauseData) do
		table.insert(info.levelPauseSources, {
			name = pauseName,
			hasTimeoutTimer = pauseInfo.timerId ~= nil
		})
	end

	for _, uid in ipairs(UIConst.StopGameTimeUI) do
		local uiInfo = pg.global.ui:collectGameTimeStopDebugInfo(uid)

		if uiInfo and (uiInfo.isOpen or uiInfo.shouldRefreshOnClose) then
			table.insert(info.uiSources, uiInfo)
		end
	end

	return info
end

function ClientSpace:dumpGameTimeStopInfo()
	local info = self:collectGameTimeStopInfo()
	local logger = self.logger

	logger:warn("========== game time stop info ==========")
	logger:warn(string.format("gameTimeScale=%s requested=%s serverRequested=%s leaseActive=%s diverged=%s", tostring(info.gameTimeScale), tostring(info.requestedGameTimeScale), tostring(info.serverRequestedGameTimeScale), tostring(info.leaseActive), tostring(info.diverged)))
	logger:warn(string.format("lastStop: type=%s(%s) sourceUI=%s", info.lastStopTypeName, tostring(info.lastStopType), tostring(info.lastStopSourceUI)))
	logger:warn(string.format("verdict now: shouldStop=%s type=%s(%s) sourceUI=%s", tostring(info.verdictShouldStop), info.verdictTypeName, tostring(info.verdictType), tostring(info.verdictSourceUI)))
	logger:warn(string.format("gates: dialogueGraph=%s cutScene=%s multiPlayer=%s gmObserve=%s", tostring(info.isPlayingDialogueGraph), tostring(info.isPlayingCutScene), tostring(info.isMultiPlayerEnv), tostring(info.gmObserve)))
	logger:warn(string.format("-- pause sources (%d) --", #info.pauseSources))

	for _, v in ipairs(info.pauseSources) do
		logger:warn(string.format("   type=%s(%s) held=%.1fs maxPauseTime=%s timeoutTimer=%s", v.timeScaleTypeName, tostring(v.timeScaleType), v.heldSeconds, tostring(v.maxPauseTime), tostring(v.hasTimeoutTimer)))
	end

	logger:warn(string.format("[dxk] -- level pause sources (%d) --", #info.levelPauseSources))

	for _, v in ipairs(info.levelPauseSources) do
		logger:warn(string.format("[dxk]    name=%s timeoutTimer=%s", tostring(v.name), tostring(v.hasTimeoutTimer)))
	end

	logger:warn(string.format("-- ui sources (%d, StopGameTimeUI total %d) --", #info.uiSources, #UIConst.StopGameTimeUI))

	for _, v in ipairs(info.uiSources) do
		logger:warn(string.format("   %s uid=%s module=%s res=%s isOpen=%s shouldRefreshOnClose=%s view=%s widget=%s closing=%s", v.active and "[ACTIVE]" or "[      ]", tostring(v.uid), tostring(v.module), tostring(v.resID), tostring(v.isOpen), tostring(v.shouldRefreshOnClose), tostring(v.hasView), tostring(v.widgetAlive), tostring(v.isClosing)))
	end

	logger:warn("=========================================")

	return info
end

function ClientSpace:init(createInfo)
	self.spaceType = createInfo.spaceType
	self.authorityId = createInfo.authorityId
	self.gameTime = createInfo.gameTime or 0
	self.logicTime = createInfo.logicTime
	self.multiPlayerEnv = ToBool(createInfo.multiPlayerEnv)
	self.spaceLoadingInfo = createInfo.spaceLoadingInfo
	self.logicTime = createInfo.logicTime or -1
	self.curPeriodIndex = createInfo.curPeriodIndex or -1
	pg.timePeriod = createInfo.timePeriod or Const.TimePeriod.Day

	ClientSpace.syncMultiplayerActiveToBridge(self.multiPlayerEnv)
	ClientSpace.super.init(self, createInfo)

	if self.gameTimeScaleRequestCheckTimer then
		self:removeTimer(self.gameTimeScaleRequestCheckTimer)
	end

	self.gameTimeScaleRequestCheckTimer = self:addRepeatTimer(Const.GAME_TIME_SCALE_REQUEST_CHECK_INTERVAL, function()
		self:_syncGameTimeScaleRequest(false, true)
	end)

	local sceneData = SceneData[self.sceneId]

	self.usePuppetElementResistProp = sceneData and sceneData.usePuppetElementResistProp == 1 or false

	if sceneData and sceneData.banEcs == true then
		pg.game.ecs:shutdownSync()
	else
		pg.game.ecs:initializeSync(createInfo.ecsFullState)
	end

	self.aiMgr:init(createInfo)

	self.abilityTimerMgr = AbilityTimerManager(self)

	for spawnerId, isValid in pairs(createInfo.spawnerNoticeIdMap) do
		if isValid then
			-- block empty
		end
	end

	self:_syncGameTimeScaleRequest(true, false)

	return true
end

function ClientSpace:tickClientTime()
	local deltaTime = Time.unscaledDeltaTime

	self.gameTime = self.gameTime + deltaTime * self.gameTimeScale

	self.timeScaleMgr:tick(deltaTime)
end

function ClientSpace:slowTtick()
	self:updateTile()
end

function ClientSpace:updateTile()
	if pg.pawn and not EnableBotTest then
		local pawnPos = pg.pawn:getPosition()
		local _, tileX, tileZ = Utils.getSpaceTile(self.sceneId, pawnPos.x, pawnPos.z)

		self:move(tileX, tileZ)
	end
end

function ClientSpace:start()
	ClientSpace.super.start(self)

	self.projLastTickTime = self:getGameTime()
	self.aiLastTickTime = self:getGameTime()

	if not EnableBotTest then
		self.slowUpdateTimer = self:addRepeatTimer(0.1, CallbackHandler(self, "slowTtick"))
	end

	local sceneInfo = SceneData[self.sceneId]
	local fixedDeltaTime = sceneInfo.accuratePhysics and 0.02 or 0.04

	if Utils.isRobEggSceneId(self.sceneId) then
		fixedDeltaTime = 0.02
	end

	pg.global.gameMgr:SetFixedDeltaTime(fixedDeltaTime)
end

function ClientSpace:RPC_SC_EcsUploadResult(uploadResult)
	pg.game.ecs:onUploadResult(uploadResult)
end

function ClientSpace:RPC_SC_EcsStateChanges(changes)
	pg.game.ecs:applyStateChanges(changes)
end

function ClientSpace:RPC_SC_EcsFullState(fullState)
	if not pg.game.ecs:applyFullState(fullState) then
		pg.game.ecs:requestFullSync()
	end
end

function ClientSpace:RPC_SC_EcsAuthorityChanged(message)
	pg.game.ecs:onAuthorityChange(message)
end

function ClientSpace:destroyManagers()
	self:clearGameTimePauseByLevel()

	if self.gameTimeScaleRequestCheckTimer then
		self:removeTimer(self.gameTimeScaleRequestCheckTimer)

		self.gameTimeScaleRequestCheckTimer = nil
	end

	if self.projectileMgrFrameId then
		TimerManager.delFrameCb(self.projectileMgrFrameId)

		self.projectileMgrFrameId = nil
	end

	if self.aiMgrFrameId then
		TimerManager.delFrameCb(self.aiMgrFrameId)

		self.aiMgrFrameId = nil
	end

	if self.tickTimer ~= nil then
		TimerManager.removeTimer(self.tickTimer)

		self.tickTimer = nil
	end

	if self.projectileMgr ~= nil then
		self.projectileMgr:destroy()

		self.projectileMgr = nil
	end

	if self.abilityTimerMgr then
		self.abilityTimerMgr:destroy()

		self.abilityTimerMgr = nil
	end

	if self.timeScaleMgr then
		self.timeScaleMgr:destroy()

		self.timeScaleMgr = nil
	end

	if self.aiMgr ~= nil then
		self.aiMgr:destroy()

		self.aiMgr = nil
	end
end

function ClientSpace:destroy()
	pg.game.ecs:shutdownSync()
	SafeCallback(self.destroyManagers, self)
	ClientSpace.super.destroy(self)
	pg.global.cameraMgr:ClearVolume()
	AIUtils.clearCache()
end

function ClientSpace:enterAbilityRuntimeDebugMode()
	if self.projectileMgr ~= nil then
		self.projectileMgr:destroy()

		self.projectileMgr = nil
	end

	if self.projectileMgrFrameId then
		TimerManager.delFrameCb(self.projectileMgrFrameId)

		self.projectileMgrFrameId = nil
	end

	self.projectileMgr = EditorProjectileManager(self, function()
		return EditorProjectile()
	end)
end

function ClientSpace:exitAbilityRuntimeDebugMode()
	if self.projectileMgr ~= nil then
		self.projectileMgr:destroy()

		self.projectileMgr = nil
	end

	if self.projectileMgrFrameId then
		TimerManager.delFrameCb(self.projectileMgrFrameId)

		self.projectileMgrFrameId = nil
	end

	self.projectileMgr = ProjectileManager(self, function()
		return ClientProjectile()
	end)
	self.projectileMgrFrameId = TimerManager.addRepeatNextFrameCb(function()
		local curTime = self:getGameTime()
		local deltaTime = curTime - self.projLastTickTime

		if deltaTime < 0 then
			self.projLastTickTime = curTime

			return
		end

		self.projectileMgr:tick(deltaTime)

		self.projLastTickTime = curTime
	end)
end

function ClientSpace:getEntityByStaticId(staticId)
	local entId = self.staticId2Id[staticId]

	if not entId then
		return nil
	end

	local ent = pg.getEntity(entId)

	return ent
end

function ClientSpace:getEntityIdByStaticId(staticId)
	return self.staticId2Id[staticId]
end

function ClientSpace:registerGlobalEntity(globalId, entity)
	self._globalId2Entity[globalId] = entity
end

function ClientSpace:unregisterGlobalEntity(globalId)
	self._globalId2Entity[globalId] = nil
end

function ClientSpace:getEntityByGlobalId(globalId)
	return self._globalId2Entity[globalId]
end

function ClientSpace:onEntityJoin(entity)
	local staticId = entity.staticId or 0

	if staticId ~= 0 then
		self.staticId2Id[staticId] = entity.id
	end

	self:registerGlobalEntity(entity:getGlobalId(), entity)
	EntityManager.eventEmitter:emit(EventConst.ENTITY_ENTER_SPACE, entity)
end

function ClientSpace:onEntityLeave(entity)
	EntityManager.eventEmitter:emit(EventConst.ENTITY_LEAVE_SPACE, entity)
	self:unregisterGlobalEntity(entity:getGlobalId(), entity)

	local staticId = entity.staticId or 0

	if staticId ~= 0 and self.staticId2Id[staticId] == entity.id then
		self.staticId2Id[staticId] = nil
	end
end

function ClientSpace:onLocalPlayerTeleportSpaceOut(player)
	return
end

function ClientSpace:isTrainStage()
	local sceneData = SceneData[self.sceneId] or {}

	return sceneData.IsTrainStage == 1
end

function ClientSpace:RPC_SC_ShowNoticeMessage(noticeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ShowNoticeMessage", noticeId)
	end

	pg.global.showBubbleMessage(noticeId)
end

function ClientSpace:RPC_SC_OnRefreshNoticeId(spawnerId, isValid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnRefreshNoticeId", spawnerId, isValid)
	end

	if isValid then
		-- block empty
	end
end

function ClientSpace:RPC_SC_SetMultiPlayerEnv(multiPlayerEnv)
	self.multiPlayerEnv = multiPlayerEnv

	ClientSpace.syncMultiplayerActiveToBridge(multiPlayerEnv)
	self:_syncGameTimeScaleRequest(false, false)

	if self.timeScaleMgr then
		self.timeScaleMgr:onMultiPlayerEnvChanged(multiPlayerEnv)
	end

	local entities = pg.global.entityMgr.getAllEntities()

	for _, ent in pairs(entities) do
		ent:postComponentMethod("onMultiPlayerEnvChanged", multiPlayerEnv)
	end
end

function ClientSpace:RPC_SC_AddTimeZone(timeZoneParams)
	if self.timeScaleMgr then
		self.timeScaleMgr:onSyncTimeZone(timeZoneParams)
	end
end

function ClientSpace:RPC_SC_RemoveTimeZone(zoneId)
	if self.timeScaleMgr then
		self.timeScaleMgr:removeTimeZone(zoneId)
	end
end

function ClientSpace:RPC_SC_OnSpaceAuthorityIdChanged(authorityId)
	self.authorityId = authorityId
end

function ClientSpace:remoteSyncAIAction(globalId, methodName, params)
	local ent = pg.getEntityByGlobalId(globalId)

	if ent and ent.authority == Const.AUTHORITY_MASTER then
		self:serverSpaceMsgNoGC("RPC_CS_RemoteSyncAIAction", globalId, methodName, params)
	end
end

function ClientSpace:RPC_SC_CallCustomEvent(entityId, eventName, params)
	local ent = pg.getEntity(entityId)

	if ent then
		ent:callCustomEvent(eventName, params)
	end
end

function ClientSpace:RPC_SC_RemoteSyncAIAction(globalId, methodName, params)
	local ent = pg.getEntityByGlobalId(globalId)

	if ent and ent.simulateAIAction and not Utils.checkIsAuthorityMaster(ent) then
		ent:simulateAIAction(methodName, params)
	end
end

function ClientSpace:RPC_SC_SpawnerLeaderInfo(entIds, leaderId, partnerIds)
	for _, entId in ipairs(entIds) do
		local ent = pg.getEntity(entId)

		if ent then
			ent.spawnerLeaderId = leaderId
			ent.spawnerPartnerIds = partnerIds
		end
	end
end

function ClientSpace:RPC_SC_ActArkCarnPutFireworks(playerId, dialogueIds)
	if pg.me.id == playerId then
		pg.game.event:playArkCarnDialogueGraph(dialogueIds[1])
	else
		pg.game.event:playArkCarnDialogueGraph(dialogueIds[2])
	end
end

function ClientSpace:RPC_SC_SpawnerDestroyFadeOut(loadedStaticIds)
	for staticId in pairs(loadedStaticIds) do
		local ent = self:getEntityByStaticId(staticId)

		if ent then
			ent.isFadeOut = true
		end
	end
end

function ClientSpace:checkHidePet()
	local spaceType = Utils.getSpaceType(self.sceneId)

	if Utils.isSpaceTown(spaceType) then
		return pg.game.setting:getHideTownPet()
	end

	return false
end

function ClientSpace:getCurDungeonId()
	local levelInfo = LevelData[self.sceneId] or {}

	return levelInfo.dungeonId
end

function ClientSpace:checkUsePrivateTime()
	local sceneInfo = SceneData[self.sceneId]

	return sceneInfo and sceneInfo.timeprivate == 1
end

function ClientSpace:checkImmuneFallDamage()
	local sceneInfo = SceneData[self.sceneId]

	return sceneInfo and sceneInfo.immuneFallDamage == 1 or false
end

function ClientSpace:checkSkipSkillCutScene()
	local sceneInfo = SceneData[self.sceneId]

	return sceneInfo and sceneInfo.skipSkillCutScene == 1 or false
end

function ClientSpace:isPhotoWorld()
	return lume.findInList(Const.PHOTO_WORLD_LIST, self.sceneId) ~= nil
end

function ClientSpace:isPhotoWorldOwner(uid)
	return self.photoWorldOwnerUid == uid
end

function ClientSpace:serverSpaceMsgNoGC(name, ...)
	lume.clear(paramCache)

	local callback
	local argLen = select("#", ...)

	if argLen > 0 then
		local final = select(argLen, ...)

		if type(final) == "function" then
			callback = final
			argLen = argLen - 1
		end
	end

	if argLen > 0 then
		for i = 1, argLen do
			paramCache[i] = select(i, ...)
		end
	end

	pg.me:serverSpaceMsg(name, paramCache, callback)
end

function ClientSpace:reliableServerSpaceMsg(name, params)
	pg.me:reliableServerSpaceMsg(name, params)
end

return ClientSpace
