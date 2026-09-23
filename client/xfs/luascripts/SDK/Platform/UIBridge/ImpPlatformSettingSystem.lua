-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformSettingSystem.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")

function M:trySyncCrossPlatformToServer()
	PlatformCrossPlatformService:syncCurrentSettingToServer()
end

function M.syncConsolePlatformUserKey(platformUserId)
	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	local setting = pg and pg.game and pg.game.setting

	if not setting or not setting.syncConsolePlatformUserKey then
		return false
	end

	return setting:syncConsolePlatformUserKey(tostring(platformUserId))
end

function M.getCurrentPlatformUserId()
	if not PlatformLoginService or not PlatformLoginService.getCurrentUser then
		return nil
	end

	local currentUser = PlatformLoginService:getCurrentUser()

	if currentUser and not string.isNilOrEmpty(currentUser.userId) then
		return tostring(currentUser.userId)
	end

	return nil
end

function M.onPlatformUserSignedIn(payload)
	local platformUserId

	if type(payload) == "table" then
		platformUserId = payload.platformUserId
	end

	if string.isNilOrEmpty(platformUserId) then
		platformUserId = M.getCurrentPlatformUserId()
	end

	M.syncConsolePlatformUserKey(platformUserId)
end

function M.registerConsoleSettingKeyListener()
	if not pg or not pg.global or not pg.global.eventEmitter then
		return
	end

	if not pg.global.eventEmitter.addEventListener then
		return
	end

	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_USER_SIGNED_IN, function(payload)
		require("SDK.Platform.UIBridge.ImpPlatformSettingSystem").onPlatformUserSignedIn(payload)
	end)
end

function M.init()
	M.registerConsoleSettingKeyListener()
	M.syncConsolePlatformUserKey(M.getCurrentPlatformUserId())
end

return M
