-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\TeamMatchTipComponent.lua

local LevelData = require("Data.level_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Const.Const")
local AudioConst = require("Const.AudioConst")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local MessageName = require("Const.MessageName")
local BaseTipComponent = require("Guis.Panels.Tips.Component.BaseTipComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local TeamMatchTipComponent = Class.LightClass("TeamMatchTipComponent", BaseTipComponent)
local UI_MATCH_SUCCESS_POP = AddressDataConst.UI_MATCH_SUCCESS_POP

function TeamMatchTipComponent:onCtor(info)
	TeamMatchTipComponent.super.onCtor(self, info)
end

function TeamMatchTipComponent:setCountDownPlaying(isPlaying)
	if self.isCountDownPlaying == isPlaying then
		return
	end

	self.isCountDownPlaying = isPlaying

	facade:sendMsgToUI(MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE, not isPlaying)
end

function TeamMatchTipComponent:initViewManual()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnNoUButton = self.objectReference:GetRefValue("btnNoUButton")
	self.btnOKUButton = self.objectReference:GetRefValue("btnOKUButton")
	self.listPlayerUList = self.objectReference:GetRefValue("listPlayerUList")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.dugNameUSDFText = self.objectReference:GetRefValue("dugNameUSDFText")
	self.btnOKHotKeyContent = self.objectReference:GetRefValue("btnOKHotKeyContent")
	self.btnNoHotKeyContent = self.objectReference:GetRefValue("btnNoHotKeyContent")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")

	function self.btnOKUButton.luaClick()
		self:confirmEnterDungeon()
	end

	function self.btnNoUButton.luaClick()
		self:rejectEnterDungeon()
	end

	function self.listPlayerUList.luaRenderItem(button, idx, data)
		self:renderPlayerState(button, idx, data)
	end

	function self.countDownUCountDown.luaFinished()
		self:setCountDownPlaying(false)
		self:closeTeamMatchTip()
	end

	self.ctrl:bindHotKeyPerform("Hud/TeamMatchConfirmGamepad", function()
		self.btnOKUButton.luaClick()
	end, self.btnOKUButton.gameObject)
	self.ctrl:bindHotKeyPerform("Hud/TeamMatchCancelGamepad", function()
		self.btnNoUButton.luaClick()
	end, self.btnNoUButton.gameObject)
	self.btnOKHotKeyContent:SetHotKeyPaths("Hud/TeamMatchConfirmGamepad")
	self.btnNoHotKeyContent:SetHotKeyPaths("Hud/TeamMatchCancelGamepad")
end

function TeamMatchTipComponent:renderPlayerState(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local headUButton = objectReference:GetRefValue("headUButton")

	LuaUIUtils.renderPlayerAvatar(headUButton, data.playerHeadData)
	button:TryChangePage("Ready", data.isReady and 1 or 0)

	local playerName = data.name
	local _h = TeamMatchTipComponent._platformHooks

	playerName = _h and _h.renderPlayerState and _h.renderPlayerState(self, button, idx, data, playerName) or playerName

	ClientTextUtils.setText(textUSDFText, playerName)
end

function TeamMatchTipComponent:confirmEnterDungeon()
	pg.game.audio:playEvent(AudioConst.EVENT_TEAM_ENTER_CONFIRM)
	pg.me:serverMsg("RPC_CS_ConfirmDungeonTeam", Const.TEAM_DUNGEON_CONFIRM.AGREE)
end

function TeamMatchTipComponent:rejectEnterDungeon()
	pg.game.audio:playEvent(AudioConst.EVENT_TEAM_ENTER_CANCEL)
	pg.me:serverMsg("RPC_CS_ConfirmDungeonTeam", Const.TEAM_DUNGEON_CONFIRM.REFUSE)
	self:closeTeamMatchTip()
end

function TeamMatchTipComponent:confirmStateChanged()
	local _h = TeamMatchTipComponent._platformHooks
	local dungeonConfirms = self:getDungeonConfirms()
	local membersInfo = self:getCurrentMembersInfo()
	local isAllReady = true

	for uid, status in pairs(dungeonConfirms) do
		if status == Const.TEAM_DUNGEON_CONFIRM.REFUSE then
			self:closeTeamMatchTip()

			local memberData = membersInfo[uid]
			local playerName = memberData and memberData.playerName or tostring(uid)

			playerName = _h and _h.confirmStateChanged and _h.confirmStateChanged(self, uid, memberData, playerName) or playerName

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("REFUSE_CONFIRM_MATCH"), playerName))

			return
		end

		if status ~= Const.TEAM_DUNGEON_CONFIRM.AGREE then
			isAllReady = false
		end
	end

	pg.game.audio:playEvent(AudioConst.EVENT_TEAM_ENTER_MEMBER_CONFIRM)

	if pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED or not isAllReady then
		local isAllTeamReady = self:isAllTeamReady()

		if isAllTeamReady then
			self:closeTeamMatchTip()
			pg.global.ui.activeDungeon:close()
		else
			local ret = {}
			local selfUid = pg.me.uid
			local selfIsReady = false

			for idx = 1, self.listPlayerUList.itemCount do
				local data = self.listPlayerUList.itemData[idx - 1]
				local status = dungeonConfirms[data.uid]

				data.isReady = status == Const.TEAM_DUNGEON_CONFIRM.AGREE

				if data.isReady and selfUid == data.uid then
					selfIsReady = true
				end

				ret[#ret + 1] = data
			end

			if isAllReady then
				self.uWidget:TryChangePage("SelfReady", 2)
				ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("WAIT_OTHER_TEAM_CONFIRM"))
			elseif selfIsReady then
				self.uWidget:TryChangePage("SelfReady", 1)
				ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("WAIT_OTHER_MEMBER_CONFIRM"))
			else
				self.uWidget:TryChangePage("SelfReady", 0)
				ClientTextUtils.setText(self.txtNameUSDFText, "")
			end

			self.listPlayerUList:SetList(ret)
		end
	else
		self:closeTeamMatchTip()
		pg.global.ui.activeDungeon:close()
		pg.me:tryEnterDungeonPrepRoom()
	end
end

function TeamMatchTipComponent:isAllTeamReady()
	local teams = pg.me.matchReadyTeams

	if not teams or not next(teams) then
		return
	end

	local isAllReady = true

	for _, team in pairs(teams) do
		local dungeonConfirms = team and (team.confirmStatus or team.dungeonConfirms)

		if dungeonConfirms then
			for _, status in pairs(dungeonConfirms) do
				if status ~= Const.TEAM_DUNGEON_CONFIRM.AGREE then
					isAllReady = false
				end
			end
		end
	end

	return isAllReady
end

function TeamMatchTipComponent:getMatchedReadyTeam()
	if pg.me.matchReadyTeams and next(pg.me.matchReadyTeams) ~= nil then
		for _, readyTeam in pairs(pg.me.matchReadyTeams) do
			if readyTeam.membersInfo[pg.me.uid] then
				return readyTeam
			end
		end
	end

	return pg.me:getCurTeamInfo()
end

function TeamMatchTipComponent:getDungeonConfirms()
	local team = self:getMatchedReadyTeam()

	return team and (team.confirmStatus or team.dungeonConfirms) or {}
end

function TeamMatchTipComponent:getCurrentMembersInfo()
	if pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED then
		local team = self:getMatchedReadyTeam()

		return team and team.membersInfo or {}
	end

	return pg.me:getCurTeamInfo().membersInfo or {}
end

function TeamMatchTipComponent:getCurrentDungeonSceneId()
	if pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED and pg.me.matchDungeonPlayId and pg.me.matchDungeonPlayId ~= "" then
		local dungeonSceneId = Utils.getDungeonSceneIdAndHardLv(pg.me.matchDungeonPlayId)

		return dungeonSceneId
	end

	return pg.me:getCurTeamInfo().dungeonSceneId
end

function TeamMatchTipComponent:getMemberInfo()
	local memberInfo = self:getCurrentMembersInfo()
	local dungeonConfirms = self:getDungeonConfirms()
	local ret = {}

	for uid, status in pairs(dungeonConfirms) do
		local memberData = memberInfo[uid]

		if memberData then
			local member = {}

			member.uid = uid

			local playerHeadData = {}

			playerHeadData.avatarIconId = memberData.headIcon
			playerHeadData.showAvatar = true
			playerHeadData.avatarFrameIconId = memberData.headFrame
			playerHeadData.showAvatarFrame = true
			member.name = memberData.playerName
			member.playerHeadData = playerHeadData
			member.isReady = status == Const.TEAM_DUNGEON_CONFIRM.AGREE
			ret[#ret + 1] = member
		end
	end

	return ret
end

function TeamMatchTipComponent:showTeamMatchTip()
	local memberInfos = self:getMemberInfo()

	if #memberInfos > 0 then
		self.view.popContainerUContainer:SetActive(true)

		if not self.view.popContainerUContainer:CheckURLLoaded(UI_MATCH_SUCCESS_POP) then
			self.view.popContainerUContainer:SetUrlWithCallback(UI_MATCH_SUCCESS_POP, function(content)
				self.view.popContainerUContainer:SetActiveFastest(true)

				self.transform = content.transform
				self.uWidget = content

				self:initViewManual()
				self:setMatchInfo()

				self.matchTime = pg.me.matchStartTime
			end)
		else
			self.view.popContainerUContainer:SetActiveFastest(true)
			self:setMatchInfo()
		end
	end
end

function TeamMatchTipComponent:setMatchInfo()
	if (not self.matchTime or self.matchTime ~= pg.me.matchStartTime or self.matchTime == 0) and not self.isCountDownPlaying then
		pg.game.audio:playEvent(AudioConst.EVENT_TEAM_INVITE)

		self.matchTime = pg.me.matchStartTime

		local levelConfig = LevelData[self:getCurrentDungeonSceneId()]

		if levelConfig then
			ClientTextUtils.setText(self.dugNameUSDFText, pg.getLocalizationText(levelConfig.name))
		else
			ClientTextUtils.setText(self.dugNameUSDFText, "")
		end

		local countDownTime = levelConfig and levelConfig.fb_type == Const.CUR_DUNGEON_TYPE.Egg and Const.TEAM_BASE.MATCH_READY_CONFIRM_TIMEOUT or Const.TEAM_BASE.MAX_WAIT_ENTER_DUN_CONFIRM_TIME

		self:setCountDownPlaying(true)
		self.countDownUCountDown:Play(countDownTime)

		self.closeTimer = self:startTimer(function()
			self:setCountDownPlaying(false)
			self:closeTeamMatchTip()
		end, countDownTime + 3)
	end

	local memberInfos = self:getMemberInfo()

	self.listPlayerUList:SetList(memberInfos)
	self:confirmStateChanged()
end

function TeamMatchTipComponent:closeTeamMatchTip()
	self.matchTime = nil

	self:setCountDownPlaying(false)

	if self.closeTimer then
		self:killTimer(self.closeTimer)

		self.closeTimer = nil
	end

	self.view.popContainerUContainer:SetActiveFastest(false)

	if self.countDownUCountDown and NotNil(self.countDownUCountDown) then
		self.countDownUCountDown:Stop()
	end
end

return TeamMatchTipComponent
