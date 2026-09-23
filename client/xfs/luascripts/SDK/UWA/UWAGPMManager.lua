-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\UWA\\UWAGPMManager.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UWAGPMConfig = require("SDK.UWA.UWAGPMConfig")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("UWAGPMManager")
local UWAGPMBridge = CS.FunPlus.WorldX.SDK.UWAGPMBridge
local UWAGPMManager = Class.OldLightClass("UWAGPMManager", nil, true)
local _instance
local REGISTER_STATE = {
	NOT_REGISTERED = 0,
	TIMEOUT = 3,
	REGISTERING = 2,
	REGISTERED = 1
}

UWAGPMManager.REGISTER_STATE = REGISTER_STATE

function UWAGPMManager.getInstance()
	if _instance == nil then
		_instance = UWAGPMManager.new()
	end

	return _instance
end

function UWAGPMManager:ctor()
	self.isInitialized = false
	self.isDebugMode = UWAGPMConfig.debugMode and true or false
end

function UWAGPMManager.checkEnableSdk()
	if DISABLE_UWA_GPM then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("UWA GPM DISABLE_UWA_GPM true")
		end

		return false
	end

	if not UWAGPMBridge.IsEnableUwaGpm() then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("UWA GPM IsEnableUwaGpm false")
		end

		return
	end

	if UNITY_EDITOR then
		return true
	end

	return UNITY_OPENHARMONY or UNITY_ANDROID or UNITY_IOS or UNITY_STANDALONE
end

function UWAGPMManager:initialize()
	if not self:checkEnableSdk() then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("UWA GPM checkEnableSdk false")
		end

		return
	end

	if self.isInitialized then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("UWA GPM 已经初始化，跳过重复初始化")
		end

		return true
	end

	if not self:canInitialize() then
		return false
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("开始初始化 UWA GPM SDK...")
	end

	local url = UWAGPMConfig.url or ""
	local appID = self:getCurrentPlatform()
	local appVersion = tostring(ClientFullVersion or "")
	local channel = ClientConfigSDKChannelName or ""

	if UWAGPMConfig.enableCrashReport ~= nil then
		UWAGPMBridge.SetCrashReport(UWAGPMConfig.enableCrashReport)
	end

	local function onInitCallback(success)
		if success == true then
			self:onInitializeSuccess()
		else
			self:onInitializeFailed()
		end
	end

	UWAGPMBridge.StaticInit(url, appID, appVersion, channel, self.isDebugMode, onInitCallback)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("UWA GPM SDK 初始化调用完成 (AppID: %s, Channel: %s, Debug: %s)", appID, channel, tostring(self.isDebugMode))
	end

	return true
end

function UWAGPMManager:getDebugMode()
	return self.isDebugMode
end

function UWAGPMManager:setDebugMode(isDebugMode)
	self.isDebugMode = isDebugMode
	self.isInitialized = false

	self:initialize()
end

function UWAGPMManager:getCurrentPlatform()
	local platformMap = UWAGPMConfig.platformAppIDs or {}

	if UNITY_ANDROID then
		return platformMap.android or ""
	elseif UNITY_IOS then
		return platformMap.ios or ""
	elseif UNITY_OPENHARMONY then
		return platformMap.openharmony or ""
	elseif UNITY_STANDALONE or UNITY_EDITOR then
		return platformMap.standalone or ""
	end

	return ""
end

function UWAGPMManager:canInitialize()
	if UNITY_EDITOR and not UWAGPMConfig.enableInEditor then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("编辑器模式且未启用 enableInEditor，跳过 UWA GPM 初始化")
		end

		return false
	end

	local appID = self:getCurrentPlatform()

	if appID == nil or appID == "" then
		logger:error("UWA GPM AppID 未配置，无法初始化。请在 SDK/UWA/UWAGPMConfig.lua 中配置")

		return false
	end

	return true
end

function UWAGPMManager:onInitializeSuccess()
	self.isInitialized = true

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("✓ UWA GPM SDK 初始化成功")
	end

	self:startNetworkLatencyTimer()
	self:updateScene()
end

function UWAGPMManager:startNetworkLatencyTimer()
	if self.networkLatencyTimer then
		return
	end

	local interval = UWAGPMConfig.networkLatencyInterval or 10

	self.networkLatencyTimer = TimerManager.addRepeatTimer(interval, function()
		local playerTTL = ClientUtils.getPlayerTTLs()

		if playerTTL and playerTTL > 0 then
			self:setNetworkLatency(playerTTL / 1000000)
		end
	end)
end

function UWAGPMManager:stopNetworkLatencyTimer()
	if self.networkLatencyTimer then
		local TimerManager = require("Core.Timer.TimerManager")

		TimerManager.removeTimer(self.networkLatencyTimer)

		self.networkLatencyTimer = nil
	end
end

function UWAGPMManager:onInitializeFailed()
	self.isInitialized = false

	logger:error("UWA GPM SDK 初始化失败")
end

function UWAGPMManager:setUserInfo(userId, userLevel)
	self:setUserId(userId)
	self:setUserLevel(userLevel)
end

function UWAGPMManager:setUserId(userId)
	if not self.isInitialized then
		return
	end

	if not userId or userId == "" then
		return
	end

	UWAGPMBridge.SetUser(tostring(userId))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("设置用户 ID: %s", tostring(userId))
	end
end

function UWAGPMManager:setUserLevel(userLevel)
	if not self.isInitialized then
		return
	end

	if not userLevel then
		return
	end

	UWAGPMBridge.SetUserLevel(tostring(userLevel))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("设置用户等级: %s", tostring(userLevel))
	end
end

function UWAGPMManager:updateScene(sceneName)
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.ChangeScene(sceneName)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("切换场景: %s", sceneName)
	end
end

function UWAGPMManager:setQuality(quality)
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.SetQuality(quality)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("设置画质等级: %s", tostring(quality))
	end
end

function UWAGPMManager:addCustomEvent(eventName, eventCategory, params)
	if not self.isInitialized then
		return
	end

	if params == nil then
		UWAGPMBridge.AddCustomEvent(eventName, eventCategory)

		return
	end

	if type(params) ~= "table" then
		logger:warn("addCustomEvent 参数必须是 table 类型")

		return
	end

	local paramCount = #params

	if paramCount % 2 ~= 0 then
		logger:warn("addCustomEvent 参数必须成对，当前参数数量: %d", paramCount)

		return
	end

	if paramCount == 0 then
		UWAGPMBridge.AddCustomEvent(eventName, eventCategory)
	elseif paramCount == 2 then
		UWAGPMBridge.AddCustomEvent(eventName, eventCategory, params[1], params[2])
	elseif paramCount == 4 then
		UWAGPMBridge.AddCustomEvent(eventName, eventCategory, params[1], params[2], params[3], params[4])
	elseif paramCount == 6 then
		UWAGPMBridge.AddCustomEvent(eventName, eventCategory, params[1], params[2], params[3], params[4], params[5], params[6])
	else
		logger:warn("addCustomEvent 最多支持 3 个参数对，当前: %d 个参数", paramCount)
	end
end

function UWAGPMManager:beginSceneLoad(sceneName)
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.BeginSceneLoad(sceneName)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("开始场景加载: %s", sceneName)
	end
end

function UWAGPMManager:endSceneLoad()
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.EndSceneLoad()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("场景加载完成")
	end
end

function UWAGPMManager:beginDeepTracking()
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.BeginDeepTracking()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("开始深度追踪")
	end
end

function UWAGPMManager:endDeepTracking()
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.EndDeepTracking()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("结束深度追踪")
	end
end

function UWAGPMManager:addCrashCustomLogPaths(paths)
	if not self.isInitialized then
		return
	end

	if paths == nil or type(paths) ~= "table" or #paths == 0 then
		return
	end

	UWAGPMBridge.AddCrashCustomLogPaths(table.unpack(paths))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("添加 %d 个崩溃日志路径", #paths)
	end
end

function UWAGPMManager:addCrashAttachmentPaths(attachmentType, paths)
	if not self.isInitialized then
		return
	end

	if paths == nil or type(paths) ~= "table" or #paths == 0 then
		return
	end

	if attachmentType == "txt" then
		UWAGPMBridge.AddCrashAttachmentPathsText(table.unpack(paths))
	else
		UWAGPMBridge.AddCrashAttachmentPathsBinary(table.unpack(paths))
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("添加 %d 个崩溃附件路径 (类型: %s)", #paths, attachmentType)
	end
end

function UWAGPMManager:setNetworkLatency(latencyMs)
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.SetNetworkLatency(latencyMs)
end

function UWAGPMManager:getSDKData(metricType)
	if not self.isInitialized then
		return -1
	end

	return UWAGPMBridge.GetSDKData(metricType)
end

function UWAGPMManager:getRegisterState()
	if UWAGPMBridge == nil then
		return REGISTER_STATE.NOT_REGISTERED
	end

	return UWAGPMBridge.GetRegisterState()
end

function UWAGPMManager:setLogLevel(level)
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.SetLogLevel(level)
end

function UWAGPMManager:enableLog()
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.EnableLog()
end

function UWAGPMManager:disableLog()
	if not self.isInitialized then
		return
	end

	UWAGPMBridge.DisableLog()
end

function UWAGPMManager:getLogLevel()
	if not self.isInitialized then
		return 0
	end

	return UWAGPMBridge.GetLogLevel()
end

return UWAGPMManager
