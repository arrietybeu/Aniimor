-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\Main.lua

local MessageName = require("Const.MessageName")
local GameApp = require("GameApp.Core.GameApp")
local ClientConst = require("Const.ClientConst")
local Client = require("Network.Client")
local Time = require("Core.Common.Time")
local GlobalData = require("Core.Client.GlobalData")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local AIUtils = require("Common.Utils.AIUtils")
local BehaviorXConst = require("Common.Const.BehaviorXConst")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local pg = pg
local _M = {}

local function OnLuaStartUpEnd()
	if not SDKLoginConfig.isEnabled() and pg.global.platform and pg.global.platform.initPlatformServices then
		pg.global.platform:initPlatformServices()
	end

	if pg.global.platform.shouldLoadPlatformBridge and pg.global.platform:shouldLoadPlatformBridge() then
		require("SDK.Platform.UIBridge.PlatformUIBridgeLoader")
	end

	if pg.global.platform.shouldLoadDiscordBridge and pg.global.platform:shouldLoadDiscordBridge() then
		require("SDK.Discord.UIBridge.DiscordUIBridgeLoader")
	end
end

function _M.main()
	pg.game = GameApp()

	pg.game:onGameStart()
	CS.FunPlus.WorldX.Utils.LuaUtils.RegisterLuaStartUp(OnLuaStartUpEnd)
end

function _M.updateTimeCache()
	Time.millisecondCache = Time.getMillisecondUTC()
	Time.secondCache = Time.millisecondCache * 0.001
	Time.realSecondCache = Time.getTickSecond()
end

function _M.updateTime(deltaTime, unscaledDeltaTime, time, unscaledTime, realtimeSinceStartup, frameCount, timeScale)
	Vector3.checkCache()

	Time.deltaTime = deltaTime
	Time.unscaledDeltaTime = unscaledDeltaTime
	Time.time = time
	Time.unscaledTime = unscaledTime
	Time.realtimeSinceStartup = realtimeSinceStartup
	Time.frameCount = frameCount
	Time.timeScale = timeScale
	Time.unityFrameCount = Time.frameCount
	Time.luaFrameCount = Time.luaFrameCount + 1

	if GlobalData.Space then
		GlobalData.Space:tickClientTime()
	end

	_M.updateTimeCache()
end

function _M.tick(deltaTime, unscaledDeltaTime, time, unscaledTime, realtimeSinceStartup, frameCount, timeScale)
	_M.updateTime(deltaTime, unscaledDeltaTime, time, unscaledTime, realtimeSinceStartup, frameCount, timeScale)
	Client.update()
end

function _M.beforeAnimation()
	pg.game:beforeAnimation()
end

function _M.getServerTime()
	return Time.secondCache
end

function _M.dispose()
	Client.dispose()
	AIUtils.destroyBehaviorXWorkSpace()
end

return _M
