-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformImpChatTeam.lua

local M = {}
local NoticeDef = require("Common.NoticeDef")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")

function M.showSpaceFollowNotify(uid, playerInfo, gameStringKey)
	local playerName = playerInfo and playerInfo.playerName

	if not string.isNilOrEmpty(playerName) then
		playerName = PlatformNameMaskService.getMaskedDisplayName({
			action = PlatformNameMaskService.Action.ToastName,
			uid = uid,
			playerInfo = playerInfo,
			rawText = playerName
		})
	end

	pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString(gameStringKey), playerName), 2)

	return true
end

function M.canHandleOfflineTeamInvitePlayerInfo(playerInfo)
	if not PlatformShellInviteService or type(PlatformShellInviteService.isSupported) ~= "function" or PlatformShellInviteService:isSupported() ~= true then
		return false
	end

	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	return PlatformIdentityUtils.isPlatformFriend(playerInfo) == true or PlatformIdentityUtils.isSamePlatformFamilyUser(playerInfo) == true
end

function M:canHandleOfflineTeamInvite(playerId, playerInfo, extraInfo)
	return M.canHandleOfflineTeamInvitePlayerInfo(playerInfo)
end

function M:recvTeamNotice(playerInfo, noticeId)
	if noticeId == NoticeDef.TEAM_MSG_MAX_PLAYER then
		pg.global.ui.tips:showTextTip(pg.getGameString("OTHER_TEAM_FULL"))

		return true
	elseif noticeId == NoticeDef.CROSS_PLATFORM_MISMATCH then
		PlatformShellActivityService:clearCurrentActivity("cross_platform_team_notice")
		PlatformCrossPlatformService.showNoticeTip(noticeId)

		return true
	elseif noticeId == NoticeDef.CROSS_PLATFORM_DISABLE_MATCHING then
		PlatformShellActivityService:clearCurrentActivity("cross_platform_team_notice")
		PlatformCrossPlatformService:showMatchPermissionDeniedToast()

		return true
	elseif noticeId == NoticeDef.CROSS_PLATFORM_DISABLE_TEAM then
		PlatformShellActivityService:clearCurrentActivity("cross_platform_team_notice")
		PlatformCrossPlatformService:showFamilyConflictToast()

		return true
	elseif noticeId == NoticeDef.CROSS_PLATFORM_DISABLE_WORLD then
		PlatformShellActivityService:clearCurrentActivity("cross_platform_team_notice")
		PlatformCrossPlatformService:showFamilyConflictToast()

		return true
	end

	return false
end

function M:tryMaskPlayerName(playerInfo, rawName, noticeId)
	local uid = playerInfo and playerInfo.uid and tostring(playerInfo.uid)

	if not playerInfo or string.isNilOrEmpty(uid) then
		return rawName
	end

	if pg and pg.me and uid == tostring(pg.me.uid) then
		return rawName
	end

	if string.isNilOrEmpty(rawName) then
		return rawName
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ToastName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return displayName
end

function M:handleRequireSpaceFollowNotify(playerId)
	local playerInfo = self:getPlayerInfo(playerId)

	return M.showSpaceFollowNotify(tostring(playerId), playerInfo, "REQUIRE_SPACE_FOLLOW")
end

function M:handleInviteSpaceFollowNotify(playerId)
	local playerInfo = self:getPlayerInfo(playerId)

	return M.showSpaceFollowNotify(tostring(playerId), playerInfo, "INVITE_SPACE_FOLLOW")
end

return M
