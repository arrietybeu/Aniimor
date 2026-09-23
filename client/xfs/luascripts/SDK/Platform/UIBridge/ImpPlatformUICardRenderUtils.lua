-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformUICardRenderUtils.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local PlatformPetNameMaskService = require("SDK.Platform.PlatformPetNameMaskService")

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

function M.isSelfMember(data)
	if data and data.isSelf == true then
		return true
	end

	local selfUid = pg and pg.me and pg.me.uid

	if selfUid == nil then
		return false
	end

	local uid = data and data.uid or nil

	return uid ~= nil and tostring(uid) == tostring(selfUid)
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

function M.fillFromPlayerCache(targetInfo, data)
	local uid = data and data.uid or PlatformUtils.getIdentityField(targetInfo, "uid") or PlatformUtils.getIdentityField(targetInfo, "playerId")
	local cachedInfo = M.getChatPlayerInfo(uid)
	local platformUserId = PlatformUtils.getIdentityField(targetInfo, "platformUserId")

	if cachedInfo == nil and platformUserId ~= nil then
		cachedInfo = M.getChatPlayerInfo(platformUserId)
	end

	return M.fillMissingIdentity(targetInfo, cachedInfo)
end

function M.resolveDisplayInfo(data)
	local displayInfo = M.copyPlayerInfo(data)

	if M.isSelfMember(data) then
		M.fillFromCurrentUser(displayInfo)
	else
		M.fillFromPlayerCache(displayInfo, data)
	end

	return displayInfo
end

function M:getRender1Plus3RoomPlayerName(data, rawName, objectReference)
	PlatformDisplayNameInjector.enableRichTextRefs(objectReference, {
		"playerNameUBaseText"
	})

	if not data then
		return nil
	end

	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.TeamRoomMemberName,
		uid = data.uid,
		playerInfo = data,
		rawText = rawName or data.playerName or ""
	})

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = data,
		config = M.CONFIG,
		rawName = displayText
	})
end

function M:render1Plus3RoomOnlineID(objectReference, data)
	local displayInfo = M.resolveDisplayInfo(data)

	return PlatformDisplayNameInjector.applyOnlineID({
		objectReference = objectReference,
		playerInfo = displayInfo,
		config = M.CONFIG
	})
end

function M:getRender1Plus3PrimaryPetName(data, p1Data)
	return PlatformPetNameMaskService.getMaskedDisplayPetName({
		action = PlatformPetNameMaskService.Action.PetCustomName,
		uid = data and data.uid,
		playerInfo = data,
		customName = p1Data and p1Data.customName,
		configName = p1Data and (p1Data.configName or p1Data.name) or ""
	})
end

return M
