-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Network\\Client.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CommonRepo = require("Core.Common.CommonRepo")
local try = require("Core.Framework.Exception")
local ClientRepo = require("Core.Client.ClientRepo")
local GlobalData = require("Core.Client.GlobalData")
local Switch = require("Core.Common.Switch")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local _M = {
	sendDelta = 0.01,
	lastSendTime = 0
}

function _M.preInit()
	local globalDeclare = require("Core.Framework.Global")

	local function RegisterGlobal()
		globalDeclare("lfs")
		globalDeclare("cmsgpack")
	end

	RegisterGlobal()

	local PhonestEnv = require("Core.Net.PhonestEnv")

	PhonestEnv.setDebugMode(ClientConfigDebugMode)

	local ClientSwitch = require("Common.ClientSwitch")
	local luaLogLevel = ClientSwitch.ClientEnableDebugLog and "DEBUG" or "ERROR"

	PhonestEnv.init(luaLogLevel, true)

	local CSLogLevel = ClientSwitch.ClientEnableDebugLog and PhonestEnv.logLevel.DEBUG or PhonestEnv.logLevel.ERROR

	CS.FunPlus.WorldX.Utils.LuaUtils.SetLogLevel(CSLogLevel)

	if UNITY_EDITOR == false then
		Switch.ReadLuaData = false

		local BddDataMgr = require("Core.Framework.BddDataMgr")

		BddDataMgr.GetInstance():setDataPathHook(function()
			return CS.FunPlus.WorldX.Utils.LuaUtils.GetBinDataPath()
		end)
	else
		Switch.ReadLuaData = true
	end
end

function _M.init()
	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(1, "Lua2Login", 0, "")
	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(1, "LuaClientInit", 0, "")

	local conf = require("json").decode(CS.FunPlus.WorldX.Utils.LuaUtils.XFSReadFile(".\\LuaScripts\\Network\\conf.json"))

	if _G_IsDebugMode then
		local ok, userConf = pcall(function()
			return require("json").decode(CS.FunPlus.WorldX.Utils.LuaUtils.XFSReadFile(".\\LuaScripts\\Network\\conf.user.json"))
		end)

		if ok then
			for k, v in pairs(userConf) do
				conf[k] = v
			end

			print("================== conf.user.json parse success! ==================")
		end

		local ClientUtils = require("Utils.ClientUtils")

		ClientUtils.reviseForceConf(conf)
	end

	ClientRepo.confJson = conf

	assert(ClientRepo.confJson ~= nil, "json config load failed!")

	local ConfigParser = require("Core.Common.ConfigParser")

	ConfigParser.parseConfig("Config.Config")

	local EntityFactory = require("Core.Common.EntityFactory")
	local ProtoCodec = require("Core.Common.ProtoCodec")
	local Scheduler = require("Core.Net.Scheduler")
	local ClientRepo = require("Core.Client.ClientRepo")
	local NetHandler = require("Core.Client.NetHandler")
	local netHandler = NetHandler(ClientRepo.confJson)

	ClientRepo.netHandler = netHandler

	local loginAgent = EntityFactory.createEntity("LoginAgent")

	loginAgent:init()

	ClientRepo.loginAgent = loginAgent

	local networkEventCallback = EntityFactory.createEntity("NetworkEventCallback")

	ClientRepo.networkEventCallback = networkEventCallback

	local LoggerManager = require("Core.Log.LoggerManager")

	CommonRepo.logger = LoggerManager.getLogger("CommonRepo")

	function CommonRepo.protoc.ReadFileHookFunc(path)
		local text = CS.FunPlus.WorldX.Utils.LuaUtils.XFSReadFile(path)

		return text
	end

	CommonRepo.protoc:addpath("./LuaScripts/Core/Proto")
	CommonRepo.protoc:loadfile("common.proto")
	CommonRepo.protoc:loadfile("game_dbmanager.proto")

	local WorldXEnv = require("Utils.WorldXEnv")
	local ReloadScheduler = require("Core.Common.ReloadScheduler")

	CommonRepo.reloadScheduler = ReloadScheduler()

	local function preReloadHook(reloadType)
		CommonRepo.logger:info("pre reload")
	end

	CommonRepo.reloadScheduler:setPreReloadHook(preReloadHook)

	local function postReloadHook(reloadType, modNameList)
		CommonRepo.logger:info("post reload")
		WorldXEnv.postReload()
	end

	CommonRepo.reloadScheduler:setPostReloadHook(postReloadHook)

	if UNITY_EDITOR then
		CommonRepo.reloadScheduler:setReloadExceptionHook(function(result)
			appFacade.onReloadException(result)
		end)
	end

	local ProtobufConst = require("Core.Common.ProtobufConst")

	ProtobufConst.init()

	ClientRepo.protoCodec = ProtoCodec()

	local scheduler = Scheduler()

	if IS_MOBILE then
		scheduler:start(1)
	else
		scheduler:start()
	end

	CommonRepo.scheduler = scheduler

	function CommonRepo.exceptionFunc(ex)
		ClientRepo.networkEventCallback:onTraceback(ex)
	end

	networkEventCallback:regCallbacksTo(netHandler)
	netHandler:setConnectLogicWithKcp(false)

	local serviceType = require("Config.ServiceType")

	for k, v in pairs(serviceType or EMPTY_TABLE) do
		CommonRepo.serviceType[k] = v
	end

	local LatencyDetectManager = require("LatencyDetect.LatencyDetectManager")

	GlobalData.LatencyDetectManager = LatencyDetectManager.GetInstance()

	local DefaultServerManager = require("LatencyDetect.DefaultServerManager")

	GlobalData.DefaultServerManager = DefaultServerManager.GetInstance()

	GlobalData.DefaultServerManager:start()

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.prefetchServerList()

	local BILogger = require("SDK.BI.BILogger")

	GlobalData.BILogger = BILogger.GetInstance()

	if IS_MOBILE then
		_M.sendDelta = 0.06
	end

	_M.Time = require("Core.Common.Time")

	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(2, "LuaClientInit", 0, "")
end

function _M.login()
	if FREE_WALK then
		return
	end

	CommonRepo.logger:info("-------------- start login username:%s, serverIndex: %s ---------", GlobalData.UserName, GlobalData.ServerId)

	local ClientRepo = require("Core.Client.ClientRepo")
	local ClientUtils = require("Utils.ClientUtils")
	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.startPullServerList(true)

	if ClientRepo.msNetworkEventCallback == nil or not ClientRepo.msNetworkEventCallback:isConnected() then
		CommonRepo.logger:info("login but ms gate not connected for %s, %s", GlobalData.UserName, GlobalData.ServerId)
		ClientUtils.connectMsGate()

		return
	end

	ClientRepo.loginAgent:loginClick()
end

function _M.createLocalPlayerAndEnterScene(sceneId, onSceneLoaded, onPlayerModelRefreshed)
	FREE_WALK = true

	pg.cmd.onLogin()

	local SceneData = require("Data.scene_data")
	local SceneUtils = require("Common.Utils.SceneUtils")
	local ClientConst = require("Const.ClientConst")
	local sceneData = SceneData[sceneId]
	local bornTpId = sceneData.bornTpId
	local portalData = SceneUtils.getScenePortalData(sceneId)
	local pos = portalData[bornTpId] and portalData[bornTpId].markPosition
	local player = _M.createLocalPlayer(pos, sceneId, onPlayerModelRefreshed)

	player.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.GMMove, false)
	pg.game.loading:enterOfflineScene(sceneId, player, onSceneLoaded)
	_M.loadLocalPuppet(player, sceneId)
	_M.loadLocalOtherItem(sceneId, player)
end

function _M.createLocalPlayer(position, sceneId, onModelRefreshed)
	local EntityFactory = require("Core.Common.EntityFactory")
	local SafeCallback = require("Core.Framework.SafeCallback")
	local player = EntityFactory.createEntity("ClientOfflinePlayer", "10000")

	if onModelRefreshed and player.eventEmitter then
		local EventConst = require("Common.Const.EventConst")

		player.eventEmitter:onceEventListener(EventConst.ENTITY_MODEL_REFRESHED, onModelRefreshed)
	end

	local function initFun()
		player:init({
			yaw = 0,
			buffTag = 0,
			__Properties__ = {
				templateId = 3003,
				actorId = 1,
				spaceId = 1
			},
			position = position,
			sceneId = sceneId
		})

		GlobalData.Player = player

		local ActorManager = require("Core.Common.ActorManager")

		ActorManager.addEntity(player.actorId, player)
		player:postInit({})
		player:start()
		player:setInScene(true)
	end

	SafeCallback(initFun)
	EModelUtils.setAgentPosition(player, position)

	return player
end

function _M.loadLocalPuppet(player, sceneId)
	local SceneUtils = require("Common.Utils.SceneUtils")
	local PuppetData = require("Data.puppet_data")
	local CharacterStateConst = require("Common.Const.CharacterStateConst")
	local sceneEntityData = SceneUtils.getSceneEntityData(sceneId)
	local entityLoadNextActorId = 10001
	local entityLoadDataList = {}

	local function _getBornState(entityData)
		local hasBornState = false
		local motionState = CharacterStateConst.LOCOMOTION
		local puppetData = PuppetData[entityData.idInType]

		if puppetData ~= nil and puppetData.bornState then
			motionState = CharacterStateConst[puppetData.bornState]
		end

		if entityData.spawnerBornState then
			motionState = CharacterStateConst[entityData.spawnerBornState]
		end

		if puppetData ~= nil and puppetData.specialBornState then
			motionState = CharacterStateConst[puppetData.specialBornState]
			hasBornState = true
		end

		if entityData.spawnerSpecialBornState then
			motionState = CharacterStateConst[entityData.spawnerSpecialBornState]
			hasBornState = true
		end

		return hasBornState, motionState
	end

	for staticId, entityData in pairs(sceneEntityData) do
		table.insert(entityLoadDataList, {
			staticId = staticId,
			entityData = entityData
		})
	end

	local sqrEnterAoiRange = 3600
	local sqrLeaveAoiRange = 4900

	player.offlinePuppetActorIds = {}
	player.offlinePuppetTimer = TimerManager.addRepeatTimer(1, function()
		if player and player.offlineIsReady then
			local pos1 = player:getPosition()
			local pos2, dx, dz, inRange, outRange, actorId, prop, isShiny, hasBornState, motionState

			for _, loadData in ipairs(entityLoadDataList) do
				pos2 = loadData.entityData.position
				dx = pos2[1] - pos1[1]
				dz = pos2[3] - pos1[3]
				inRange = dx * dx + dz * dz < sqrEnterAoiRange
				outRange = dx * dx + dz * dz > sqrLeaveAoiRange

				if (not loadData.actorId or not pg.getEntityByActorId(loadData.actorId)) and inRange then
					actorId = entityLoadNextActorId
					isShiny = loadData.entityData.enable_shiny_rate and math.random(1, 100) <= loadData.entityData.shiny_rate * 100
					hasBornState, motionState = _getBornState(loadData.entityData)
					prop = {
						actorId = actorId,
						templateId = loadData.entityData.idInType,
						staticId = loadData.staticId,
						isShiny = isShiny,
						hasBornState = hasBornState,
						motionState = motionState
					}

					_M.createLocalPuppet(tostring(actorId), Vector3.New(pos2[1], pos2[2], pos2[3]), prop)

					loadData.actorId = actorId
					player.offlinePuppetActorIds[actorId] = true

					if player and player.registerOfflinePuppet then
						player:registerOfflinePuppet(loadData.staticId)
					end

					entityLoadNextActorId = entityLoadNextActorId + 1
				end

				if loadData.actorId and outRange then
					_M.destroyLocalPuppet(loadData.actorId)

					player.offlinePuppetActorIds[loadData.actorId] = nil
					loadData.actorId = nil
				end
			end
		end
	end)
end

function _M.createLocalPuppet(entityId, position, prop)
	local EntityFactory = require("Core.Common.EntityFactory")
	local SafeCallback = require("Core.Framework.SafeCallback")
	local puppet = EntityFactory.createEntity("ClientOfflinePuppet", entityId)

	local function initFun()
		puppet:init({
			buffTag = 0,
			yaw = 0,
			__Properties__ = prop,
			position = position
		})

		local ActorManager = require("Core.Common.ActorManager")

		ActorManager.addEntity(puppet.actorId, puppet)
		puppet:postInit({})
		puppet:start()
		puppet:setInScene(true)
	end

	SafeCallback(initFun)
	EModelUtils.setAgentPosition(puppet, position)

	return puppet
end

function _M.destroyLocalPuppet(actorId)
	if actorId == nil then
		return
	end

	local SafeCallback = require("Core.Framework.SafeCallback")
	local ActorManager = require("Core.Common.ActorManager")
	local puppet = ActorManager.getEntity(actorId)

	local function destroyFun()
		if puppet then
			ClientUtils.safeDestroy(puppet)
		end
	end

	SafeCallback(destroyFun)
end

function _M.loadLocalOtherItem(sceneId, player)
	player.offlineSandboxIds = {}

	local SceneUtils = require("Common.Utils.SceneUtils")
	local sceneSandboxData = SceneUtils.getSceneSandboxData(sceneId)

	for sandboxId, sandboxConf in pairs(sceneSandboxData) do
		if sandboxConf.levelItems and table.getCount(sandboxConf.levelItems) > 0 then
			local shell = appFacade.sandboxManager:CreateSandbox(sandboxId, sandboxConf.name)

			player.offlineSandboxIds[sandboxId] = true

			shell:Start()

			for levelItemId, levelItemConf in pairs(sandboxConf.levelItems) do
				local level_item_config_data = require("Data.level_item_config_data")
				local itemCfg = level_item_config_data[levelItemConf.configId]
				local levelItemType = require("GameApp.Sandbox." .. itemCfg.subType)
				local levelItem = levelItemType.new(nil, levelItemConf, {})
				local csItem = shell:CreateLevelItem(levelItemId)

				levelItem:bindShell(csItem)
				levelItem:setIsActive(true)
			end
		end
	end
end

function _M.update()
	local catch, _, statue, err = try(_M.poll)

	catch(_M.callback, statue, err)

	if _M.Time.realSecondCache - _M.lastSendTime >= _M.sendDelta then
		CommonRepo.scheduler:clientSendMessage()

		_M.lastSendTime = _M.Time.realSecondCache
	end
end

function _M.dispose()
	local debugger = require("Common.AI.Behaviac.Debugger")

	if debugger.lib then
		debugger.lib.finishDebugger()
	end

	if ClientRepo.networkEventCallback then
		ClientRepo.networkEventCallback:destroy()
	end

	if ClientRepo.msNetworkEventCallback then
		ClientRepo.msNetworkEventCallback:destroy()
	end

	CommonRepo.scheduler:stop()

	local phonestcore = require("phonestcore")

	phonestcore.enableTracyAutoInstrument(false)
end

function _M.poll()
	CommonRepo.scheduler:poll()
	CommonRepo.scheduler:tick()
end

function _M.callback(ex)
	ClientRepo.networkEventCallback:onTraceback(ex)
end

return _M
