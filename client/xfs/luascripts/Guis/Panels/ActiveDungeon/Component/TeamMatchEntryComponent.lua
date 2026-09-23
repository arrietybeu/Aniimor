-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ActiveDungeon\\Component\\TeamMatchEntryComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TeamUtils = require("Utils.TeamUtils")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ConstData = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local LevelData = require("Data.level_data")
local MatchConfigData = require("Data.match_data")
local MessageName = require("Const.MessageName")
local MatchConst = require("Common.Const.MatchConst")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")

local function getChaosTicketConfig()
	local ticketConfig = require("Common.Const.ItemConst").ROBEGG_TICKET_CHAOS

	if not ticketConfig then
		return nil, 0
	end

	return next(ticketConfig)
end

local TeamMatchEntryComponent = Class.LightClass("TeamMatchEntryComponent", UIComponent)

TeamMatchEntryComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"onTeamInfoChanged",
		true
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.TEAM_MATCH_START_TIME_CHANGE] = {
		"refreshTeamMatchStartTime"
	},
	[MessageName.TEAM_ENTER_MEMBER_AGREE_CHANGE] = {
		"onTeamMatchedConFirmChanged",
		true
	},
	[MessageName.TEAM_PUSH_GO_READY_ROOM] = {
		"onGoReadyRoomPush",
		true
	},
	[MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE] = {
		"refreshMatchEntryInteractable",
		true
	}
}

function TeamMatchEntryComponent:findObjects(content, data)
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnInvite = objectReference:GetRefValue("btnInvite")
	self.btnMatch = objectReference:GetRefValue("btnMatch")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.countDown = objectReference:GetRefValue("countDown")
	self.teamInviteUWidget = objectReference:GetRefValue("teamInviteUWidget")
	self.teamStateUWidget = objectReference:GetRefValue("teamStateUWidget")
	self.txtTeamMember = objectReference:GetRefValue("txtTeamMember")
	self.btnTeam = objectReference:GetRefValue("btnTeam")
	self.txtTips = objectReference:GetRefValue("txtTips")
	self.txtEnter = objectReference:GetRefValue("txtEnter")
	self.btnExitTeam = objectReference:GetRefValue("btnExitTeam")
	self.txtWaitingUSDFText = objectReference:GetRefValue("txtWaitingUSDFText")
	self.goStraightInUButton = objectReference:GetRefValue("goStraightInUButton")
	self.addTeammatesUButton = objectReference:GetRefValue("addTeammatesUButton")
	self.txtCancelUText = self.btnCancel.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
end

function TeamMatchEntryComponent:addListener()
	function self.btnMatch.luaClick()
		self:onStartClick()
	end

	function self.btnCancel.luaClick()
		self:onCancelMatch()
	end

	function self.btnInvite.luaClick()
		self:onInviteMember()
	end

	if NotNil(self.btnExitTeam) then
		function self.btnExitTeam.luaClick()
			self:onBtnExitTeam()
		end
	end

	if NotNil(self.btnTeam) then
		function self.btnTeam.luaClick()
			pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
		end
	end

	if NotNil(self.goStraightInUButton) then
		function self.goStraightInUButton.luaClick()
			self:setSelectedMatchType(self:getPrimaryMatchType())
		end
	end

	if NotNil(self.addTeammatesUButton) then
		function self.addTeammatesUButton.luaClick()
			self:setSelectedMatchType(MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER)
		end
	end

	self.btnCancel.gameObject:SetActiveEx(true)
end

function TeamMatchEntryComponent:onCtor(info)
	self.dungeonType = info.dungeonType or Const.CUR_DUNGEON_TYPE.Dungeon
	self.isTeamRoomCtrl = self.ctrl and self.ctrl.className == "TeamRoomCtrl"

	local hardLv = info.hardLv or 0

	if info.dungeonType == Const.CUR_DUNGEON_TYPE.Egg and hardLv == 0 then
		hardLv = pg.global.ui.grabEggsMode.model:getSelectedDifLv()
	end

	self.initialDungeonId = info.dungeonId
	self.initialHardLv = hardLv

	self:updateDungeonMatchInfo(info.dungeonId, hardLv)

	self.showCheck = 0
end

function TeamMatchEntryComponent:updateDungeonMatchInfo(dungeonId, hardLv, forceUpdate)
	if not self.isTeamRoomCtrl then
		dungeonId = self.initialDungeonId
		hardLv = self.initialHardLv
		forceUpdate = true
	end

	if forceUpdate or dungeonId then
		self.dungeonId = dungeonId
	end

	if hardLv ~= nil then
		self.hardLv = hardLv
	end

	self.dungeonConfig = self.dungeonId and LevelData[self.dungeonId]

	if self.dungeonConfig then
		self.dungeonType = self.dungeonConfig.fb_type or self.dungeonType
	end

	self.matchId = self.dungeonConfig and self.dungeonConfig.matchId
	self.matchCfg = self.matchId and MatchConfigData[self.matchId]
	self.canMatch = self.matchId and self.matchId ~= 0

	if not self.dungeonConfig then
		self.isAutoAddMembers = false
	end
end

function TeamMatchEntryComponent:initView()
	if pg.me:isInTeamDungeonScene() then
		self:hide()

		return
	else
		self:show()
	end

	ClientTextUtils.setText(self.txtCancelUText, pg.getGameString("CANCEL_MATCHING"))
	ClientTextUtils.setText(self.txtWaitingUSDFText, pg.getGameString("MATCHING"))
	self:setBtnName(self.btnInvite, "FAST_TEAM_INVITE")
	self:addListener()
	self:refreshView()
end

function TeamMatchEntryComponent:setBtnName(button, name)
	if not button then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString(name))
end

function TeamMatchEntryComponent:getSelectedMatchType()
	return self.selectedMatchType or self:getPrimaryMatchType()
end

function TeamMatchEntryComponent:shouldMatchMembers()
	return self:getSelectedMatchType() ~= MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER
end

function TeamMatchEntryComponent:setSelectedMatchType(matchType)
	if not self:isMatchTypeAvailable(matchType) then
		return
	end

	self.selectedMatchType = matchType

	local prefsKey = self:getMatchTypePrefsKey()

	if prefsKey then
		pg.global.prefsCacheUtils:setInt(prefsKey, matchType, ClientConst.CACHE_TYPE_FLAG.USER)
	end

	self:refreshMatchTypeButtons(false, true)
end

function TeamMatchEntryComponent:getMatchTypePrefsKey()
	if not self.dungeonId then
		return nil
	end

	return string.format("%s_%s", ClientConst.PrefKey.LastTeamMatchType, self.dungeonId)
end

function TeamMatchEntryComponent:getCachedMatchType()
	local prefsKey = self:getMatchTypePrefsKey()

	if not prefsKey then
		return nil
	end

	local matchType = pg.global.prefsCacheUtils:getInt(prefsKey, -1, ClientConst.CACHE_TYPE_FLAG.USER)

	return matchType >= 0 and matchType or nil
end

function TeamMatchEntryComponent:isMatchTypeAvailable(matchType)
	for _, data in ipairs(self.matchTypeOptions or EMPTY_TABLE) do
		if data.matchType == matchType then
			return true
		end
	end

	return false
end

function TeamMatchEntryComponent:hasAICooperate()
	local aiGroupId = self.dungeonConfig and self.dungeonConfig.aiGroupId

	return aiGroupId and (Utils.isTable(aiGroupId) and #aiGroupId > 0 or aiGroupId > 0)
end

function TeamMatchEntryComponent:getPrimaryMatchType()
	return self:hasAICooperate() and MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_BOT_ENTER or MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER
end

function TeamMatchEntryComponent:refreshMatchTypeButtons(inTeamMatching, canOperate)
	if self:isCreateTeamState() then
		self.matchTypeOptions = {}
	end

	inTeamMatching = inTeamMatching == true
	canOperate = canOperate ~= false
	self.matchTypeOptions = self.dungeonConfig and self:getTeamMatchTypeFunc() or {}

	if #self.matchTypeOptions == 0 then
		self.selectedMatchType = nil
		self.defaultMatchType = nil
	end

	if inTeamMatching then
		self.selectedMatchType = pg.me:isMatchPlayer() and MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER or self:getPrimaryMatchType()
	else
		local matchType = self:getCachedMatchType() or self.selectedMatchType or self.defaultMatchType or self:getPrimaryMatchType()

		self.selectedMatchType = self:isMatchTypeAvailable(matchType) and matchType or self.defaultMatchType
	end

	self.showCheck = not self:isCreateTeamState() and #self.matchTypeOptions > 1 and canOperate and not inTeamMatching and (not pg.me:isInTeam() or pg.me:isTeamLeader()) and 1 or 0

	self.rootUComponent:TryChangePage("MateType", self.showCheck)

	local canSelect = self.showCheck == 1 and canOperate and not inTeamMatching
	local primaryMatchType = self:getPrimaryMatchType()

	self:setBtnName(self.goStraightInUButton, self:hasAICooperate() and "MATCH_BOT_ENTER" or "DIRECTLY_ENTER")
	self:setBtnName(self.addTeammatesUButton, "ADDITION_TEAMMATES")

	if NotNil(self.goStraightInUButton) then
		self.goStraightInUButton.interactable = canSelect and self:isMatchTypeAvailable(primaryMatchType)
		self.goStraightInUButton.visualInteractable = self.goStraightInUButton.interactable

		self.goStraightInUButton:SetSelected(self.selectedMatchType == primaryMatchType)
	end

	if NotNil(self.addTeammatesUButton) then
		self.addTeammatesUButton.interactable = canSelect and self:isMatchTypeAvailable(MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER)
		self.addTeammatesUButton.visualInteractable = self.addTeammatesUButton.interactable

		self.addTeammatesUButton:SetSelected(self.selectedMatchType == MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER)
	end
end

function TeamMatchEntryComponent:getAutoAddMembersType()
	return self.matchCfg and self.matchCfg.autoAddMembers or MatchConst.MATCH_ADD_MEM_TYPE.BAN_AUTO_ADD
end

function TeamMatchEntryComponent:refreshMatchModeState(inTeamMatching, canOperate, canStart)
	inTeamMatching = inTeamMatching == true
	canOperate = canOperate ~= false

	if canStart == nil then
		canStart = self:canMatchEntryStart(inTeamMatching)
	end

	self.rootUComponent:TryChangePage("MatchLock", inTeamMatching and 1 or 0)
	self.rootUComponent:TryChangePage("MatchState", inTeamMatching and 1 or 0)
	self:refreshMatchButtonState(canStart)
	self:refreshMatchTypeButtons(inTeamMatching, canOperate)
	self:refreshMatchTipsState()
end

function TeamMatchEntryComponent:refreshNormalView()
	if self.dungeonConfig == nil then
		return
	end

	self.isAutoAddMembers = false

	local _, maxCount = pg.me:isTeamMemberEnough(self.dungeonId)
	local playerNumMax, playerNumMin

	if self.canMatch then
		self.isAutoAddMembers = self:getAutoAddMembersType() == MatchConst.MATCH_ADD_MEM_TYPE.FORCE_AUTO_ADD
		self.isSingle = false
		playerNumMax = maxCount
		playerNumMin = self.matchCfg.membersCount and self.matchCfg.membersCount[1] or 1

		if self.teamInviteUWidget then
			self.teamInviteUWidget.gameObject:SetActiveEx(not pg.me:isInTeam())
		end

		if self.teamStateUWidget then
			self.teamStateUWidget.gameObject:SetActiveEx(pg.me:isInTeam())
		end
	else
		playerNumMax = self.dungeonConfig.playerNumMax
		playerNumMin = self.dungeonConfig.playerNumMin
		self.isSingle = playerNumMax == 1

		if playerNumMin > 1 then
			if self.teamInviteUWidget then
				self.teamInviteUWidget.gameObject:SetActiveEx(not pg.me:isInTeam())
			end

			if self.teamStateUWidget then
				self.teamStateUWidget.gameObject:SetActiveEx(pg.me:isInTeam())
			end
		else
			if self.teamInviteUWidget then
				self.teamInviteUWidget.gameObject:SetActiveEx(false)
			end

			if self.teamStateUWidget then
				self.teamStateUWidget.gameObject:SetActiveEx(false)
			end
		end
	end

	if pg.me:isInTeam() then
		local isMemberPass = pg.me:isLevelMemberPass(self.dungeonId)
		local txtCount = pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1
		local txtMax = playerNumMax
		local content

		if isMemberPass then
			content = pg.getFormatText(pg.getGameString("TEAM_MEMBERS"), txtCount, txtMax)
		else
			content = pg.getFormatText(pg.getGameString("TEAM_MEMBERS"), string.format("<style=Item_Lack>%d</style>", txtCount), txtMax)
		end

		ClientTextUtils.setText(self.txtTeamMember, content)
	end
end

function TeamMatchEntryComponent:refreshEggView()
	self:refreshNormalView()
end

function TeamMatchEntryComponent:refreshView(dungeonId, hardLv)
	self:updateDungeonMatchInfo(dungeonId, hardLv)
	self:refreshNormalView()

	if self.matchStatus == Const.DUNGEON_CHANGE_STATUS.WaitChange and pg.me:isInTeam() and pg.me:isTeamLeader() and not pg.me:isInMatching() then
		self:onStartClick()

		self.matchStatus = nil
	end

	local inTeamMatching = self:getTeamMatchingInfo()

	self:refreshMatchModeState(inTeamMatching)
	self:onTeamInfoChanged()
	self:refreshTeamMatchStartTime()
end

function TeamMatchEntryComponent:getTeamMatchTypeFunc()
	local ret = {}
	local matchType = MatchConst.MATCH_TEAM_MEMBER_TYPE
	local dungeonConfig = self.dungeonConfig or {}
	local memberCount = pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1
	local playerNumMin = self.matchCfg and self.matchCfg.membersCount and self.matchCfg.membersCount[1] or dungeonConfig.playerNumMin or 1
	local _, playerNumMax = pg.me:isTeamMemberEnough(self.dungeonId)

	playerNumMax = playerNumMax or dungeonConfig.playerNumMax or playerNumMin

	local hasAI = self:hasAICooperate()
	local primaryMatchType = self:getPrimaryMatchType()

	if not self.canMatch then
		ret[#ret + 1] = {
			matchType = primaryMatchType
		}
		self.defaultMatchType = primaryMatchType

		return ret
	end

	local addMembersType = self:getAutoAddMembersType()
	local canMatchMember = addMembersType == MatchConst.MATCH_ADD_MEM_TYPE.AUTO_ADD and memberCount < playerNumMax

	if addMembersType == MatchConst.MATCH_ADD_MEM_TYPE.FORCE_AUTO_ADD then
		ret[#ret + 1] = {
			matchType = matchType.MATCH_MEMBER_ENTER,
			label = pg.getGameString("ADDITION_TEAMMATES")
		}
		self.defaultMatchType = matchType.MATCH_MEMBER_ENTER

		return ret
	end

	if memberCount < playerNumMin and not hasAI then
		if canMatchMember then
			ret[#ret + 1] = {
				matchType = matchType.MATCH_MEMBER_ENTER,
				label = pg.getGameString("ADDITION_TEAMMATES")
			}
		end

		self.defaultMatchType = ret[1] and ret[1].matchType or matchType.DIRECTLY_ENTER

		return ret
	end

	if playerNumMin <= memberCount or hasAI then
		ret[#ret + 1] = {
			matchType = primaryMatchType
		}
	end

	if canMatchMember then
		ret[#ret + 1] = {
			matchType = matchType.MATCH_MEMBER_ENTER
		}
	end

	self.defaultMatchType = #ret > 1 and canMatchMember and matchType.MATCH_MEMBER_ENTER or ret[1] and ret[1].matchType

	return ret
end

function TeamMatchEntryComponent:isCreateTeamState()
	return self.ctrl and self.ctrl.className == "TeamRoomCtrl" and not pg.me:isInTeam()
end

function TeamMatchEntryComponent:isNeedPreEquipTeamRoomState()
	return self.ctrl and self.ctrl.model and self.ctrl.model.needPreEquip and self.ctrl.model:needPreEquip(self.dungeonConfig) and pg.me:isInTeam()
end

function TeamMatchEntryComponent:getWaitingReadyText()
	return pg.getFormatText(pg.getGameString("WAITING_READY"), pg.me:getPrepareCount(), pg.me:getTeamMemberCount())
end

function TeamMatchEntryComponent:getNeedPreEquipMatchEnterBtnName()
	if not self:isNeedPreEquipTeamRoomState() then
		return nil
	end

	if pg.me:isTeamLeader() then
		return pg.me:isAllPrepare() and pg.getGameString("TEAM_START_CHALLENGE") or self:getWaitingReadyText()
	end

	return pg.getGameString(pg.me:isUidPrepare(pg.me.uid) and "TEAM_CANCEL_READY" or "TEAM_READY")
end

function TeamMatchEntryComponent:refreshMatchEnterBtnName()
	ClientTextUtils.setText(self.txtEnter, self:getMatchEnterBtnName())
end

function TeamMatchEntryComponent:canMatchEntryStart(inTeamMatching)
	if inTeamMatching then
		return false
	end

	if self:isTeamMemberCountOverflow() then
		return false
	end

	if self:isNeedPreEquipTeamRoomState() then
		if not self.dungeonConfig then
			return false
		end

		if pg.me:isTeamLeader() then
			return pg.me:isAllPrepare()
		end

		return true
	end

	if self:isCreateTeamState() then
		return true
	end

	return self.dungeonConfig ~= nil and (not pg.me:isInTeam() or pg.me:isTeamLeader())
end

function TeamMatchEntryComponent:refreshMatchButtonState(canStart)
	canStart = canStart == true

	self:refreshMatchEnterBtnName()

	self.btnMatch.interactable = canStart
	self.btnMatch.visualInteractable = canStart

	self.btnMatch:TryChangePage("button", canStart and 0 or 4)
	self.rootUComponent:TryChangePage("Colour", canStart and 0 or 1)
end

function TeamMatchEntryComponent:isTeamMemberCountOverflow()
	if not self.dungeonConfig or not pg.me:isInTeam() then
		return false
	end

	local playerNumMax = self.dungeonConfig.playerNumMax

	return playerNumMax ~= nil and playerNumMax < pg.me:getTeamMemberCount()
end

function TeamMatchEntryComponent:getDungeonDisableTip()
	if not self.dungeonConfig then
		return nil
	end

	if self.dungeonType == Const.CUR_DUNGEON_TYPE.Egg and self.dungeonId == ConstData.ROB_EGG_SCENE_ID and pg.global.ui.grabEggsMode and pg.global.ui.grabEggsMode.model then
		local state, reason = pg.global.ui.grabEggsMode.model:checkMatchCondition()

		if not state then
			return reason
		end
	end

	if self.dungeonType == Const.CUR_DUNGEON_TYPE.BOSSRush then
		local result, playerName, titleCondition = pg.me:checkLevelConditionTitle()

		if not result then
			return pg.me:getTitleTip(playerName, titleCondition)
		end
	end

	return nil
end

function TeamMatchEntryComponent:refreshMatchTipsState()
	local tip
	local isWarn = true

	if self:isCreateTeamState() then
		tip = nil
		isWarn = false
	elseif pg.me:isInTeam() and pg.me:isTeamLeader() and not self.dungeonConfig then
		tip = pg.getGameString("TEAM_ROOM_NO_TARGET_TIP")
	elseif pg.me:isInTeam() and not pg.me:isTeamLeader() and not self:isNeedPreEquipTeamRoomState() then
		tip = pg.getGameString("TEAM_ROOM_MEMBER_DISABLE_TIP")
	elseif self:isTeamMemberCountOverflow() then
		tip = pg.getGameString("NUMBER_NOT_READY")
	else
		tip = self:getDungeonDisableTip()

		if not tip and self.isAutoAddMembers then
			tip = pg.getGameString("ADDITION_TEAMMATES_AUTO")
			isWarn = false
		end
	end

	local showTip = tip ~= nil and tip ~= "" and not self:isTeamMatchingState()

	self.txtTips.gameObject:SetActiveEx(showTip)
	ClientTextUtils.setText(self.txtTips, tip or "")

	if showTip and isWarn then
		self.rootUComponent:TryChangePage("Colour", 1)
	end
end

function TeamMatchEntryComponent:createTeam()
	pg.me:createSingleTeam(0, 0)
end

function TeamMatchEntryComponent:hasEnoughRobEggChaosTicket()
	local isChaosMode = self.dungeonType == Const.CUR_DUNGEON_TYPE.Egg and self.dungeonId == Const.ROB_EGG_SCENE_CLIP_ID and self.hardLv == Const.DungeonDifficultLevel.CHAOS

	if not isChaosMode then
		return true
	end

	local ticketItemId, ticketCost = getChaosTicketConfig()

	if not ticketItemId then
		return true
	end

	return pg.me:getItemCountById(ticketItemId) >= (ticketCost or 0)
end

function TeamMatchEntryComponent:runWithTeamRoomInterceptConfirm(isCaptain, callback)
	if self.ctrl and self.ctrl.runWithInterceptConfirm then
		self.ctrl:runWithInterceptConfirm(isCaptain, callback)

		return
	end

	callback()
end

function TeamMatchEntryComponent:handleNeedPreEquipTeamRoomClick()
	if not self:isNeedPreEquipTeamRoomState() then
		return false
	end

	if self:getTeamMatchingInfo() then
		return true
	end

	if not self.dungeonConfig then
		return true
	end

	if pg.me:isTeamLeader() then
		return not pg.me:isAllPrepare()
	end

	if pg.me:isUidPrepare(pg.me.uid) then
		pg.me:cancelPrepareTeamDungeon()
	else
		if not self:hasEnoughRobEggChaosTicket() then
			pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_LACK_TICKET)

			return true
		end

		pg.me:prepareTeamDungeon()
	end

	return true
end

function TeamMatchEntryComponent:startPlay()
	if self.dungeonConfig then
		if not pg.me:isLevelMemberPass(self.dungeonId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("NUMBER_NOT_READY"))

			return
		end

		pg.me:applyTeamDungeon(self.dungeonId)
	end
end

function TeamMatchEntryComponent:startEggMatch(matchType)
	local state, reason = pg.global.ui.grabEggsMode.model:checkMatchCondition()

	if not state then
		pg.global.showBubbleMessageRaw(reason, 3)

		return
	end

	local isTeamMemberEnough, count = pg.me:isTeamMemberEnough(self.dungeonId)

	pg.me:startMatch(self.dungeonId, self.hardLv, isTeamMemberEnough and MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER or matchType)
end

function TeamMatchEntryComponent:startNormalMatch(matchType)
	if not pg.me:isLevelMemberPass(self.dungeonId, true) then
		pg.global.showBubbleMessageRaw(pg.getGameString("NUMBER_NOT_READY"))

		return
	end

	if self.dungeonType == Const.CUR_DUNGEON_TYPE.BOSSRush then
		local result, playerName, titleCondition = pg.me:checkLevelConditionTitle()

		if not result then
			pg.global.showBubbleMessageRaw(pg.me:getTitleTip(playerName, titleCondition))

			return
		end
	end

	pg.me:startMatch(self.dungeonId, self.hardLv, matchType)
end

function TeamMatchEntryComponent:tryStartDungeon(matchType)
	self.matchStatus = pg.me:tryStartDungeon(self.dungeonId, self.hardLv)

	if self.matchStatus == Const.DUNGEON_CHANGE_STATUS.PASS then
		self:startMatch(matchType)
	end
end

function TeamMatchEntryComponent:startMatch(matchType)
	matchType = matchType or self:getSelectedMatchType()

	local isTeamMemberEnough, count = pg.me:isTeamMemberEnough(self.dungeonId)
	local isMatch = matchType ~= MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER

	if self.dungeonType == Const.CUR_DUNGEON_TYPE.Egg then
		if self.dungeonId == ConstData.ROB_EGG_SCENE_ID then
			self:startEggMatch(matchType)

			return
		end

		if isMatch and not isTeamMemberEnough then
			self:startNormalMatch(matchType)
		else
			self:startPlay()
		end
	else
		if isTeamMemberEnough or not isMatch then
			self:startPlay()

			return
		end

		self:startNormalMatch(matchType)
	end
end

function TeamMatchEntryComponent:onStartClick()
	if self:isCreateTeamState() then
		self:createTeam()

		return
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if pg.me:isInTeam() and lume.getMapLen(pg.me.teamInfo.playerInDungeon) > 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_HAS_PLAYER_IN_DUNGEON"))

		return
	end

	self.matchStatus = pg.me:tryStartDungeon(self.dungeonId, self.hardLv)

	if self.matchStatus ~= Const.DUNGEON_CHANGE_STATUS.PASS then
		return
	end

	local matchType = self:getSelectedMatchType()
	local shouldMatchMembers = self:shouldMatchMembers()

	if not self.canMatch then
		self:startPlay()
	else
		local isTeamMemberEnough, count = pg.me:isTeamMemberEnough(self.dungeonId)

		if not shouldMatchMembers and not isTeamMemberEnough and (self.matchCfg.autoAddMembersPrompt or 0) > 0 then
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), string.format(pg.getGameString("AUTO_ADD_MEMBERS_CHECK"), count), function()
				self:startMatch(MatchConst.MATCH_TEAM_MEMBER_TYPE.DIRECTLY_ENTER)
			end, nil, nil, nil, nil, {
				okBtnDesc = self:getMatchEnterBtnName()
			})
		else
			self:startMatch(matchType)
		end
	end
end

function TeamMatchEntryComponent:onCancelMatch()
	if not pg.me:isInMatching() then
		return
	end

	if pg.me.matchState and pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED then
		pg.global.showBubbleMessageById(11115)

		return
	end

	pg.me:cancelTeamMatching()
end

function TeamMatchEntryComponent:onInviteMember()
	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_DUNGEON_INVITE, {
		dungeonId = self.dungeonId,
		hardLv = self.hardLv
	})
end

function TeamMatchEntryComponent:onBtnExitTeam()
	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("EXIT_TEAM_CONFIRM"), function()
		pg.me:leaveTeam()
	end)
end

function TeamMatchEntryComponent:isTeamMatchingState()
	local status = pg.me.matchState

	return status == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON or status == Const.PLAYER_MATCH_STATUS.MATCH_TEAM
end

function TeamMatchEntryComponent:getTeamMatchingInfo()
	local startTs = Time.secondCache
	local inTeamMatching = false
	local curDungeonId = pg.me:getMatchDungeonId()

	if curDungeonId == self.dungeonId then
		local teamInfo = pg.me:getShowTeamInfo()

		if self.dungeonType == Const.CUR_DUNGEON_TYPE.Egg and teamInfo.hardLv == self.hardLv then
			inTeamMatching = pg.me:isInEggMatching()
			startTs = pg.me.matchStartTime
		else
			inTeamMatching = (pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON or pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCH_TEAM) and not pg.me:isInEggMatching()
			startTs = pg.me.matchStartTime
		end
	end

	return inTeamMatching, startTs
end

function TeamMatchEntryComponent:onTeamMatchedStatusChange()
	self:refreshTeamRoomFrameMatchState()
	self:refreshTeamMatchStartTime()
end

function TeamMatchEntryComponent:refreshTeamMatchStartTime()
	if pg.me.matchStartTime == 0 then
		self.countDown:Stop()

		return
	end

	self.countDown.positiveTiming = true

	self.countDown:Play(math.max(0, Time.secondCache - pg.me.matchStartTime), 3600)
end

function TeamMatchEntryComponent:getMatchEnterBtnName()
	local needPreEquipBtnName = self:getNeedPreEquipMatchEnterBtnName()

	if needPreEquipBtnName then
		return needPreEquipBtnName
	end

	if self:isCreateTeamState() then
		return pg.getGameString("CREATE_TEAM")
	end

	return pg.getGameString("TEAM_START_CHALLENGE")
end

function TeamMatchEntryComponent:bindTeamRoomFrameStartButton()
	function self.btnMatch.luaClick()
		self:onTeamRoomFrameStartClick()
	end

	self:refreshTeamRoomFrameMatchState()
end

function TeamMatchEntryComponent:onTeamInfoChanged()
	local dungeonId = self.ctrl and self.ctrl.getTeamRoomFrameDungeonId and self.ctrl:getTeamRoomFrameDungeonId() or self.dungeonId
	local hardLv = self.hardLv

	if self.model and self.model.getDifficultLv then
		hardLv = self.model:getDifficultLv()
	end

	if self:isTeamMatchingState() then
		self:updateDungeonMatchInfo(dungeonId, hardLv, true)
		self:refreshNormalView()
		self:refreshMatchModeState(self:getTeamMatchingInfo(), false, false)

		return
	end

	self:refreshTeamRoomFrameMatchEntryState(dungeonId, hardLv)
	self.btnExitTeam.gameObject:SetActiveEx(self.ctrl.className == "TeamRoomCtrl" and pg.me:isInTeam())
end

function TeamMatchEntryComponent:refreshTeamRoomFrameMatchEntryState(dungeonId, hardLv)
	if self:isTeamMatchingState() then
		return
	end

	if not dungeonId then
		local matchDungeonId = pg.me:getMatchDungeonId()

		dungeonId = matchDungeonId and matchDungeonId ~= 0 and matchDungeonId or self.dungeonId
	end

	if hardLv == nil then
		local teamInfo = pg.me:getCurTeamInfo()

		hardLv = teamInfo and teamInfo.hardLv or self.hardLv
	end

	self:updateDungeonMatchInfo(dungeonId, hardLv or 0, true)
	self:refreshNormalView()

	local hasTarget = self.dungeonConfig ~= nil
	local canOperate = hasTarget and (not pg.me:isInTeam() or pg.me:isTeamLeader())

	self:refreshMatchModeState(false, canOperate)
end

function TeamMatchEntryComponent:refreshTeamRoomFrameMatchState()
	local matchDungeonId = pg.me:getMatchDungeonId()

	if matchDungeonId and matchDungeonId ~= 0 then
		local teamInfo = pg.me:getCurTeamInfo()

		self:updateDungeonMatchInfo(matchDungeonId, teamInfo and teamInfo.hardLv or self.hardLv, true)
	end

	self:refreshNormalView()

	local hasTarget = self.dungeonConfig ~= nil
	local inTeamMatching = hasTarget and self:isTeamMatchingState()
	local canOperate = hasTarget and (not pg.me:isInTeam() or pg.me:isTeamLeader())

	self:refreshMatchModeState(inTeamMatching, canOperate)
end

function TeamMatchEntryComponent:onTeamRoomFrameStartClick(interceptConfirmed)
	if self:isCreateTeamState() then
		self:createTeam()

		return
	end

	local isCancelPrepare = self:isNeedPreEquipTeamRoomState() and not pg.me:isTeamLeader() and pg.me:isUidPrepare(pg.me.uid)

	if not interceptConfirmed and not isCancelPrepare then
		self:runWithTeamRoomInterceptConfirm(pg.me:isTeamLeader(), function()
			self:onTeamRoomFrameStartClick(true)
		end)

		return
	end

	if self:handleNeedPreEquipTeamRoomClick() then
		return
	end

	if not self.dungeonConfig then
		return
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		return
	end

	local inTeamMatching = self:getTeamMatchingInfo()

	if inTeamMatching then
		return
	end

	self:onStartClick()
end

function TeamMatchEntryComponent:onGoReadyRoomPush()
	local dungeonConfirms = {}

	if pg.me.dungeonMatchStatus == Const.DUNGEON_MATCH_STAGE.AGREE_ENTER then
		local teamId = pg.me:getCurTeamInfo().teamId
		local team = pg.me.matchReadyTeams[teamId]

		dungeonConfirms = team.confirmStatus or {}
	else
		dungeonConfirms = pg.me:getCurTeamInfo().dungeonConfirms or {}
	end

	for uid, status in pairs(dungeonConfirms) do
		if status == Const.TEAM_DUNGEON_CONFIRM.REFUSE then
			self:refreshMatchEntryInteractable(true)

			return
		end
	end

	self:refreshMatchEntryInteractable(false)
end

function TeamMatchEntryComponent:onTeamMatchedConFirmChanged()
	local dungeonConfirms = {}

	if pg.me.dungeonMatchStatus == Const.DUNGEON_MATCH_STAGE.AGREE_ENTER then
		local teamId = pg.me:getCurTeamInfo().teamId
		local team = pg.me.matchReadyTeams[teamId]

		dungeonConfirms = team.confirmStatus or {}
	else
		dungeonConfirms = pg.me:getCurTeamInfo().dungeonConfirms or {}
	end

	for uid, status in pairs(dungeonConfirms) do
		if status == Const.TEAM_DUNGEON_CONFIRM.REFUSE then
			self:refreshMatchEntryInteractable(true)

			return
		end
	end
end

function TeamMatchEntryComponent:refreshMatchEntryInteractable(interactable)
	interactable = interactable == true

	if self.gameObject.activeSelf == interactable then
		return
	end

	self.gameObject:SetActiveEx(interactable)
end

return TeamMatchEntryComponent
