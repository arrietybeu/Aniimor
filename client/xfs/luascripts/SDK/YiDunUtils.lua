-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\YiDunUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("YiDunUtils")
local json = require("json")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local YiDunUtils = {}

YiDunUtils.sdkEnableDecision = nil
YiDunUtils.sdkConfig = {
	gameKey = "7s9k2p5z8q4x6r1t3g7b9n2m5d1f8h3j",
	businessIdIOS = "661541461f9e0ef41f734394689e860e",
	businessIdWindows = "22dec3feaa4cfe2af5efe70faac4fe1a",
	businessIdAndroid = "543d24b6b13cfdc7859e647261f87adf",
	productId = "YD00650763029250"
}

local function isSupportedPlatform()
	if UNITY_ANDROID or UNITY_STANDALONE or UNITY_IOS then
		return true
	end

	logger:info("[YiDun] 当前平台不是 Android、iOS 或 Standalone，跳过易盾SDK调用")

	return false
end

local function isSDKManagerAvailable()
	if csSDKManager ~= nil then
		return true
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("[YiDun] SDKManager不存在，跳过易盾SDK调用")
	end

	return false
end

function YiDunUtils.getServerTypeByCountry()
	local country = ClientConfigAppCountry or "cn"

	if UNITY_ANDROID or UNITY_IOS then
		if country == "cn" then
			return 1
		elseif country == "tw" then
			return 2
		else
			return 3
		end
	elseif UNITY_STANDALONE then
		if country == "cn" then
			return 1
		elseif country == "tw" then
			return 3
		else
			return 2
		end
	end

	return 1
end

function YiDunUtils.getGameId()
	local country = ClientConfigAppCountry or "cn"

	if country == "cn" then
		return "worldx.cn.prod"
	else
		return "worldx.global.prod"
	end
end

function YiDunUtils.getChannelName()
	return ClientConfigSDKChannelName or ""
end

function YiDunUtils.getVersion()
	return tostring(ClientFullVersion or "0.0.1")
end

function YiDunUtils.getDefaultRoleInfo()
	local channel = YiDunUtils.getChannelName()
	local version = YiDunUtils.getVersion()
	local defaultRoleInfo = {
		roleAccount = "funplus",
		roleName = "WorldX",
		roleId = "888888",
		state = 0,
		roleLevel = 1,
		serverId = 1,
		roleServer = "default_server",
		gameVersion = version,
		assetVersion = version,
		gameId = YiDunUtils.getGameId(),
		pkgChannel = channel
	}

	return defaultRoleInfo
end

function YiDunUtils.checkEnableSdk()
	if YiDunUtils.sdkEnableDecision ~= nil then
		return YiDunUtils.sdkEnableDecision
	end

	if not ENABLE_YI_DUN_SDK then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("[YiDun] ENABLE_YI_DUN_SDK false")
		end

		YiDunUtils.sdkEnableDecision = false

		return false
	end

	YiDunUtils.sdkEnableDecision = ClientUtils.checkModuleGrayEnabled("YiDunSdk")

	if not isSupportedPlatform() then
		YiDunUtils.sdkEnableDecision = false

		return false
	end

	if not isSDKManagerAvailable() then
		YiDunUtils.sdkEnableDecision = false

		return false
	end

	return YiDunUtils.sdkEnableDecision
end

function YiDunUtils.initialize()
	if not YiDunUtils.checkEnableSdk() then
		return
	end

	local config = YiDunUtils.sdkConfig

	csSDKManager.YiDunSetConfig(config.productId, config.businessIdAndroid, config.businessIdWindows, config.businessIdIOS, config.gameKey)

	local defaultRoleInfo = YiDunUtils.getDefaultRoleInfo()
	local serverType = YiDunUtils.getServerTypeByCountry()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[YiDun] 开始初始化易盾SDK - serverType: %s, channel: %s", tostring(serverType), defaultRoleInfo.pkgChannel)
	end

	YiDunUtils.initSDK(serverType, defaultRoleInfo)
end

function YiDunUtils.initSDK(serverType, defaultRoleInfo)
	local initJson = json.encode({
		serverType = serverType,
		channel = defaultRoleInfo.pkgChannel
	})

	if UNITY_IOS then
		local function cbFunc()
			YiDunUtils.setRoleInfo(defaultRoleInfo)
		end

		csSDKManager.YiDunInitializeSDK(initJson, cbFunc)
	else
		csSDKManager.YiDunInitializeSDK(initJson)
		YiDunUtils.setRoleInfo(defaultRoleInfo)
	end
end

function YiDunUtils.setRoleInfo(roleInfo)
	if not YiDunUtils.checkEnableSdk() then
		return
	end

	roleInfo.state = 1
	roleInfo.gameVersion = YiDunUtils.getVersion()
	roleInfo.assetVersion = YiDunUtils.getVersion()
	roleInfo.pkgChannel = YiDunUtils.getChannelName()
	roleInfo.gameId = YiDunUtils.getGameId()

	if not roleInfo.roleAccount then
		roleInfo.roleAccount = pg.global.sdkManager:getAccountId()
	end

	local roleInfoJson = json.encode(roleInfo)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[YiDun] 设置角色信息: %s", roleInfoJson)
	end

	csSDKManager.YiDunSetRoleInfo(roleInfoJson)
end

function YiDunUtils.isInitialized()
	if csSDKManager == nil then
		return false
	end

	return csSDKManager.YiDunIsInitialized()
end

return YiDunUtils
