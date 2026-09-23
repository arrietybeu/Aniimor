-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Core\\GameApp.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local ClientCache = require("Entities.SpaceEntities.ClientCache")
local InputSystem = require("GameApp.Input.InputSystem")
local LoadingSystem = require("GameApp.Loading.LoadingSystem")
local ResourceDownloadSystem = require("GameApp.ResourceDownload.ResourceDownloadSystem")
local CameraSystem = require("GameApp.Camera.CameraSystem")
local EffectSystem = require("GameApp.Effect.EffectSystem")
local CutsceneSystem = require("GameApp.Cutscene.CutsceneSystem")
local DialogueSystem = require("GameApp.DialogueGraph.DialogueSystem")
local TopLogoSystem = require("GameApp.TopLogo.TopLogoSystem")
local CommunicationSystem = require("GameApp.Communication.CommunicationSystem2")
local ControllerSystem = require("GameApp.Controller.ControllerSystem")
local AudioSystem = require("GameApp.Audio.AudioSystem")
local AvatarSystem = require("GameApp.Avatar.AvatarSystem")
local VoxelSystem = require("GameApp.Voxel.VoxelSystem")
local TimelineSystem = require("GameApp.Timeline.TimelineSystem")
local UISceneSystem = require("GameApp.UIScene.UISceneSystem")
local InteractionSystem = require("GameApp.Interaction.InteractionSystem")
local TrapEventSystem = require("GameApp.TrapEvent.TrapEventSystem")
local SpawnManageSystem = require("GameApp.Spawn.SpawnManageSystem")
local SettingSystem = require("GameApp.Setting.SettingSystem")
local EnvObjSystem = require("GameApp.EnvObj.EnvObjSystem")
local QuestSystem = require("GameApp.Quest.QuestSystem")
local TimerSystem = require("GameApp.Timer.TimerSystem")
local QteSystem = require("GameApp.Qte.QteSystem")
local PVPSystem = require("GameApp.PVP.PVPSystem")
local GrabEggSystem = require("GameApp.GrabEgg.GrabEggSystem")
local MapSystem = require("GameApp.Map.MapSystem")
local WeatherSystem = require("GameApp.Weather.WeatherSystem")
local EventSystem = require("GameApp.Event.EventSystem")
local MarkShareSystem = require("GameApp.MarkShare.MarkShareSystem")
local LeylineTreeSystem = require("GameApp.LeylineTree.LeylineTreeSystem")
local NavEffectSystem = require("GameApp.NavEffect.NavEffectSystem")
local SocialSystem = require("GameApp.Social.SocialSystem")
local QuizSystem = require("GameApp.Quiz.QuizSystem")
local PetBallSystem = require("GameApp.PetBall.PetBallSystem")
local ShopSystem = require("GameApp.Shop.ShopSystem")
local RechargeSystem = require("GameApp.Recharge.RechargeSystem")
local PetTransmogSystem = require("GameApp.PetTransmog.PetTransmogSystem")
local PetVariantSystem = require("GameApp.PetVariant.PetVariantSystem")
local MonthCardSystem = require("GameApp.MonthCard.MonthCardSystem")
local BindAccountSystem = require("GameApp.BindAccount.BindAccountSystem")
local RankSystem = require("GameApp.Rank.RankSystem")
local PerformanceSystem = require("GameApp.Performance.PerformanceSystem")
local ChatTriggerSystem = require("GameApp.Trigger.ChatTriggerSystem")
local GuideSystem = require("GameApp.Guide.GuideSystem")
local EvolutionSystem = require("GameApp.Evolution.EvolutionSystem")
local SoulEggEvolutionSystem = require("GameApp.Evolution.SoulEggEvolutionSystem")
local EntityCountSystem = require("GameApp.EntityCount.EntityCountSystem")
local SeamlessSystem = require("GameApp.Seamless.SeamlessSystem")
local ChallengeSystem = require("GameApp.Challenge.ChallengeSystem")
local HomeSystem = require("GameApp.Home.HomeSystem")
local HomeCarSystem = require("GameApp.Home.HomeCar.HomeCarSystem")
local TargetSystem = require("GameApp.Target.TargetSystem")
local EcsSystem = require("GameApp.Ecs.EcsSystem")
local MarqueeSystem = require("GameApp.Marquee.MarqueeSystem")
local InteractionSignSystem = require("GameApp.InteractionSign.InteractionSignSystem")
local SpeechSystem = require("GameApp.Speech.SpeechSystem")
local NpcDuelSystem = require("GameApp.NpcDuel.NpcDuelSystem")
local PetManageSystem = require("GameApp.PetManage.PetManageSystem")
local CmdSocketSystem = require("GameApp.CmdSocket.CmdSocketSystem")
local PlatformSystem = require("GameApp.Platform.PlatformSystem")
local SandboxSystem = require("GameApp.Sandbox.SandboxSystem")
local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")
local ClientUtils = require("Utils.ClientUtils")
local NetworkClient = require("Network.Client")
local FeedAvatar = require("GameApp.Feed.FeedAvatar")
local FeedWebView = require("GameApp.Feed.FeedWebView")
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local GlobalData = require("Core.Client.GlobalData")
local YiDunUtils = require("SDK.YiDunUtils")
local FEED_SCENE_ID = 3007
local FEED_REPORT_SCENE = 7001
local FEED_OFFLINE_REPORT_TIMEOUT = 30

require("GameApp.Chat.ImpChatFriend")
require("GameApp.Chat.ImpChatMail")
require("GameApp.Chat.ImpChatMessage")
require("GameApp.Chat.ImpChatTranslation")
require("GameApp.Chat.ImpChatTeam")
require("GameApp.WorldXGraph.Common.init")
require("GameApp.Controller.ImpControllerInput")
require("GameApp.Controller.ImpControllerSwitch")

local entityManager = appFacade.entityManager
local GameApp = Class.LightClass("GameApp")

local function isLoginGameState(gameApp)
	return gameApp.gameState == ClientConst.GS_CONNECT or gameApp.gameState == ClientConst.GS_LOGIN
end

local function isSelfInTeam()
	if pg.me and type(pg.me.isInTeam) == "function" then
		return pg.me:isInTeam() == true
	end

	return false
end

local function isMultiPlayerEnv()
	return pg.space and pg.space.isMultiPlayerEnv and pg.space:isMultiPlayerEnv() == true
end

local function shouldBeginPremiumFeatureSession(gameApp)
	return not isLoginGameState(gameApp) and (isMultiPlayerEnv() or isSelfInTeam())
end

local function shouldEndPremiumFeatureSession(gameApp)
	return isLoginGameState(gameApp) or not isMultiPlayerEnv() and not isSelfInTeam()
end

function GameApp:ctor()
	self.systemRefs = {}
	self.tickSystems = {}
	self.tickBeforeAnimationSystems = {}
	self.gameState = ClientConst.GS_NONE
	self.globalTimeScale = 1
	self.baseTimeScale = 1
	self.moduleDisableMap = {}
	self.isFocused = false
	self.isGameStartFinished = false
	self.feedScenePending = false
	self.feedSceneEnterStarted = false
end

function GameApp:setGameState(gameState)
	self.gameState = gameState
end

function GameApp:onGameStart()
	if ClientConfigCloudEnable ~= "true" then
		local UWAGPMManager = require("SDK.UWA.UWAGPMManager")

		pg.global.UWAGPMManager = UWAGPMManager.getInstance()

		pg.global.UWAGPMManager:initialize()
	end

	YiDunUtils.initialize()

	local clientGameFlowUtil = require("Utils.ClientGameFlowUtil")

	clientGameFlowUtil.initSystem()

	local clientResMgrUtil = require("Utils.ClientResMgrUtil")

	clientResMgrUtil.initSystem()

	local clientXPartUtil = require("Utils.ClientXPartUtil")

	clientXPartUtil.initSystem()
	self:setGameState(ClientConst.GS_START)
	self:ctorAllSystem()
	self:initAllSystem()

	self.tickId = TimerManager.addRepeatTimer(0, function()
		self:tick()
	end)

	pg.global.ui:init()
	self:onAppFocus(Application.isFocused)

	if IS_MOBILE then
		GlobalData.GamePlatform = "Phone"
	elseif pg.global.platform then
		if pg.global.platform:isXbox() then
			GlobalData.GamePlatform = "Xbox"
		elseif pg.global.platform:isPS() then
			GlobalData.GamePlatform = "PlayStation"
		end
	end

	local shouldEnterFeedScene = pg.global.sdkManager:getIsFeedScene()

	if not shouldEnterFeedScene and not FREE_WALK then
		self:loadLoginSceneWithErrorTip()
	end

	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(3, "LuaOnGameStart", 10, "")
	pg.global.resMgr:DebugDump(2004)

	self.isGameStartFinished = true

	if shouldEnterFeedScene or self.feedScenePending then
		self:tryEnterFeedScene("onGameStart")
	end

	pg.global.localHostMode = LocalHostMode

	if pg.global.localHostMode > 0 then
		GlobalData.BlockBindSoulClientNotMatch = true
	end
end

function GameApp:tryEnterFeedScene(source)
	if FREE_WALK or self.feedSceneEnterStarted then
		return true
	end

	if not pg.global.sdkManager:getIsFeedScene() then
		return false
	end

	if not self.isGameStartFinished then
		self.feedScenePending = true

		return true
	end

	self.feedScenePending = false
	self.feedSceneEnterStarted = true

	local ok, err = xpcall(function()
		self.setting:setVideoQuality(Const.VIDEO_QUALITY.TOP, false)

		if pg.global.scene and pg.global.scene.curScene then
			pg.global.scene:destroyCurrScene()
		end

		local feedPlayType = math.random(3)

		if feedPlayType == 1 then
			pg.global.scene:hideLoadingPanel()
			FeedAvatar.open()

			return
		end

		if feedPlayType == 2 then
			pg.global.scene:hideLoadingPanel()
			FeedWebView.open()

			return
		end

		self.feedOfflineSceneReported = false
		self.feedOfflineReportTimer = TimerManager.addTimer(FEED_OFFLINE_REPORT_TIMEOUT, function()
			self.feedOfflineReportTimer = nil

			self:reportFeedOfflineScene()
		end)

		NetworkClient.createLocalPlayerAndEnterScene(FEED_SCENE_ID, nil, function()
			self:reportFeedOfflineScene()
		end)
	end, debug.traceback)

	if not ok then
		self.feedSceneEnterStarted = false

		TimerManager.removeTimer(self.feedOfflineReportTimer)

		self.feedOfflineReportTimer = nil

		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), err, function()
			return
		end, true)
	end

	return ok
end

function GameApp:reportFeedOfflineScene()
	if self.feedOfflineSceneReported then
		return
	end

	self.feedOfflineSceneReported = true

	TimerManager.removeTimer(self.feedOfflineReportTimer)

	self.feedOfflineReportTimer = nil

	pg.global.sdkManager:reportScene(FEED_REPORT_SCENE)
end

function GameApp:resetRepeatTimer()
	if self.tickId then
		TimerManager.removeTimer(self.tickId)

		self.tickId = nil
	end

	self.tickId = TimerManager.addRepeatTimer(0, function()
		self:tick()
	end)
end

function GameApp:loadLoginSceneWithErrorTip()
	local ok, err = xpcall(function()
		pg.global.scene:loadScene(ClientConst.SCENE_LOGIN_ID)
	end, debug.traceback)

	if not ok then
		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("STARTUP_LOGIN_SCENE_FAILED"), function()
			return
		end, true)
	end
end

function GameApp:ctorAllSystem1()
	self.setting = SettingSystem("setting")

	self:addSystem(self.setting)
	require("Core.Common.ClientLODTickManager").init()

	self.input = InputSystem("input")

	self:addSystem(self.input, 0)

	self.loading = LoadingSystem("loading")

	self:addSystem(self.loading)

	self.resourceDownload = ResourceDownloadSystem("resourceDownload")

	self:addSystem(self.resourceDownload)

	self.controller = ControllerSystem("controller")

	self:addSystem(self.controller, 0)

	local controllerMeta = getmetatable(self.controller)
	local controllerVtbl = controllerMeta.__index

	setmetatable(self.controller, {
		__index = function(tbl, key)
			local ret = controllerVtbl[key]

			if ret or key == "me" or key == "pawn" then
				return ret
			end

			local curCtrl = rawget(tbl, "curController")

			if curCtrl then
				ret = curCtrl[key]

				if ret then
					return ret
				end
			end
		end
	})

	self.camera = CameraSystem("camera")

	self:addSystem(self.camera, 0)

	self.effect = EffectSystem("effect")

	self:addSystem(self.effect)

	self.cutscene = CutsceneSystem("cutscene")

	self:addSystem(self.cutscene)

	self.dialogue = DialogueSystem("dialogue")

	self:addSystem(self.dialogue, 1)

	self.topLogo = TopLogoSystem("topLogo")

	self:addSystem(self.topLogo, 0.05)

	self.communication = CommunicationSystem("communication")

	self:addSystem(self.communication)

	self.audio = AudioSystem("audio")

	self:addSystem(self.audio, 0.1)

	self.voxel = VoxelSystem("voxel")

	self:addSystem(self.voxel, 1)

	self.timeline = TimelineSystem("timeline")

	self:addSystem(self.timeline, 0)

	self.uiScene = UISceneSystem("uiScene")

	self:addSystem(self.uiScene, nil, true)

	self.interaction = InteractionSystem("interaction")

	self:addSystem(self.interaction, 0.3, true)

	self.spawnManage = SpawnManageSystem("spawnManage")

	self:addSystem(self.spawnManage, 0.3)

	self.entityCount = EntityCountSystem("EntityCount")

	self:addSystem(self.entityCount, 0.1)

	self.envObj = EnvObjSystem("envObj")

	self:addSystem(self.envObj, 0.5)

	self.trapEvent = TrapEventSystem("trapEvent")

	self:addSystem(self.trapEvent, 0.1)

	self.quest = QuestSystem("quest")

	self:addSystem(self.quest)

	self.timer = TimerSystem("timer")

	self:addSystem(self.timer, 0.01)

	self.target = TargetSystem("target")

	self:addSystem(self.target)

	self.qte = QteSystem("qte")

	self:addSystem(self.qte, 0.04)

	self.performance = PerformanceSystem("performance")

	self:addSystem(self.performance, 0.1)

	self.chatTrigger = ChatTriggerSystem("chatTrigger")

	self:addSystem(self.chatTrigger)
end

function GameApp:ctorAllSystem2()
	self.map = MapSystem("map")

	self:addSystem(self.map, 0.5)

	self.weather = WeatherSystem("weather")

	self:addSystem(self.weather)

	self.event = EventSystem("event")

	self:addSystem(self.event)

	self.markShare = MarkShareSystem("markShare")

	self:addSystem(self.markShare, 0.03)

	self.leylineTree = LeylineTreeSystem("leylineTree")

	self:addSystem(self.leylineTree)

	self.navEffect = NavEffectSystem("navEffect")

	self:addSystem(self.navEffect, 1)

	self.social = SocialSystem("social")

	self:addSystem(self.social, 0.1, true)

	self.quiz = QuizSystem("quiz")

	self:addSystem(self.quiz)

	self.petBall = PetBallSystem("petBall")

	self:addSystem(self.petBall)

	self.shop = ShopSystem("shop")

	self:addSystem(self.shop)

	self.recharge = RechargeSystem("recharge")

	self:addSystem(self.recharge)

	self.petTransmog = PetTransmogSystem("petTransmog")

	self:addSystem(self.petTransmog)

	self.petVariant = PetVariantSystem("petVariant")

	self:addSystem(self.petVariant)

	self.monthCard = MonthCardSystem("monthCard")

	self:addSystem(self.monthCard)

	self.bindAccount = BindAccountSystem("bindAccount")

	self:addSystem(self.bindAccount)

	self.rank = RankSystem("rank")

	self:addSystem(self.rank)

	self.pvp = PVPSystem("pvp")

	self:addSystem(self.pvp)

	self.grabEgg = GrabEggSystem("grabEgg")

	self:addSystem(self.grabEgg)

	self.guide = GuideSystem("guide")

	self:addSystem(self.guide)

	self.chat = ChatSystem("chat")

	self:addSystem(self.chat, 1)

	self.evolution = EvolutionSystem("evolution")

	self:addSystem(self.evolution)

	self.soulEggEvolution = SoulEggEvolutionSystem("soulEggEvolution")

	self:addSystem(self.soulEggEvolution, 0.1)

	self.avatar = AvatarSystem("avatar")

	self:addSystem(self.avatar, 0)

	self.seamless = SeamlessSystem("seamless")

	self:addSystem(self.seamless)

	self.challenge = ChallengeSystem("challenge")

	self:addSystem(self.challenge, 0.5)

	self.home = HomeSystem("home")

	self:addSystem(self.home, 0.1)

	self.homeCar = HomeCarSystem("homeCar")

	self:addSystem(self.homeCar, 0.1)

	self.ecs = EcsSystem("ecs")

	self:addSystem(self.ecs, 0.1)

	self.marquee = MarqueeSystem("marquee")

	self:addSystem(self.marquee, 1)

	self.interactionSignSystem = InteractionSignSystem("interactionSignSystem")

	self:addSystem(self.interactionSignSystem, InteractionSignSystem.DISTANCE_CHECK_INTERVAL)

	self.speech = SpeechSystem("speech")

	self:addSystem(self.speech, 5)

	self.npcDuel = NpcDuelSystem("npcDuel")

	self:addSystem(self.npcDuel)

	self.petManage = PetManageSystem("petManage")

	self:addSystem(self.petManage)

	self.cmdSocket = CmdSocketSystem("cmdSocket")

	self:addSystem(self.cmdSocket)

	self.platform = PlatformSystem("platform")

	self:addSystem(self.platform, 0.5)

	self.sandbox = SandboxSystem("sandbox")

	self:addSystem(self.sandbox)
end

function GameApp:ctorAllSystem()
	self:ctorAllSystem1()
	self:ctorAllSystem2()

	local _h = GameApp._platformHooks

	if _h and _h.ctorAllSystem then
		_h.ctorAllSystem(self)
	end
end

function GameApp:initAllSystem()
	for _, system in ipairs(self.systemRefs) do
		system:initSystem()
	end
end

function GameApp:addSystem(system, tickInterval, needOtherTick)
	self.systemRefs[#self.systemRefs + 1] = system

	system:onCtor()

	if tickInterval then
		self.tickSystems[#self.tickSystems + 1] = {
			nexTickTime = 0,
			interval = tickInterval,
			system = system
		}
	end

	if needOtherTick then
		self.tickBeforeAnimationSystems[#self.tickBeforeAnimationSystems + 1] = system
	end
end

function GameApp:tick()
	if EnableBotTest then
		return
	end

	local curSpace = pg.global.scene.curSpace
	local globalFreeze = 1
	local globalTimeScale = 1
	local gameTimeScale = 1
	local baseRatio = self.baseTimeScale

	if curSpace and curSpace.timeScaleMgr then
		globalFreeze = baseRatio * curSpace.timeScaleMgr:getGlobalFreeze()
		gameTimeScale = baseRatio * curSpace.gameTimeScale
		globalTimeScale = gameTimeScale * curSpace.timeScaleMgr:getTimeScale(nil)
	end

	if Time.timeScale ~= globalFreeze then
		Time.timeScale = globalFreeze
		UnityTime.timeScale = globalFreeze
	end

	if self.globalTimeScale ~= globalTimeScale then
		self.globalTimeScale = globalTimeScale

		facade:SendMessageCommand(MessageName.TIMESCALE_CHANGE, globalTimeScale)
		pg.global.gameMgr:SetTimeScale(globalTimeScale)
	end

	if self.uiTimeScale ~= gameTimeScale then
		self.uiTimeScale = gameTimeScale

		pg.global.gameMgr:SetUITimeScale(gameTimeScale)
	end

	self:tickAllSystem()
end

function GameApp:beforeAnimation()
	local systems = self.tickBeforeAnimationSystems
	local sampleOn = SampleUtils.sampleOn()

	for i = 1, #systems do
		local system = systems[i]

		if sampleOn then
			SampleUtils.beginSample(string.format("%s.beforeAnimation", system.name))
		end

		system:beforeAnimation()

		if sampleOn then
			SampleUtils.endSample()
		end
	end
end

function GameApp:tickAllSystem()
	local now = Time.realSecondCache
	local tickSystems = self.tickSystems
	local sampleOn = SampleUtils.sampleOn()

	for i = 1, #tickSystems do
		local tickInfo = tickSystems[i]
		local nexTickTime = tickInfo.nexTickTime

		if nexTickTime <= now then
			local system = tickInfo.system

			tickInfo.nexTickTime = now + tickInfo.interval

			if sampleOn then
				SampleUtils.beginSample(tostring(system.name))
			end

			system:tick()

			if sampleOn then
				SampleUtils.endSample()
			end
		end
	end
end

function GameApp:onGameEnd()
	ClientCache.flushActive()

	if self.tickId then
		TimerManager.removeTimer(self.tickId)

		self.tickId = nil
	end

	self.tickSystems = {}
	self.tickBeforeAnimationSystems = {}

	self:setGameState(ClientConst.GS_NONE)

	local toDel = {}

	for i = #self.systemRefs, 1, -1 do
		local system = self.systemRefs[i]

		toDel[#toDel + 1] = system:getName()

		system:destroy()
	end

	for _, systemName in ipairs(toDel) do
		self[systemName] = nil
	end

	self.systemRefs = {}

	pg.global.prefsCacheUtils:save()
end

function GameApp:onClear()
	self:clearModuleDisableMap()

	for i = #self.systemRefs, 1, -1 do
		local system = self.systemRefs[i]

		ClientUtils.tryWithLogError(function()
			system:clear()
		end)
	end
end

function GameApp:onLogin()
	appFacade.EnterGame()
	self:setGameState(ClientConst.GS_LOGIN)

	for _, system in ipairs(self.systemRefs) do
		system:onLogin()
	end
end

function GameApp:onBackToLogin()
	appFacade.ExitGame()
	self:setGameState(ClientConst.GS_CONNECT)

	for _, system in ipairs(self.systemRefs) do
		system:onBackToLogin()
	end

	PetJewelryOssCache.reset()
	self:onClear()
end

function GameApp:onConnected()
	self:setGameState(ClientConst.GS_PLAYGAME)

	if pg.me then
		pg.me:resendReliableServerSpaceMsgs()
	end

	for _, system in ipairs(self.systemRefs) do
		system:onConnected()
	end
end

function GameApp:onDisconnected()
	ClientCache.flushActive()
	self:setGameState(ClientConst.GS_DISCONNECT)

	for _, system in ipairs(self.systemRefs) do
		system:onDisconnected()
	end
end

function GameApp:onMemoryWarning()
	for _, system in ipairs(self.systemRefs) do
		system:onMemoryWarning()
	end
end

function GameApp:onPlayerInit(player)
	self:setGameState(ClientConst.GS_PLAYGAME)

	for _, system in ipairs(self.systemRefs) do
		system:onPlayerInit(player)
	end

	facade:sendMsgToUI(MessageName.PLAYER_INIT)
end

function GameApp:onPlayerDestroy(player)
	for _, system in ipairs(self.systemRefs) do
		system:onPlayerDestroy(player)
	end

	facade:sendMsgToUI(MessageName.PLAYER_DESTROY)
end

function GameApp:onWorldSceneDestroy(sceneId)
	for _, system in ipairs(self.systemRefs) do
		system:onWorldSceneDestroy(sceneId)
	end
end

function GameApp:onStartLoadScene(sceneId, sceneName)
	pg.global.gameMgr:OnStartLoadScene(sceneId, sceneName)
end

function GameApp:onSpaceCreated(space)
	for _, system in ipairs(self.systemRefs) do
		system:onSpaceCreated(space)
	end
end

function GameApp:onSpaceDestroy(space)
	for _, system in ipairs(self.systemRefs) do
		system:onSpaceDestroy(space)
	end
end

function GameApp:onSceneLoaded(sceneId, sceneName)
	pg.global.gameMgr:OnSceneLoaded(sceneId, sceneName)

	if FREE_WALK then
		return
	end

	if pg.me and pg.me.space then
		pg.me:playRougeSceneScan(false)
		pg.me:playBossRushSceneScan(false)
	end

	local entities = pg.getEntities()

	if pg.me and pg.me.space ~= nil and pg.me.setInScene then
		ClientUtils.tryWithLogError(function()
			pg.me:setInScene(true)
		end)
	end

	if pg.me and pg.me.space then
		ClientUtils.tryWithLogError(function()
			pg.me.space:onSceneLoaded()
		end)
	end

	for _, ent in pairs(entities) do
		if ent ~= pg.me and ent.space ~= nil and ent.setInScene then
			ClientUtils.tryWithLogError(function()
				ent:setInScene(true)
			end)
		end
	end

	for _, system in ipairs(self.systemRefs) do
		ClientUtils.tryWithLogError(function()
			system:onSceneLoaded(sceneId, sceneName)
		end)
	end

	facade:sendMsgToUI(MessageName.SCENE_LOADED)
	self:notifyServerSceneLoaded(sceneId)

	if pg.me then
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_IN_TIME_WEATHER_BLOCK)
	end
end

function GameApp:notifyServerSceneLoaded(sceneId)
	if pg.me then
		local pos3 = pg.me:getPosition()

		pg.me:serverMsg("RPC_CS_ClientLoadSceneEnd", sceneId, {
			pos3.x,
			pos3.y,
			pos3.z
		})
	end
end

function GameApp:onSceneUnloaded(sceneId, sceneName)
	pg.global.resMgr:ClearCache()
	pg.global.gameMgr:OnSceneUnloaded(sceneId, sceneName)

	for _, system in ipairs(self.systemRefs) do
		system:onSceneUnloaded(sceneId, sceneName)
	end

	if pg.me and pg.me.space then
		ClientUtils.tryWithLogError(function()
			pg.me.space:onSceneUnloaded()
		end)
	end

	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.space ~= nil and ent.setInScene then
			ClientUtils.tryWithLogError(function()
				ent:setInScene(false)
			end)
		end
	end

	facade:sendMsgToUI(MessageName.SCENE_UNLOAD)
end

function GameApp:onStartReloadScene(sceneId, sceneName)
	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.space ~= nil and ent.setInScene then
			xpcall(ent.setInScene, debug.traceback, ent, false)
		end
	end

	facade:SendMessageCommand(MessageName.RELOAD_CURRENT_SCENE)

	if pg.me and pg.me.onSceneStartReload then
		pg.me:onSceneStartReload()
	end
end

function GameApp:onEndReloadScene()
	if pg.me and pg.me.onSceneEndReload then
		pg.me:onSceneEndReload()
	end
end

function GameApp:onSceneReset(sceneId, sceneName, extraInfo)
	for _, system in ipairs(self.systemRefs) do
		system:onSceneReset(sceneId, sceneName, extraInfo)
	end

	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.space ~= nil and ent.setInScene then
			ent:setInScene(true, true, extraInfo)
		end
	end

	facade:sendMsgToUI(MessageName.SCENE_LOADED)
end

function GameApp:onAppFocus(focus, fromApplicationPause)
	self.isFocused = focus

	if not focus then
		local player = GlobalData.Player

		if player ~= nil then
			ClientUtils.tryWithLogError(function()
				ClientCache.flush(player)
			end)
		end
	end

	if self.input then
		self.input:onAppFocusChanged(focus)
	end

	if self.audio then
		self.audio:onAppFocusChanged(focus, fromApplicationPause)
	end

	local _h = GameApp._platformHooks

	if _h and _h.onAppFocus then
		_h.onAppFocus(self, focus)
	end
end

function GameApp:EVENT_PostReload()
	for _, system in ipairs(self.systemRefs) do
		if system.EVENT_PostReload then
			system:EVENT_PostReload()
		end
	end
end

function GameApp:onTimePeriodChange(period)
	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent.onTimePeriodChange then
			ent:onTimePeriodChange()
		end

		if ent.onTimePeriodChangeAITrigger then
			ent:onTimePeriodChangeAITrigger(period)
		end
	end

	pg.global.gameMgr:SetTimePeriod(period)
	pg.game.audio:onTimePeriodChange(period)

	if pg.me then
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_IN_TIME_WEATHER_BLOCK)
	end
end

function GameApp:onPlayerEnterScene()
	if shouldBeginPremiumFeatureSession(self) then
		PlatformPremiumFeatureService:beginSession("cross_play", function()
			return true
		end, 0)
	end

	for _, system in ipairs(self.systemRefs) do
		if system.onPlayerEnterScene then
			system:onPlayerEnterScene()
		end
	end
end

function GameApp:onPlayerLeaveScene()
	if shouldEndPremiumFeatureSession(self) then
		PlatformPremiumFeatureService:endSession(function()
			return true
		end, 0)
	end

	for _, system in ipairs(self.systemRefs) do
		if system.onPlayerLeaveScene then
			system:onPlayerLeaveScene()
		end
	end
end

function GameApp:checkModuleEnable(moduleKey)
	local disableInfo = self.moduleDisableMap[moduleKey]

	if Utils.tableIsEmptyOrNil(disableInfo) then
		return true
	end

	return false
end

function GameApp:clearModuleDisableMap()
	for moduleKey, disableInfo in pairs(self.moduleDisableMap) do
		self:clearModuleDisable(moduleKey)
	end
end

function GameApp:clearModuleDisable(moduleKey)
	if string.isNilOrEmpty(moduleKey) then
		return
	end

	local oldModuleEnable = self:checkModuleEnable(moduleKey)

	self.moduleDisableMap[moduleKey] = {}

	local moduleEnable = self:checkModuleEnable(moduleKey)

	if oldModuleEnable ~= moduleEnable then
		facade:SendMessageCommand(MessageName.MODULE_ENABLE_CHANGED, {
			moduleKey = moduleKey,
			enable = moduleEnable
		})
	end
end

function GameApp:setModuleEnable(reasonKey, moduleKey, enable)
	if string.isNilOrEmpty(moduleKey) then
		return
	end

	reasonKey = reasonKey or "Default"

	local oldModuleEnable = self:checkModuleEnable(moduleKey)
	local disableInfo = self.moduleDisableMap[moduleKey] or {}

	if enable then
		disableInfo[reasonKey] = nil
	else
		disableInfo[reasonKey] = true
	end

	self.moduleDisableMap[moduleKey] = disableInfo

	local moduleEnable = self:checkModuleEnable(moduleKey)

	if oldModuleEnable ~= moduleEnable then
		facade:SendMessageCommand(MessageName.MODULE_ENABLE_CHANGED, {
			moduleKey = moduleKey,
			enable = moduleEnable
		})
	end
end

function GameApp:setPetVisibleInLevel(visible, isAllPet)
	if visible then
		self.hidePetInfo = nil
	else
		self.hidePetInfo = {
			visible,
			isAllPet
		}
	end

	local entities = pg.getEntities()

	for _, ent in pairs(entities) do
		if ent and Utils.isPet(ent) then
			ent:refreshVisible()
		end
	end
end

function GameApp:getPetVisible(petEnt)
	if petEnt then
		if self.hidePetInfo then
			if self.hidePetInfo[2] then
				return false
			elseif petEnt.isMainPet then
				return false
			end
		end

		return true
	end

	return false
end

function GameApp:onEntityCreated(entity)
	if entity.eModel then
		entityManager:OnEntityCreated(entity.eModel)
	end
end

return GameApp
