-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInfoPlayerMainCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformNameMaskRefreshHelper = require("SDK.Platform.PlatformNameMaskRefreshHelper")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.CONFIG = PlatformDisplayNameConfig.UI_Pb_InfoPlayer_Main

function M.isMissing(value)
	return value == nil or value == ""
end

function M.isSelfPlayer(playerInfo)
	local selfUid = pg and pg.me and pg.me.uid

	return playerInfo ~= nil and playerInfo.uid ~= nil and selfUid ~= nil and tostring(playerInfo.uid) == tostring(selfUid)
end

function M.copyPlayerInfo(playerInfo)
	local copiedInfo = {}

	if playerInfo == nil then
		return copiedInfo
	end

	local canIterate, iterator, state, firstKey = pcall(pairs, playerInfo)

	if canIterate then
		for key, value in iterator, state, firstKey do
			copiedInfo[key] = value
		end
	end

	return copiedInfo
end

function M.buildDisplayPlayerInfo(playerInfo)
	if not M.isSelfPlayer(playerInfo) then
		return playerInfo
	end

	local missingFamily = M.isMissing(playerInfo.platformFamily)
	local missingUserId = M.isMissing(playerInfo.platformUserId)
	local missingDisplayName = M.isMissing(playerInfo.platformDisplayName)

	if not missingFamily and not missingUserId and not missingDisplayName then
		return playerInfo
	end

	local displayPlayerInfo = M.copyPlayerInfo(playerInfo)

	if missingFamily and PlatformIdentityUtils and PlatformIdentityUtils.getCurrentPlatformFamily then
		local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

		if not M.isMissing(currentFamily) then
			displayPlayerInfo.platformFamily = currentFamily
		end
	end

	local currentUser = PlatformLoginService and PlatformLoginService.getCurrentUser and PlatformLoginService:getCurrentUser() or nil

	if currentUser ~= nil then
		if missingUserId and not M.isMissing(currentUser.userId) then
			displayPlayerInfo.platformUserId = tostring(currentUser.userId)
		end

		if missingDisplayName and not M.isMissing(currentUser.displayName) then
			displayPlayerInfo.platformDisplayName = tostring(currentUser.displayName)
		end
	end

	return displayPlayerInfo
end

function M:applyDisplayName(displayName)
	local view = self.view

	PlatformDisplayNameInjector.enableRichText(view and view.panelInfoPlayerNameText)

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = M.buildDisplayPlayerInfo(self.playerInfo),
		config = M.CONFIG,
		rawName = displayName
	})
end

function M:applyName(rawName)
	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.InfoPlayerCardName,
		uid = self.playerInfo.uid,
		playerInfo = self.playerInfo,
		rawText = rawName
	})

	return M.applyDisplayName(self, displayName)
end

function M:onCreate()
	PlatformNameMaskRefreshHelper.register(self, function(ctrl)
		if type(ctrl.setPlayerBaseInfo) == "function" then
			ctrl:setPlayerBaseInfo()
		end
	end)
end

function M:setPlayerBaseInfoName(rawName)
	return M.applyName(self, rawName)
end

function M:refreshPlayerName(rawName)
	return M.applyName(self, rawName)
end

function M:onDestroy()
	PlatformNameMaskRefreshHelper.unregister(self)
end

function M:setPlayerBaseInfoSign(rawSign)
	return PlatformNameMaskService:getVisibleProfileSignature(self.playerInfo and self.playerInfo.uid, self.playerInfo, rawSign)
end

function M:setPlayerBaseInfoOnlineID()
	if not pg.global.platform:isPS() then
		return
	end

	local view = self.view

	if view == nil or PlatformDisplayNameInjector.isUnityNil(view.onlineIDImage) or PlatformDisplayNameInjector.isUnityNil(view.onlineIDText) then
		return
	end

	local playerId = self.playerInfo and self.playerInfo.uid

	if string.isNilOrEmpty(playerId) then
		PlatformDisplayNameInjector.setNodeActive(view.onlineIDImage, false)

		return
	end

	local objectReference = view.panelInfoObjectReference

	local function applyWithPlayerInfo(playerInfo)
		if not self.view then
			return
		end

		PlatformDisplayNameInjector.applyOnlineID({
			objectReference = objectReference,
			playerInfo = playerInfo,
			config = M.CONFIG
		})
	end

	local cachedInfo = pg.game.chat:getPlayerInfo(playerId)

	if cachedInfo then
		applyWithPlayerInfo(cachedInfo)
	else
		PlatformDisplayNameInjector.setNodeActive(view.onlineIDImage, false)
		pg.game.chat:getPlayerInfoFromServer(playerId, nil, function(playerInfo)
			applyWithPlayerInfo(playerInfo)
		end)
	end
end

return M
