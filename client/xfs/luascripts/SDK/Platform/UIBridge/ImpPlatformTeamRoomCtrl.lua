-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformTeamRoomCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")

M.CONFIG = PlatformDisplayNameConfig.UI_Node_TeamRoom_CenterItem
M.IDENTITY_FIELDS = {
	"platformDisplayName",
	"platformUserId",
	"platformFamily",
	"platform",
	"os",
	"isAllowedCrossPlatform"
}

function M.isMissing(value)
	return value == nil or value == ""
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

	PlatformUtils.fillMissingFlatIdentityFields(copiedInfo, playerInfo)

	return copiedInfo
end

function M.fillMissingIdentity(targetInfo, fallbackInfo)
	if targetInfo == nil or fallbackInfo == nil then
		return targetInfo
	end

	return PlatformUtils.fillMissingFlatIdentityFields(targetInfo, fallbackInfo)
end

function M.isSelfMember(data, memberInfo)
	local selfUid = pg and pg.me and pg.me.uid

	if selfUid == nil then
		return false
	end

	local uid = data and data.uid or nil

	if uid ~= nil and tostring(uid) == tostring(selfUid) then
		return true
	end

	local memberUid = PlatformUtils.getIdentityField(memberInfo, "uid")
	local memberPlayerId = PlatformUtils.getIdentityField(memberInfo, "playerId")

	return memberUid ~= nil and tostring(memberUid) == tostring(selfUid) or memberPlayerId ~= nil and tostring(memberPlayerId) == tostring(selfUid)
end

function M.fillFromCurrentUser(targetInfo)
	local currentUser = PlatformLoginService and PlatformLoginService.getCurrentUser and PlatformLoginService:getCurrentUser()

	if currentUser == nil then
		return targetInfo
	end

	local displayName = PlatformUtils.getIdentityField(currentUser, "displayName")
	local userId = PlatformUtils.getIdentityField(currentUser, "userId")

	if M.isMissing(targetInfo.platformDisplayName) and not M.isMissing(displayName) then
		targetInfo.platformDisplayName = tostring(displayName)
	end

	if M.isMissing(targetInfo.platformUserId) and not M.isMissing(userId) then
		targetInfo.platformUserId = tostring(userId)
	end

	if M.isMissing(targetInfo.platformFamily) and PlatformIdentityUtils and PlatformIdentityUtils.getCurrentPlatformFamily then
		targetInfo.platformFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	end

	return targetInfo
end

function M.getChatPlayerInfo(uid)
	local chatSystem = pg and pg.game and pg.game.chat

	if uid == nil or chatSystem == nil or chatSystem.getPlayerInfo == nil then
		return nil
	end

	local cachedInfo = chatSystem:getPlayerInfo(tostring(uid))

	if PlatformFriendListService and PlatformFriendListService.resolveDisplayPlayerInfo then
		return PlatformFriendListService:resolveDisplayPlayerInfo(chatSystem, tostring(uid), cachedInfo)
	end

	return cachedInfo
end

function M.fillFromPlayerCache(targetInfo, data, memberInfo)
	local uid = data and data.uid or PlatformUtils.getIdentityField(targetInfo, "uid") or PlatformUtils.getIdentityField(targetInfo, "playerId")
	local cachedInfo = M.getChatPlayerInfo(uid)
	local platformUserId = PlatformUtils.getIdentityField(memberInfo, "platformUserId")

	if cachedInfo == nil and platformUserId ~= nil then
		cachedInfo = M.getChatPlayerInfo(platformUserId)
	end

	return M.fillMissingIdentity(targetInfo, cachedInfo)
end

function M.resolveDisplayInfo(data, memberInfo)
	local displayInfo = M.copyPlayerInfo(memberInfo)
	local isSelf = M.isSelfMember(data, memberInfo)

	if isSelf then
		M.fillFromCurrentUser(displayInfo)
	else
		M.fillFromPlayerCache(displayInfo, data, memberInfo)
	end

	return displayInfo
end

function M:getRenderPlayerName(data, memberInfo, rawName, objectReference)
	PlatformDisplayNameInjector.enableRichTextRefs(objectReference, {
		"playerNameUBaseText"
	})

	if not memberInfo then
		return nil
	end

	local displayInfo = M.resolveDisplayInfo(data, memberInfo)
	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TeamRoomMemberName,
		uid = data.uid,
		playerInfo = displayInfo,
		rawText = rawName or memberInfo.playerName or ""
	})

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = displayInfo,
		config = M.CONFIG,
		rawName = displayText
	})
end

function M:renderPlayerOnlineID(objectReference, data, memberInfo)
	local displayInfo = M.resolveDisplayInfo(data, memberInfo)

	return PlatformDisplayNameInjector.applyOnlineID({
		objectReference = objectReference,
		playerInfo = displayInfo,
		config = M.CONFIG
	})
end

return M
