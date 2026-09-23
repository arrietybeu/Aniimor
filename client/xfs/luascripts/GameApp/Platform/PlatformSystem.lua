-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Platform\\PlatformSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformShellJoinService = require("SDK.Platform.PlatformShellJoinService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformSystem = Class.LightClass("PlatformSystem", SystemBase)

function PlatformSystem.getPlatformBridgeLuaFacade()
	local cs = rawget(_G, "CS")
	local funPlus = cs and cs.FunPlus
	local worldX = funPlus and funPlus.WorldX
	local sdk = worldX and worldX.SDK
	local platform = sdk and sdk.Platform

	return platform and platform.PlatformBridgeLuaFacade
end

function PlatformSystem.isRuntimeReady()
	local platformBridgeLuaFacade = PlatformSystem.getPlatformBridgeLuaFacade()

	return platformBridgeLuaFacade and platformBridgeLuaFacade.IsRuntimeInitialized and platformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformSystem.isCurrentPlatformSupported()
	return PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformSystem.isCurrentPlayStationSupported()
	return PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation
end

function PlatformSystem:initAfterLogin()
	if not PlatformSystem.isCurrentPlatformSupported() then
		return
	end

	PlatformUGCService:requestDeferredServerSync("login")
	PlatformShellActivityService:publishLoginActivity()
	PlatformShellActivityService:ensureRepublishTimer()
	PlatformShellJoinService:init(PlatformSystem.isRuntimeReady())
end

function PlatformSystem:onPlayerEnterScene()
	if not PlatformSystem.isCurrentPlatformSupported() then
		return
	end

	PlatformUGCService:flushDeferredServerSync("player_enter_scene")
	PlatformShellJoinService:tryShowPendingTextTip()

	if PlatformSystem.isCurrentPlayStationSupported() then
		PlatformShellJoinService:clearDelayPremiumFeatureSessionUntilPlayerEnterScene()
	end
end

function PlatformSystem:onBackToLogin()
	if not PlatformSystem.isCurrentPlatformSupported() then
		return
	end

	PlatformUGCService:cancelDeferredServerSync("back_to_login")
	PlatformShellActivityService:shutdown()
	PlatformShellJoinService:clearPendingTextTip()
	PlatformShellJoinService:clearDelayPremiumFeatureSessionUntilPlayerEnterScene()
	PlatformShellJoinService:shutdown()
end

return PlatformSystem
