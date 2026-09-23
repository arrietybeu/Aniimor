-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Setting\\SettingSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local bit = require("bit")
local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local logger = LoggerManager.getLogger("SettingSystem")
local AudioConst = require("Const.AudioConst")
local ClientConst = require("Const.ClientConst")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local SettingFuncListData = require("Data.setting_func_list_data")
local SystemLanguageMapData = require("Data.system_language_map_data")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local SettingConst = require("Const.SettingConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local VideoSettingData = require("Data.video_setting_data")
local VideoSettingMap = require("Data.video_setting_map")
local DeviceVideoOverride = require("GameApp.Setting.DeviceVideoOverride")
local ConsoleVideoResolutionData = require("Data.console_video_resolution_data")
local json = require("json")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local GlobalData = require("Core.Client.GlobalData")
local SysConfigData = require("Data.sys_config_data")
local GM_SPECIAL_VIDEO_SETTING_TYPES = {
	transparentInOnePass = "bool",
	postTaa5TapSharpen = "bool",
	transparentInIndependentPass = "bool"
}
local SettingSystem = Class.LightClass("SettingSystem", SystemBase)
local CLOUD_GAME_VIDEO_QUALITY = Const.VIDEO_QUALITY.MID
local CLOUD_GAME_TARGET_FRAMERATE = 45
local CLOUD_GAME_STREAMING_MIPMAPS_MEMORY_BUDGET = 896
local CLOUD_GAME_STREAMING_MIPMAPS_RENDERERS_PER_FRAME = 128
local ENTITY_MIN_LOD_TYPES = {
	"Player",
	"Puppet",
	"EnvObject",
	"Pet",
	"SimpleMoveNpc",
	"StaticNpc"
}
local PERFORMANCE_QUERY_HOST_CN = "worldx-office-api.yimo.com"
local PERFORMANCE_QUERY_HOST = "worldx-office-api.aniimo.com"
local PERFORMANCE_QUERY_STAGE_HOST_CN = "worldx-office-api-stage.yimo.com"
local PERFORMANCE_QUERY_STAGE_HOST = "worldx-office-api-stage.aniimo.com"
local PERFORMANCE_QUERY_PATH = "/api/performance/external/score"
local PERFORMANCE_QUERY_TIMEOUT_MS = 10000
local PERFORMANCE_QUERY_HEADERS = {
	Authorization = "Bearer 4d66ede0e5dd0ba50e0ff4a1980fc31dr3kr0ZtpCZp",
	["Content-Type"] = "application/json",
	Accept = "*/*"
}
local LARGE_SCREEN_MODE_KEY = "largeScreenMode"
local LARGE_SCREEN_MODE_MIN_SHORT_SIDE = 1600
local large_foldable_patterns = {
	"galaxy%s+z%s*fold",
	"galaxy%s+z%s*trifold",
	"samsung%s+galaxy%s+z%s*fold",
	"samsung%s+galaxy%s+z%s*trifold",
	"samsung%s+w%d+",
	"huawei%s+mate%s*x",
	"honor%s+magic%s*v",
	"honor%s+v%s*purse",
	"oppo%s+find%s*n",
	"oneplus%s+open",
	"xiaomi%s+mix%s*fold",
	"mi%s+mix%s*fold",
	"vivo%s+x%s*fold",
	"google%s+pixel%s+fold",
	"google%s+pixel%s+%d+%s*pro%s*fold",
	"motorola%s+razr%s*fold",
	"tecno%s+phantom%s*v%s*fold",
	"royole%s+flexpai"
}

local function maybe_large_foldable_phone(model_name)
	if model_name == nil or model_name == "" then
		return false
	end

	local name = tostring(model_name):lower()

	for _, pattern in ipairs(large_foldable_patterns) do
		if name:find(pattern) then
			return true
		end
	end

	return false
end

local function getScreenShortSide()
	local width = 0
	local height = 0
	local success = pcall(function()
		local display = CS.UnityEngine.Display.main

		width = tonumber(display.systemWidth) or 0
		height = tonumber(display.systemHeight) or 0
	end)

	if not success or width <= 0 or height <= 0 then
		width = tonumber(CS.UnityEngine.Screen.width) or 0
		height = tonumber(CS.UnityEngine.Screen.height) or 0
	end

	if width <= 0 or height <= 0 then
		return 0
	end

	return math.min(width, height)
end

local CLOUD_GAME_ANTIALIASING = "DeepLearningSuperSampling"
local CLOUD_GAME_DLSS_MODE_BALANCED = 2
local CLOUD_GAME_SHADOW_QUALITY_MEDIUM = 2
local CLOUD_GAME_GLOBAL_ILLUMINATION_LOW = 2
local CLOUD_GAME_REFLECTION_QUALITY_MEDIUM = 1
local CLOUD_GAME_AMBIENT_OCCLUSION_QUALITY_MEDIUM = 1
local PERFORMANCE_QUERY_HOST_CN = "worldx-office-api.yimo.com"
local PERFORMANCE_QUERY_HOST = "worldx-office-api.aniimo.com"
local PERFORMANCE_QUERY_PATH = "/api/performance/external/score"
local PERFORMANCE_QUERY_TIMEOUT_MS = 10000
local PERFORMANCE_QUERY_HEADERS = {
	Authorization = "Bearer 4d66ede0e5dd0ba50e0ff4a1980fc31dr3kr0ZtpCZp",
	["Content-Type"] = "application/json",
	Accept = "*/*"
}

function SettingSystem:onInit()
	self.curPlatform = CS.FunPlus.WorldX.Setting.VideoSetting.GetCurrentPlatform()

	if self.curPlatform == "Editor" then
		if UNITY_OPENHARMONY then
			self.curPlatform = "OpenHarmony"
		elseif UNITY_EDITOR_OSX then
			self.curPlatform = "IOS"
		elseif UNITY_GAMECORE or UNITY_XBOXPC then
			self.curPlatform = "XBOX"
		elseif UNITY_PS4 or UNITY_PS5 then
			self.curPlatform = "PS5"
		elseif ClientConfigPublishPlatform == "steam" then
			self.curPlatform = "Steam"
		else
			self.curPlatform = "Windows"
		end
	end

	logger:info("curPlatform" .. self.curPlatform)

	self.curPlatformId = ClientConst.Platforms[self.curPlatform]
	self.cacheSettings = {}

	self:resetSetting()

	self.useTopLogoCache = true
	self.vitalityEnabled = false
	self.enableHitCameraShake = true
	self.showSettingPackDownload = false

	self:setLuaTickFrameInterval()
	self:queryLuaTickFrameInterval()
end

function SettingSystem:setLuaTickFrameInterval()
	local GmToolUtils = CS.FunPlus.WorldX.Utils.GmToolUtils

	if self:isMobileRenderPlatform() then
		GmToolUtils.SetLuaTickFrameInterval(2)
	elseif self:isConsolePlatform() then
		GmToolUtils.SetLuaTickFrameInterval(1)
	end
end

function SettingSystem:queryLuaTickFrameInterval()
	local GmToolUtils = CS.FunPlus.WorldX.Utils.GmToolUtils

	self.luaTickFrameInterval = GmToolUtils.GetLuaTickFrameInterval()
end

function SettingSystem:getLuaTickFrameInterval()
	return self.luaTickFrameInterval
end

function SettingSystem:resetSetting()
	self.aiHelperStrength = nil
	self.resolutionScaleUserModified = nil
	self.resolutionScaleValue = nil
	self.largeScreenModeUserModified = nil
	self.largeScreenModeValue = nil
	self.largeScreenModeAutoValue = nil

	self:initAudioVolume()
	self:initVideoSetting()
	self:initPlayableLog()
	self:initLanguage()
	self:initAntialiasingSetting()
	self:initVSync()
	self:initTargetFramerate()
	self:initFrameGeneration()
	self:applyCloudGamePerformanceSettings()
	ClientSettingUtils.applyWorldCameraColorGrading()

	self.showDebugId = self:getBool(ClientConst.PrefKey.ShowDebugId, false)
	self.hideGuide = self:getBool(ClientConst.PrefKey.HideGuide, false)
	self.showDebugText = self:getBool(ClientConst.PrefKey.ShowDebugInfo, false)
	self.showDebugTextSimple = self:getBool(ClientConst.PrefKey.ShowDebugInfoSimple, false)
	self.enableGamepadDebugCapture = self:getBool(ClientConst.PrefKey.GamepadDebugCapture, false)

	self:initGamepadNavDebug()

	self.hideTownPet = self:getBool(ClientConst.PrefKey.HideTownPet, false)
	self.hideSkillType = self:getBool(ClientConst.PrefKey.HideSkillType, false)
	self.hideAllHudArrowType = self:getBool(ClientConst.PrefKey.HideAllHudArrowType, false)
	self.bloodTypeCache = nil
end

function SettingSystem:applyCloudGamePerformanceSettings()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self:setVideoQuality(CLOUD_GAME_VIDEO_QUALITY, false)

	if self:isEntityCountSettingReady() then
		ClientSettingUtils.applyRelationValue(ClientConst.SettingFuncType.VideoQuality, Const.VIDEO_QUALITY.LOW, false)
	end
end

function SettingSystem:applyCloudGameFramePacingSettings()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	local framePacingUserModified = self:isCloudGameFramePacingUserModified()
	local vSyncCount = framePacingUserModified and self:getInt(ClientConst.PrefKey.VSync, 0) or 0
	local targetFramerate = framePacingUserModified and self:getInt(ClientConst.PrefKey.TargetFramerate, CLOUD_GAME_TARGET_FRAMERATE) or CLOUD_GAME_TARGET_FRAMERATE

	self:setVSync(vSyncCount, true)
	self:setTargetFramerate(targetFramerate, true)
end

function SettingSystem:applyCloudGameQualityOverrides()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self:setVSync(0, true)
	self:setTargetFramerate(CLOUD_GAME_TARGET_FRAMERATE, true)

	local CsVideoSetting = CS.FunPlus.WorldX and CS.FunPlus.WorldX.Setting and CS.FunPlus.WorldX.Setting.VideoSetting

	if CsVideoSetting and CsVideoSetting.SetStreamingMipmapsRenderersPerFrame then
		CsVideoSetting.SetStreamingMipmapsRenderersPerFrame(CLOUD_GAME_STREAMING_MIPMAPS_RENDERERS_PER_FRAME)
	else
		logger:error("applyCloudGameQualityOverrides: VideoSetting.SetStreamingMipmapsRenderersPerFrame not found")
	end
end

function SettingSystem:isCloudGameFramePacingUserModified()
	return ClientConfigCloudEnable == "true" and self:getBool(ClientConst.PrefKey.CloudGameFramePacingUserModified, false)
end

function SettingSystem:markCloudGamePerformanceSettingUserModified(funcType)
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	if funcType == ClientConst.SettingFuncType.VSync or funcType == ClientConst.SettingFuncType.TargetFramerate then
		self.gmVSyncCount = nil

		self:setBool(ClientConst.PrefKey.CloudGameFramePacingUserModified, true)
	end
end

function SettingSystem:resetCloudGamePerformanceSettingUserModified()
	self.pendingPlayerVideoQualityRelation = nil

	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self.gmVSyncCount = nil

	self:setBool(ClientConst.PrefKey.CloudGameFramePacingUserModified, false)
	self:applyCloudGamePerformanceSettings()
end

function SettingSystem:applyPlayerVideoQualityRelation(videoQuality)
	if not self:isEntityCountSettingReady() then
		self.pendingPlayerVideoQualityRelation = videoQuality

		return
	end

	ClientSettingUtils.applyRelationValue(ClientConst.SettingFuncType.VideoQuality, videoQuality, false)

	self.pendingPlayerVideoQualityRelation = nil
end

function SettingSystem:applyPendingPlayerVideoQualityRelation()
	if self.pendingPlayerVideoQualityRelation == nil or not self:isEntityCountSettingReady() then
		return
	end

	self:applyPlayerVideoQualityRelation(self.pendingPlayerVideoQualityRelation)
end

function SettingSystem:onSceneLoaded(sceneId, sceneName)
	local animationQuality = self.pendingAnimationQuality or self:getAnimationQuality()

	if ClientSettingUtils.apply_animationQuality(animationQuality) then
		self.pendingAnimationQuality = nil
	end
end

function SettingSystem:initAfterLogin()
	if self:checkNeedGetVideoLevelFromServer() then
		-- block empty
	end

	self:initEntityCountSetting()
	self:applyPendingPlayerVideoQualityRelation()

	local _h = SettingSystem._platformHooks

	if _h and _h.trySyncCrossPlatformToServer then
		_h.trySyncCrossPlatformToServer(self)
	end

	if self:isMobileRenderPlatform() then
		self:applyMobileFramerate()
	end

	self:applyCloudGamePerformanceSettings()
end

function SettingSystem:getDefaultSettingValue(funcType, funcParam)
	return ClientSettingUtils.getDefaultSettingValue(funcType, funcParam)
end

function SettingSystem:getSettingRelationValue(func, param, key)
	return ClientSettingUtils.getSettingRelationValue(func, param, key)
end

function SettingSystem:setUIDKey(uid)
	local newUID = uid .. "_"

	if newUID == self.uidKey then
		return
	end

	self.uidKey = newUID
	self.pendingPlayerVideoQualityRelation = nil
	self.entityCountSettingUIDKey = nil

	pg.global.prefsCacheUtils:setString(ClientConst.PrefKey.SettingKey, self:getUIDKey())
	self:resetSetting()
end

function SettingSystem:syncConsolePlatformUserKey(platformUserId)
	if not pg.global.platform:isConsoleFamily() then
		return false
	end

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	self:setUIDKey(tostring(platformUserId))

	return true
end

function SettingSystem:getUIDKey()
	if not self.uidKey then
		local lastUIDKey = pg.global.prefsCacheUtils:getString(ClientConst.PrefKey.SettingKey, "CBT2_")

		self.uidKey = lastUIDKey
	end

	return self.uidKey
end

function SettingSystem:getString(key, defaultValue)
	return pg.global.prefsCacheUtils:getString(self:getUIDKey() .. key, defaultValue)
end

function SettingSystem:setString(key, value)
	return pg.global.prefsCacheUtils:setString(self:getUIDKey() .. key, value)
end

function SettingSystem:setStringImmediately(key, value)
	return pg.global.prefsCacheUtils:setStringImmediately(self:getUIDKey() .. key, value)
end

function SettingSystem:getFloat(key, defaultValue)
	return pg.global.prefsCacheUtils:getFloat(self:getUIDKey() .. key, defaultValue)
end

function SettingSystem:setFloat(key, value)
	return pg.global.prefsCacheUtils:setFloat(self:getUIDKey() .. key, value)
end

function SettingSystem:getBool(key, defaultValue)
	return pg.global.prefsCacheUtils:getBool(self:getUIDKey() .. key, defaultValue)
end

function SettingSystem:setBool(key, value)
	return pg.global.prefsCacheUtils:setBool(self:getUIDKey() .. key, value)
end

function SettingSystem:setBoolImmediately(key, value)
	return pg.global.prefsCacheUtils:setBoolImmediately(self:getUIDKey() .. key, value)
end

function SettingSystem:getInt(key, defaultValue)
	return pg.global.prefsCacheUtils:getInt(self:getUIDKey() .. key, defaultValue)
end

function SettingSystem:setInt(key, value)
	return pg.global.prefsCacheUtils:setInt(self:getUIDKey() .. key, value)
end

function SettingSystem:initLanguage()
	local language
	local languageType = self:getString(ClientConst.PrefKey.Language)

	if ClientConfigAppCountry == "cn" then
		languageType = ClientConst.LANGUAGE_TYPE_MAP.zh_CN
		language = ClientConst.LANGUAGE_TYPE_DESC_MAP[languageType]

		pg.global.prefsCacheUtils:setBoolImmediately(ClientConst.PrefKey.LanguageSelectionConfirmed, true)
	elseif not string.isNilOrEmpty(languageType) then
		languageType = tonumber(languageType)
		language = ClientConst.LANGUAGE_TYPE_DESC_MAP[languageType]
	else
		local systemLanguage = CS.UnityEngine.Application.systemLanguage
		local systemLanguageConfig = SystemLanguageMapData[systemLanguage:ToString()]

		if systemLanguageConfig then
			languageType = systemLanguageConfig.gameLanguage
			language = ClientConst.LANGUAGE_TYPE_DESC_MAP[languageType]
		end

		if language == nil then
			languageType = ClientConst.LANGUAGE_TYPE_MAP.en
			language = ClientConst.LANGUAGE_TYPE_DESC_MAP[languageType]

			if ClientConfigDefaultLang ~= "" then
				for i, v in pairs(ClientConst.LANGUAGE_TYPE_DESC_MAP) do
					if v == ClientConfigDefaultLang then
						languageType = i
						language = v
					end
				end
			end
		end
	end

	self:setLanguage(language)
	pg.game.audio:initAudioLanguage()
	pg.game.audio:initLoseFocusAudio()
end

function SettingSystem:setLanguage(language)
	local languageType = ClientConst.LANGUAGE_TYPE_MAP[language]

	self.language = language
	pg.languageType = languageType
	GlobalData.Language = language
	pg.global.localizationMgr.SelectedLanguage = languageType

	self:setStringImmediately(ClientConst.PrefKey.Language, languageType)
	pg.global.uiMgr:SetDialogueTextStepLen(languageType == ClientConst.LANGUAGE_TYPE_MAP.en and 2 or 1)
	pg.global.sdkManager:setLanguage(languageType)

	if pg.me then
		pg.me:serverMsg("RPC_CS_SetLanguage", language)
	end
end

function SettingSystem:getLanguage()
	return self.language or ClientConst.LANGUAGE_TYPE_DESC_MAP[0]
end

function SettingSystem:getLanguageType()
	return pg.languageType or 0
end

function SettingSystem:initAudioVolume()
	for _, volumeKey in pairs(AudioConst.VolumeType) do
		local volume = self:getVolume(volumeKey)

		pg.game.audio:setVolume(volumeKey, volume)
	end

	self:_refreshVideoVolume()
end

function SettingSystem:getVolume(volumeKey)
	local nilValue = -10
	local volume = self:getFloat(volumeKey, nilValue)

	if volume == nilValue then
		local defaultValue = self:getDefaultSettingValue(AudioConst.VolumeType2SetFunc[volumeKey])

		volume = tonumber(defaultValue)

		self:setFloat(volumeKey, volume)
	end

	return volume
end

function SettingSystem:setVolume(volumeKey, volume)
	self:setFloat(volumeKey, volume)
	pg.game.audio:setVolume(volumeKey, volume)

	if pg.me and pg.me:isInSpeechChannel(pg.me.uid) then
		pg.global.gmeManager:SetSpeakerVolume(self:getTeamVol())
	end

	self:_refreshVideoVolume()
end

function SettingSystem:getSkillAutoLock()
	return self:getBool(ClientConst.PrefKey.SkillAutoLock, true)
end

function SettingSystem:setSkillAutoLock(autoLock)
	return self:setBool(ClientConst.PrefKey.SkillAutoLock, autoLock)
end

function SettingSystem:getAiHelperStrength()
	if self.aiHelperStrength ~= nil then
		return self.aiHelperStrength
	end

	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.AIHelperStrength)

	self.aiHelperStrength = self:getInt(ClientConst.PrefKey.AIHELPERStrength, defaultValue)

	return self.aiHelperStrength
end

function SettingSystem:setAiHelperStrength(value)
	self.aiHelperStrength = value

	return self:setInt(ClientConst.PrefKey.AIHELPERStrength, value)
end

function SettingSystem:getAttackForceLock()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AttackForceLock)

	return self:getBool(ClientConst.PrefKey.AttackForceLock, ToBool(defaultValue))
end

function SettingSystem:setAttackForceLock(value)
	return self:setBool(ClientConst.PrefKey.AttackForceLock, ToBool(value))
end

function SettingSystem:getAutoCast()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AutoCast)

	return self:getBool(ClientConst.PrefKey.AutoCast, ToBool(defaultValue))
end

function SettingSystem:setAutoCast(value)
	return self:setBool(ClientConst.PrefKey.AutoCast, ToBool(value))
end

function SettingSystem:getAutoAcceptSpaceFollowRequire()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AutoAcceptSpaceFollowRequire) or ClientConst.AutoAcceptSpaceFollowType.Close

	return self:getInt(ClientConst.PrefKey.AutoAcceptSpaceFollowRequire, defaultValue)
end

function SettingSystem:setAutoAcceptSpaceFollowRequire(value)
	return self:setInt(ClientConst.PrefKey.AutoAcceptSpaceFollowRequire, value)
end

function SettingSystem:getAutoAcceptSpaceFollowInvite()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AutoAcceptSpaceFollowInvite) or ClientConst.AutoAcceptSpaceFollowType.Close

	return self:getInt(ClientConst.PrefKey.AutoAcceptSpaceFollowInvite, defaultValue)
end

function SettingSystem:setAutoAcceptSpaceFollowInvite(value)
	return self:setInt(ClientConst.PrefKey.AutoAcceptSpaceFollowInvite, value)
end

function SettingSystem:getMobileJoystickMode()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.MobileJoystickMode) or ClientConst.MobileJoystickMode.Fixed
	local mode = self:getInt(ClientConst.PrefKey.MobileJoystickMode, defaultValue)

	return mode
end

function SettingSystem:setMobileJoystickMode(mode)
	self:setInt(ClientConst.PrefKey.MobileJoystickMode, mode)

	local mobileOperateCtrl = pg.global.ui and pg.global.ui.mobileOperate

	if mobileOperateCtrl and mobileOperateCtrl.moveJoyStick then
		mobileOperateCtrl.moveJoyStick:setJoystickMode(mode)
	end
end

function SettingSystem:getGamepadCursorSpeed()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.GamepadCursorSpeed)

	return self:getInt(ClientConst.PrefKey.GamepadCursorSpeed, defaultValue)
end

function SettingSystem:setGamepadCursorSpeed(value)
	return self:setInt(ClientConst.PrefKey.GamepadCursorSpeed, value)
end

function SettingSystem:getHoldToEnterCatchMode()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.HoldToEnterCatchMode) or 0

	return self:getBool(ClientConst.PrefKey.HoldToEnterCatchMode, ToBool(defaultValue))
end

function SettingSystem:setHoldToEnterCatchMode(value)
	return self:setBool(ClientConst.PrefKey.HoldToEnterCatchMode, ToBool(value))
end

function SettingSystem:getInvertHorizontalLook()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.InvertHorizontalLook)

	return self:getBool(ClientConst.PrefKey.InvertHorizontalLook, ToBool(defaultValue))
end

function SettingSystem:setInvertHorizontalLook(value)
	return self:setBool(ClientConst.PrefKey.InvertHorizontalLook, ToBool(value))
end

function SettingSystem:getInvertVerticalLook()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.InvertVerticalLook)

	return self:getBool(ClientConst.PrefKey.InvertVerticalLook, ToBool(defaultValue))
end

function SettingSystem:setInvertVerticalLook(value)
	return self:setBool(ClientConst.PrefKey.InvertVerticalLook, ToBool(value))
end

function SettingSystem:getInvertHorizontalLookMouse()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.InvertHorizontalLookMouse)

	return self:getBool(ClientConst.PrefKey.InvertHorizontalLookMouse, ToBool(defaultValue))
end

function SettingSystem:setInvertHorizontalLookMouse(value)
	return self:setBool(ClientConst.PrefKey.InvertHorizontalLookMouse, ToBool(value))
end

function SettingSystem:getInvertVerticalLookMouse()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.InvertVerticalLookMouse)

	return self:getBool(ClientConst.PrefKey.InvertVerticalLookMouse, ToBool(defaultValue))
end

function SettingSystem:setInvertVerticalLookMouse(value)
	return self:setBool(ClientConst.PrefKey.InvertVerticalLookMouse, ToBool(value))
end

function SettingSystem:getGamepadLeftStickDeadzone()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.GamepadLeftStickDeadzone)

	return self:getInt(ClientConst.PrefKey.GamepadLeftStickDeadzone, defaultValue)
end

function SettingSystem:setGamepadLeftStickDeadzone(value)
	return self:setInt(ClientConst.PrefKey.GamepadLeftStickDeadzone, value)
end

function SettingSystem:getGamepadRightStickDeadzone()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.GamepadRightStickDeadzone)

	return self:getInt(ClientConst.PrefKey.GamepadRightStickDeadzone, defaultValue)
end

function SettingSystem:setGamepadRightStickDeadzone(value)
	return self:setInt(ClientConst.PrefKey.GamepadRightStickDeadzone, value)
end

function SettingSystem:getUseExtendLockCamera()
	local lockHelper = pg.game.controller and pg.game.controller.lockHelper

	if lockHelper then
		return lockHelper.isUseLockOnExtendCamera
	end

	local defaultMode = tonumber(self:getDefaultSettingValue(ClientConst.SettingFuncType.UseExtendLockCamera)) or 0

	return self:getBool(ClientConst.PrefKey.UseExtendLockCamera, defaultMode ~= 0)
end

function SettingSystem:setUseExtendLockCamera(value)
	value = ToBool(value)

	local lockHelper = pg.game.controller and pg.game.controller.lockHelper

	if lockHelper then
		lockHelper:setIsUseLockOnExtendCamera(value)
	else
		self:setBool(ClientConst.PrefKey.UseExtendLockCamera, value)
	end
end

function SettingSystem:getLockCameraMode()
	if not self:getUseExtendLockCamera() then
		return 0
	end

	local lockHelper = pg.game.controller and pg.game.controller.lockHelper

	if lockHelper then
		return lockHelper.isUseLockOnCamera and 1 or 2
	end

	local defaultMode = tonumber(self:getDefaultSettingValue(ClientConst.SettingFuncType.UseExtendLockCamera)) or 0
	local isUseLockOnCamera = self:getBool(ClientConst.PrefKey.IsForceLockTarget, defaultMode == 1)

	return isUseLockOnCamera and 1 or 2
end

function SettingSystem:setLockCameraMode(value)
	local mode = tonumber(value) or 0

	self:setUseExtendLockCamera(mode ~= 0)

	local isUseLockOnCamera = mode == 1
	local lockHelper = pg.game.controller and pg.game.controller.lockHelper

	if lockHelper then
		lockHelper:setIsUseLockOnCamera(isUseLockOnCamera)
	else
		self:setBool(ClientConst.PrefKey.IsForceLockTarget, isUseLockOnCamera)
	end
end

function SettingSystem:getAutoCameraWhenNoLock()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AutoCameraWhenNoLock)

	return self:getBool(ClientConst.PrefKey.AutoCameraWhenNoLock, ToBool(defaultValue))
end

function SettingSystem:setAutoCameraWhenNoLock(value)
	value = ToBool(value)

	self:setBool(ClientConst.PrefKey.AutoCameraWhenNoLock, value)

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode

	if not value and playerCameraMode and playerCameraMode.normalAttackLockOnCamera then
		playerCameraMode.normalAttackLockOnCamera:deactivate()
	end
end

function SettingSystem:getSkillAimSwitchMode()
	return self:getBool(ClientConst.PrefKey.SkillAimSwitchMode, false)
end

function SettingSystem:setSkillAimSwitchMode(enable)
	return self:setBool(ClientConst.PrefKey.SkillAimSwitchMode, enable)
end

function SettingSystem:save()
	pg.global.prefsCacheUtils:save()
end

function SettingSystem:onSpaceDestroy(space)
	pg.global.ui.setting.model:clearSettingData()

	self.cacheSettings = {}
end

function SettingSystem:setVitalityEnable(enable)
	self.vitalityEnabled = enable
end

function SettingSystem:getEnableVitality()
	return self.vitalityEnabled
end

function SettingSystem:setEnableHitCameraShake(isSelected)
	self.enableHitCameraShake = isSelected
end

function SettingSystem:getEnableHitCameraShake()
	return self.enableHitCameraShake
end

function SettingSystem:setShowDebugId(bShow)
	self:setBool(ClientConst.PrefKey.ShowDebugId, bShow)

	self.showDebugId = bShow
end

function SettingSystem:getShowDebugId()
	return self.showDebugId
end

function SettingSystem:setHideGuide(bHide)
	self:setBool(ClientConst.PrefKey.HideGuide, bHide)

	self.hideGuide = bHide
end

function SettingSystem:getHideGuide()
	return self.hideGuide
end

function SettingSystem:setShowDebugText(bShow)
	self:setBool(ClientConst.PrefKey.ShowDebugInfo, bShow)

	if self.showDebugText ~= bShow then
		self.showDebugText = bShow

		local entities = pg.getEntities()

		for _, ent in pairs(entities) do
			if ent and ent.refreshDebugTick then
				ent:refreshDebugTick()
			end
		end
	end
end

function SettingSystem:getShowDebugText()
	return self.showDebugText
end

function SettingSystem:setShowDebugTextSimple(bShow)
	self:setBool(ClientConst.PrefKey.ShowDebugInfoSimple, bShow)

	self.showDebugTextSimple = bShow
end

function SettingSystem:getShowDebugTextSimple()
	return self.showDebugTextSimple
end

function SettingSystem:onleaveScene()
	return
end

function SettingSystem:initPlayableLog()
	self.enablePlayableLog = self:getBool(ClientConst.PrefKey.ShowPlayableLog, false)
	CS.FunPlus.WorldX.Entities.Components.PlayableComponent.showGlobalLog = self.enablePlayableLog
end

function SettingSystem:setEnablePlayableLog(bShow)
	self:setBool(ClientConst.PrefKey.ShowPlayableLog, bShow)

	self.enablePlayableLog = bShow or false
	CS.FunPlus.WorldX.Entities.Components.PlayableComponent.showGlobalLog = self.enablePlayableLog
end

function SettingSystem:getEnablePlayableLog()
	return self.enablePlayableLog
end

function SettingSystem:setEnableGamepadDebugCapture(bEnable)
	self:setBool(ClientConst.PrefKey.GamepadDebugCapture, bEnable)

	self.enableGamepadDebugCapture = bEnable
end

function SettingSystem:getEnableGamepadDebugCapture()
	return self.enableGamepadDebugCapture
end

function SettingSystem:initGamepadNavDebug()
	self.gamepadNavDebug = self:getBool(ClientConst.PrefKey.GmGamepadNavDebug, false)

	if self.gamepadNavDebug and pg.global.uiMgr then
		pg.global.uiMgr:SetGamepadNavDebugLog(true)
	end
end

function SettingSystem:setGamepadNavDebug(bEnable)
	self:setBool(ClientConst.PrefKey.GmGamepadNavDebug, bEnable)

	self.gamepadNavDebug = bEnable

	if pg.global.uiMgr then
		pg.global.uiMgr:SetGamepadNavDebugLog(bEnable)
	end
end

function SettingSystem:getGamepadNavDebug()
	return self.gamepadNavDebug
end

function SettingSystem:isMobileRenderPlatform()
	return IS_MOBILE or ClientConfigInputPlatform == "Mobile"
end

function SettingSystem:initVideoSetting()
	if self:isMobileRenderPlatform() or ClientConfigCloudEnable == "true" or self:isConsolePlatform() then
		-- block empty
	else
		self:setResolution()
	end

	pg.global.gameMgr:RegisterScreenResolutionUpdateEvent(function(width, height, screenMode)
		if self.gmLowResolutionEnabled then
			self:applyGmLowResolution()

			return
		end

		self:setString(ClientConst.PrefKey.PcResolution, width .. "x" .. height)
		self:setString(ClientConst.PrefKey.PcScreenMode, screenMode)
		facade:SendMessageCommand(MessageName.SCREEN_RESOLUTION_UPDATE)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			pg.global.ui.funcMenu:close()
		end
	end)

	if self:checkNeedGetVideoLevelFromServer() then
		self:getVideoLevelFromServer()
	end

	self:initVideoQuality()
end

function SettingSystem:initVideoQuality()
	self:setVideoQuality(self:getVideoQuality(), true)
end

function SettingSystem:isConsolePlatform()
	return pg.global.platform ~= nil and pg.global.platform:isConsole()
end

function SettingSystem:isForceVSyncPlatform()
	if ClientConfigCloudEnable == "true" then
		return false
	end

	return self:isMobileRenderPlatform() or self:isConsolePlatform()
end

function SettingSystem:getConsoleDeviceKey()
	if not self:isConsolePlatform() then
		return nil
	end

	local p = pg.global.platform

	if p:isXbox() then
		return p:isXboxSeriesS() and "XSS" or "XSX"
	end

	return p:isPS5Pro() and "PS5Pro" or "PS5Base"
end

function SettingSystem:deriveConsoleVideoQuality(preset)
	local deviceKey = self:getConsoleDeviceKey()

	if not deviceKey then
		return nil
	end

	local base = deviceKey == "XSS" and 0 or 2

	return base + preset + 1
end

function SettingSystem:getVideoSettingPlatformAndIndex(videoQuality)
	local deviceKey = self:getConsoleDeviceKey()

	if not deviceKey then
		return self.curPlatform, videoQuality
	end

	local idx = deviceKey == "XSS" and videoQuality or videoQuality - 2

	if idx < 1 then
		idx = 1
	elseif idx > 2 then
		idx = 2
	end

	return deviceKey, idx
end

local CONSOLE_DEVICE_NAME = {
	XSS = "XboxSeriesS",
	PS5Pro = "PS5Pro",
	PS5Base = "PS5Base",
	XSX = "XboxSeriesX"
}
local GM_LOW_RESOLUTION_HEIGHT = 320

function SettingSystem:getConsoleFixedResolution()
	local deviceKey = self:getConsoleDeviceKey()

	if not deviceKey then
		return
	end

	local deviceName = CONSOLE_DEVICE_NAME[deviceKey]

	if not self.consoleResolutionMap then
		self.consoleResolutionMap = {}

		for _, cfg in ipairs(ConsoleVideoResolutionData) do
			self.consoleResolutionMap[cfg.deviceName] = cfg
		end
	end

	local cfg = self.consoleResolutionMap[deviceName]

	if not cfg then
		logger:warn("applyConsoleFixedResolution: no console resolution config for " .. tostring(deviceName))

		return
	end

	local isPerformance = self:getPreset() == 0
	local resolutionStr = isPerformance and cfg.performance_mode_resolution or cfg.quality_mode_resolution
	local resolution = string.split(resolutionStr, "x")
	local width = tonumber(resolution[1])
	local height = tonumber(resolution[2])

	if not width or not height then
		logger:warn("applyConsoleFixedResolution: invalid resolution str " .. tostring(resolutionStr))

		return
	end

	local screenMode = ClientConst.SettingDefaultValue.ScreenModeDefaultValue

	return width, height, screenMode
end

function SettingSystem:applyConsoleFixedResolution()
	if self.gmLowResolutionEnabled then
		self:applyGmLowResolution()

		return
	end

	local width, height, screenMode = self:getConsoleFixedResolution()

	if not width or not height then
		return
	end

	pg.global.gameMgr:SetResolution(width, height, screenMode)
end

function SettingSystem:getResolution()
	local resolutionStr = self:getString(ClientConst.PrefKey.PcResolution, "")

	if resolutionStr == "" then
		resolutionStr = self:getDefaultResolution()

		self:setString(ClientConst.PrefKey.PcResolution, resolutionStr)
	end

	return resolutionStr
end

function SettingSystem:getDefaultResolution()
	local width = CS.UnityEngine.Screen.width
	local height = CS.UnityEngine.Screen.height
	local resolutions = CS.UnityEngine.Screen.resolutions

	if resolutions.Length > 0 then
		local defaultResolution = resolutions[resolutions.Length - 1]

		width = defaultResolution.width
		height = defaultResolution.height
	end

	if width == Const.PC_4K_WIDTH and height == Const.PC_4K_HEIGHT and not self:checkShow4K() then
		width = Const.PC_2K_WIDTH
		height = Const.PC_2K_HEIGHT
	end

	return width .. "x" .. height
end

function SettingSystem:get2KResolutionValue()
	if not self.resolution2KValue then
		self.resolution2KValue = Const.PC_2K_WIDTH .. "x" .. Const.PC_2K_HEIGHT
	end

	return self.resolution2KValue
end

function SettingSystem:get4KResolutionValue()
	if not self.resolution4KValue then
		self.resolution4KValue = Const.PC_4K_WIDTH .. "x" .. Const.PC_4K_HEIGHT
	end

	return self.resolution4KValue
end

function SettingSystem:checkShow4K()
	return true
end

function SettingSystem:checkSupport4K()
	if UNITY_EDITOR then
		return true
	end

	local resolutions = CS.UnityEngine.Screen.resolutions

	for i = 0, resolutions.Length - 1 do
		local res = resolutions[i]

		if res.width >= Const.PC_4K_WIDTH then
			return true
		end
	end

	return false
end

function SettingSystem:getResolutionNumber()
	local resolutionStr = self:getResolution()
	local screenModeDefaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.SetScreenMode) or ClientConst.SettingDefaultValue.ScreenModeDefaultValue
	local screenMode = self:getString(ClientConst.PrefKey.PcScreenMode, screenModeDefaultValue)
	local resolution = string.split(resolutionStr, "x")
	local width = tonumber(resolution[1])
	local height = tonumber(resolution[2])

	if not width or not height then
		width = CS.UnityEngine.Screen.width
		height = CS.UnityEngine.Screen.height
	end

	if width < ClientConst.ResolutionMinValue.width or height < ClientConst.ResolutionMinValue.height then
		width = ClientConst.ResolutionMinValue.width
		height = ClientConst.ResolutionMinValue.height
	end

	return width, height, screenMode
end

function SettingSystem:setResolution()
	if self.gmLowResolutionEnabled then
		self:applyGmLowResolution()

		return
	end

	local width, height, screenMode = self:getResolutionNumber()

	pg.global.gameMgr:SetResolution(width, height, screenMode)
end

function SettingSystem:getGmLowResolutionCurrentState()
	if self:isMobileRenderPlatform() then
		return {
			type = "renderHeight",
			height = self:getMobileResolutionHeight(self:getVideoQuality())
		}
	end

	return {
		type = "renderHeight",
		height = 0
	}
end

function SettingSystem:applyGmLowResolution()
	CS.FunPlus.WorldX.Setting.VideoSetting.SetMobileResolution(GM_LOW_RESOLUTION_HEIGHT)
end

function SettingSystem:restoreGmLowResolution(state)
	if state and state.type == "renderHeight" and state.height ~= nil then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetMobileResolution(state.height)

		if self:isConsolePlatform() and ClientConfigCloudEnable ~= "true" then
			self:applyConsoleFixedResolution()
		end

		return
	end

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(self:getVideoQuality())
	elseif self:isConsolePlatform() and ClientConfigCloudEnable ~= "true" then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetMobileResolution(0)
		self:applyConsoleFixedResolution()
	else
		CS.FunPlus.WorldX.Setting.VideoSetting.SetMobileResolution(0)
	end
end

function SettingSystem:setGmLowResolutionEnabled(enable)
	if enable then
		if not self.gmLowResolutionEnabled then
			self.gmLowResolutionSavedState = self:getGmLowResolutionCurrentState()
		end

		self.gmLowResolutionEnabled = true

		self:applyGmLowResolution()

		return
	end

	if not self.gmLowResolutionEnabled then
		return
	end

	self.gmLowResolutionEnabled = false

	local state = self.gmLowResolutionSavedState

	self.gmLowResolutionSavedState = nil

	self:restoreGmLowResolution(state)
end

function SettingSystem:getGmLowResolutionEnabled()
	return self.gmLowResolutionEnabled == true
end

function SettingSystem:tryResetResolution(videoQuality)
	if ClientConfigCloudEnable == "true" then
		return
	end

	if not self:checkShow4K() then
		local width, height, screenMode = self:getResolutionNumber()

		if width == Const.PC_4K_WIDTH and height == Const.PC_4K_HEIGHT then
			local resolution = self:get2KResolutionValue()

			self:setString(ClientConst.PrefKey.PcResolution, resolution)
			self:setResolution()
		end
	end
end

local AntialiasingMode = {
	TAAU = 4,
	TAA = 3,
	FSR = 2,
	DLSS = 1,
	NONE = 0
}
local AntialiasingModeProjection = {
	None = AntialiasingMode.NONE,
	DeepLearningSuperSampling = AntialiasingMode.DLSS,
	FidelityFXSuperResolution = AntialiasingMode.FSR,
	TemporalAntialiasing = AntialiasingMode.TAA,
	TAAU = AntialiasingMode.TAAU
}
local CONSOLE_ANTIALIASING = "FidelityFXSuperResolution"

function SettingSystem:initAntialiasingSetting()
	if self:isConsolePlatform() then
		self:setAntialiasing(self:getAntialiasing())

		return
	end

	local antialiasing = self:getString(ClientConst.PrefKey.Antialiasing, "")

	if antialiasing ~= "" and (antialiasing == "DeepLearningSuperSampling" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() or antialiasing == "FidelityFXSuperResolution" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() or antialiasing == "TAAU" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport()) then
		antialiasing = ""
	end

	if antialiasing == "" then
		antialiasing = CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() and "DeepLearningSuperSampling" or CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() and "FidelityFXSuperResolution" or CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport() and "TAAU" or "TemporalAntialiasing"
	end

	if antialiasing ~= "" then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetAntialiasing(AntialiasingModeProjection[antialiasing])
	end
end

function SettingSystem:resetAntialiasingSetting(isInit)
	if self:isConsolePlatform() then
		self:setAntialiasing(self:getAntialiasing())

		return
	end

	local antialiasing

	if isInit then
		antialiasing = self:getAntialiasing()

		if antialiasing == "DeepLearningSuperSampling" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() or antialiasing == "FidelityFXSuperResolution" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() or antialiasing == "TAAU" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport() then
			antialiasing = "TemporalAntialiasing"

			if CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() then
				antialiasing = "DeepLearningSuperSampling"
			elseif CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() then
				antialiasing = "FidelityFXSuperResolution"
			elseif CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport() then
				antialiasing = "TAAU"
			end
		end
	else
		antialiasing = "TemporalAntialiasing"

		if CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() then
			antialiasing = "DeepLearningSuperSampling"
		elseif CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() then
			antialiasing = "FidelityFXSuperResolution"
		elseif CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport() then
			antialiasing = "TAAU"
		end
	end

	self:setAntialiasing(antialiasing)
end

function SettingSystem:resetEffectLevelSetting()
	CS.FunPlus.WorldX.Setting.VideoSetting.SetEffectLevelSetting(self.curVideoQuality)
end

function SettingSystem:getAntialiasing()
	if self:isConsolePlatform() then
		local saved = self:getString(ClientConst.PrefKey.Antialiasing, "")

		if saved == "" then
			return CONSOLE_ANTIALIASING
		end

		return saved
	end

	local antialiasing = self:getString(ClientConst.PrefKey.Antialiasing, "")

	if antialiasing == "" then
		antialiasing = CS.FunPlus.WorldX.Setting.VideoSetting.GetAntialiasing()
	end

	return antialiasing
end

function SettingSystem:setAntialiasing(antialiasing)
	self:setString(ClientConst.PrefKey.Antialiasing, antialiasing)
	CS.FunPlus.WorldX.Setting.VideoSetting.SetAntialiasing(AntialiasingModeProjection[antialiasing])

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
	end
end

local FrameGenerationMode = {
	GenerateThree = 3,
	GenerateTwo = 2,
	GenerateOne = 1,
	NONE = 0,
	Dynamic = 6,
	GenerateFive = 5,
	GenerateFour = 4
}
local FrameGenerationModeString = {
	"None",
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Dynamic"
}
local FrameGenerationModeProjection = {
	None = FrameGenerationMode.NONE,
	One = FrameGenerationMode.GenerateOne,
	Two = FrameGenerationMode.GenerateTwo,
	Three = FrameGenerationMode.GenerateThree,
	Four = FrameGenerationMode.GenerateFour,
	Five = FrameGenerationMode.GenerateFive,
	Dynamic = FrameGenerationMode.Dynamic
}
local DEFAULT_FRAME_GENERATION_MODE = FrameGenerationMode.NONE
local DYNAMIC_FRAME_GENERATION_FALLBACK_MULTIPLIER = 6

local function getMaxSupportFrameGenerationCount()
	local maxSupportCount = CS.FunPlus.WorldX.Setting.VideoSetting.MaxFrameGenerationCount()

	return math.min(maxSupportCount, FrameGenerationMode.GenerateFive)
end

local function isDynamicFrameGenerationSupported()
	if CS.FunPlus.WorldX.Setting.VideoSetting.CheckDynamicFrameGenerationSupport == nil then
		return false
	end

	return CS.FunPlus.WorldX.Setting.VideoSetting.CheckDynamicFrameGenerationSupport()
end

local function normalizeFrameGenerationMode(frameGeneration)
	frameGeneration = frameGeneration or FrameGenerationMode.NONE

	if frameGeneration == FrameGenerationMode.Dynamic then
		if isDynamicFrameGenerationSupported() then
			return frameGeneration
		end

		return getMaxSupportFrameGenerationCount()
	end

	if frameGeneration < FrameGenerationMode.NONE then
		return FrameGenerationMode.NONE
	end

	local maxSupportCount = getMaxSupportFrameGenerationCount()

	if maxSupportCount < frameGeneration then
		return maxSupportCount
	end

	return frameGeneration
end

local function isFrameGenerationEnabled(frameGeneration)
	return (frameGeneration or FrameGenerationMode.NONE) ~= FrameGenerationMode.NONE
end

function SettingSystem:initFrameGeneration()
	local frameGenerationCount = 0
	local frameGenerationString = self:getString(ClientConst.PrefKey.FrameGeneration, "")

	if frameGenerationString == "" then
		frameGenerationCount = DEFAULT_FRAME_GENERATION_MODE
	else
		frameGenerationCount = FrameGenerationModeProjection[frameGenerationString] or FrameGenerationMode.NONE
	end

	frameGenerationCount = normalizeFrameGenerationMode(frameGenerationCount)

	self:setFrameGeneration(FrameGenerationModeString[frameGenerationCount + 1])
end

function SettingSystem:resetFrameGenerationSetting(isInit)
	local frameGeneration = 0

	if isInit then
		local frameGenerationString = self:getString(ClientConst.PrefKey.FrameGeneration, "")

		if frameGenerationString == "" then
			frameGeneration = DEFAULT_FRAME_GENERATION_MODE
		else
			frameGeneration = FrameGenerationModeProjection[frameGenerationString] or FrameGenerationMode.NONE
		end
	else
		frameGeneration = DEFAULT_FRAME_GENERATION_MODE
	end

	frameGeneration = normalizeFrameGenerationMode(frameGeneration)

	self:setFrameGeneration(FrameGenerationModeString[frameGeneration + 1])
end

function SettingSystem:getFrameGeneration()
	local key = ClientConst.PrefKey.FrameGeneration
	local val = self.cacheSettings[key]

	if val then
		return val
	end

	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.FrameGeneration)
	local frameGeneration = self:getString(key, defaultValue)

	self.cacheSettings[key] = frameGeneration

	return frameGeneration
end

function SettingSystem:getFrameGenerationMultiplier()
	local frameGeneration = FrameGenerationModeProjection[self:getFrameGeneration()] or FrameGenerationMode.NONE

	frameGeneration = normalizeFrameGenerationMode(frameGeneration)

	if frameGeneration == FrameGenerationMode.Dynamic then
		return DYNAMIC_FRAME_GENERATION_FALLBACK_MULTIPLIER
	end

	return frameGeneration + 1
end

function SettingSystem:setFrameGeneration(farmeGeneration)
	local key = ClientConst.PrefKey.FrameGeneration
	local frameGenerationMode = FrameGenerationModeProjection[farmeGeneration] or FrameGenerationMode.NONE

	frameGenerationMode = normalizeFrameGenerationMode(frameGenerationMode)
	farmeGeneration = FrameGenerationModeString[frameGenerationMode + 1] or FrameGenerationModeString[FrameGenerationMode.NONE + 1]

	if isFrameGenerationEnabled(frameGenerationMode) and not self:isForceVSyncPlatform() and self:getVSync() ~= 0 then
		self:setInt(ClientConst.PrefKey.VSync, 0)
		CS.FunPlus.WorldX.Setting.VideoSetting.SetVSync(0)
	end

	self:setString(key, farmeGeneration)

	self.cacheSettings[key] = farmeGeneration

	CS.FunPlus.WorldX.Setting.VideoSetting.SetFrameGeneration(frameGenerationMode)

	if isFrameGenerationEnabled(frameGenerationMode) and pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function SettingSystem:initVSync()
	local vSync = self:getVSync()

	if self:isForceVSyncPlatform() and self.gmVSyncCount == nil then
		self:setInt(ClientConst.PrefKey.VSync, vSync)
	end

	CS.FunPlus.WorldX.Setting.VideoSetting.SetVSync(vSync)
end

function SettingSystem:getVSync()
	if self.gmVSyncCount ~= nil then
		return self.gmVSyncCount
	end

	if ClientConfigCloudEnable == "true" and not self:isCloudGameFramePacingUserModified() then
		return 0
	end

	if self:isForceVSyncPlatform() then
		return 1
	end

	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.VSync) or 0
	local vSync = self:getInt(ClientConst.PrefKey.VSync, defaultValue)

	return vSync
end

function SettingSystem:setVSync(vSyncCount, allowCloudChange)
	if self.gmVSyncCount ~= nil then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetVSync(self.gmVSyncCount)

		return
	end

	if ClientConfigCloudEnable == "true" and allowCloudChange ~= true then
		vSyncCount = self:isCloudGameFramePacingUserModified() and self:getInt(ClientConst.PrefKey.VSync, 0) or 0
	end

	if self:isForceVSyncPlatform() then
		vSyncCount = 1
	elseif vSyncCount ~= 0 then
		local frameGenerationKey = ClientConst.PrefKey.FrameGeneration
		local frameGeneration = FrameGenerationModeString[FrameGenerationMode.NONE + 1]

		self:setString(frameGenerationKey, frameGeneration)

		self.cacheSettings[frameGenerationKey] = frameGeneration

		CS.FunPlus.WorldX.Setting.VideoSetting.SetFrameGeneration(FrameGenerationMode.NONE)
	end

	self:setInt(ClientConst.PrefKey.VSync, vSyncCount)
	CS.FunPlus.WorldX.Setting.VideoSetting.SetVSync(vSyncCount)

	if vSyncCount ~= 0 and not self:isForceVSyncPlatform() then
		self:setTargetFramerate(-1, true)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
			pg.global.ui.setting:refreshSettingListNoData()
		end
	end
end

function SettingSystem:setGmVSync(vSyncCount)
	self.gmVSyncCount = vSyncCount ~= 0 and 1 or 0

	CS.FunPlus.WorldX.Setting.VideoSetting.SetVSync(self.gmVSyncCount)
end

function SettingSystem:getGmVSync()
	if self.gmVSyncCount ~= nil then
		return self.gmVSyncCount
	end

	return self:getVSync()
end

function SettingSystem:getPreset()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.Preset) or 0

	return self:getInt(ClientConst.PrefKey.Preset, defaultValue)
end

function SettingSystem:setPreset(value)
	self:setInt(ClientConst.PrefKey.Preset, value)

	if self:isConsolePlatform() then
		self:setVideoQuality(self:deriveConsoleVideoQuality(value), false)
	end
end

function SettingSystem:applyConsoleFramerate()
	local targetFramerate = self:getTargetFramerate()

	CS.UnityEngine.Application.targetFrameRate = targetFramerate

	if pg.global.platform:isPS() then
		CS.UnityEngine.QualitySettings.vSyncCount = targetFramerate == 30 and 2 or 1
	else
		CS.UnityEngine.QualitySettings.vSyncCount = 1
	end
end

function SettingSystem:applyMobileFramerate()
	CS.UnityEngine.Application.targetFrameRate = self:getTargetFramerate()
end

function SettingSystem:initTargetFramerate()
	if self:isConsolePlatform() and ClientConfigCloudEnable ~= "true" then
		self:applyConsoleFramerate()

		return
	end

	local targetFramerate = self:getTargetFramerate()

	CS.UnityEngine.Application.targetFrameRate = targetFramerate
end

function SettingSystem:setTargetFramerate(value, allowCloudChange)
	if ClientConfigCloudEnable == "true" and allowCloudChange ~= true then
		value = self:isCloudGameFramePacingUserModified() and self:getInt(ClientConst.PrefKey.TargetFramerate, CLOUD_GAME_TARGET_FRAMERATE) or CLOUD_GAME_TARGET_FRAMERATE
	end

	self:setInt(ClientConst.PrefKey.TargetFramerate, value)

	CS.UnityEngine.Application.targetFrameRate = value

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
	end

	if value ~= -1 and not self:isForceVSyncPlatform() and self:getVSync() ~= 0 then
		self:setVSync(0, true)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
			pg.global.ui.setting:refreshSettingListNoData()
		end
	end
end

function SettingSystem:getTargetFramerate()
	if ClientConfigCloudEnable == "true" then
		if not self:isCloudGameFramePacingUserModified() then
			return CLOUD_GAME_TARGET_FRAMERATE
		end

		return self:getInt(ClientConst.PrefKey.TargetFramerate, CLOUD_GAME_TARGET_FRAMERATE)
	end

	if self:isConsolePlatform() then
		return self:getPreset() == 0 and 60 or 30
	end

	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.TargetFramerate) or -1

	return self:getInt(ClientConst.PrefKey.TargetFramerate, defaultValue)
end

function SettingSystem:getHideTownPet()
	return self.hideTownPet
end

function SettingSystem:setHideTownPet(isHide)
	self:setBool(ClientConst.PrefKey.HideTownPet, isHide)

	if self.hideTownPet ~= isHide then
		self.hideTownPet = isHide

		self:refreshAllPetsVisible()

		if pg.global.ui.hudV2 and pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList then
			pg.global.ui.hudV2.RM.petList:refreshPetListVisible()
		end
	end
end

function SettingSystem:refreshAllPetsVisible()
	local entities = pg.getEntities()

	for id, entity in pairs(entities) do
		if Utils.isPet(entity) then
			entity:refreshVisible()
		end
	end
end

function SettingSystem:setCompassState(state)
	self:setInt(ClientConst.PrefKey.Compass, state)
end

function SettingSystem:getGuideLabelState()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.GuideLabel, ClientConst.SettingFuncParam.GuideLabel) or 1

	return self:getInt(ClientConst.PrefKey.GuideLabel, defaultValue)
end

function SettingSystem:setGuideLabelState(state)
	pg.global.ui.hudV2.view:switchGuideLabel(1 - state)

	if pg.global.ui.tips then
		pg.global.ui.tips:switchGuideLabel(1 - state)
	end

	self:setInt(ClientConst.PrefKey.GuideLabel, state)
end

function SettingSystem:setUseTopLogoCache(useCache)
	self.useTopLogoCache = useCache

	self:setBool(ClientConst.PrefKey.UseTopLogoCache, useCache)
end

function SettingSystem:getHideSkillType()
	return self.hideSkillType
end

function SettingSystem:setHideSkillType(hideSkillType)
	self.hideSkillType = hideSkillType

	self:setBool(ClientConst.PrefKey.HideSkillType, hideSkillType)
	pg.global.ui.hudV2:refreshSkillList()
end

function SettingSystem:getHideAllHudArrowType()
	return self.hideAllHudArrowType
end

function SettingSystem:setHideAllHudArrowType(hideType)
	self.hideAllHudArrowType = hideType

	self:setBool(ClientConst.PrefKey.HideAllHudArrowType, hideType)
	pg.global.ui.hatredArrowTip:refreshAllArrowState()
end

function SettingSystem:isEntityCountSettingReady()
	return self.entityCountMin ~= nil and self.entityCountSettingUIDKey == self:getUIDKey()
end

function SettingSystem:initEntityCountSetting()
	if EnableBotTest then
		return
	end

	self.entityCountMax = {}
	self.entityCountMin = {}

	for index, type in pairs(SettingConst.EntityCountLimitType) do
		self.entityCountMax[type] = self:getEntityCountMax(type)
		self.entityCountMin[type] = self:getEntityCountMin(type)

		local count = self:getEntityCount(type)

		pg.game.entityCount:setCountLimit(type, count)
	end

	self.entityCountSettingUIDKey = self:getUIDKey()
end

function SettingSystem:setEntityCountByLevel(level)
	local newCountLimit = SettingConst.EntityCountLimitLevel[level]

	for k, v in pairs(newCountLimit) do
		self:setEntityCount(k, v)
	end
end

function SettingSystem:getEntityCount(type)
	local defaultValue = self:getSettingRelationValue("setVideoQuality", self.curVideoQuality, ClientConst.SettingFuncType[type]) or 10
	local count = self:getInt(ClientConst.PrefKey[type], defaultValue)

	return math.clamp(count, self.entityCountMin[type], self.entityCountMax[type])
end

function SettingSystem:setEntityCount(type, count)
	count = math.clamp(count, self.entityCountMin[type], self.entityCountMax[type])

	self:setInt(ClientConst.PrefKey[type], count)
	pg.game.entityCount:setCountLimit(type, count)
end

function SettingSystem:getEntityCountMax(type)
	local countMax = self:getSettingRelationValue("setVideoQuality", Const.VIDEO_QUALITY.TOP, ClientConst.SettingFuncType[type]) or 8

	if self:isMobileRenderPlatform() then
		return math.floor(countMax * 1.5)
	end

	return countMax
end

function SettingSystem:getEntityCountMin(type)
	return self:getSettingRelationValue("setVideoQuality", Const.VIDEO_QUALITY.LOW, ClientConst.SettingFuncType[type]) or 4
end

function SettingSystem:initTeamSpeechSetting()
	return
end

function SettingSystem:setTeamSpeechAutoEnter(autoEnter)
	self:setBool(ClientConst.PrefKey.AutoEnterTeamSpeech, autoEnter)

	if pg.me then
		LuaUIUtils.sendCustomLog(Const.BILogName.TEAM_SPEECH, {
			joinChannelMode = autoEnter and 1 or 2
		})

		if not pg.me:isInSpeechChannel(pg.me.uid) then
			pg.me:joinSpeechChannel()
		end
	end
end

function SettingSystem:getTeamSpeechAutoEnter()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.AutoEnterTeamSpeech) == 1 and true or false
	local autoEnter = self:getBool(ClientConst.PrefKey.AutoEnterTeamSpeech, defaultValue)

	return autoEnter
end

function SettingSystem:setTeamSpeechFreeTalk(enableFreeTalk)
	self:setBool(ClientConst.PrefKey.TeamSpeechSpeakType .. pg.me.uid, enableFreeTalk)

	if pg.me and pg.me:isInSpeechChannel(pg.me.uid) then
		pg.global.gmeManager:EnableMic(enableFreeTalk, true)

		if enableFreeTalk then
			pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_SPEECH_ENABLE_FREE_TALK"))
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_SPEECH_DISABLE_FREE_TALK"))
		end

		pg.global.ui.tips:refreshHotKeyHint(true)
	end

	if pg.me then
		LuaUIUtils.sendCustomLog(Const.BILogName.TEAM_SPEECH, {
			speakMode = enableFreeTalk and 1 or 2
		})
	end

	pg.global.ui.tips:refreshShortCutKey()
end

function SettingSystem:getTeamSpeechFreeTalk()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.TeamSpeechSpeakType) == 1 and true or false
	local freeTalk = self:getBool(ClientConst.PrefKey.TeamSpeechSpeakType .. pg.me.uid, defaultValue)

	return freeTalk
end

function SettingSystem:setMicVol(volume)
	self:setInt(ClientConst.PrefKey.TeamSpeechMicVol, volume)

	if pg.me and pg.me:isInSpeechChannel(pg.me.uid) then
		pg.global.gmeManager:SetMicVolume(volume)
	end
end

function SettingSystem:getMicVol()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.TeamSpeechMicVol)
	local volume = self:getInt(ClientConst.PrefKey.TeamSpeechMicVol, defaultValue)

	return volume
end

function SettingSystem:setTeamVol(volume)
	self:setInt(ClientConst.PrefKey.TeamSpeechTeamVol, volume)

	if pg.me and pg.me:isInSpeechChannel(pg.me.uid) then
		pg.global.gmeManager:SetSpeakerVolume(volume)
	end
end

function SettingSystem:getTeamVol()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.TeamSpeechTeamVol)
	local volume = self:getInt(ClientConst.PrefKey.TeamSpeechTeamVol, defaultValue)

	return volume
end

function SettingSystem:handleVideoSettingByQuality(videoQuality, isInit)
	if self:isConsolePlatform() then
		self:handleConsoleVideoSettingByQuality(videoQuality, isInit)

		return
	end

	for i, config in pairs(VideoSettingData) do
		if i ~= 1 and self:checkPlatform(config) then
			local isShow = config.isShow == 1 and config.valueType ~= "enum"
			local value, defaultValue
			local values = config[self.curPlatform]

			if values then
				if config.key == LARGE_SCREEN_MODE_KEY then
					defaultValue = self:getLargeScreenModeAutoValue()
				else
					defaultValue = values[videoQuality]

					if defaultValue == nil and videoQuality == Const.VIDEO_QUALITY.TOP then
						defaultValue = values[Const.VIDEO_QUALITY.HIGH]
					end
				end

				if config.key == ClientConst.PrefKey.ResolutionScale then
					value = self:getResolutionScale(defaultValue)
				elseif config.key == LARGE_SCREEN_MODE_KEY then
					value = self:getLargeScreenMode(defaultValue)
				elseif isInit and isShow then
					value = self:getCommonVideoSettingValueInner(config, defaultValue)
				else
					value = defaultValue
				end

				if value ~= nil then
					local shouldSave = isShow and not isInit and config.key ~= ClientConst.PrefKey.ResolutionScale and config.key ~= LARGE_SCREEN_MODE_KEY

					self:setCommonVideoSettingValueInner(config.key, value, config.valueType, shouldSave, isInit)
				end
			end
		end
	end
end

function SettingSystem:handleConsoleVideoSettingByQuality(videoQuality, isInit)
	local pKey, idx = self:getVideoSettingPlatformAndIndex(videoQuality)

	for i, config in pairs(VideoSettingData) do
		if i ~= 1 and self:checkPlatform(config) then
			local isShow = config.isShow == 1 and config.valueType ~= "enum"
			local values = config[pKey]

			if values then
				local defaultValue = values[idx]
				local value

				if isInit and isShow then
					value = self:getCommonVideoSettingValueInner(config, defaultValue)
				else
					value = defaultValue
				end

				if value ~= nil then
					local shouldSave = isShow and not isInit

					self:setCommonVideoSettingValueInner(config.key, value, config.valueType, shouldSave, isInit)
				end
			end
		end
	end
end

function SettingSystem:checkPlatform(config)
	if config.key == ClientConst.PrefKey.ResolutionScale then
		return self:isMobileRenderPlatform()
	end

	if config.key == LARGE_SCREEN_MODE_KEY then
		return self:isLargeScreenModeAvailable()
	end

	if config.key == "supportDLSS" and not CS.FunPlus.WorldX.Setting.VideoSetting.IsDlssAvailable() then
		return false
	end

	if config.platform == nil then
		return true
	end

	if self.curPlatformId then
		return table.contains(config.platform, self.curPlatformId)
	end

	return false
end

function SettingSystem:getVideoQuality()
	if ClientConfigCloudEnable == "true" then
		return CLOUD_GAME_VIDEO_QUALITY
	end

	if self:isConsolePlatform() then
		return self:deriveConsoleVideoQuality(self:getPreset())
	end

	local videoQuality = self:getInt(ClientConst.PrefKey.VideoQuality, -1)

	if videoQuality == -1 then
		videoQuality = self:getVideoDefaultQualityNew()
	end

	return videoQuality
end

function SettingSystem:setVideoQuality(videoQuality, isInit)
	if pg.global.sdkManager:isDouyinCloudChannel() then
		videoQuality = Const.VIDEO_QUALITY.TOP
		isInit = false
	elseif ClientConfigCloudEnable == "true" then
		videoQuality = CLOUD_GAME_VIDEO_QUALITY
		isInit = false
	end

	self:setInt(ClientConst.PrefKey.VideoQuality, videoQuality)
	CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoQuality(videoQuality)

	self.curVideoQuality = videoQuality

	self:handleVideoSettingByQuality(self.curVideoQuality, isInit)

	if not self:isConsolePlatform() then
		self:tryResetResolution(videoQuality)
	end

	self:resetAntialiasingSetting(isInit)
	self:resetFrameGenerationSetting(isInit)
	self:resetEffectLevelSetting()

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(videoQuality)
	elseif self:isConsolePlatform() and ClientConfigCloudEnable ~= "true" then
		self:applyConsoleFixedResolution()
	end

	if self:isConsolePlatform() and ClientConfigCloudEnable ~= "true" then
		self:applyConsoleFramerate()
	end

	if self:isMobileRenderPlatform() then
		self:applyMobileFramerate()
	end

	if ClientConfigCloudEnable == "true" then
		self:applyCloudGameQualityOverrides()
	end

	self:applyDeviceVideoOverrides()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end

	facade:SendMessageCommand(MessageName.VIDEO_QUALITY_CHANGED, videoQuality)
end

function SettingSystem:getVideoDefaultQualityNew()
	return Const.VIDEO_QUALITY.MID
end

function SettingSystem:getCommonVideoSettingValue(key)
	local id = VideoSettingMap[key]
	local config = VideoSettingData[id]

	if config then
		local defaultValue = self:getVideoSettingDefaultValue(key)

		return self:getCommonVideoSettingValueInner(config, defaultValue)
	end
end

function SettingSystem:getCommonVideoSettingValueInner(config, defaultValue)
	if config.key == "animationQuality" then
		return self:getAnimationQuality(defaultValue)
	elseif config.key == ClientConst.PrefKey.ResolutionScale then
		return self:getResolutionScale(defaultValue)
	elseif config.key == LARGE_SCREEN_MODE_KEY then
		return self:getLargeScreenMode(defaultValue)
	end

	if config.valueType == "bool" then
		return self:getBool(config.key, defaultValue)
	elseif config.valueType == "int" then
		return self:getInt(config.key, defaultValue)
	elseif config.valueType == "float" then
		return self:getFloat(config.key, defaultValue)
	elseif config.valueType == "enum" then
		-- block empty
	end
end

function SettingSystem:setCommonVideoSettingValue(key, value)
	local id = VideoSettingMap[key]
	local config = VideoSettingData[id]

	if config then
		self:setCommonVideoSettingValueInner(key, value, config.valueType, true)
	end
end

function SettingSystem:tryGetLogicValue(key, defaultValue)
	if key == "animationQuality" then
		return self:getAnimationQuality(defaultValue)
	elseif key == "RemoveOverheadPartsPlayer" then
		return self:getOverheadPartDeal(1, key, defaultValue)
	elseif key == "RemoveOverheadPartsOtherPlayer" then
		return self:getOverheadPartDeal(2, key, defaultValue)
	elseif key == "RemoveOverheadPartsPuppet" then
		return self:getOverheadPartDeal(4, key, defaultValue)
	elseif key == "RemoveOverheadPartsUI" then
		return self:getOverheadPartDeal(8, key, defaultValue)
	end

	return false
end

function SettingSystem:trySetLogicValue(key, value, valueType, shouldSave, isInit)
	if key == "animationQuality" then
		self:setAnimationQuality(value, shouldSave, isInit)

		return true
	elseif key == ClientConst.PrefKey.ResolutionScale then
		self:setResolutionScale(value, shouldSave)

		return true
	elseif key == LARGE_SCREEN_MODE_KEY then
		self:setLargeScreenMode(value, shouldSave)

		return true
	elseif key == "RemoveOverheadPartsPlayer" then
		self:setOverheadPartDeal(1, value, shouldSave, isInit)

		return true
	elseif key == "RemoveOverheadPartsOtherPlayer" then
		self:setOverheadPartDeal(2, value, shouldSave, isInit)

		return true
	elseif key == "RemoveOverheadPartsPuppet" then
		self:setOverheadPartDeal(4, value, shouldSave, isInit)

		return true
	elseif key == "RemoveOverheadPartsUI" then
		self:setOverheadPartDeal(8, value, shouldSave, isInit)

		return true
	end

	return false
end

function SettingSystem:setCommonVideoSettingValueInner(key, value, valueType, shouldSave, isInit)
	if self:trySetLogicValue(key, value, valueType, shouldSave, isInit) then
		return
	end

	if valueType == "bool" then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoSettingValueBool(key, value)

		if shouldSave then
			self:setBool(key, value)
		end
	elseif valueType == "int" then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoSettingValueInt(key, value)

		if shouldSave then
			self:setInt(key, value)
		end
	elseif valueType == "float" then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoSettingValueFloat(key, value)

		if shouldSave then
			self:setFloat(key, value)
		end
	elseif valueType == "enum" then
		local data = {}

		for _, param in ipairs(value) do
			table.insert(data, param)
		end

		CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoSettingValueEnum(key, data)
	end
end

function SettingSystem:resolveVideoSettingOverride(key, requestedValue)
	local gmOverrides = self.gmSpecialVideoSettingOverrides

	if gmOverrides and gmOverrides[key] ~= nil then
		return gmOverrides[key]
	end

	return DeviceVideoOverride.resolve(key, requestedValue, self.curPlatform, CS.UnityEngine.SystemInfo.deviceModel)
end

function SettingSystem:applySpecialVideoSettingValue(key)
	if DeviceVideoOverride.valueTypes[key] ~= "bool" then
		return
	end

	local effectiveValue = self:resolveVideoSettingOverride(key, DeviceVideoOverride.defaults[key])

	CS.FunPlus.WorldX.Setting.VideoSetting.SetVideoSettingValueBool(key, effectiveValue)
end

function SettingSystem:applyDeviceVideoOverrides()
	for key, _ in pairs(DeviceVideoOverride.defaults) do
		self:applySpecialVideoSettingValue(key)
	end
end

function SettingSystem:refreshDeviceVideoOverrides()
	self:handleVideoSettingByQuality(self:getVideoQuality(), true)
	self:applyDeviceVideoOverrides()
end

function SettingSystem:setGmSpecialVideoSettingValue(key, value)
	if not GM_SPECIAL_VIDEO_SETTING_TYPES[key] then
		return
	end

	self.gmSpecialVideoSettingOverrides = self.gmSpecialVideoSettingOverrides or {}
	self.gmSpecialVideoSettingOverrides[key] = value

	self:applySpecialVideoSettingValue(key)
end

function SettingSystem:getGmSpecialVideoSettingValue(key)
	if not GM_SPECIAL_VIDEO_SETTING_TYPES[key] then
		return false
	end

	return self:resolveVideoSettingOverride(key, DeviceVideoOverride.defaults[key])
end

function SettingSystem:setGmTransparentInOnePassEnabled(enable)
	self:setGmSpecialVideoSettingValue("transparentInOnePass", enable)
end

function SettingSystem:getGmTransparentInOnePassEnabled()
	return self:getGmSpecialVideoSettingValue("transparentInOnePass")
end

function SettingSystem:setGmTransparentInIndependentPassEnabled(enable)
	self:setGmSpecialVideoSettingValue("transparentInIndependentPass", enable)
end

function SettingSystem:getGmTransparentInIndependentPassEnabled()
	return self:getGmSpecialVideoSettingValue("transparentInIndependentPass")
end

function SettingSystem:setGmPostTaa5TapSharpenEnabled(enable)
	self:setGmSpecialVideoSettingValue("postTaa5TapSharpen", enable)
end

function SettingSystem:getGmPostTaa5TapSharpenEnabled()
	return self:getGmSpecialVideoSettingValue("postTaa5TapSharpen")
end

function SettingSystem:getAnimationQuality(defaultValue)
	if defaultValue == nil then
		defaultValue = self:getVideoSettingDefaultValue("animationQuality")
	end

	return self:getInt(ClientConst.PrefKey.AnimationQuality, defaultValue)
end

function SettingSystem:setAnimationQuality(value, shouldSave, deferApply)
	if shouldSave then
		self:setInt(ClientConst.PrefKey.AnimationQuality, value)
	end

	self.pendingAnimationQuality = value

	if not deferApply and ClientSettingUtils.apply_animationQuality(value) then
		self.pendingAnimationQuality = nil
	end
end

function SettingSystem:getResolutionScale(defaultValue)
	defaultValue = tonumber(defaultValue) or 1

	if self.resolutionScaleUserModified == nil then
		local savedValue = self:getFloat(ClientConst.PrefKey.ResolutionScale, -1)

		self.resolutionScaleUserModified = savedValue >= 0

		if self.resolutionScaleUserModified then
			self.resolutionScaleValue = savedValue
		end
	end

	if self.resolutionScaleUserModified then
		return self.resolutionScaleValue
	end

	return defaultValue
end

function SettingSystem:setResolutionScale(value, shouldSave)
	value = tonumber(value)

	if value == nil then
		return
	end

	if shouldSave then
		self:setFloat(ClientConst.PrefKey.ResolutionScale, value)

		self.resolutionScaleUserModified = true
		self.resolutionScaleValue = value

		if self:isMobileRenderPlatform() then
			self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
		end
	end
end

function SettingSystem:resetResolutionScale()
	pg.global.prefsCacheUtils:deleteKey(self:getUIDKey() .. ClientConst.PrefKey.ResolutionScale)

	self.resolutionScaleUserModified = false
	self.resolutionScaleValue = nil

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
	end
end

function SettingSystem:isLargeScreenModeAvailable()
	if self.largeScreenModeAvailable ~= nil then
		return self.largeScreenModeAvailable
	end

	local shortSide = getScreenShortSide()

	self.largeScreenModeAvailable = self:isMobileRenderPlatform() and shortSide >= LARGE_SCREEN_MODE_MIN_SHORT_SIDE and not maybe_large_foldable_phone(CS.UnityEngine.SystemInfo.deviceModel)

	return self.largeScreenModeAvailable
end

function SettingSystem:getLargeScreenModeAutoValue()
	if self.largeScreenModeAutoValue ~= nil then
		return self.largeScreenModeAutoValue
	end

	local value = self:isLargeScreenModeAvailable()

	self.largeScreenModeAutoValue = value

	return value
end

function SettingSystem:getLargeScreenMode(defaultValue)
	if not self:isLargeScreenModeAvailable() then
		return false
	end

	if defaultValue == nil then
		defaultValue = self:getLargeScreenModeAutoValue()
	end

	defaultValue = ToBool(defaultValue)

	if self.largeScreenModeUserModified == nil then
		self.largeScreenModeUserModified = self:getBool(ClientConst.PrefKey.LargeScreenModeUserModified, false)

		if self.largeScreenModeUserModified then
			self.largeScreenModeValue = self:getBool(LARGE_SCREEN_MODE_KEY, defaultValue)
		end
	end

	if self.largeScreenModeUserModified then
		return self.largeScreenModeValue
	end

	return defaultValue
end

function SettingSystem:setLargeScreenMode(value, shouldSave)
	if not self:isLargeScreenModeAvailable() then
		self.largeScreenModeValue = false

		return
	end

	value = ToBool(value)
	self.largeScreenModeValue = value

	if shouldSave then
		self:setBool(LARGE_SCREEN_MODE_KEY, value)
		self:setBool(ClientConst.PrefKey.LargeScreenModeUserModified, true)

		self.largeScreenModeUserModified = true

		if self:isMobileRenderPlatform() then
			self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
		end
	end
end

function SettingSystem:resetLargeScreenMode()
	pg.global.prefsCacheUtils:deleteKey(self:getUIDKey() .. ClientConst.PrefKey.LargeScreenModeUserModified)

	self.largeScreenModeUserModified = false
	self.largeScreenModeValue = nil
	self.largeScreenModeAutoValue = nil

	if self:isMobileRenderPlatform() then
		self:initMobileResolution(self.curVideoQuality or self:getVideoQuality())
	end
end

function SettingSystem:getOverheadPartDeal(idx, key, defaultValue)
	local v = self:getInt(ClientConst.PrefKey.OverheadPartDeal, 0)

	if v == 0 then
		return self:getVideoSettingDefaultValue(key)
	end

	return bit.band(v, idx) == idx
end

function SettingSystem:setOverheadPartDeal(idx, value, shouldSave, deferApply)
	local v = self:getInt(ClientConst.PrefKey.OverheadPartDeal, 0)

	v = bit.bor(v, idx)

	if not value then
		v = v - idx
	end

	self:setInt(ClientConst.PrefKey.OverheadPartDeal, v)
	CS.FunPlus.WorldX.Manager.EntityManager.RefreshOverheadPartDeal(v)
end

function SettingSystem:getVideoSettingDefaultValue(key)
	local id = VideoSettingMap[key]
	local videoQuality = self.curVideoQuality or self:getVideoQuality()

	if key == LARGE_SCREEN_MODE_KEY then
		return self:getLargeScreenModeAutoValue()
	end

	if self:isConsolePlatform() then
		return self:getConsoleVideoSettingDefaultValue(key, videoQuality)
	end

	if id and VideoSettingData[id] then
		local values = VideoSettingData[id][self.curPlatform]

		if values then
			local defaultValue = values[videoQuality]

			if defaultValue == nil and videoQuality == Const.VIDEO_QUALITY.TOP then
				defaultValue = values[Const.VIDEO_QUALITY.HIGH]
			end

			return defaultValue
		end
	end
end

function SettingSystem:getConsoleVideoSettingDefaultValue(key, videoQuality)
	local id = VideoSettingMap[key]

	if id and VideoSettingData[id] then
		local pKey, idx = self:getVideoSettingPlatformAndIndex(videoQuality)
		local values = VideoSettingData[id][pKey]

		if values then
			return values[idx]
		end
	end
end

function SettingSystem:setCatchAbsorbSpeed(speed, key)
	self:setInt(ClientConst.PrefKey["CatchAbsorbSpeed_" .. key], speed)

	if pg.game.camera.playerCameraMode.catchCamera then
		pg.game.camera.playerCameraMode.catchCamera:onInputDeviceChange()
	end
end

function SettingSystem:getCatchAbsorbSpeed(key)
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType["CatchAbsorbSpeed_" .. key])
	local speed = self:getInt(ClientConst.PrefKey["CatchAbsorbSpeed_" .. key], defaultValue)

	return math.clamp(speed, 0, 5)
end

function SettingSystem:setCatchDampingRate(rate, key)
	self:setInt(ClientConst.PrefKey["CatchDampingRate_" .. key], rate)

	if pg.game.camera.playerCameraMode.catchCamera then
		pg.game.camera.playerCameraMode.catchCamera:onInputDeviceChange()
	end
end

function SettingSystem:getCatchDampingRate(key)
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType["CatchDampingRate_" .. key])
	local rate = self:getInt(ClientConst.PrefKey["CatchDampingRate_" .. key], defaultValue)

	return math.clamp(rate, 0, 5)
end

function SettingSystem:getRealSettingValue(key)
	return CS.FunPlus.WorldX.Setting.VideoSetting.GetSettingValue(key)
end

function SettingSystem:checkNeedGetVideoLevelFromServer()
	local videoQuality = self:getInt(ClientConst.PrefKey.VideoQualityRecommend, -1)

	return videoQuality == -1
end

function SettingSystem:getVideoLevelFromServer(isInit, onlyUpdateRecommendation)
	local deviceModel = CS.UnityEngine.SystemInfo.deviceModel
	local cpu = CS.UnityEngine.SystemInfo.processorType
	local gpu = CS.UnityEngine.SystemInfo.graphicsDeviceName
	local platform = self:isMobileRenderPlatform() and Const.ClientPerformancePlatform.Mobile or Const.ClientPerformancePlatform.PC

	isInit = isInit or false
	onlyUpdateRecommendation = onlyUpdateRecommendation == true

	local requestUIDKey = self:getUIDKey()
	local body = json.encode({
		model = deviceModel,
		cpu = cpu,
		gpu = gpu,
		platform = platform
	})
	local isCn = ClientConfigAppCountry == "cn"
	local host

	if ClientConfigEnvType <= 0 then
		host = isCn and PERFORMANCE_QUERY_STAGE_HOST_CN or PERFORMANCE_QUERY_STAGE_HOST
	else
		host = isCn and PERFORMANCE_QUERY_HOST_CN or PERFORMANCE_QUERY_HOST
	end

	local request = HttpRequest(host, nil, HttpRequest.Method.POST, PERFORMANCE_QUERY_PATH, PERFORMANCE_QUERY_HEADERS, body, true)

	HttpClientProxy():httpRequest(request, PERFORMANCE_QUERY_TIMEOUT_MS, function(reply)
		self:_queryPerformanceCallback(isInit, requestUIDKey, onlyUpdateRecommendation, reply)
	end, false)
end

function SettingSystem:_queryPerformanceCallback(isinit, requestUIDKey, onlyUpdateRecommendation, reply)
	if requestUIDKey ~= self:getUIDKey() then
		return
	end

	local resp = {}
	local httpStatus = tonumber(reply and reply.header and reply.header.HTTP_STATUS)
	local isHttpSuccess = reply and reply.err == 0 and (httpStatus == nil or httpStatus >= 200 and httpStatus < 300)

	if isHttpSuccess then
		local decodeSuccess, response = pcall(json.decode, reply.body)

		if decodeSuccess and type(response) == "table" and tonumber(response.code) == 200 and type(response.data) == "table" then
			resp = response.data
		else
			local responseCode = type(response) == "table" and response.code or nil

			logger:warn("query performance response invalid, httpStatus=%s, code=%s", tostring(httpStatus), tostring(responseCode))
		end
	else
		logger:warn("query performance request failed, err=%s, httpStatus=%s", tostring(reply and reply.err), tostring(httpStatus))
	end

	local recommendedDeviceLevel = Const.ClientPerformanceLevelDefault
	local responseLevel = tonumber(resp.level)
	local responseScore = tonumber(resp.score)

	if resp.flag ~= true or not responseLevel then
		return
	end

	recommendedDeviceLevel = responseLevel

	if ClientConfigCloudEnable == "true" then
		self:setInt(ClientConst.PrefKey.VideoQualityRecommend, recommendedDeviceLevel)

		if responseScore then
			self:setInt(ClientConst.PrefKey.VideoQualityScore, math.floor(responseScore))
		end

		self:applyCloudGamePerformanceSettings()

		return
	end

	if self:isConsolePlatform() then
		self:setInt(ClientConst.PrefKey.VideoQualityRecommend, self:getVideoQuality())

		return
	end

	self:setInt(ClientConst.PrefKey.VideoQualityRecommend, recommendedDeviceLevel)

	if responseScore then
		self:setInt(ClientConst.PrefKey.VideoQualityScore, math.floor(responseScore))
		self:tryShowForbidden()
		self:tryShowMobileVideoQualityTip()
	end

	if onlyUpdateRecommendation then
		return
	end

	if pg.me then
		ClientSettingUtils.applyRelationValue("setVideoQuality", recommendedDeviceLevel, false)
	end

	self:setVideoQuality(recommendedDeviceLevel, isinit)
end

function SettingSystem:getVideoQualityRecommend()
	return pg.game.setting:getInt(ClientConst.PrefKey.VideoQualityRecommend, -1)
end

function SettingSystem:gotoPC()
	local isCn = ClientConfigAppCountry == "cn"

	if isCn then
		pg.global.sdkManager:openUrl("settingSystem", "gotoPC", "https://yimo.com/")
	else
		pg.global.sdkManager:openUrl("settingSystem", "gotoPC", "https://www.aniimo.com/")
	end
end

function SettingSystem:gotoCloud()
	if self.curPlatform == "IOS" and not string.isNilOrEmpty(SysConfigData.IOSCloudUrl) then
		pg.global.sdkManager:openUrl("settingSystem", "IOSCloud", SysConfigData.IOSCloudUrl)
	elseif self.curPlatform == "Android" and not string.isNilOrEmpty(SysConfigData.AndroidCloudUrl) then
		pg.global.sdkManager:openUrl("settingSystem", "AndroidCloud", SysConfigData.AndroidCloudUrl)
	end
end

function SettingSystem:tryShowForbidden()
	if not self:isMobileRenderPlatform() then
		return
	end

	local score = self:getInt(ClientConst.PrefKey.VideoQualityScore, -1)

	if score == -1 then
		return
	end

	local isForbidden = score < SysConfigData.ClientPerformanceLevelScoreForbidden

	if isForbidden then
		local isCn = ClientConfigAppCountry == "cn"
		local title = pg.getGameString("popup_common_tips")
		local desc = pg.getGameString("popup_mobile_lowspec_content_new")

		if isCn then
			pg.global.showConfirmMsgRaw(title, desc, function()
				self:gotoCloud()
				appFacade.QuitGame()
			end, false, function()
				appFacade.QuitGame()
			end, nil, nil, {
				needPetIcon = true,
				blockNextTip = true,
				okBtnDesc = pg.getGameString("popup_mobile_lowspec_cloud_new"),
				cancelBtnDesc = pg.getGameString("popup_common_never_new")
			})
		else
			pg.global.showConfirmMsgRaw(title, desc, function()
				appFacade.QuitGame()
			end, true, nil, nil, nil, {
				needPetIcon = true,
				okBtnType = 1,
				blockNextTip = true,
				okBtnDesc = pg.getGameString("popup_common_never_new")
			})
		end
	end
end

function SettingSystem:tryShowMobileVideoQualityTip()
	if not self:isMobileRenderPlatform() then
		return
	end

	local disable = self:getBool(ClientConst.PrefKey.DisableVideoQualityTip, false)

	if disable then
		return
	end

	local score = self:getInt(ClientConst.PrefKey.VideoQualityScore, -1)

	if score == -1 then
		return
	end

	local tooLow = score < SysConfigData.ClientPerformanceLevelLowScoreLimit and score >= SysConfigData.ClientPerformanceLevelScoreForbidden
	local lastTipTime = self:getInt(ClientConst.PrefKey.VideoQualityTipTime, -1)

	if tooLow then
		local day = os.date("*t").day

		if lastTipTime ~= day then
			self:setInt(ClientConst.PrefKey.VideoQualityTipTime, day)

			local title = pg.getGameString("popup_common_tips")
			local desc = pg.getGameString("popup_pc_lowspec_content_new")
			local isCn = ClientConfigAppCountry == "cn"

			if isCn then
				pg.global.showConfirmMsgRaw(title, desc, function()
					self:gotoCloud()
				end, false, function()
					return
				end, nil, nil, {
					okBtnType = 0,
					cancelType = 0,
					needPetIcon = true,
					hint = true,
					hintDesc = pg.getGameString("DISABLE_TIP"),
					okBtnDesc = pg.getGameString("popup_mobile_lowspec_cloud_new"),
					cancelBtnDesc = pg.getGameString("popup_common_continue_new"),
					hintCb = function(isSelected)
						self:setBool(ClientConst.PrefKey.DisableVideoQualityTip, isSelected)
					end
				})
			else
				pg.global.showConfirmMsgRaw(title, desc, function()
					return
				end, false, function()
					appFacade.QuitGame()
				end, nil, nil, {
					okBtnType = 0,
					cancelType = 1,
					needPetIcon = true,
					hint = true,
					hintDesc = pg.getGameString("DISABLE_TIP"),
					okBtnDesc = pg.getGameString("popup_common_continue_new"),
					cancelBtnDesc = pg.getGameString("popup_common_never_new"),
					hintCb = function(isSelected)
						self:setBool(ClientConst.PrefKey.DisableVideoQualityTip, isSelected)
					end
				})
			end
		end
	end
end

function SettingSystem:_refreshVideoVolume()
	CS.com.vasd.pandora.PVideoController.SetVolume(pg.game.setting:getVolume(AudioConst.VolumeType.All) * pg.game.setting:getVolume(AudioConst.VolumeType.BGM) * 0.01)
end

function SettingSystem:getMobileResolutionScale()
	local defaultValue = self:getVideoSettingDefaultValue(ClientConst.PrefKey.ResolutionScale) or self:getDefaultSettingValue(ClientConst.SettingFuncType.ResolutionScale) or 1
	local value = self:getResolutionScale(defaultValue)
	local scale = Const.MOBILE_RESOLUTION_SCALE[value] or value

	scale = tonumber(scale) or 1

	if scale <= 0 then
		scale = 1
	end

	return scale, value
end

function SettingSystem:getMobileResolutionHeight(videoQuality)
	local baseHeightList = self:getLargeScreenMode() and Const.MOBILE_LARGE_SCREEN_VIDEO_QUALITY_BASE_HEIGHT or Const.MOBILE_VIDEO_QUALITY_BASE_HEIGHT
	local baseHeight = baseHeightList[videoQuality] or baseHeightList[Const.VIDEO_QUALITY.MID]
	local scale, scaleValue = self:getMobileResolutionScale()
	local useTop60FpsTaaSceneScale = self:getTargetFramerate() == 60 and self:getAntialiasing() == "TemporalAntialiasing" and videoQuality == Const.VIDEO_QUALITY.TOP

	if useTop60FpsTaaSceneScale then
		scale = scale * 0.9
	end

	local height = math.floor(baseHeight * scale + 0.5)

	return height, baseHeight, scaleValue, scale
end

function SettingSystem:getMobileUIResolutionHeight(videoQuality)
	local baseHeightList = self:getLargeScreenMode() and Const.MOBILE_LARGE_SCREEN_UI_VIDEO_QUALITY_BASE_HEIGHT or Const.MOBILE_UI_VIDEO_QUALITY_BASE_HEIGHT
	local baseHeight = baseHeightList[videoQuality] or baseHeightList[Const.VIDEO_QUALITY.MID]
	local scale, scaleValue = self:getMobileResolutionScale()
	local height = math.floor(baseHeight * scale + 0.5)

	return height, baseHeight, scaleValue, scale
end

function SettingSystem:initMobileUIResolution(videoQuality)
	local height = self:getMobileUIResolutionHeight(videoQuality)

	CS.FunPlus.WorldX.Setting.VideoSetting.SetUIFixedHeight(true, height)
end

function SettingSystem:initMobileResolution(videoQuality)
	self:initMobileUIResolution(videoQuality)

	if self.gmLowResolutionEnabled then
		self:applyGmLowResolution()

		return
	end

	local height, _, _, _ = self:getMobileResolutionHeight(videoQuality)

	CS.FunPlus.WorldX.Setting.VideoSetting.SetMobileResolution(height)
end

function SettingSystem:getUISceneResolutionHeight(isHighQuality)
	if self:isMobileRenderPlatform() then
		local videoQuality = self:getVideoQuality()
		local height, _, _, _ = self:getMobileResolutionHeight(videoQuality)
		local scale = 1

		if isHighQuality then
			scale = 1.2
		end

		return height * scale
	end

	return 0
end

function SettingSystem:setResourceQuality(value)
	self:setInt(ClientConst.PrefKey.ResourceQuality, value)
end

function SettingSystem:getResourceQuality()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.ResourceQuality)
	local quality = self:getInt(ClientConst.PrefKey.ResourceQuality, defaultValue)

	return quality
end

function SettingSystem:getIsShowResist()
	local defaultValue = self:getDefaultSettingValue(ClientConst.SettingFuncType.IsShowResist)
	local isShowResist = self:getInt(ClientConst.PrefKey.IsShowResist, defaultValue)

	return ToBool(isShowResist)
end

function SettingSystem:setIsShowResist(value)
	self:setInt(ClientConst.PrefKey.IsShowResist, value)
end

function SettingSystem:needShowIntel13or14GenCPUWarning()
	local isDisabled = self:getBool(ClientConst.PrefKey.DisableIntel13or14GenCPUWarning, false)

	return not isDisabled and self:isIntel13or14GenCPU()
end

function SettingSystem:isIntel13or14GenCPU()
	local cpuName = CS.UnityEngine.SystemInfo.processorType

	if string.find(cpuName, "i5%-13%d") or string.find(cpuName, "i5%-14%d") or string.find(cpuName, "i7%-13%d") or string.find(cpuName, "i7%-14%d") or string.find(cpuName, "i9%-13%d") or string.find(cpuName, "i9%-14%d") then
		return true
	end

	return false
end

function SettingSystem:disableIntel13or14GenCPUWarning(isSelected)
	self:setBool(ClientConst.PrefKey.DisableIntel13or14GenCPUWarning, isSelected)
end

function SettingSystem:getBloodType()
	local cached = self.bloodTypeCache

	if cached ~= nil then
		return cached
	end

	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.BloodType)
	local isSimple = self:getInt(ClientConst.SettingFuncType.BloodType, defaultValue)

	self.bloodTypeCache = isSimple

	return isSimple
end

function SettingSystem:setBloodType(value)
	self:setInt(ClientConst.SettingFuncType.BloodType, value)

	self.bloodTypeCache = value
end

return SettingSystem
