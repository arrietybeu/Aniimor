-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientTeamComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local LevelData = require("Data.level_data")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local MatchConfigData = require("Data.match_data")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local MatchConst = require("Common.Const.MatchConst")
local ListPool = require("Common.Container.ListPool")
local FuncIdConfigData = require("Data.func_index_config_data")
local ClientConst = require("Const.ClientConst")
local ConstData = require("Common.Const.Const")
local SysNoticeData = require("Data.sys_notice_data")
local TeamUtils = require("Utils.TeamUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local AppearanceActionData = require("Data.appearance_action_data")
local ToBool = ToBool
local TEAM_SPEECH_JOIN_PENDING_TIMEOUT = 5
local TEAM_MEMBER_COUNT_QUERY_TIMEOUT = 5
local ClientTeamComponent = class.Component("ClientTeamComponent")

function ClientTeamComponent.isValidTeamInfo(teamInfo)
	return teamInfo and not string.isNilOrEmpty(teamInfo.teamId)
end

function ClientTeamComponent.callTeamPlatformHook(methodName, self, ...)
	local _h = ClientTeamComponent._platformHooks

	return _h and _h[methodName] and _h[methodName](self, ...) == true
end

function ClientTeamComponent.tryTeamPlatformHook(methodName, self, ...)
	local firstHookArg = ...

	if self and self.isUidTeamMember and self:isUidTeamMember(firstHookArg) then
		return false
	end

	return ClientTeamComponent.callTeamPlatformHook(methodName, self, ...)
end

local function checkPlatformBlockedTarget(uid)
	local targetPlayerInfo = pg.game.chat and pg.game.chat:getPlayerInfo(uid)

	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(targetPlayerInfo) == true
end

function ClientTeamComponent:ctor()
	self.teamInfo = {}
	self.inviterInfoMap = {}
	self.applicantInfoMap = {}
	self.pendingSpeechRoomId = nil
	self.teamMemberCountQueries = {}
end

function ClientTeamComponent:init(dict)
	self.teamInfo = dict.teamInfo or {}
	self.inviterInfoMap = dict.inviterInfoMap or self.inviterInfoMap or {}
	self.applicantInfoMap = dict.applicantInfoMap or self.applicantInfoMap or {}

	if self:isInTeam() then
		self:handleSyncTeamInfo()
	end

	local _h = ClientTeamComponent._platformHooks

	if _h and _h.init then
		_h.init(self)
	end

	facade:SendMessageCommand(MessageName.IN_LEADER_WORLD_STATE_CHANGED, {
		newV = self.inLeaderWorld
	})

	return true
end

function ClientTeamComponent:getSpaceDungeonTeamInfo()
	local space = self.space or pg.space

	return space and space.dungeonTeamInfo or nil
end

function ClientTeamComponent:setSpaceDungeonTeamInfo(dungeonTeamInfo)
	local space = self.space or pg.space

	if not space then
		return
	end

	space.dungeonTeamInfo = ClientTeamComponent.isValidTeamInfo(dungeonTeamInfo) and dungeonTeamInfo or nil
end

function ClientTeamComponent:hasDungeonTeamInfo()
	return ClientTeamComponent.isValidTeamInfo(self:getSpaceDungeonTeamInfo())
end

function ClientTeamComponent:getCurTeamInfo()
	local dungeonTeamInfo = self:getSpaceDungeonTeamInfo()

	if ClientTeamComponent.isValidTeamInfo(dungeonTeamInfo) then
		return dungeonTeamInfo
	end

	return self.teamInfo
end

function ClientTeamComponent:destroy()
	local _h = ClientTeamComponent._platformHooks

	if _h and _h.destroy then
		_h.destroy(self)
	end

	if self.teamRefresh then
		TimerManager.removeTimer(self.teamRefresh)

		self.teamRefresh = nil
	end

	pg.game.effect:getTeamLinkController():onEntityDestroy(self)
end

function ClientTeamComponent:isInTeam(ignoreSingleTeam)
	local teamInfo = self:getCurTeamInfo()

	return ClientTeamComponent.isValidTeamInfo(teamInfo) and (not ignoreSingleTeam or self:getTeamMemberCount(true) > 1)
end

function ClientTeamComponent:isInSingleTeam()
	local teamInfo = self:getCurTeamInfo()

	return ClientTeamComponent.isValidTeamInfo(teamInfo) and (not teamInfo.membersInfo or lume.getMapLen(teamInfo.membersInfo) <= 1)
end

function ClientTeamComponent:isInDungeonTeam()
	local dungeonTeamInfo = self:getSpaceDungeonTeamInfo()

	if ClientTeamComponent.isValidTeamInfo(dungeonTeamInfo) then
		return true
	end

	return false
end

function ClientTeamComponent:isTeamLeader()
	local teamInfo = self:getCurTeamInfo()

	return teamInfo and self.uid == teamInfo.leaderUid
end

function ClientTeamComponent:isUidTeamLeader(uid)
	local teamInfo = self:getCurTeamInfo()

	return teamInfo and uid == teamInfo.leaderUid
end

function ClientTeamComponent:isUidTeamMember(uid)
	local teamInfo = self:getCurTeamInfo()

	return uid ~= nil and teamInfo and teamInfo.membersInfo and teamInfo.membersInfo[uid] ~= nil
end

function ClientTeamComponent:isTeamFull()
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.membersInfo then
		return false
	end

	local maxPlayerNum = SysConfigData.MAX_PLAYER_NUM
	local levelConfig = LevelData[teamInfo.dungeonSceneId]

	if levelConfig and levelConfig.playerNumMax then
		maxPlayerNum = levelConfig.playerNumMax
	end

	return maxPlayerNum <= lume.getMapLen(teamInfo.membersInfo)
end

function ClientTeamComponent:isTeamPet(entityId)
	return table.contains(self.petPrepareList, entityId)
end

function ClientTeamComponent:isInMatching()
	return self.matchState ~= Const.PLAYER_MATCH_STATUS.IDLE
end

function ClientTeamComponent:isMatchPlayer()
	return self.matchState == Const.PLAYER_MATCH_STATUS.MATCH_TEAM
end

function ClientTeamComponent:isInEggMatching()
	if self:isEggTeam() then
		return self:isInMatching()
	end

	return false
end

function ClientTeamComponent:getDungeonSceneId()
	if pg.me then
		return pg.me:getCurTeamInfo().dungeonSceneId or 0
	end

	return 0
end

function ClientTeamComponent:getDungeonHardLv()
	return self:getCurTeamInfo().hardLv or 1
end

function ClientTeamComponent:isEggTeam()
	local dungeonSceneId = pg.me:getCurTeamInfo().dungeonSceneId or 0

	return self:isEggDungeon(dungeonSceneId)
end

function ClientTeamComponent:isEggDungeon(dungeonSceneId)
	return dungeonSceneId == ConstData.ROB_EGG_SCENE_ID or dungeonSceneId == ConstData.ROB_EGG_SCENE_CLIP_ID
end

function ClientTeamComponent:isPreEquipDungeon(dungeonSceneId)
	local dungeonConfig = LevelData[dungeonSceneId]

	return dungeonConfig and dungeonConfig.fb_type == Const.CUR_DUNGEON_TYPE.Egg
end

function ClientTeamComponent:tryStartDungeon(newDungeonId, difficultLv)
	local oldDungeonId = self:getMatchDungeonId()

	if oldDungeonId == newDungeonId then
		return Const.DUNGEON_CHANGE_STATUS.PASS
	end

	if self:isInMatching() then
		if self.matchState == Const.PLAYER_MATCH_STATUS.MATCHED then
			pg.global.showBubbleMessageById(11116)

			return Const.DUNGEON_CHANGE_STATUS.Error
		end

		local oldName = self:getDungeonName(self:getMatchDungeonId())
		local newName = self:getDungeonName(newDungeonId)

		if self:isEggDungeon(self:getMatchDungeonId()) then
			local oldDiffName = pg.global.ui.grabEggsMode.model:getDifficultName(self:getDungeonHardLv())

			oldName = oldName .. oldDiffName
		end

		if self:isEggDungeon(newDungeonId) then
			local newDiffName = pg.global.ui.grabEggsMode.model:getDifficultName(difficultLv)

			newName = newName .. newDiffName
		end

		pg.global.showConfirmMsgRaw(nil, pg.getFormatText(pg.getGameString("CHANGE_MATCH"), oldName, newName), function()
			if self:isInSingleTeam() then
				self:leaveTeam()
			else
				self:cancelTeamMatching()
			end
		end)

		return Const.DUNGEON_CHANGE_STATUS.PASS
	end

	return Const.DUNGEON_CHANGE_STATUS.PASS
end

function ClientTeamComponent:isInPreparingRoom()
	if not self:isInTeam() then
		return false
	end

	if self:getCurTeamInfo().status == Const.TEAM_STATE.S_DUN_PREPARE then
		return true
	else
		return false
	end
end

function ClientTeamComponent:getCurTeamMemberInfo()
	local teamInfo = self:getCurTeamInfo()

	return teamInfo and teamInfo.membersInfo or {}
end

function ClientTeamComponent:isFollowing()
	if not self:isInTeam() then
		return false
	end

	local teamInfo = self:getCurTeamInfo() or {}
	local followInfo = teamInfo.followInfo

	if followInfo == nil then
		return false
	end

	local _, followList = table.firstOrDefault(followInfo)

	if followList == nil then
		return false
	end

	return table.contains(followList, self.uid)
end

function ClientTeamComponent:EVENT_EnterScene()
	local lastSceneId = pg.global.scene and pg.global.scene.lastScene and pg.global.scene.lastScene.sceneId

	if not lastSceneId or not Utils.isRobEggSceneId(lastSceneId) or Utils.isSelfInSpaceDungeon() then
		return
	end

	if pg.game.seamless and pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	if not self:tryEnterPrepRoom(nil, true) then
		pg.game.grabEgg:tryInvokeSettlement()
	end

	pg.global.teamComponentEnterScene = true
end

function ClientTeamComponent:tryEnterPrepRoom(openTeamRoom, isEnterScene)
	local hasOpenTeamRoom = false

	if self:isInGrabEggTeamRoom() then
		local lastScene = isEnterScene and pg.global.scene and pg.global.scene.lastScene
		local isRepeatedEnterScene = isEnterScene and self.handledRobEggLastScene == lastScene

		if isEnterScene then
			self.handledRobEggLastScene = lastScene
		end

		if not isRepeatedEnterScene then
			if isEnterScene then
				pg.global.ui.grabEggsMode:open({
					backgroundOpen = true
				}, nil, nil, nil, nil, true)
			end

			self:grabEgg_enterPrepRoom()
		end

		hasOpenTeamRoom = true
	elseif openTeamRoom then
		pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
	end

	if self == pg.me then
		self:setSpaceFollowInfo(self.teamInfo and self.teamInfo.followInfo)
	end

	return hasOpenTeamRoom
end

function ClientTeamComponent:joinSpeechChannel(options)
	if ClientTeamComponent.callTeamPlatformHook("beforeJoinSpeechChannel", self, options) then
		return
	end

	local teamInfo = self:getCurTeamInfo()

	if self:isInTeam() and teamInfo and teamInfo.rtcRoomId then
		local roomId = tostring(teamInfo.rtcRoomId)

		if self.pendingSpeechRoomId == roomId then
			return
		end

		self.pendingSpeechRoomId = roomId

		TimerManager.addTimer(TEAM_SPEECH_JOIN_PENDING_TIMEOUT, function()
			if self.pendingSpeechRoomId == roomId then
				self.pendingSpeechRoomId = nil
			end
		end)

		local function onEnterRoomComplete(code, ignored)
			if self.pendingSpeechRoomId == roomId then
				self.pendingSpeechRoomId = nil
			end

			if ignored then
				return
			end

			pg.game.speech:onEnterSpeechRoomResult(code)
		end

		if pg.game.speech:checkMemberInRoom(pg.me.uid) then
			pg.global.gmeManager:SwitchRoom(roomId, onEnterRoomComplete)
		else
			pg.global.gmeManager:EnterRoom(roomId, 1, onEnterRoomComplete)
		end
	end
end

function ClientTeamComponent:quitSpeechChannel()
	self.pendingSpeechRoomId = nil

	pg.global.gmeManager:ExitRoom(function(code)
		if code == 0 then
			pg.game.speech:onExitSpeechRoomResult()
		end
	end)
	pg.global.ui.tips:refreshHotKeyHint(true)
	LuaUIUtils.sendCustomLog(Const.BILogName.TEAM_SPEECH, {
		exitedVoiceChannel = 1
	})
end

function ClientTeamComponent:isInSpeechChannel(uid)
	if self:isUidTeamMember(uid) and pg.game.speech:checkMemberInRoom(uid) then
		return true
	end

	return false
end

function ClientTeamComponent:tryAutoJoinTeamSpeech()
	if pg.game.setting:getTeamSpeechAutoEnter() and self:isInTeam() and not pg.game.speech:checkMemberInRoom(pg.me.uid) then
		self:joinSpeechChannel()
	end
end

function ClientTeamComponent:getTeamMemberCount(curTeam)
	local teamInfo = self:getShowTeamInfo(curTeam)

	return teamInfo and teamInfo.membersInfo and lume.getMapLen(teamInfo.membersInfo) or 0
end

function ClientTeamComponent:queryTeamMemberCount(teamId)
	if self:isInTeam(true) or string.isNilOrEmpty(teamId) then
		return false
	end

	local queryExpireTime = self.teamMemberCountQueries[teamId]

	if queryExpireTime and queryExpireTime > Time.realSecondCache then
		return false
	end

	self.teamMemberCountQueries[teamId] = Time.realSecondCache + TEAM_MEMBER_COUNT_QUERY_TIMEOUT

	self:serverMsg("RPC_CS_QueryTeamMemberCount", teamId)

	return true
end

function ClientTeamComponent:RPC_SC_QueryTeamMemberCount(teamId, memberCount)
	self.teamMemberCountQueries[teamId] = nil

	facade:SendMessageCommand(MessageName.TEAM_MEMBER_COUNT_QUERY_RESULT, {
		teamId = teamId,
		memberCount = memberCount
	})
end

function ClientTeamComponent:isTeamMemberEnough(dungeonId)
	local teamInfo = pg.me:getCurTeamInfo()
	local dungeonSceneId = dungeonId or teamInfo.dungeonSceneId
	local levelConfig = LevelData[dungeonSceneId]

	if not levelConfig then
		return false
	end

	if not levelConfig.matchId then
		return true
	end

	local mCount = self:getTeamMemberCount()
	local matchCfg = MatchConfigData[levelConfig.matchId]

	if matchCfg and matchCfg.autoAddMembersPrompt and matchCfg.autoAddMembersPrompt == 1 then
		return mCount >= matchCfg.membersCount[2], matchCfg.membersCount[2]
	end

	return mCount >= levelConfig.playerNumMax, levelConfig.playerNumMax
end

function ClientTeamComponent:isLevelMemberPass(dungeonId, onlyMax)
	local dungeonSceneId = dungeonId or pg.me:getCurTeamInfo().dungeonSceneId
	local levelConfig = LevelData[dungeonSceneId]

	if not levelConfig then
		return false
	end

	local mCount = self:isInTeam() and self:getTeamMemberCount() or 1

	if onlyMax then
		return mCount <= levelConfig.playerNumMax
	end

	return mCount >= levelConfig.playerNumMin and mCount <= levelConfig.playerNumMax
end

function ClientTeamComponent:checkLevelConditionTitle()
	local levelCfg = LevelData[Const.BossRushSceneId]
	local titleCondition = levelCfg and levelCfg.playerTitleCondition

	if not titleCondition then
		return true
	end

	if pg.me:isInTeam() then
		for uid, memberInfo in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if titleCondition > memberInfo.starTitle then
				return false, memberInfo.playerName, titleCondition
			end
		end
	elseif titleCondition > pg.me.starTitle then
		return false, pg.me.playerName, titleCondition
	end

	return true
end

function ClientTeamComponent:getTitleTip(playerName, titleCondition)
	local noticeCfg = SysNoticeData[NoticeDef.TEAM_MSG_PLAYER_DUN_ERROR_NEED_TITLE]
	local tip = pg.getLocalizationText(noticeCfg and noticeCfg.text or "")

	tip = string.gsub(tip, "<player>", playerName)
	tip = string.gsub(tip, "<title>", LuaUIUtils.getStarTitleName(titleCondition, true))

	return tip
end

function ClientTeamComponent:getTeamLeaderPlayer()
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.leaderUid then
		return nil
	end

	local leaderInfo = teamInfo.membersInfo and teamInfo.membersInfo[teamInfo.leaderUid]

	return leaderInfo and pg.getEntity(leaderInfo.entityId)
end

function ClientTeamComponent:getDungeonName(dungeonSceneId)
	local cData = LevelData[dungeonSceneId]

	if cData == nil then
		return
	end

	return pg.getLocalizationText(cData.name)
end

function ClientTeamComponent:getDungeonNameWithHardLv(dungeonSceneId, hardLv)
	local dungeonConfig = LevelData[dungeonSceneId]
	local title = dungeonConfig and pg.getLocalizationText(dungeonConfig.name) or pg.getGameString("TEAM_NO_TARGET")

	hardLv = tonumber(hardLv or 0)

	if hardLv > 0 and DungeonDifficultLevelData[dungeonSceneId] and DungeonDifficultLevelData[dungeonSceneId][hardLv] then
		return ClientTextUtils.concatByLanguage(title, pg.getGameString("DUNGEON_DIFFICUITY_" .. hardLv))
	end

	return title
end

function ClientTeamComponent:getMatchDungeonId()
	if not self:isInMatching() then
		return 0
	end

	local teamInfo = pg.me:getCurTeamInfo()

	if self:isInEggMatching() then
		return teamInfo and teamInfo.dungeonSceneId or 0
	end

	if not string.isNilOrEmpty(pg.me.matchDungeonPlayId) then
		local dungeonSceneId, _ = Utils.getDungeonSceneIdAndHardLv(pg.me.matchDungeonPlayId)

		if dungeonSceneId > 0 then
			self._matchDungeonSceneId = dungeonSceneId

			return dungeonSceneId
		end
	end

	return teamInfo and teamInfo.dungeonSceneId and teamInfo.dungeonSceneId > 0 and teamInfo.dungeonSceneId or self._matchDungeonSceneId or 0
end

function ClientTeamComponent:isAllPrepare()
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.prepareInfos then
		return false
	end

	local allPrepare = true

	for uid, value in pairs(teamInfo.prepareInfos) do
		if not self:isUidTeamLeader(uid) then
			allPrepare = allPrepare and value.isPrepare
		end
	end

	return allPrepare
end

function ClientTeamComponent:isUidPrepare(uid)
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.prepareInfos then
		return false
	end

	if teamInfo.prepareInfos[uid] then
		return teamInfo.prepareInfos[uid].isPrepare
	end

	return false
end

function ClientTeamComponent:getPrepareCount()
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.prepareInfos then
		return 0
	end

	local count = 0

	for uid, value in pairs(teamInfo.prepareInfos) do
		if self:isUidTeamLeader(uid) or value.isPrepare then
			count = count + 1
		end
	end

	return count
end

function ClientTeamComponent:isTeamPlayerInWorld()
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.membersInfo then
		return false
	end

	for _, memberInfo in pairs(teamInfo.membersInfo) do
		if memberInfo.entityId and memberInfo.entityId ~= self.id and pg.getEntity(memberInfo.entityId) then
			return true
		end
	end

	return false
end

function ClientTeamComponent:getTeamPetCount(uid)
	return Const.PET_PREPARE_NUM_LIMIT
end

function ClientTeamComponent:getTeamPetIds()
	return self.petPrepareList
end

function ClientTeamComponent:getTeamPetInfos()
	local petInfos = {}

	for i = 1, self:getTeamPetCount(self.uid) do
		petInfos[i] = self:getPetInfo(self.petPrepareList[i])
	end

	return petInfos
end

function ClientTeamComponent:getTeamOrderByEntityId(entId)
	local teamInfo = self:getCurTeamInfo()

	if not teamInfo or not teamInfo.sortList then
		return nil
	end

	for index, uid in ipairs(teamInfo.sortList) do
		local memberInfo = teamInfo.membersInfo[uid]

		if memberInfo and memberInfo.entityId == entId then
			return index
		end
	end

	return nil
end

function ClientTeamComponent:getTeamRoomPlayerOrderData(dungeonConfig)
	local data = {}
	local maxCount = dungeonConfig and dungeonConfig.playerNumMax or SysConfigData.MAX_PLAYER_NUM

	if maxCount > 2 then
		maxCount = SysConfigData.MAX_PLAYER_NUM
	end

	for i = 1, maxCount do
		table.insert(data, {
			empty = true,
			tIndex = 0
		})
	end

	local teamInfo = self:getShowTeamInfo()
	local dataList = teamInfo.sortList or {}

	for i, uid in ipairs(dataList) do
		data[i].empty = false
		data[i].uid = uid
	end

	return data
end

function ClientTeamComponent:getFirstPetDataList()
	if not pg.me:isInTeam() then
		return
	end

	local petDatas = {}
	local teamInfo = self:getShowTeamInfo()

	for i, uid in ipairs(teamInfo.sortList) do
		local pList = teamInfo.membersInfo[uid].petInfoList

		petDatas[i] = pList and pList[1] or {
			empty = true
		}
	end

	return petDatas
end

function ClientTeamComponent:onTeamNoticeId(playerInfo, noticeId)
	pg.game.chat:recvTeamNotice(playerInfo, noticeId)
end

function ClientTeamComponent:RPC_SC_TeamNoticeId(playerInfo, noticeId)
	if noticeId == NoticeDef.TEAM_GO_LEADER_WORLD and self.sceneId ~= playerInfo.sceneId then
		self:seamless_setEnableCheck(false)
	end

	self:onTeamNoticeId(playerInfo, noticeId)

	local _h = ClientTeamComponent._platformHooks

	if _h and _h.RPC_SC_TeamNoticeId then
		_h.RPC_SC_TeamNoticeId(self, playerInfo, noticeId)
	end
end

function ClientTeamComponent:RPC_SC_SyncTeamInfo(teamInfo)
	local oldLeaderPlayer = self:getTeamLeaderPlayer()
	local oldTeamInfo = self.teamInfo

	self:setSpaceFollowInfo(teamInfo.followInfo)

	self.teamInfo = teamInfo

	self:refreshCurTeamInfo()
	self:handleSyncTeamInfo()

	local newLeaderPlayer = self:getTeamLeaderPlayer()

	if oldLeaderPlayer ~= newLeaderPlayer then
		self:onTeamLeaderChanged(oldLeaderPlayer, newLeaderPlayer)
	end

	self:tryShowLeaderChangePreEquipDungeonTargetNotice(oldTeamInfo, teamInfo)
	self:refreshTeamMarkInfo(teamInfo)
end

function ClientTeamComponent:tryShowLeaderChangePreEquipDungeonTargetNotice(oldTeamInfo, newTeamInfo)
	if Utils.isSelfInSpaceDungeon() then
		return
	end

	if not ClientTeamComponent.isValidTeamInfo(oldTeamInfo) or not ClientTeamComponent.isValidTeamInfo(newTeamInfo) then
		return
	end

	if oldTeamInfo.teamId ~= newTeamInfo.teamId then
		return
	end

	if not oldTeamInfo.membersInfo or not oldTeamInfo.membersInfo[self.uid] then
		return
	end

	if not newTeamInfo.membersInfo or not newTeamInfo.membersInfo[self.uid] then
		return
	end

	if newTeamInfo.leaderUid == self.uid then
		return
	end

	local oldDungeonSceneId = oldTeamInfo.dungeonSceneId or 0
	local newDungeonSceneId = newTeamInfo.dungeonSceneId or 0
	local oldHardLv = oldTeamInfo.hardLv or 0
	local newHardLv = newTeamInfo.hardLv or 0

	if oldDungeonSceneId == newDungeonSceneId and oldHardLv == newHardLv or newDungeonSceneId == 0 then
		return
	end

	if not self:isPreEquipDungeon(newDungeonSceneId) then
		return
	end

	local leaderUid = newTeamInfo.leaderUid
	local leaderInfo = newTeamInfo.membersInfo[leaderUid]

	if not leaderInfo then
		return
	end

	local noticePlayerInfo = lume.clone(leaderInfo)

	noticePlayerInfo.teamId = newTeamInfo.teamId
	noticePlayerInfo.teamMembers = lume.getMapLen(newTeamInfo.membersInfo or {})

	local dungeonTitle = self:getDungeonNameWithHardLv(newDungeonSceneId, newHardLv)

	pg.global.ui.tips:addHudNotice(leaderUid, noticePlayerInfo, dungeonTitle, SysConfigData.MAX_WAIT_CONFIRM_TIME, function()
		pg.me:tryEnterDungeonPrepRoom()
	end, function()
		return
	end, function()
		return
	end, {
		overrideYesText = "GO_TO_PREPARE",
		tIndex = 1,
		type = 0,
		dungeonSceneId = newDungeonSceneId,
		hardLv = newHardLv,
		funcName = Const.FUNCTION_NAME.TEAM,
		overrideTitleText = pg.getGameString("LEADER_CHANGE_PREP_DUNGEON_TARGET")
	})
end

function ClientTeamComponent:onTeamLeaderChanged(oldLeaderPlayer, newLeaderPlayer)
	if oldLeaderPlayer then
		oldLeaderPlayer.spaceOwnerMapMarkCache = nil
	end

	if newLeaderPlayer then
		newLeaderPlayer.spaceOwnerMapMarkCache = nil
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("team leader changed, oldLeader=%s, newLeader=%s", oldLeaderPlayer and oldLeaderPlayer:repr() or "", newLeaderPlayer and newLeaderPlayer:repr() or "")
	end
end

function ClientTeamComponent:handleFirstEnterTeam()
	if self:isInTeam() then
		if pg.game.chat.showFirstEnterTeam then
			facade:SendMessageCommand(MessageName.FIRST_ENTER_TEAM)
			self:postComponentMethod("Event_OnJoinTeam")

			pg.game.chat.showFirstEnterTeam = false

			LuaUIUtils.sendCustomLog(Const.BILogName.TEAM_SPEECH, {
				createVoiceChannel = 1
			})
			self:tryAutoJoinTeamSpeech()
		end
	else
		if not pg.game.chat.showFirstEnterTeam then
			facade:SendMessageCommand(MessageName.LEAVE_TEAM)
			self:postComponentMethod("Event_OnLeaveTeam")
			pg.global.ui.tips:refreshHotKeyHint(true)

			local _h = ClientTeamComponent._platformHooks

			if _h and _h.onLeaveTeam then
				_h.onLeaveTeam(self)
			end

			local discordHooks = ClientTeamComponent._discordHooks

			if discordHooks and discordHooks.onLeaveTeam then
				discordHooks.onLeaveTeam(self)
			end
		end

		self:quitSpeechChannel()

		pg.game.chat.showFirstEnterTeam = true
	end
end

function ClientTeamComponent:handleSyncTeamInfo()
	self:handleFirstEnterTeam()
	facade:SendMessageCommand(MessageName.SYNC_TEAM_INFO)
	self.eventEmitter:emit(EventConst.TOPLOGO_TEAM_STATE)

	if not string.isNilOrEmpty(self.curCombatPetId) then
		local curCombatPet = pg.getEntity(self.curCombatPetId)

		if curCombatPet then
			curCombatPet.eventEmitter:emit(EventConst.TOPLOGO_TEAM_STATE)
		end
	end

	pg.game.chat:setTeamId(self:getCurTeamInfo().teamId or "")
	pg.game.chat:syncTeamMembersInfo(self.teamInfo)

	local _h = ClientTeamComponent._platformHooks

	if _h and _h.handleSyncTeamInfo then
		_h.handleSyncTeamInfo(self)
	end

	local discordHooks = ClientTeamComponent._discordHooks

	if discordHooks and discordHooks.onTeamInfoChanged then
		discordHooks.onTeamInfoChanged(self)
	end
end

function ClientTeamComponent:getTeamMembersInfo()
	local teamInfo = self:getShowTeamInfo()

	return teamInfo and teamInfo.membersInfo or {}
end

function ClientTeamComponent:getTeamOrder(targetUid)
	if self:isInTeam() then
		local teamInfo = self:getCurTeamInfo()

		if teamInfo.sortList then
			for index, uid in ipairs(teamInfo.sortList) do
				if targetUid == uid then
					return index
				end
			end
		end
	end

	return 0
end

function ClientTeamComponent:isInTeamDungeonScene()
	local dungeonSceneId = pg.me:getCurTeamInfo().dungeonSceneId

	return pg.me.space and pg.me.space.sceneId == dungeonSceneId
end

function ClientTeamComponent:inviteTeamMember(uid, extraInfo)
	if ClientTeamComponent.tryTeamPlatformHook("inviteTeamMemberByPlatformFriend", self, uid, extraInfo) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("inviteTeamMemberBySamePlatformFamily", self, uid, extraInfo) then
		return
	end

	self:serverMsg("RPC_CS_InviteTeamMember", uid, extraInfo and extraInfo.dungeonSceneId or 0, extraInfo and extraInfo.hardLv or 0)
end

function ClientTeamComponent:RPC_SC_TeamInvited(uid, inviterInfo, dungeonInfo)
	if ClientTeamComponent.callTeamPlatformHook("beforeReceiveTeamInvite", self, uid, inviterInfo, dungeonInfo) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_TeamInvited: " .. uid)
	end

	self.inviterInfoMap[uid] = inviterInfo

	if dungeonInfo.dungeonSceneId then
		pg.game.chat:recvTeamInvite(uid, inviterInfo, dungeonInfo.dungeonSceneId, dungeonInfo.hardLv)
	else
		pg.game.chat:recvTeamInvite(uid, inviterInfo)
	end
end

function ClientTeamComponent:acceptTeamInvite(uid, accept)
	if self:isInTeam(true) then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_ALREADY_IN_TEAM"))

		return
	end

	if not self:isMatchStatusInit() then
		if accept and self:isInSingleTeam() then
			ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("ACCEPT_TEAM_INVITE_MATCHING_TIP"), function()
				if ClientTeamComponent.tryTeamPlatformHook("beforeAcceptTeamInvite", self, uid) then
					return
				end

				self:serverMsg("RPC_CS_AcceptTeamInvite", uid, accept)
			end)

			return
		end

		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	if accept and ClientTeamComponent.tryTeamPlatformHook("beforeAcceptTeamInvite", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_AcceptTeamInvite", uid, accept)
end

function ClientTeamComponent:RPC_SC_DeleteInviterInfo(uid)
	self.inviterInfoMap[uid] = nil
end

function ClientTeamComponent:requestJoinTeam(uid)
	if self:isInTeam(true) then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_ALREADY_IN_TEAM"))

		return
	end

	if not self:isMatchStatusInit() then
		if self:isInSingleTeam() then
			ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("REQUEST_JOIN_TEAM_MATCHING_TIP"), function()
				if ClientTeamComponent.tryTeamPlatformHook("requestJoinTeamByPlatformFriend", self, uid) then
					return
				end

				if ClientTeamComponent.tryTeamPlatformHook("requestJoinTeamBySamePlatformFamily", self, uid) then
					return
				end

				self:serverMsg("RPC_CS_RequestJoinTeam", uid)
			end)

			return
		end

		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("requestJoinTeamByPlatformFriend", self, uid) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("requestJoinTeamBySamePlatformFamily", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_RequestJoinTeam", uid)
end

function ClientTeamComponent:RPC_SC_RequestJoinTeam(uid, applicantInfo)
	if ClientTeamComponent.callTeamPlatformHook("beforeReceiveJoinTeamRequest", self, uid, applicantInfo) then
		return
	end

	self.applicantInfoMap[uid] = applicantInfo

	pg.game.chat:recvJoinRequest(uid, applicantInfo)
end

function ClientTeamComponent:acceptTeamJoinRequest(uid, accept)
	if not self:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	self:serverMsg("RPC_CS_AcceptTeamJoinRequest", uid, accept)
end

function ClientTeamComponent:setAutoAcceptTeamJoinRequest(isAutoAccept)
	self:serverMsg("RPC_CS_SetAutoAcceptTeamJoinRequest", isAutoAccept and true or false)
end

function ClientTeamComponent:RPC_SC_DeleteJoinInfo(uid)
	return
end

function ClientTeamComponent:leaveTeam(isMatchTeam)
	isMatchTeam = isMatchTeam or false

	if not self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return
	end

	if self:isInTeamDungeonScene() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	self:serverMsg("RPC_CS_LeaveTeam")
end

function ClientTeamComponent:changeTeamLeader(newLeaderUid)
	if not self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return
	end

	if not self:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if not self:isMatchStatusInit() and not pg.me.space:isBossRushEnv() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	self:serverMsg("RPC_CS_ChangeTeamLeader", newLeaderUid)
end

function ClientTeamComponent:kickTeamMember(kickUid)
	if not self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return
	end

	if not self:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if not self:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	self:serverMsg("RPC_CS_KickTeamMember", kickUid)
end

function ClientTeamComponent:disbandTeam()
	if not self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return
	end

	if not self:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	self:serverMsg("RPC_CS_DisbandTeam")
end

function ClientTeamComponent:cancelTeamMatching()
	if pg.me:isInMatching() then
		pg.me:serverMsg("RPC_CS_CancelMatch")
	else
		pg.global.showBubbleMessageById(11101)
	end
end

function ClientTeamComponent:RPC_SC_ReceiveEnterWorldRequest(uid, playerInfo)
	if ClientTeamComponent.callTeamPlatformHook("beforeReceiveEnterWorldRequest", self, uid, playerInfo) then
		return
	end

	pg.game.chat:recvEnterWorldRequest(uid, playerInfo)
end

function ClientTeamComponent:handleEnterWorldRequest(uid, accept)
	if not self:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	self:serverMsg("RPC_CS_HandleEnterWorldRequest", uid, accept)
end

function ClientTeamComponent:RPC_SC_ReceiveEnterWorldInvite(uid, playerInfo, inviteWorldParams)
	if ClientTeamComponent.callTeamPlatformHook("beforeReceiveEnterWorldInvite", self, uid, playerInfo, inviteWorldParams) then
		return
	end

	if pg.logDebug() then
		self.logger:debug("RPC_SC_ReceiveEnterWorldInvite, uid=%s, playerInfo=%s, inviteWorldParams=%s", uid, inspect(playerInfo), inspect(inviteWorldParams), self:repr())
	end

	pg.game.chat:recvEnterWorldInvite(uid, playerInfo, inviteWorldParams)
end

function ClientTeamComponent:RPC_SC_SyncDungeonTeamInfo(dungeonTeamInfo)
	self.logger:debug("RPC_SC_SyncDungeonTeamInfo")

	local hasDungeonTeamInfo = self:hasDungeonTeamInfo()

	self:setSpaceDungeonTeamInfo(dungeonTeamInfo)

	dungeonTeamInfo = self:getSpaceDungeonTeamInfo()

	self:refreshCurTeamInfo()
	facade:SendMessageCommand(MessageName.SYNC_TEAM_INFO)

	if dungeonTeamInfo ~= nil then
		if pg.game.setting:getTeamSpeechAutoEnter() and not hasDungeonTeamInfo then
			if not hasDungeonTeamInfo then
				self:joinSpeechChannel()
			else
				self:quitSpeechChannel()
			end
		end
	elseif pg.game.setting:getTeamSpeechAutoEnter() and pg.me:isInTeam() then
		self:joinSpeechChannel()
	else
		self:quitSpeechChannel()
	end

	self:refreshTeamMarkInfo(dungeonTeamInfo)
	self.eventEmitter:emit(EventConst.TOPLOGO_TEAM_STATE)

	if self.space and self.space:isGrabEgg() and self.tryRestoreGrabEggState then
		self:tryRestoreGrabEggState()
	end

	local _h = ClientTeamComponent._platformHooks

	if _h and _h.RPC_SC_SyncDungeonTeamInfo then
		_h.RPC_SC_SyncDungeonTeamInfo(self, dungeonTeamInfo)
	end
end

function ClientTeamComponent:RPC_SC_SyncDungeonMatchConfirms(matchReadyTeams)
	self.logger:debug("RPC_SC_SyncDungeonMatchConfirms", inspect(matchReadyTeams))

	self.matchReadyTeams = matchReadyTeams

	facade:sendMsgToUI(MessageName.TEAM_ENTER_MEMBER_AGREE_CHANGE, matchReadyTeams)
end

function ClientTeamComponent:handleEnterWorldInvite(uid, accept)
	if not self:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	if accept and ClientTeamComponent.callTeamPlatformHook("beforeAcceptEnterWorldInvite", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_HandleEnterWorldInvite", uid, accept)
end

function ClientTeamComponent:leaveLeaderWorld()
	if not self.inLeaderWorld then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_LEADER_WORLD"))

		return
	end

	self:serverMsg("RPC_CS_LeaveLeaderWorld")
end

function ClientTeamComponent:RPC_SC_DungeonEnterTips(dungeonSceneId, hardLv, tipsInfo)
	self.logger:debug("RPC_SC_DungeonEnterTips", dungeonSceneId, hardLv, inspect(tipsInfo))
end

function ClientTeamComponent:createSingleTeam(dungeonSceneId, difficultLv)
	if self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_ALREADY_IN_TEAM"))

		return
	end

	dungeonSceneId = dungeonSceneId or 0
	difficultLv = difficultLv or 0

	self:serverMsg("RPC_CS_CreateDungeonSingleTeam", dungeonSceneId, difficultLv)
end

function ClientTeamComponent:RPC_SC_NewTeamInfo()
	if not self:isInTeam() then
		return
	end

	local dungeonSceneId = self.teamInfo.dungeonSceneId

	if dungeonSceneId == Const.ROB_EGG_SCENE_ID or dungeonSceneId == Const.ROB_EGG_SCENE_CLIP_ID then
		self:grabEgg_enterPrepRoom()
	end
end

function ClientTeamComponent:tryEnterDungeonPrepRoom()
	local dungeonSceneId = self.teamInfo.dungeonSceneId

	if dungeonSceneId == Const.BossRushSceneId then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_MAIN) then
			pg.global.ui:close(UIConst.UI_ID_BOSS_RUSH_MAIN)
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_CHALLENGE) then
			pg.global.ui:close(UIConst.UI_ID_BOSS_RUSH_CHALLENGE)
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			pg.global.ui:close(UIConst.UI_ID_FUNC_MENU)
		end
	end

	if dungeonSceneId == Const.ROB_EGG_SCENE_ID or dungeonSceneId == Const.ROB_EGG_SCENE_CLIP_ID then
		self:grabEgg_enterPrepRoom()
	else
		pg.global.ui.teamRoom:open()
	end
end

function ClientTeamComponent:applyTeamDungeon(dungeonSceneId, difficultLv, isChange)
	if self:isInTeam() and not self:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	self.dungeonSceneId = dungeonSceneId
	difficultLv = difficultLv or self:getCurTeamInfo().hardLv or 0

	if not isChange or isChange == false then
		self:startMatch(dungeonSceneId, difficultLv, MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER)
	else
		self:serverMsg("RPC_CS_ApplyChangeTeamDungeon", dungeonSceneId, difficultLv)
	end
end

function ClientTeamComponent:_startMatchImpl(dungeonSceneId, difficultLv, matchType)
	self.dungeonSceneId = dungeonSceneId
	difficultLv = difficultLv or self:getCurTeamInfo().hardLv or 0

	if type(matchType) == "boolean" then
		matchType = matchType and MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER or MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER
	end

	matchType = matchType or MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER

	if matchType ~= MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER then
		self._matchDungeonSceneId = dungeonSceneId
	end

	self:serverMsg("RPC_CS_ApplyEnterTeamDungeon", dungeonSceneId, difficultLv, matchType)
end

function ClientTeamComponent:startMatch(dungeonSceneId, difficultLv, matchType)
	if self:isInTeam() and not self:isTeamLeader() then
		pg.global.showBubbleMessageById(11101)

		return
	end

	local _h = ClientTeamComponent._platformHooks

	if _h and _h.startMatch then
		return _h.startMatch(self, dungeonSceneId, difficultLv, matchType)
	end

	self:_startMatchImpl(dungeonSceneId, difficultLv, matchType)
end

function ClientTeamComponent:cancelTeamDungeon()
	if not self:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return
	end

	self:serverMsg("RPC_CS_ApplyChangeTeamDungeon", 0, 0)
end

function ClientTeamComponent:RPC_SC_SyncTeamDungeonConfirm(dungeonSceneId, dungeonConfirms)
	self.logger:debug("RPC_SC_SyncTeamDungeonConfirm", dungeonSceneId, inspect(dungeonConfirms))

	self.dungeonSceneId = dungeonSceneId
	self:getCurTeamInfo().dungeonConfirms = dungeonConfirms

	facade:sendMsgToUI(MessageName.TEAM_PUSH_GO_READY_ROOM, {
		dungeonSceneId = dungeonSceneId
	})
end

function ClientTeamComponent:prepareTeamDungeon()
	self:serverMsg("RPC_CS_PrepareTeam")
end

function ClientTeamComponent:cancelPrepareTeamDungeon()
	self:serverMsg("RPC_CS_CancelPrepareTeam")
end

function ClientTeamComponent:startTeamDungeon()
	local dungeonSceneId = self.teamInfo.dungeonSceneId
	local hardLv = self.teamInfo.hardLv

	self:startMatch(dungeonSceneId, hardLv, MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER)
end

function ClientTeamComponent:requestEnterWorld(uid)
	if pg.me and pg.me.space and Utils.isSpaceDungeon(pg.me.space.spaceType) then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_APPLY_ERROR_SELF_IN_DUNGEON"))

		return
	end

	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	if pg.game.chat:checkEnterWorldRequestInCD(uid) then
		return
	end

	local ent = pg.getEntityByUid(uid)

	if self:isInTeam() and not ent and not self:isUidTeamLeader(uid) then
		pg.global.ui.tips:showTextTip(pg.getGameString("ENTER_WORLD_FAILED"))

		return
	end

	if not self:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

		return
	end

	if not ent then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_ENTER_WORLD"))
	end

	if self:isUidTeamMember(uid) then
		if ClientTeamComponent.callTeamPlatformHook("beforeRequestEnterWorld", self, uid) then
			return
		end

		self:serverMsg("RPC_CS_RequestEnterWorld", uid)

		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("requestEnterWorldByPlatformFriend", self, uid) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("requestEnterWorldBySamePlatformFamily", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_RequestEnterWorld", uid)
end

function ClientTeamComponent:inviteMultiPlayer()
	self:serverMsg("RPC_CS_InviteMultiPlayer", {})
end

function ClientTeamComponent:RPC_SC_GatherTeammate(uid, playerInfo)
	pg.game.chat:recvGatherTeammate(uid, playerInfo)
end

function ClientTeamComponent:acceptGatherTeammate(uid, accept)
	self:serverMsg("RPC_CS_AcceptGatherTeammate", uid, accept)
end

function ClientTeamComponent:RPC_SC_SendBossChallengeReward(rewardMap, pos)
	for playerId, rewardType in pairs(rewardMap) do
		local ent = pg.getEntity(playerId)

		if ent then
			ent:playEffect(DungeonConst.MULTIBOSS_REWARD_TRAIL_EFFECT[rewardType], {
				position = pos,
				loadCallback = function(effectItem)
					local track = effectItem.effectTrans.gameObject:GetComponent(typeof(CS.FunPlus.WorldX.ParabolaFollowTrack))

					track = track or effectItem.effectTrans.gameObject:AddComponent(typeof(CS.FunPlus.WorldX.ParabolaFollowTrack))

					if track then
						track.addHeight = ent:getHeight() * 0.5

						track:SetEffectItem(effectItem)
						track:StartTrackByActorId(ent.actorId)
					end
				end
			})
		end
	end

	local delayTime = SysConfigData.Multiple_Battle_Reward_Eff_Delay

	TimerManager.addTimer(delayTime, function()
		for playerId, rewardType in pairs(rewardMap) do
			local ent = pg.getEntity(playerId)

			if ent then
				ent:playEffect(DungeonConst.MULTIBOSS_REWARD_GAIN_EFFECT[rewardType])
			end
		end
	end)
end

function ClientTeamComponent:on_matchState_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_matchState_changed old:%s, new:%s", oldVal, newVal)
	end

	if pg.me and pg.me.updateStateCache then
		pg.me:updateStateCache("DUNGEON_MATCHING_ST")
	end

	if newVal == Const.PLAYER_MATCH_STATUS.IDLE then
		self._matchDungeonSceneId = nil
	end

	self:refreshCurTeamInfo()

	if newVal == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON and oldVal ~= Const.PLAYER_MATCH_STATUS.MATCH_TEAM or newVal == Const.PLAYER_MATCH_STATUS.MATCH_TEAM and oldVal ~= Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON then
		local curDungeonSceneId = self:getMatchDungeonId()
		local dungeonConfig = LevelData[curDungeonSceneId]

		if dungeonConfig then
			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("LEADER_START_MATCH"), pg.getLocalizationText(dungeonConfig.name)))
		end
	end

	if self.waiApplyTeam then
		self.waiApplyTeam()

		self.waiApplyTeam = nil
	end

	facade:sendMsgToUI(MessageName.TEAM_MATCHED_STATUS_CHANGE, {})
	facade:SendMessageCommand(MessageName.EGG_MATCH_STATE_CHANGE, {
		oldStatus = oldVal,
		newStatus = newVal
	})
end

function ClientTeamComponent:on_matchStartTime_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_matchStartTime_changed old:%s, new:%s", oldVal, newVal)
	end

	facade:sendMsgToUI(MessageName.TEAM_MATCH_START_TIME_CHANGE)
end

function ClientTeamComponent:on_matchDungeonPlayId_changed(oldVal, newVal)
	self:getMatchDungeonId()
	facade:sendMsgToUI(MessageName.TEAM_MATCHED_STATUS_CHANGE, {})
end

function ClientTeamComponent:syncTeamRoomAction(configId)
	self:serverMsg("RPC_CS_DoActionId", configId)
end

function ClientTeamComponent:RPC_SC_DungeonTeamDoActionId(uid, configId)
	pg.game.chat:recvSyncTeamRoomAni(uid, configId)
end

function ClientTeamComponent:handleRemoteInviteSinglePlayer(uid, type)
	if pg.me and pg.me.space and Utils.isSpaceDungeon(pg.me.space.spaceType) then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_APPLY_ERROR_SELF_IN_DUNGEON"))

		return
	end

	if pg.me and pg.me.space and pg.me.space:isDittoSpace() then
		return
	end

	if pg.game.chat:checkEnterWorldInviteInCD(uid) then
		return
	end

	if TeamUtils.isPlayerWithinMeetRange(uid) then
		pg.global.ui.tips:showTextTip(pg.getGameString("PLAYER_WITHIN_RANGE"))

		return
	end

	type = type or Const.InviteWorldType.NORMAL_INVITE

	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(FuncIdConfigData[Const.FUNCTION_NAME.TEAM].unlockDesc))

		return
	end

	if not pg.me:checkInviteFriendNear() then
		return
	end

	local ent = pg.getEntityByUid(uid)

	if pg.me:isInTeam() and not ent and not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAMP_MEMBER_MEET_INVITE_TIP"))

		return
	end

	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if type == Const.InviteWorldType.NORMAL_INVITE and self:isUidTeamMember(uid) then
		if not playerInfo.online then
			pg.global.ui.tips:showTextTipById(NoticeDef.TEAM_INVITE_MEMBER_OFFLINE)

			return
		end

		self:serverMsg("RPC_CS_InviteSinglePlayer", uid, {
			type = type
		})
		pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))

		return
	end

	local canHandleOfflineInvite = ClientTeamComponent.tryTeamPlatformHook("canHandleOfflineInviteEnterWorld", self, uid, type, playerInfo)

	if not playerInfo.online and not canHandleOfflineInvite then
		pg.global.ui.tips:showTextTipById(NoticeDef.TEAM_INVITE_MEMBER_OFFLINE)

		return
	end

	if ClientTeamComponent.callTeamPlatformHook("inviteEnterWorldByPlatformFriend", self, uid, type) then
		return
	end

	if ClientTeamComponent.callTeamPlatformHook("inviteEnterWorldBySamePlatformFamily", self, uid, type) then
		return
	end

	self:serverMsg("RPC_CS_InviteSinglePlayer", uid, {
		type = type
	})
	pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
end

function ClientTeamComponent:refreshCurTeamInfo()
	return self:getCurTeamInfo()
end

function ClientTeamComponent:getShowTeamInfo(curTeam)
	local teamInfo = self:getCurTeamInfo()

	return (self:isInTeamDungeonScene() or pg.global.ui.grabEggBag.model:isInGrabEggSpace() or curTeam) and teamInfo or self.teamInfo
end

function ClientTeamComponent:on_inLeaderWorld_changed(oldV, newV)
	facade:SendMessageCommand(MessageName.IN_LEADER_WORLD_STATE_CHANGED, {
		oldV = oldV,
		newV = newV
	})
end

function ClientTeamComponent:isInLeaderWorld()
	return self.inLeaderWorld or false
end

function ClientTeamComponent:leaveDungeonScene()
	if self:isInLeaderWorld() and not self.space:isGrabEgg() and not Utils.isScenePhoto() and not self.space:isHomeland() then
		self:leaveLeaderWorld()
	else
		self:serverMsg("RPC_CS_QuitSpace")
	end
end

function ClientTeamComponent:reqSpaceFollow(leaderUid)
	if not Utils.checkSpaceFollowAvailable() then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIMELINE_FORBID_SPACE_FOLLOW"))

		return
	end

	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		ClientUtils.showBubbleMessageById(NoticeDef.FOLLOW_NOT_SCENE)

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow reqSpaceFollow", leaderUid)
	end

	if checkPlatformBlockedTarget(leaderUid) then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("reqSpaceFollowByPlatformFriend", self, leaderUid) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("reqSpaceFollowBySamePlatformFamily", self, leaderUid) then
		return
	end

	self:serverMsg("RPC_CS_ReqSpaceFollow", leaderUid)
end

function ClientTeamComponent:quickInviteSpaceFollow(uid)
	if self:isInTeam() and not self:isTeamLeader() and not self:isUidTeamMember(uid) then
		pg.global.showBubbleMessageRaw(pg.getGameString("TEAMP_MEMBER_MEET_INVITE_TIP"))

		return
	end

	if self:isTeamFull() and not self:isUidTeamMember(uid) then
		pg.global.showBubbleMessageRaw(pg.getGameString("SELF_TEAM_FULL"))

		return
	end

	if not Utils.checkSpaceFollowAvailable() then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIMELINE_FORBID_SPACE_FOLLOW"))

		return
	end

	if self.space and self.space.sceneId and not Utils.canSpaceFollow(self.space.sceneId) then
		pg.global.showBubbleMessageById(NoticeDef.FOLLOW_NOT_SCENE)

		return
	end

	if checkPlatformBlockedTarget(uid) then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("quickInviteSpaceFollowByPlatformFriend", self, uid) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("quickInviteSpaceFollowBySamePlatformFamily", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_QuickInviteTeamSpaceFollow", uid)
end

function ClientTeamComponent:RPC_SC_QuickInviteTeamSpaceFollowRet(targetUid, result, extraParam)
	if result == NoticeDef.SUCCESS then
		local targetEnt = pg.getEntityByUid(targetUid)
		local quickSpaceFollowActionId = 901008

		if AppearanceActionData[quickSpaceFollowActionId] then
			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getLocalizationText(AppearanceActionData[quickSpaceFollowActionId].interactToast), targetEnt.playerName))
		end
	end
end

function ClientTeamComponent:RPC_SC_NotifyReqSpaceFollow(reqUid)
	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		return
	end

	if checkPlatformBlockedTarget(reqUid) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow RPC_SC_NotifyReqSpaceFollow", reqUid)
	end

	pg.game.chat:recvRequireSpaceFollow(reqUid)
end

function ClientTeamComponent:agreeSpaceFollow(reqUid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow agreeSpaceFollow", reqUid)
	end

	if not Utils.checkSpaceFollowAvailable() then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIMELINE_FORBID_SPACE_FOLLOW"))

		return
	end

	self:serverMsg("RPC_CS_AgreeSpaceFollow", reqUid)
end

function ClientTeamComponent:inviteSpaceFollow(uid)
	if not Utils.checkSpaceFollowAvailable() then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIMELINE_FORBID_SPACE_FOLLOW"))

		return
	end

	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		ClientUtils.showBubbleMessageById(NoticeDef.FOLLOW_NOT_SCENE)

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow inviteSpaceFollow", uid)
	end

	if checkPlatformBlockedTarget(uid) then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("inviteSpaceFollowByPlatformFriend", self, uid) then
		return
	end

	if ClientTeamComponent.tryTeamPlatformHook("inviteSpaceFollowBySamePlatformFamily", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_InviteSpaceFollow", uid)
end

function ClientTeamComponent:RPC_SC_NotifyReqSpaceFollowRet(receiverUid, result, extraInfo)
	if result == NoticeDef.SUCCESS then
		local playerInfo = pg.game.chat:getPlayerInfo(receiverUid)
		local playerName = playerInfo.playerName
		local _h = ClientTeamComponent._platformHooks

		playerName = _h and _h.notifyReqSpaceFollowRetName and _h.notifyReqSpaceFollowRetName(self, receiverUid, playerInfo, playerName) or playerName

		ClientUtils.showBubbleMessageById(NoticeDef.FOLLOW_XXX_REQUIRE, playerName)
		pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, true, ClientConst.FriendInteractType.Require)
	else
		ClientUtils.showBubbleMessageById(result)
	end
end

function ClientTeamComponent:RPC_SC_NotifyInviteSpaceFollowRet(receiverUid, result, extraInfo)
	if result == NoticeDef.SUCCESS then
		local playerInfo = pg.game.chat:getPlayerInfo(receiverUid)
		local playerName = playerInfo and playerInfo.playerName or ""
		local _h = ClientTeamComponent._platformHooks

		playerName = _h and _h.notifyInviteSpaceFollowRetName and _h.notifyInviteSpaceFollowRetName(self, receiverUid, playerInfo, playerName) or playerName

		ClientUtils.showBubbleMessageById(NoticeDef.FOLLOW_XXX_INVITE, playerName)
		pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, true, ClientConst.FriendInteractType.Invite)
	else
		ClientUtils.showBubbleMessageById(result)
	end
end

function ClientTeamComponent:RPC_SC_NotifyInviteSpaceFollow(inviterUid)
	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		return
	end

	if checkPlatformBlockedTarget(inviterUid) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow RPC_SC_NotifyInviteSpaceFollow", inviterUid)
	end

	pg.game.chat:recvInviteSpaceFollow(inviterUid)
end

function ClientTeamComponent:agreeInviteSpaceFollow(inviterUid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow agreeInviteSpaceFollow", inviterUid)
	end

	if not Utils.checkSpaceFollowAvailable() then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIMELINE_FORBID_SPACE_FOLLOW"))

		return
	end

	self:serverMsg("RPC_CS_AgreeInviteSpaceFollow", inviterUid)
end

function ClientTeamComponent:refuseSpaceFollow(inviterUid, type)
	self:serverMsg("RPC_CS_RefuseSpaceFollow", inviterUid, type)
end

function ClientTeamComponent:RPC_SC_NotifyRefuseSpaceFollow(uid, type)
	pg.global.showBubbleMessageRaw(pg.getGameString("SPACE_FOLLOW_REJECTED"), 2)
	pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, false, type)
end

function ClientTeamComponent:exitSpaceFollow(force)
	if force then
		self:serverMsg("RPC_CS_ExitSpaceFollow")

		return
	end

	local desc = pg.me.space:isSpaceFollowLeader(pg.me.uid) and pg.getGameString("EXIT_SPACE_FOLLOW_DESC_GUIDE") or pg.getGameString("EXIT_SPACE_FOLLOW_DESC_FOLLOWER")

	pg.global.showConfirmMsgRaw(pg.getGameString("EXIT_SPACE_FOLLOW_TITLE"), desc, function()
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("@SpaceFollow exitSpaceFollow")
		end

		self:serverMsg("RPC_CS_ExitSpaceFollow")
	end, nil)
end

function ClientTeamComponent:kickSpaceFollow(followUid)
	local playerInfo = pg.game.chat:getPlayerInfo(followUid)
	local displayName = playerInfo.playerName or ""
	local _h = ClientTeamComponent._platformHooks

	if _h and _h.kickSpaceFollowName then
		displayName = _h.kickSpaceFollowName(self, followUid, playerInfo, displayName)
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("KICK_SPACE_FOLLOW_TITLE"), pg.getFormatText(pg.getGameString("KICK_SPACE_FOLLOW_DESC"), displayName), function()
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("@SpaceFollow kickSpaceFollow", followUid)
		end

		self:serverMsg("RPC_CS_KickSpaceFollow", followUid)
	end, nil)
end

function ClientTeamComponent:RPC_SC_NotifySpaceFollow(followInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow RPC_SC_NotifySpaceFollow", inspect(followInfo))
	end

	self:setSpaceFollowInfo(followInfo)
	pg.game.chat:onSpaceFollowUpdate(followInfo)
	pg.game.chat:handleTopLogoFriendInteract(pg.me.uid, false, 0)
end

function ClientTeamComponent:RPC_SC_NotifyOtherSpaceFollowInfo(followInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("@SpaceFollow RPC_SC_NotifyOtherSpaceFollowInfo", inspect(followInfo))
	end

	self:setSpaceFollowInfo(followInfo)
end

function ClientTeamComponent:setSpaceFollowStaminaRatio(isFollowing)
	local followStaminaRatio = SysConfigData.followStaminaCostReductionRate or 0.5

	self.isSpaceFollowStaminaReduced = ToBool(isFollowing)

	if self.staminaTickData then
		self.staminaTickData.followRatio = self.isSpaceFollowStaminaReduced and followStaminaRatio or 1
	end
end

function ClientTeamComponent:setSpaceFollowInfo(followInfo)
	if not self.space or not self.space.canSpaceFollow or not self.space:canSpaceFollow() then
		return
	end

	if self.teamInfo == nil then
		self.teamInfo = {}
	end

	followInfo = followInfo or {}
	self.teamInfo.followInfo = followInfo
	self.space.followInfo = followInfo or {}

	self:setSpaceFollowStaminaRatio(self.space and self.space:isSpaceFollowed(self.uid))
end

function ClientTeamComponent:onSkeletonLoaded()
	pg.game.effect:getTeamLinkController():onSkeletonLoaded(self)
end

function ClientTeamComponent:RPC_SC_NotifyExitSpaceFollowNotTeamLeader()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_NotifyExitSpaceFollowNotTeamLeader")
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("SPACE_FOLLOW_END_DESC"))
end

function ClientTeamComponent:RPC_SC_PushTeammateInfo(uid, petTemplateId, petLabel, isControlPet, hp, hpMax)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_PushTeammateInfo: ", uid, petTemplateId, petLabel, isControlPet, hp, hpMax)
	end

	facade:SendMessageCommand(MessageName.CUR_COMBAT_PET_CHANGED, {
		uid = uid,
		petTemplateId = petTemplateId,
		petLabel = petLabel,
		isControlPet = isControlPet
	})
	facade:SendMessageCommand(MessageName.TEAM_PET_HP_CHANGED, {
		uid = uid,
		curHp = hp,
		maxHp = hpMax
	})
end

function ClientTeamComponent:RPC_SC_TeammateNotifyCombatPetChange(uid, petTemplateId, petLabel, isControlPet)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_TeammateNotifyCombatPetChange: ", uid, petTemplateId, petLabel, isControlPet)
	end

	facade:SendMessageCommand(MessageName.CUR_COMBAT_PET_CHANGED, {
		uid = uid,
		petTemplateId = petTemplateId,
		petLabel = petLabel,
		isControlPet = isControlPet
	})
end

function ClientTeamComponent:RPC_SC_TeammateNotifyCombatPetHpChange(uid, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_TeammateNotifyCombatPetHpChange: ", uid, newv)
	end

	facade:SendMessageCommand(MessageName.TEAM_PET_HP_CHANGED, {
		uid = uid,
		curHp = newv
	})
end

function ClientTeamComponent:RPC_SC_TeammateNotifyCombatPetHpMaxChange(uid, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_TeammateNotifyCombatPetHpMaxChange: ", uid, newv)
	end

	facade:SendMessageCommand(MessageName.TEAM_PET_MAX_HP_CHANGED, {
		uid = uid,
		maxHp = newv
	})
end

function ClientTeamComponent:trackTeamMapMark(sceneId, genId, dividingId)
	if pg.me:isInTeam() then
		pg.me:serverMsg("RPC_CS_TrackTeamMapMark", sceneId, genId, dividingId)
	end
end

function ClientTeamComponent:unTrackTeamMapMark(sceneId, genId, dividingId)
	if pg.me:isInTeam() then
		pg.me:serverMsg("RPC_CS_UnTrackTeamMapMark", sceneId, genId, dividingId)
	end
end

function ClientTeamComponent:refreshTeamMarkInfo(teamInfo)
	if pg.game.map then
		pg.game.map:refreshTeamMarkPointData()
	end
end

function ClientTeamComponent:RPC_SC_SyncGenerateUserSig(userSig, expireTime)
	local gmeManager = pg.global and pg.global.gmeManager

	if gmeManager then
		gmeManager:onUserSigGenerated(userSig, expireTime)
	end
end

return ClientTeamComponent
