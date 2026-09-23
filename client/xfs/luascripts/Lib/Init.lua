-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\Init.lua

if jit then
	if UNITY_PS5 then
		jit.off(true, true)
	else
		jit.off()
	end
end

if not UNITY_EDITOR and IS_MOBILE then
	collectgarbage("setpause", 150)
	collectgarbage("setstepmul", 200)
end

if TOOL_EDITOR then
	local EditorEnv = require("Utils.EditorEnv")

	EditorEnv.init()

	return
end

local MessageName = require("Const.MessageName")
local globalDeclare = require("Core.Framework.Global")

globalDeclare("pg")

pg = {}

globalDeclare("EnableBotTest")

EnableBotTest = false

local Client = require("Network.Client")

Client.preInit()

local WorldXEnv = require("Utils.WorldXEnv")

WorldXEnv.init()
WorldXEnv.posInit()
Client.init()

local ConsoleUtils = require("Utils.ConsoleUtils")

globalDeclare("ConsoleUtils", ConsoleUtils)

local CmdSocketBridge = require("GameApp.CmdSocket.CmdSocketBridge")

globalDeclare("CmdSocketBridge", CmdSocketBridge)

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerHelper = require("Common.LoggerHelper")
local suc, phonestcore = xpcall(require, debug.traceback, "phonestcore")

if not suc then
	error(phonestcore)
end

local level2Name = {
	[phonestcore.SPDLOG_LEVEL_TRACE] = "trace",
	[phonestcore.SPDLOG_LEVEL_DEBUG] = "debug",
	[phonestcore.SPDLOG_LEVEL_INFO] = "info",
	[phonestcore.SPDLOG_LEVEL_WARN] = "warning",
	[phonestcore.SPDLOG_LEVEL_ERROR] = "error",
	[phonestcore.SPDLOG_LEVEL_CRITICAL] = "critical"
}
local Time = require("Core.Common.Time")

local function loggerHook(level, msg)
	local levelStr = level and level2Name[level] or tostring(level)
	local realMsg

	if ClientConfigDebugMode then
		local timeStr = os.date("%Y-%m-%d %H:%M:%S", Time.secondCache)

		realMsg = string.format("[lua][%s][%s]%s", timeStr, levelStr, msg)
	else
		realMsg = string.format("[lua][%s]%s", levelStr, msg)
	end

	local len = #realMsg

	CS.FunPlus.WorldX.Utils.LuaUtils.LogForLua(level, realMsg, len)
end

LoggerManager.setHook(loggerHook)

local ClientAbilityManager = require("GameApp.Ability.ClientAbilityManager")

pg.global.abilityMgr = ClientAbilityManager()

local Events = require("Common.Container.Events")

pg.global.eventEmitter = Events.new()

if pg.global.sdkManager and pg.global.sdkManager.registerClientSwitchChangedListener then
	pg.global.sdkManager:registerClientSwitchChangedListener()
end

local cmd = {}
local isAllowedCloudSDKCallback = require("SDK.CloudSDKCallbackAllowList")

function cmd.isAllowedCloudSDKCallback(module, func)
	return isAllowedCloudSDKCallback(module, func)
end

function cmd.changeScene(sceneId)
	pg.global.scene:loadScene(sceneId)
end

function cmd.handleMove(x, y, z)
	pg.game.input:handleMoveEvent(x, y, z)
end

function cmd.handleInputDeviceChanged(deviceType)
	pg.game.input:onInputDeviceChanged(deviceType)
end

function cmd.onGamepadConnectionChanged()
	pg.game.input:onGamepadConnectionChanged()
end

function cmd.handleNoOperation()
	pg.global.ui:clearMemory()
end

function cmd.handleActionTriggered(inputInfo)
	if pg.game == nil or pg.game.input == nil then
		return true
	end

	return pg.game.input:handleActionTriggered(inputInfo)
end

function cmd.onActionTriggeredFinished(inputInfo, needPass)
	if pg.game == nil or pg.game.input == nil then
		return
	end

	pg.game.input:onActionTriggeredFinished(inputInfo, needPass)
end

function cmd.onEnableInputMap(mapName, enabled)
	if pg.game.input == nil then
		return
	end

	pg.game.input:onEnableInputMap(mapName, enabled)
end

function cmd.onLogin()
	pg.game:onLogin()
	Client.login()
	pg.global.ui:onLogin()

	local AIUtils = require("Common.Utils.AIUtils")

	AIUtils.initBehaviorXWorkSpace()
end

function cmd.onFocus(isFocus, fromApplicationPause)
	if pg.game ~= nil then
		pg.game:onAppFocus(isFocus, fromApplicationPause)
	end
end

function cmd.getCameraBlendTime(fromCameraMode, toCameraMode)
	local blendTime = -1

	if pg.game ~= nil then
		blendTime = pg.game.camera:getCameraBlendTime(fromCameraMode, toCameraMode)
	end

	return blendTime
end

function cmd.applyPuppetAppearance(modelInfo, puppetId, extraInfo)
	local ClientModelUtils = require("Utils.ClientModelUtils")

	ClientModelUtils.applyPuppetAppearance(modelInfo, puppetId, extraInfo)
end

function cmd.applyPetAppearance(modelInfo, petId, extraInfo)
	local ClientModelUtils = require("Utils.ClientModelUtils")

	if pg.game == nil or pg.game.controller == nil or pg.me == nil or pg.me:getCurPetEntity() == nil then
		ClientModelUtils.applyPetAppearance(modelInfo, petId, extraInfo)
	else
		local myCurPet = pg.me:getCurPetEntity()

		ClientModelUtils.applyPetAppearance(modelInfo, myCurPet.petInfo.templateId, {
			modelScale = myCurPet.petInfo.bornScale
		})
	end
end

function cmd.applyAvatarAppearance(modelInfo, curAvatarID, extraInfo)
	local ClientModelUtils = require("Utils.ClientModelUtils")

	ClientModelUtils.applyAvatarAppearance(modelInfo, curAvatarID, extraInfo)
end

function cmd.doEvent(eventId, context)
	if pg.me == nil then
		return
	end

	pg.me:doEvent(eventId, context)
end

function cmd.doEventByData(eventId, eventParam)
	if pg.me == nil then
		return
	end

	pg.me:doEventByData({
		eventId,
		eventParam
	}, {})
end

function cmd.onSDKInitCallback(result)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onSDKInitCallback(result)
end

function cmd.onScreenShotDetected()
	if pg.global == nil then
		return
	end

	facade:sendMsgToUI(MessageName.SCREENSHOT_DETECTED)
end

function cmd.onSDKLoginCallback(result, fpId, ticket, accountId, sessionKey, isNew, bindInfos)
	pg.global.sdkManager:onSDKLoginCallback(result, fpId, ticket, accountId, sessionKey, isNew, bindInfos)
end

function cmd.onPlatformAchievementAccountChanging()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onPlatformAchievementAccountChanging()
end

function cmd.onPlatformAchievementAccountReady()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onPlatformAchievementAccountReady()
end

function cmd.onSDKLoginGameCenterCallback(code, isAuth)
	pg.global.sdkManager:onSDKLoginGameCenterCallback(code, isAuth)
end

function cmd.onSDKGetSocialInfoCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKGetSocialInfoCallback(result)
	end
end

function cmd.onSDKRefreshSocialCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKRefreshSocialCallback(result)
	end
end

function cmd.onSDKFunStoreInitCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKFunStoreInitCallback(result)
	end
end

function cmd.onSDKFunStoreOpenCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKFunStoreOpenCallback(result)
	end
end

function cmd.onSDKWebViewClosedCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKWebViewClosedCallback(result)
	end
end

function cmd.onSDKQrcodeLoginCallback(result)
	if pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onSDKQrcodeLoginCallback(result)
	end
end

function cmd.onDiscordFriendsUpdated()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordFriendsUpdated()
end

function cmd.onDiscordStatusChanged(status, errorMessage, errorDetail)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordStatusChanged(status, errorMessage, errorDetail)
end

function cmd.onDiscordAuthorizationComplete(code, verifier, redirectUri)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordAuthorizationComplete(code, verifier, redirectUri)
end

function cmd.onDiscordAuthorizationFailed(errorMessage)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordAuthorizationFailed(errorMessage)
end

function cmd.onDiscordRichPresenceUpdated(success, errorMessage)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordRichPresenceUpdated(success, errorMessage)
end

function cmd.onDiscordInviteSent(success, targetUserId, errorMessage)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordInviteSent(success, targetUserId, errorMessage)
end

function cmd.onDiscordActivityJoin(joinSecret)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onDiscordActivityJoin(joinSecret)
end

function cmd.onSDKBindCallback(result, bindInfos)
	pg.global.sdkManager:onSDKBindCallback(result, bindInfos)
end

function cmd.onSDKUnbindCallback(result)
	pg.global.sdkManager:onSDKUnbindCallback(result)
end

function cmd.onSDKLogoutCallback(result)
	pg.global.sdkManager:onSDKLogoutCallback(result)
end

function cmd.onSDKFPXPayBuyCallBack(result, eventName, callbackResponseCode, callbackResponseMessage)
	pg.global.sdkManager:onSDKFPXPayBuyCallBack(result, eventName, callbackResponseCode, callbackResponseMessage)
end

function cmd.onSidebarFocusIn()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onSidebarFocusIn()
end

function cmd.onFeedStatusChange(status)
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onFeedStatusChange(status)
end

function cmd.onLaunchOptions(code, data)
	if pg.global == nil or pg.global.sdkManager == nil or not pg.global.sdkManager.onLaunchOptions then
		return
	end

	pg.global.sdkManager:onLaunchOptions(code, data)
end

function cmd.onClientIPInfo()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onClientIPInfo()
end

function cmd.onFuntapCheckUser()
	if pg.global == nil or pg.global.sdkManager == nil then
		return
	end

	pg.global.sdkManager:onFuntapCheckUser()
end

function cmd.onQuitGame()
	local SafeCallback = require("Core.Framework.SafeCallback")
	local ClientUtils = require("Utils.ClientUtils")
	local ClientCache = require("Entities.SpaceEntities.ClientCache")
	local AIUtils = require("Common.Utils.AIUtils")

	ClientCache.flushActive()
	AIUtils.destroyBehaviorXWorkSpace()
	pg.global.ui:closeAllUIPanel({})
	ClientUtils.destroyAll()
	SafeCallback(pg.game.onGameEnd, pg.game)
end

function cmd.onTriggerEnter(ownerId, userData)
	local owner = pg.getEntity(ownerId)

	if owner ~= nil then
		owner:onTriggerEnter(userData)
	end
end

function cmd.onTriggerExit(ownerId, userData)
	local owner = pg.getEntity(ownerId)

	if owner ~= nil then
		owner:onTriggerExit(userData)
	end
end

function cmd.addOncePerceptibility(staticId, increaseValue)
	local entity = pg.me.space:getEntityByStaticId(staticId)

	if entity then
		entity:addOncePerceptibility(pg.me.actorId, increaseValue)
	end
end

function cmd.levelHideAllUI(customKey, whiteList)
	pg.global.ui:levelHideAllUI(customKey, whiteList)
end

function cmd.levelRestoreAllUI(customKey)
	pg.global.ui:levelRestoreAllUI(customKey)
end

function cmd.tipsHideAllAreasWithFlag(flag, ignoreAreas)
	pg.global.ui:tipsHideAllAreasWithFlag(flag, ignoreAreas)
end

function cmd.tipsShowAllAreasWithFlag(flag)
	pg.global.ui:tipsShowAllAreasWithFlag(flag)
end

function cmd.levelSetHudSkillVisible(key, visible)
	key = key or "Default"

	local ClientConst = require("Const.ClientConst")

	pg.game:setModuleEnable("Level_" .. key, ClientConst.ModuleKey.Skill, visible)
end

function cmd.levelSetHudStatusVisible(key, visible)
	key = key or "Default"

	local ClientConst = require("Const.ClientConst")

	pg.game:setModuleEnable("Level_" .. key, ClientConst.ModuleKey.PetLink, visible)
end

function cmd.levelSetPetListVisible(key, visible)
	key = key or "Default"

	local ClientConst = require("Const.ClientConst")

	pg.game:setModuleEnable("Level_" .. key, ClientConst.ModuleKey.PetList, visible)
end

function cmd.pauseGameByLevel(pauseName, pauseTime)
	if pg.space then
		pg.space:pauseGameByLevel(pauseName, pauseTime)
	end
end

function cmd.resumeGameByLevel(pauseName)
	if pg.space then
		pg.space:resumeGameByLevel(pauseName)
	end
end

pg.cmd = cmd
