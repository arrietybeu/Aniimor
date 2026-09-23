-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientMainPlayer.lua

local M = {}
local NoticeDef = require("Common.NoticeDef")
local PlatformInviteTokenService = require("SDK.Platform.PlatformInviteTokenService")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")

M.CLEAR_ACTIVITY_NOTICE_REASONS = {
	[NoticeDef.CROSS_PLATFORM_MISMATCH] = "cross_platform_receive_notice",
	[NoticeDef.TEAM_INVITE_EXPIRED] = "team_invite_expired"
}

function M.clearShellInviteTokenCache()
	PlatformInviteTokenService:clearAll()
end

function M.onLeaveSpace()
	M.clearShellInviteTokenCache()
end

function M.onLoseServer()
	M.clearShellInviteTokenCache()
end

function M:RPC_SC_receiveNotice(noticeId, noticeArgs)
	local reason = M.CLEAR_ACTIVITY_NOTICE_REASONS[noticeId]

	if not reason then
		return
	end

	PlatformShellActivityService:clearCurrentActivity(reason)
end

M.SPACE_FOLLOW_NOTICE_NAME_ACTIONS = {
	[NoticeDef.FOLLOW_XXX_ENTER] = PlatformNameMaskService.Action.FollowEnterName,
	[NoticeDef.FOLLOW_EXIT_XXX] = PlatformNameMaskService.Action.ExitFollowName
}

function M.getChatSystem()
	return pg and pg.game and pg.game.chat or nil
end

function M.normalizeUid(uid)
	uid = uid and tostring(uid) or nil

	return not string.isNilOrEmpty(uid) and uid or nil
end

function M.getPlayerInfoByUid(uid, fallbackPlayerInfo)
	local chatSystem = M.getChatSystem()

	uid = M.normalizeUid(uid)

	if uid and chatSystem and type(chatSystem.getPlayerInfo) == "function" then
		local playerInfo = chatSystem:getPlayerInfo(uid)

		if type(playerInfo) == "table" then
			return playerInfo
		end
	end

	return fallbackPlayerInfo
end

function M.findTeamMemberByName(playerName)
	if string.isNilOrEmpty(playerName) or not pg or not pg.me or type(pg.me.getCurTeamInfo) ~= "function" then
		return nil, nil, false
	end

	local teamInfo = pg.me:getCurTeamInfo()
	local membersInfo = teamInfo and teamInfo.membersInfo

	if type(membersInfo) ~= "table" then
		return nil, nil, false
	end

	local matchedUid, matchedPlayerInfo

	for uid, playerInfo in pairs(membersInfo) do
		if type(playerInfo) == "table" and playerInfo.playerName == playerName then
			if matchedUid then
				return nil, nil, true
			end

			matchedUid = M.normalizeUid(uid)
			matchedPlayerInfo = M.getPlayerInfoByUid(matchedUid, playerInfo)
		end
	end

	return matchedUid, matchedPlayerInfo, false
end

function M.getFriendList()
	local chatSystem = M.getChatSystem()

	if chatSystem and type(chatSystem.getFriendList) == "function" then
		local friendList = chatSystem:getFriendList()

		if type(friendList) == "table" then
			return friendList
		end
	end

	return nil
end

function M.getFriendUid(friendInfo)
	if type(friendInfo) ~= "table" then
		return nil
	end

	return M.normalizeUid(friendInfo.playerId or friendInfo.uid or friendInfo.userId)
end

function M.findFriendByPlayerName(playerName)
	local friendList = M.getFriendList()

	if string.isNilOrEmpty(playerName) or not friendList then
		return nil, nil, false
	end

	local matchedUid, matchedPlayerInfo

	for _, friendInfo in ipairs(friendList) do
		local uid = M.getFriendUid(friendInfo)
		local playerInfo = M.getPlayerInfoByUid(uid, type(friendInfo) == "table" and friendInfo.playerInfo or nil)

		if uid and type(playerInfo) == "table" and playerInfo.playerName == playerName then
			if matchedUid then
				return nil, nil, true
			end

			matchedUid = uid
			matchedPlayerInfo = playerInfo
		end
	end

	return matchedUid, matchedPlayerInfo, false
end

function M.findFriendByRemark(playerName)
	local chatSystem = M.getChatSystem()
	local friendList = M.getFriendList()

	if string.isNilOrEmpty(playerName) or not friendList or not chatSystem or type(chatSystem.getFriendCustomInfo) ~= "function" then
		return nil, nil, false
	end

	local matchedUid, matchedPlayerInfo

	for _, friendInfo in ipairs(friendList) do
		local uid = M.getFriendUid(friendInfo)
		local customInfo = uid and chatSystem:getFriendCustomInfo(uid) or nil

		if type(customInfo) == "table" and customInfo.remark == playerName then
			if matchedUid then
				return nil, nil, true
			end

			matchedUid = uid
			matchedPlayerInfo = M.getPlayerInfoByUid(uid, type(friendInfo) == "table" and friendInfo.playerInfo or nil)
		end
	end

	return matchedUid, matchedPlayerInfo, false
end

function M.findSpaceFollowPlayerByName(playerName)
	local uid, playerInfo, duplicated = M.findTeamMemberByName(playerName)

	if uid or duplicated then
		return uid, playerInfo
	end

	uid, playerInfo, duplicated = M.findFriendByPlayerName(playerName)

	if uid or duplicated then
		return uid, playerInfo
	end

	uid, playerInfo = M.findFriendByRemark(playerName)

	return uid, playerInfo
end

function M.getMaskedSpaceFollowNoticeArgs(noticeId, noticeArgs)
	local action = M.SPACE_FOLLOW_NOTICE_NAME_ACTIONS[noticeId]

	if not action or type(noticeArgs) ~= "table" then
		return noticeArgs
	end

	local rawName = noticeArgs[1]
	local uid, playerInfo = M.findSpaceFollowPlayerByName(rawName)

	if string.isNilOrEmpty(uid) then
		return noticeArgs
	end

	local maskedArgs = {}

	for i, arg in ipairs(noticeArgs) do
		maskedArgs[i] = arg
	end

	maskedArgs[1] = PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or ""
	})

	return maskedArgs
end

function M:replaceNoticeArgs(noticeId, noticeArgs)
	if noticeId == NoticeDef.CROSS_PLATFORM_MISMATCH then
		PlatformCrossPlatformService.showCrossPlayPrivilegeUi()
	end

	return M.getMaskedSpaceFollowNoticeArgs(noticeId, noticeArgs)
end

return M
