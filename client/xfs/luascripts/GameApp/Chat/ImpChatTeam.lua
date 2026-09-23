-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\ImpChatTeam.lua

local ChatSystem = require("GameApp.Chat.ChatSystem")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SysConfigData = require("Data.sys_config_data")
local lume = require("Core.Common.lume")
local LevelData = require("Data.level_data")
local Time = require("Core.Common.Time")
local FuncIdConfigData = require("Data.func_index_config_data")
local EntityManager = require("Core.Common.EntityManager")
local ClientUtils = require("Utils.ClientUtils")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local Utils = require("Common.Utils.Utils")
local spaceFollowUnavailableKeys = {}

function ChatSystem:getPlayerTeamMemberCount(playerId)
	local playerInfo = self:getPlayerInfo(playerId)

	if playerInfo then
		return playerInfo.teamId and playerInfo.teamId ~= "" and playerInfo.teamMembers or 0
	end

	return 0
end

function ChatSystem:CheckCanTeamInvite(playerInfo)
	if pg.me:isInTeam() and pg.me:isTeamFull() then
		return false
	end

	return playerInfo.teamId == nil or playerInfo.teamId == "" or playerInfo.teamMembers == 1
end

function ChatSystem:CheckCanTeamApply(playerInfo)
	if pg.me:isInTeam(true) then
		return false
	end

	return playerInfo.teamId and playerInfo.teamId ~= "" and playerInfo.teamMembers < Const.TEAM_BASE.MAX_PLAYER_NUM and playerInfo.teamMembers > 1
end

function ChatSystem:teamHandle(playerId, cb, extraInfo)
	if pg.me and pg.me.space and Utils.isSpaceDungeon(pg.me.space.spaceType) then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_APPLY_ERROR_SELF_IN_DUNGEON"))

		return
	end

	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(FuncIdConfigData[Const.FUNCTION_NAME.TEAM].unlockDesc))

		return
	end

	local querySent = self:getPlayerInfoFromServer(playerId, self.queryPlayerInfoType.ApplyTeam, cb, extraInfo)

	if not querySent then
		local playerInfo = self:getPlayerInfo(playerId)

		if playerInfo then
			self:teamHandleInner(playerId, playerInfo, extraInfo)

			if cb then
				cb(playerInfo)
			end
		else
			logger:warn("teamHandle no cached playerInfo playerId=%s", tostring(playerId))
		end
	end
end

function ChatSystem:teamHandleInner(playerId, playerInfo, extraInfo)
	if playerInfo == nil then
		logger:warn("teamHandleInner abort: playerInfo nil playerId=%s", tostring(playerId))

		return
	end

	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	local _h = ChatSystem._platformHooks
	local platformCanHandleOfflineInvite = _h and _h.canHandleOfflineTeamInvite and _h.canHandleOfflineTeamInvite(self, playerId, playerInfo, extraInfo) == true

	if not playerInfo.online and not platformCanHandleOfflineInvite then
		pg.global.ui.tips:showTextTipById(NoticeDef.TEAM_INVITE_MEMBER_OFFLINE)

		return
	end

	if extraInfo and extraInfo.isDungeonInvite and (not playerInfo.teamId or playerInfo.teamId == "") then
		pg.global.ui.tips:showTextTip(pg.getGameString("INVITATION_EXPIRED"))

		return
	end

	if not pg.me:isMatchStatusInit() and (not pg.me:isInSingleTeam() or not self:CheckCanTeamApply(playerInfo)) then
		pg.global.ui.tips:showTextTip(pg.getGameString("MATCHING_TEAM_INVITE_TIP"))

		return
	end

	local cdTime = SysConfigData.INVITE_CD

	if self.teamInviteHistory[playerId] and self.teamInviteHistory[playerId] + cdTime > Time.realSecondCache then
		logger:warn("teamHandleInner operate too many playerId=%s lastInviteTime=%s now=%s cd=%s remain=%s", tostring(playerId), tostring(self.teamInviteHistory[playerId]), tostring(Time.realSecondCache), tostring(cdTime), tostring(self.teamInviteHistory[playerId] + cdTime - Time.realSecondCache))
		pg.global.ui.tips:showTextTip(pg.getGameString("OPERATE_TOO_MANY"))

		return
	end

	self.teamInviteHistory[playerId] = Time.realSecondCache

	if self:CheckCanTeamApply(playerInfo) then
		pg.me:requestJoinTeam(playerId)
	elseif self:CheckCanTeamInvite(playerInfo) then
		if pg.me:isInTeam() and not pg.me:isTeamLeader() then
			pg.global.ui.tips:showTextTip(pg.getGameString("TEAMP_MEMBER_MEET_INVITE_TIP"))

			return
		end

		pg.me:inviteTeamMember(playerId, extraInfo)
	elseif pg.me:isInTeam() and pg.me:isTeamFull() then
		pg.global.ui.tips:showTextTip(pg.getGameString("SELF_TEAM_FULL"))
	elseif pg.me:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("ALREADY_HAVE_TEAM"))
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("OTHER_TEAM_FULL"))
	end
end

function ChatSystem:checkEnterWorldInviteInCD(playerId)
	local cdTime = SysConfigData.INVITE_CD

	if not self.enterWorldInviteHistory then
		self.enterWorldInviteHistory = {}
	end

	if self.enterWorldInviteHistory[playerId] and self.enterWorldInviteHistory[playerId] + cdTime > Time.realSecondCache then
		pg.global.ui.tips:showTextTip(pg.getGameString("OPERATE_TOO_MANY"))

		return true
	end

	self.enterWorldInviteHistory[playerId] = Time.realSecondCache

	return false
end

function ChatSystem:checkEnterWorldRequestInCD(playerId)
	local cdTime = SysConfigData.INVITE_CD

	if not self.enterWorldRequestHistory then
		self.enterWorldRequestHistory = {}
	end

	if self.enterWorldRequestHistory[playerId] and self.enterWorldRequestHistory[playerId] + cdTime > Time.realSecondCache then
		pg.global.ui.tips:showTextTip(pg.getGameString("OPERATE_TOO_MANY"))

		return true
	end

	self.enterWorldRequestHistory[playerId] = Time.realSecondCache

	return false
end

function ChatSystem:recvTeamInvite(uid, inviterInfo, dungeonSceneId, hardLv)
	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	local extraParam = {
		type = 0,
		tIndex = 1,
		funcName = Const.FUNCTION_NAME.TEAM
	}

	if dungeonSceneId and dungeonSceneId > 0 then
		extraParam = {
			type = 0,
			tIndex = 1,
			dungeonSceneId = dungeonSceneId,
			hardLv = hardLv,
			funcName = Const.FUNCTION_NAME.TEAM
		}
	end

	self:setPlayerData(uid, inviterInfo)

	local notice = dungeonSceneId and dungeonSceneId > 0 and pg.getGameString("DUNGEON_INVITE") or pg.getGameString("TEAM_INVITE")

	local function showTeamInviteNotice(playerInfo)
		if playerInfo then
			self:setPlayerData(uid, playerInfo)
		end

		local autoAcceptType = Const.FriendshipPermissionType.TeamAutoAccept
		local autoAcceptEnabled = pg.me:isFriendFuncEnabled(uid, autoAcceptType)

		pg.global.ui.tips:addHudNotice(uid, self.playerDatas[uid], notice, SysConfigData.WAIT_INVITE_TIME, function()
			pg.me:acceptTeamInvite(uid, true)
		end, function()
			pg.me:acceptTeamInvite(uid, false)
		end, function()
			pg.me:acceptTeamInvite(uid, autoAcceptEnabled)
		end, extraParam)
	end

	pg.me:queryPlayerInfo(uid, self.queryPlayerInfoType.RecvTeamInvite, true, showTeamInviteNotice)
end

function ChatSystem:recvJoinRequest(uid, applicantInfo)
	self:setPlayerData(uid, applicantInfo)

	local autoAcceptType = Const.FriendshipPermissionType.TeamAutoAccept
	local autoAcceptEnabled = pg.me:isFriendFuncEnabled(uid, autoAcceptType)

	pg.global.ui.tips:addHudNotice(uid, self.playerDatas[uid], pg.getGameString("TEAM_APPLY"), SysConfigData.WAIT_APPLICANT_TIME, function()
		pg.me:acceptTeamJoinRequest(uid, true)
	end, function()
		pg.me:acceptTeamJoinRequest(uid, false)
	end, function()
		pg.me:acceptTeamJoinRequest(uid, autoAcceptEnabled)
	end, {
		funcName = Const.FUNCTION_NAME.TEAM
	})
end

function ChatSystem:recvGatherTeammate(uid, playerInfo)
	self:setPlayerData(uid, playerInfo)
	pg.global.ui.tips:addHudNotice(uid, self.playerDatas[uid], pg.getGameString("TEAM_ENTER_WORLD_INVITE"), SysConfigData.WAIT_APPLICANT_TIME, function()
		pg.me:acceptGatherTeammate(uid, true)
	end, function()
		pg.me:acceptGatherTeammate(uid, false)
	end, function()
		pg.me:acceptGatherTeammate(uid, false)
	end, {
		funcName = Const.FUNCTION_NAME.TEAM
	})
end

function ChatSystem:recvTeamNotice(playerInfo, noticeId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvTeamNotice and _h.recvTeamNotice(self, playerInfo, noticeId) then
		return
	end

	if playerInfo == nil then
		return
	end

	if playerInfo.uid then
		self:setPlayerData(playerInfo.uid, playerInfo)
	end

	local displayName = playerInfo.playerName or ""

	displayName = _h and _h.tryMaskPlayerName and _h.tryMaskPlayerName(self, playerInfo, displayName, noticeId) or displayName

	if noticeId == NoticeDef.TEAM_MEMBER_ENTER_TEAM then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("ENTER_TEAM")))
	elseif noticeId == NoticeDef.TEAM_MEMBER_LEAVE_TEAM then
		if playerInfo.uid == pg.me.uid then
			if playerInfo.teamId ~= pg.me:getCurTeamInfo().teamId then
				pg.global.ui.tips:showTextTip(pg.getGameString("LEAVE_GAMEPLAY_TEAM"))
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("LEAVE_TEAM"))
			end
		elseif playerInfo.teamId ~= pg.me:getCurTeamInfo().teamId then
			pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("LEAVE_GAMEPLAY_TEAM")))
		else
			pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("LEAVE_TEAM")))
		end
	elseif noticeId == NoticeDef.TEAM_MEMBER_ENTER_WORLD then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("ENTER_WORLD")))
	elseif noticeId == NoticeDef.TEAM_ENTER_DUNGEON then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ENTER_DUNGEON"))
		facade:SendMessageCommand(MessageName.TEAM_ENTER_DUNGEON)
	elseif noticeId == NoticeDef.TEAM_ENTER_WORLD_REJECT_BY_PLAYER then
		local tip = pg.getGameString("TEAM_REFUSE_ENTER_WORLD")

		if tip ~= "" then
			pg.global.ui.tips:showTextTip(string.gsub(tip, "{0}", displayName), 1)
		end
	elseif noticeId == NoticeDef.CANNOT_ENTER_HOMECAMP then
		PlatformNoticeUtils.showTextTipById(noticeId)
	elseif noticeId == NoticeDef.TEAM_INVITEE_IN_DUNGEON then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_APPLY_ERROR_OTHER_IN_DUNGEON"))
	elseif noticeId == NoticeDef.TEAM_REFUSE_APPLY_JOIN then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_REFUSE_APPLY_JOIN"))
	elseif noticeId == NoticeDef.TEAM_REJECT_INVITE then
		local tip = pg.getGameString("TEAM_REFUSE_TEAM_INVITE")

		if tip ~= "" then
			pg.global.ui.tips:showTextTip(string.gsub(tip, "{0}", displayName), 1)
		end
	elseif noticeId == NoticeDef.TEAM_MEMBER_CHANGE_LEADER then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("TEAM_LEADER_CHANGE")))
	elseif noticeId == NoticeDef.TEAM_GO_LEADER_WORLD then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ENTER_LEADER_WORLD"))
	elseif noticeId == NoticeDef.TEAM_BACK_SINGLE_WORLD then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_BACK_SELF_WORLD"))
	elseif noticeId == NoticeDef.TEAM_MSG_START_DUN_ERROR_PLAYER_NUM then
		ClientUtils.showBubbleMessageById(noticeId)
	elseif noticeId == NoticeDef.TEAM_MSG_START_DUN_ERROR_PLAYER_LEVEL then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_START_DUN_ERROR_PLAYER_LEVEL"))
	elseif noticeId == NoticeDef.TEAM_MSG_COMFIRM_REFUSE then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("TEAM_COMFIRM_REFUSE")))
		facade:SendMessageCommand(MessageName.TEAM_CONFIRM_FAIL)
	elseif noticeId == NoticeDef.TEAM_MSG_PLAYER_MATCH_STATUS_NOT_INIT then
		pg.global.showBubbleMessageById(11117)
	elseif noticeId == NoticeDef.TEAM_MSG_PLAYER_DUN_ERROR_CONFIG_NIL then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_APPLY_ERROR_DUNGEON_CONFIG_NIL"))
	elseif noticeId == NoticeDef.TEAM_MSG_PLAYER_DUN_ERROR_PRE_DUN then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("TEAM_APPLY_ERROR_PRE_DUNGEON_NOT_FINISH")))
	elseif noticeId == NoticeDef.TEAM_INVITE_SENT then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_INVITE_SUCCESS"))
	elseif noticeId == NoticeDef.TEAM_INVITEE_FUNCTION_UNLOCK then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_INVITE_FUNCTION_UNLOCK"))
	elseif noticeId == NoticeDef.TEAM_DISBAND_TEAM then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_DISBAND_TEAM"))
	elseif noticeId == NoticeDef.TEAM_MEMBER_LEAVE_WORLD then
		pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(displayName, pg.getGameString("LEAVE_WORLD")))
	else
		ClientUtils.showBubbleMessageById(noticeId)
	end
end

function ChatSystem:recvEnterWorldRequest(uid, playerInfo)
	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	self:setPlayerData(uid, playerInfo)

	local autoAcceptType = Const.FriendshipPermissionType.EnterWorldAutoAccept
	local autoAcceptEnabled = pg.me:isFriendFuncEnabled(uid, autoAcceptType)
	local extraParam = {
		type = 2,
		tIndex = 1,
		funcName = Const.FUNCTION_NAME.TEAM
	}

	pg.global.ui.tips:addHudNotice(uid, self.playerDatas[uid], pg.getGameString("APPLY_ENTER_WORLD"), SysConfigData.WAIT_APPLICANT_TIME, function()
		pg.me:handleEnterWorldRequest(uid, true)
	end, function()
		pg.me:handleEnterWorldRequest(uid, false)
	end, function()
		pg.me:handleEnterWorldRequest(uid, autoAcceptEnabled)
	end, extraParam)
end

function ChatSystem:recvEnterWorldInvite(uid, playerInfo, inviteWorldParams)
	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	self:setPlayerData(uid, playerInfo)

	local extraParam = {
		funcName = Const.FUNCTION_NAME.TEAM
	}

	if inviteWorldParams and (inviteWorldParams.type == Const.InviteWorldType.EXCHANGE_PET or inviteWorldParams.type == Const.InviteWorldType.NORMAL_INVITE) then
		if pg.me:getExchangeSocialInfo() ~= nil then
			return
		end

		extraParam = {
			type = 4,
			tIndex = 1,
			funcName = Const.FUNCTION_NAME.TEAM
		}
	end

	pg.global.ui.tips:addHudNotice(uid, self.playerDatas[uid], pg.getGameString("TEAM_ENTER_WORLD_INVITE"), SysConfigData.WAIT_APPLICANT_TIME, function()
		pg.me:handleEnterWorldInvite(uid, true)
	end, function()
		pg.me:handleEnterWorldInvite(uid, false)
	end, function()
		pg.me:handleEnterWorldInvite(uid, false)
	end, extraParam)
end

function ChatSystem:setTeamId(teamId)
	for _, channel in ipairs(self.worldChannelListData) do
		if channel.type == self.channelType.Team then
			if channel.groupId ~= teamId then
				self:cleanChannelMessage(self.channelType.Team)
			end

			channel.groupId = teamId

			return
		end
	end
end

function ChatSystem:receiveApplyTeamDungeon(dungeonSceneId)
	pg.global.ui.tips:addHudNotice(pg.me.teamInfo.leaderUid, self.playerDatas[pg.me.teamInfo.leaderUid], pg.getGameString("APPLY_TEAM_DUNGEON"), SysConfigData.MAX_WAIT_CONFIRM_TIME, function()
		local hasTeamRoom = pg.me.teamInfo.prepareInfos and lume.getMapLen(pg.me.teamInfo.prepareInfos) > 0

		if hasTeamRoom then
			pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_COMFIRM_REFUSE"))
		end
	end, function()
		return
	end, function()
		return
	end, {
		type = 0,
		tIndex = 1,
		dungeonSceneId = dungeonSceneId,
		funcName = Const.FUNCTION_NAME.TEAM
	})
end

function ChatSystem:syncTeamRoomAni(configId)
	pg.me:syncTeamRoomAction(configId)
end

function ChatSystem:recvSyncTeamRoomAni(uid, configId)
	if uid == pg.me.uid then
		return
	end

	if pg.global.ui:checkUIVisible(UIConst.UI_ID_TEAM_ROOM) then
		pg.global.ui.teamRoom.uiScene:syncTeamRoomAni(uid, configId)
	end
end

function ChatSystem:setSpaceFollowAvailable(key, available)
	if available == nil then
		available = key
		key = "default"
	end

	key = key or "default"

	if available == false then
		spaceFollowUnavailableKeys[key] = true
	else
		spaceFollowUnavailableKeys[key] = nil
	end

	if not self:checkSpaceFollowAvailable() and pg.me and pg.me.space and pg.me.space.getSpaceFollowLeader and pg.me.space:getSpaceFollowLeader(pg.me.uid) then
		pg.me:exitSpaceFollow(true)
	end
end

function ChatSystem:checkSpaceFollowAvailable()
	return next(spaceFollowUnavailableKeys) == nil
end

function ChatSystem:handleRequireSpaceFollowNotify(playerId)
	local _h = ChatSystem._platformHooks

	if _h and _h.handleRequireSpaceFollowNotify and _h.handleRequireSpaceFollowNotify(self, playerId) then
		return
	end

	local playerInfo = self:getPlayerInfo(playerId)

	pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("REQUIRE_SPACE_FOLLOW"), playerInfo.playerName), 2)
end

function ChatSystem:handleInviteSpaceFollowNotify(playerId)
	local _h = ChatSystem._platformHooks

	if _h and _h.handleInviteSpaceFollowNotify and _h.handleInviteSpaceFollowNotify(self, playerId) then
		return
	end

	local playerInfo = self:getPlayerInfo(playerId)

	pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("INVITE_SPACE_FOLLOW"), playerInfo.playerName), 2)
end

function ChatSystem:checkAutoAcceptSpaceFollow(playerId, autoAcceptType)
	if autoAcceptType == ClientConst.AutoAcceptSpaceFollowType.All then
		return true
	end

	if autoAcceptType == ClientConst.AutoAcceptSpaceFollowType.FriendOnly then
		return self:checkFriendList(playerId)
	end

	return false
end

function ChatSystem:recvRequireSpaceFollow(playerId)
	pg.me:queryPlayerInfo(playerId, nil, true, function(playerData)
		if PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerData) == true then
			return
		end

		local autoAcceptEnabled = self:checkAutoAcceptSpaceFollow(playerId, pg.game.setting:getAutoAcceptSpaceFollowRequire())

		if autoAcceptEnabled then
			pg.me:agreeSpaceFollow(playerId)

			return
		end

		self:handleTopLogoFriendInteract(playerId, true, ClientConst.FriendInteractType.Require)
		pg.global.ui.tips:addHudNotice(playerId, playerData, pg.getGameString("REQUIRE_SPACE_FOLLOW"), 10, function()
			pg.me:agreeSpaceFollow(playerId)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Require)
		end, function()
			pg.me:refuseSpaceFollow(playerId, ClientConst.FriendInteractType.Require)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Require)
		end, function()
			pg.me:refuseSpaceFollow(playerId, ClientConst.FriendInteractType.Require)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Require)
		end, {
			type = 0,
			tIndex = 1,
			overrideTitleText = pg.getGameString("ENTER_FOLLOW_TEXT")
		})
	end)
end

function ChatSystem:recvInviteSpaceFollow(playerId)
	pg.me:queryPlayerInfo(playerId, nil, true, function(playerData)
		if PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerData) == true then
			return
		end

		local autoAcceptEnabled = self:checkAutoAcceptSpaceFollow(playerId, pg.game.setting:getAutoAcceptSpaceFollowInvite())

		if autoAcceptEnabled then
			pg.me:agreeInviteSpaceFollow(playerId)

			return
		end

		self:handleTopLogoFriendInteract(playerId, true, ClientConst.FriendInteractType.Invite)
		pg.global.ui.tips:addHudNotice(playerId, playerData, pg.getGameString("INVITE_SPACE_FOLLOW"), 10, function()
			pg.me:agreeInviteSpaceFollow(playerId)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Invite)
		end, function()
			pg.me:refuseSpaceFollow(playerId, ClientConst.FriendInteractType.Invite)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Invite)
		end, function()
			pg.me:refuseSpaceFollow(playerId, ClientConst.FriendInteractType.Invite)
			self:handleTopLogoFriendInteract(playerId, false, ClientConst.FriendInteractType.Invite)
		end, {
			type = 0,
			tIndex = 1,
			overrideTitleText = pg.getGameString("ENTER_FOLLOW_TEXT")
		})
	end)
end

function ChatSystem:spaceFollowCurLeader()
	if pg.me and pg.me.space and pg.me.space.followInfo then
		if pg.me.followState ~= Const.SpaceFollowMemberState.Normal then
			return
		end

		local leader = ""
		local followIndex = 1

		for leaderUid, followList in pairs(pg.me.space.followInfo) do
			for idx, followerUid in ipairs(followList) do
				if followerUid == pg.me.uid then
					leader = leaderUid
					followIndex = idx

					break
				end
			end
		end

		if not string.isNilOrEmpty(leader) and leader ~= pg.me.uid then
			local targetEntity = EntityManager.getEntityByUid(leader)

			if targetEntity and pg.pawn:followTarget(targetEntity.actorId) then
				pg.pawn:setFollowTargetDistanceByIndex(followIndex)
			end

			return
		end
	end

	self:cancelSpaceFollow()
end

function ChatSystem:cancelSpaceFollow()
	if pg.pawn and pg.pawn.eModel then
		pg.pawn:cancelFollowTarget()
	end
end

function ChatSystem:onSpaceFollowUpdate(followInfo)
	followInfo = followInfo or {
		pg.me.teamInfo and pg.me.teamInfo.followInfo
	} and pg.me.teamInfo.followInfo or {}

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.ball then
		pg.global.ui.hudV2.LD.ball:refreshUIVisible()
	end

	facade:SendMessageCommand(MessageName.SPACE_FOLLOW_UPDATE, {
		followInfo = followInfo
	})
end

function ChatSystem:handleTopLogoFriendInteract(playerId, visible, spaceFollowType, actionId)
	local ent = playerId == pg.me.uid and pg.me or EntityManager.getEntityByUid(playerId)

	if ent then
		local targetEnt = ent:isControllingPet() and ent:getCurPetEntity() or ent

		if visible == true then
			targetEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW)
		end

		targetEnt.eventEmitter:emit(EventConst.TOPLOGO_FRIEND_INTERACT, visible, spaceFollowType, actionId)
	end
end

function ChatSystem:openSpaceFollowPetGivePanel(petId, skipCultivationCheck)
	local followMemberUids = self:getGivePetEligibleFollowerUids(petId)

	if not followMemberUids or #followMemberUids <= 0 then
		return
	end

	local timeLeft = self:givePetTimeLeft(petId)

	if timeLeft <= 0 then
		return
	end

	if not skipCultivationCheck and pg.game.petManage:hasPetCultivation(petId) then
		pg.global.showConfirmMsgRaw(pg.getGameString("GIVE_PET_INHERIT_WARN"), pg.getGameString("GIVE_PET_INHERIT_DESC"), function()
			local canInherit, errType = pg.game.petManage:checkInheritSourcePetLegal(pg.me, petId)

			if not canInherit then
				local errNoticeId = pg.game.petManage:getErrNoticeId(errType)

				if errNoticeId then
					pg.global.showBubbleMessageById(errNoticeId)
				end

				return
			end

			pg.game.petManage:resetInheritDataModel()
			pg.game.petManage:setInheritSourcePetId(petId)
			pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_MAIN, {
				petId = petId
			})
		end, false, function()
			self:openSpaceFollowPetGivePanel(petId, true)
		end, true, nil, {
			okBtnDesc = pg.getGameString("GO_TO_INHERIT_PET"),
			cancelBtnDesc = pg.getGameString("GIVE_PET_DIRECTLY"),
			nextBtnDesc = pg.getGameString("COMMON_CANCEL"),
			okBtnType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
			cancelType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
			nextBtnType = UIConst.MENU_EXIT_BTN_TYPE.Cancel,
			cancelBtnKey = Const.ExitButtonType.TEMPORARY_EXIT
		})

		return
	end

	if #followMemberUids == 1 then
		pg.global.ui:open(UIConst.UI_ID_SPACE_FOLLOW_GIVE_CONFIRM, {
			petId = petId,
			playerId = followMemberUids[1],
			timeLeft = timeLeft
		})
	else
		pg.global.ui:open(UIConst.UI_ID_SPACE_FOLLOW_MEMBER, {
			petId = petId,
			spaceFollowMembers = followMemberUids,
			timeLeft = timeLeft
		})
	end
end

function ChatSystem:getGivePetEligibleFollowerUids(petId)
	local eligibleFollowerMap = pg.me.givePetEligibleFollowerMap

	if not eligibleFollowerMap then
		return
	end

	return eligibleFollowerMap[petId] or eligibleFollowerMap[tostring(petId)]
end

function ChatSystem:givePetTimeLeft(petId)
	local gotInFollowedMap = pg.me.gotInFollowedMap
	local gotInFollowedTime = gotInFollowedMap and (gotInFollowedMap[petId] or gotInFollowedMap[tostring(petId)])

	if not gotInFollowedTime then
		return -1
	end

	local timeLeft = gotInFollowedTime + SysConfigData.GIVE_PET_TIME_LIMIT - Time.secondCache

	return timeLeft > 0 and math.floor(timeLeft) or -1
end

function ChatSystem:checkCanGivePetAway(petId)
	local pet = pg.me:getPetInfo(petId)
	local followMemberUids = self:getGivePetEligibleFollowerUids(petId)

	return pet and followMemberUids and #followMemberUids > 0 and self:givePetTimeLeft(petId) > 0 and pg.me.space and pg.me.space:isSpaceFollowed(pg.me.uid)
end
