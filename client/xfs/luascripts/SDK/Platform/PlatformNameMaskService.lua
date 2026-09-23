-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformNameMaskService.lua

local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformNameMaskService = {}

PlatformNameMaskService.Action = {
	KickSpaceFollowName = "ugc_kick_space_follow_name",
	DungeonInviteName = "ugc_dungeon_invite_name",
	InfoPlayerCardName = "ugc_info_player_card_name",
	ChatChannelLastMessagePlayerName = "ugc_chat_channel_last_message_player_name",
	AccusationName = "ugc_accusation_name",
	ChatMessagePlayerName = "ugc_chat_message_player_name",
	MarkShareViewName = "ugc_mark_share_view_name",
	ChatGroupChannelName = "ugc_chat_group_channel_name",
	HomeCarName = "ugc_home_car_name",
	ChatChannelName = "ugc_chat_channel_name",
	HomeCarOrnament = "ugc_home_car_ornament",
	FriendTitlePrefixName = "ugc_friend_title_prefix_name",
	HomeCampVisitName = "ugc_home_camp_visit_name",
	FriendOnlineToastName = "ugc_friend_online_toast_name",
	HomeCampInviteFriendName = "ugc_home_camp_invite_friend_name",
	FriendshipToastName = "ugc_friendship_toast_name",
	HomeStationManageName = "ugc_home_station_manage_name",
	FriendshipUpName = "ugc_friendship_up_name",
	HomeNameTip = "ugc_home_name_tip",
	FriendIntimacyName = "ugc_friend_intimacy_name",
	HomeCampCustomName = "ugc_home_camp_custom_name",
	FriendGiftName = "ugc_friend_gift_name",
	MailGiftGiverName = "ugc_mail_gift_giver_name",
	FriendNewComponentName = "ugc_friend_new_component_name",
	PetUtilSourceName = "ugc_pet_util_source_name",
	FriendInviteListName = "ugc_friend_invite_list_name",
	PetDetailSourceName = "ugc_pet_detail_source_name",
	FriendAddName = "ugc_friend_add_name",
	PetExchangePlayerName = "ugc_pet_exchange_player_name",
	FriendApplyName = "ugc_friend_apply_name",
	PetExchangeTipPlayerName = "ugc_pet_exchange_tip_player_name",
	FriendRecommendName = "ugc_friend_recommend_name",
	InteractSwitchPetName = "ugc_interact_switch_pet_name",
	FriendListName = "ugc_friend_list_name",
	InteractSwitchPlayerName = "ugc_interact_switch_player_name",
	ExitFollowName = "ugc_exit_follow_name",
	TopLogoName = "ugc_top_logo_name",
	FollowEnterName = "ugc_follow_enter_name",
	TopLogoSubName = "ugc_top_logo_sub_name",
	InviteSpaceFollowRetName = "ugc_invite_space_follow_ret_name",
	TopLogoCarBoardName = "ugc_top_logo_car_board_name",
	SpaceFollowRequestRetName = "ugc_space_follow_request_ret_name",
	TestNameOld = "ugc_name_old",
	SpaceFollowGiveConfirmName = "ugc_space_follow_give_confirm_name",
	TestNameNew = "ugc_name_new",
	ToastName = "ugc_toast_name",
	TestNameAlive = "ugc_name_alive",
	TeamMatchRefuseName = "ugc_team_match_refuse_name",
	BossRushChallengeMemberName = "ugc_boss_rush_challenge_member_name",
	TeamMatchPlayerName = "ugc_team_match_player_name",
	BossRushChallengeResultMemberName = "ugc_boss_rush_challenge_result_member_name",
	TeamInvitePlayerName = "ugc_team_invite_player_name",
	RankBasePlayerName = "ugc_rank_base_player_name",
	LoadingTeamMemberName = "ugc_loading_team_member_name",
	CashGiftReceiverName = "ugc_cash_gift_receiver_name",
	TeamRoomMemberName = "ugc_team_room_member_name",
	FriendSetupFriendName = "ugc_friend_setup_friend_name",
	FriendSetupAddMemberName = "ugc_friend_setup_add_member_name",
	InviteFriendListName = "ugc_invite_friend_list_name",
	DungeonInvitePopupPlayerName = "ugc_dungeon_invite_popup_player_name"
}
PlatformNameMaskService.FriendSelectionListActions = {
	[PlatformNameMaskService.Action.FriendGiftName] = true,
	[PlatformNameMaskService.Action.FriendInviteListName] = true,
	[PlatformNameMaskService.Action.FriendNewComponentName] = true,
	[PlatformNameMaskService.Action.InviteFriendListName] = true,
	[PlatformNameMaskService.Action.FriendSetupAddMemberName] = true,
	[PlatformNameMaskService.Action.TeamInvitePlayerName] = true,
	[PlatformNameMaskService.Action.DungeonInviteName] = true,
	[PlatformNameMaskService.Action.HomeCampInviteFriendName] = true
}
PlatformNameMaskService.maskedNameByUid = {}

function PlatformNameMaskService.isFriendSelectionListAction(action)
	return PlatformNameMaskService.FriendSelectionListActions[action] == true
end

function PlatformNameMaskService.makeMaskedPlayerName(key)
	if key == nil or key == "" then
		return string.format("player%05d", math.random(0, 99999))
	end

	local hash = 5381
	local s = tostring(key)

	for i = 1, #s do
		hash = (hash * 33 + string.byte(s, i)) % 1000000007
	end

	return string.format("player%05d", hash % 100000)
end

function PlatformNameMaskService.getMaskedNameCacheKey(uid)
	if uid == nil then
		return nil
	end

	local key = tostring(uid)

	if key == "" then
		return nil
	end

	return key
end

function PlatformNameMaskService.peekMaskedName(uid)
	local key = PlatformNameMaskService.getMaskedNameCacheKey(uid)

	if not key then
		return nil
	end

	return PlatformNameMaskService.maskedNameByUid[key]
end

function PlatformNameMaskService.ensureMaskedName(uid)
	local key = PlatformNameMaskService.getMaskedNameCacheKey(uid)

	if not key then
		return PlatformNameMaskService.makeMaskedPlayerName()
	end

	local cachedName = PlatformNameMaskService.maskedNameByUid[key]

	if cachedName then
		return cachedName
	end

	cachedName = PlatformNameMaskService.makeMaskedPlayerName(key)
	PlatformNameMaskService.maskedNameByUid[key] = cachedName

	return cachedName
end

function PlatformNameMaskService.clearMaskedName(uid)
	local key = PlatformNameMaskService.getMaskedNameCacheKey(uid)

	if not key then
		return
	end

	PlatformNameMaskService.maskedNameByUid[key] = nil
end

function PlatformNameMaskService.isLocalPlayer(uid, playerInfo)
	local me = pg and pg.me
	local localUid = me and me.uid
	local localPlayerId = me and me.id

	if localUid == nil and localPlayerId == nil then
		return false
	end

	function PlatformNameMaskService.matchesLocalId(value)
		if value == nil then
			return false
		end

		return localUid ~= nil and tostring(value) == tostring(localUid) or localPlayerId ~= nil and tostring(value) == tostring(localPlayerId)
	end

	if PlatformNameMaskService.matchesLocalId(uid) then
		return true
	end

	return type(playerInfo) == "table" and (PlatformNameMaskService.matchesLocalId(playerInfo.uid) or PlatformNameMaskService.matchesLocalId(playerInfo.playerId))
end

function PlatformNameMaskService.isPlatformFriend(playerInfo)
	return type(playerInfo) == "table" and playerInfo.isPlatformFriend == true
end

function PlatformNameMaskService.getChatSystem()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformNameMaskService.getCachedPlayerInfo(uid)
	local chatSystem = PlatformNameMaskService.getChatSystem()

	if string.isNilOrEmpty(uid) or not chatSystem or not chatSystem.getPlayerInfo then
		return nil
	end

	return chatSystem:getPlayerInfo(uid)
end

function PlatformNameMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	if type(playerInfo) == "table" then
		return playerInfo
	end

	return PlatformNameMaskService.getCachedPlayerInfo(uid)
end

function PlatformNameMaskService.resolveBlockPlayerInfo(uid, playerInfo)
	local platformUserId = type(playerInfo) == "table" and type(PlatformIdentityUtils.resolvePlatformUserId) == "function" and PlatformIdentityUtils.resolvePlatformUserId(playerInfo) or nil

	if not string.isNilOrEmpty(platformUserId) then
		return playerInfo
	end

	local cachedPlayerInfo = PlatformNameMaskService.getCachedPlayerInfo(uid)

	if type(cachedPlayerInfo) == "table" then
		return cachedPlayerInfo
	end

	return playerInfo
end

function PlatformNameMaskService.isBlockedByLocalUser(playerInfo)
	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false
	end

	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
end

function PlatformNameMaskService.makeAllowContext(reason)
	return {
		nameVisible = true,
		nameDecision = PlatformTextCommunicationService.Decision.Allow,
		nameReason = reason or string.Empty
	}
end

function PlatformNameMaskService.makeDenyContext(reason, ugcDecision)
	return {
		ugcVisible = false,
		nameVisible = false,
		ugcDecision = ugcDecision or PlatformTextCommunicationService.Decision.Deny,
		nameDecision = PlatformTextCommunicationService.Decision.Deny,
		nameReason = reason or string.Empty
	}
end

function PlatformNameMaskService.makeNameContext(decision, visible, reason)
	return {
		ugcDecision = decision,
		ugcVisible = visible ~= false,
		nameDecision = decision,
		nameVisible = visible ~= false,
		nameReason = reason or string.Empty
	}
end

function PlatformNameMaskService.isCurrentConsoleFamily()
	return PlatformIdentityUtils and type(PlatformIdentityUtils.getCurrentPlatformFamily) == "function" and type(PlatformIdentityUtils.isConsoleFamily) == "function" and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformNameMaskService.isCurrentXboxFamily()
	return PlatformIdentityUtils and type(PlatformIdentityUtils.getCurrentPlatformFamily) == "function" and PlatformIdentityUtils.Family and PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.Xbox
end

function PlatformNameMaskService.isCurrentPSNFamily()
	return PlatformIdentityUtils and type(PlatformIdentityUtils.getCurrentPlatformFamily) == "function" and PlatformIdentityUtils.Family and PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation
end

function PlatformNameMaskService.getLocalUgcPolicy()
	if not PlatformUGCService or type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		logger:error("PlatformNameMaskService local UGC policy service missing; allow by default")

		return nil
	end

	return PlatformUGCService:peekLocalPolicy()
end

function PlatformNameMaskService.resolveLocalUgcVisibility(resolvedPlayerInfo, action)
	local policy = PlatformNameMaskService.getLocalUgcPolicy()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}
	local Decision = PlatformTextCommunicationService.Decision

	if policy == nil then
		logger:error("PlatformNameMaskService local UGC policy cache missing; allow by default")

		return Decision.Allow, true, PlatformNameMaskService.makeNameContext(Decision.Allow, true, "local_ugc_policy_cache_missing")
	end

	if policy == Policy.Blocked or policy == "blocked" then
		return Decision.Deny, false, PlatformNameMaskService.makeNameContext(Decision.Deny, false, "local_ugc_privacy_blocked")
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		local visible = PlatformNameMaskService.isPlatformFriend(resolvedPlayerInfo)
		local decision = visible and Decision.Allow or Decision.Deny

		if not visible then
			return decision, visible, PlatformNameMaskService.makeNameContext(decision, visible, "local_ugc_privacy_friends_only")
		end

		if PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
			local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, "local_ugc_privacy_friends_only")
			local targetDecision = targetVisible and Decision.Allow or Decision.Deny

			return targetDecision, targetVisible, PlatformNameMaskService.makeNameContext(targetDecision, targetVisible, targetContext and targetContext.ugcReason or "local_ugc_privacy_friends_only")
		end

		return decision, visible, PlatformNameMaskService.makeNameContext(decision, visible, "local_ugc_privacy_friends_only")
	end

	local reason = (policy == Policy.Fallback or policy == "fallback") and "local_ugc_privacy_fallback" or "local_ugc_privacy_allow"

	if PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
		local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, reason)
		local targetDecision = targetVisible and Decision.Allow or Decision.Deny

		return targetDecision, targetVisible, PlatformNameMaskService.makeNameContext(targetDecision, targetVisible, targetContext and targetContext.ugcReason or reason)
	end

	return Decision.Allow, true, PlatformNameMaskService.makeNameContext(Decision.Allow, true, reason)
end

function PlatformNameMaskService:getMaskedPlayerName(uid)
	return PlatformNameMaskService.ensureMaskedName(uid)
end

function PlatformNameMaskService:checkNameVisibilityNow(uid, playerInfo, action)
	local resolvedPlayerInfo = PlatformNameMaskService.resolveSeedPlayerInfo(uid, playerInfo)

	if PlatformNameMaskService.isLocalPlayer(uid, resolvedPlayerInfo) then
		if action ~= PlatformNameMaskService.Action.ChatGroupChannelName then
			return PlatformTextCommunicationService.Decision.Allow, true, resolvedPlayerInfo, PlatformNameMaskService.makeAllowContext("local_player")
		else
			local decision, visible, context = PlatformNameMaskService.resolveLocalUgcVisibility(resolvedPlayerInfo)

			return decision, visible, resolvedPlayerInfo, context
		end
	end

	local blockPlayerInfo = PlatformNameMaskService.resolveBlockPlayerInfo(uid, resolvedPlayerInfo)
	local blockState = PlatformNameMaskService.isBlockedByLocalUser(blockPlayerInfo)

	if blockState == true or blockState == nil then
		local reason = blockState == true and "local_block_list" or "local_block_list_pending"

		return PlatformTextCommunicationService.Decision.Deny, false, resolvedPlayerInfo, PlatformNameMaskService.makeDenyContext(reason)
	end

	local decision, visible, context = PlatformNameMaskService.resolveLocalUgcVisibility(resolvedPlayerInfo, action)

	return decision, visible, resolvedPlayerInfo, context
end

function PlatformNameMaskService:resolveNameVisibility(action, uid, playerInfo, onResolved)
	local decision, visible, resolvedPlayerInfo, context = self:checkNameVisibilityNow(uid, playerInfo, action)

	if type(onResolved) == "function" then
		onResolved(visible ~= false, resolvedPlayerInfo, context or {})
	end

	return false
end

function PlatformNameMaskService.resolvePlatformDisplayRawTextUnsafe(uid, playerInfo, rawText, options)
	if string.isNilOrEmpty(uid) or type(PlatformFriendListService.resolveDisplayPlayerInfo) ~= "function" then
		return rawText
	end

	local cachedInfo = PlatformNameMaskService.getCachedPlayerInfo(uid)
	local seedPlayerInfo = type(cachedInfo) == "table" and cachedInfo or type(playerInfo) == "table" and playerInfo or nil

	if type(seedPlayerInfo) ~= "table" then
		return rawText
	end

	if seedPlayerInfo.isPlatformFriend ~= true and type(PlatformFriendListService.getPlatformFriendEntries) == "function" then
		PlatformFriendListService:getPlatformFriendEntries({
			mappedOnly = true
		})

		cachedInfo = PlatformNameMaskService.getCachedPlayerInfo(uid)

		if type(cachedInfo) == "table" then
			seedPlayerInfo = cachedInfo
		end
	end

	local displayInfo = PlatformFriendListService:resolveDisplayPlayerInfo(PlatformNameMaskService.getChatSystem(), uid, seedPlayerInfo, options)

	if displayInfo ~= seedPlayerInfo and type(displayInfo) == "table" and not string.isNilOrEmpty(displayInfo.playerName) then
		logger:info("[platform_name_mask] override rawText to platform id uid=%s rawText=%s platformName=%s seedFromCache=%s", tostring(uid), tostring(rawText), tostring(displayInfo.playerName), tostring(type(cachedInfo) == "table"))

		return displayInfo.playerName
	end

	return rawText
end

function PlatformNameMaskService.resolvePlatformDisplayRawText(uid, playerInfo, rawText, options)
	local ok, result = pcall(PlatformNameMaskService.resolvePlatformDisplayRawTextUnsafe, uid, playerInfo, rawText, options)

	if not ok then
		logger:error("[platform_name_mask] resolve gamertag failed uid=%s, fallback rawText=%s err=%s", tostring(uid), tostring(rawText), tostring(result))

		return rawText
	end

	return result
end

function PlatformNameMaskService.resolveDisplayName(options, createMaskedName)
	if type(options) ~= "table" then
		return "", true, nil, PlatformNameMaskService.makeAllowContext("invalid_options")
	end

	local rawText = options.rawText or ""

	if PlatformNameMaskService.isFriendSelectionListAction(options.action) then
		options.allowPurePlatformId = true
	end

	rawText = PlatformNameMaskService.resolvePlatformDisplayRawText(options.uid, options.playerInfo, rawText, options) or rawText

	if not PlatformNameMaskService.isCurrentConsoleFamily() then
		return rawText, true, options.playerInfo, PlatformNameMaskService.makeAllowContext("non_console_family")
	end

	local decision, visible, resolvedInfo, context = PlatformNameMaskService:checkNameVisibilityNow(options.uid, options.playerInfo, options.action)

	if visible == false then
		local display = createMaskedName ~= false and PlatformNameMaskService.ensureMaskedName(options.uid) or PlatformNameMaskService.peekMaskedName(options.uid) or rawText

		return display, false, resolvedInfo, context
	end

	PlatformNameMaskService.clearMaskedName(options.uid)

	return rawText, true, resolvedInfo, context
end

function PlatformNameMaskService.getMaskedDisplayName(options)
	return PlatformNameMaskService.resolveDisplayName(options, true)
end

function PlatformNameMaskService:getVisibleProfileSignature(uid, playerInfo, rawSign)
	rawSign = rawSign or ""

	if PlatformNameMaskService.isLocalPlayer(uid, playerInfo) then
		return rawSign
	end

	local _, visible = self:checkNameVisibilityNow(uid, playerInfo, PlatformNameMaskService.Action.InfoPlayerCardName)

	if visible == false then
		return " "
	end

	return rawSign
end

return PlatformNameMaskService
