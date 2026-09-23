-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomSelectComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TeamRoomSelectComponent = Class.LightClass("TeamRoomSelectComponent", UIComponent)
local Const = require("Common.Const.Const")

TeamRoomSelectComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshView",
		true
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"refreshView",
		true
	},
	[MessageName.TEAM_MATCH_START_TIME_CHANGE] = {
		"refreshView"
	},
	[MessageName.TEAM_ENTER_MEMBER_AGREE_CHANGE] = {
		"refreshView",
		true
	},
	[MessageName.TEAM_PUSH_GO_READY_ROOM] = {
		"refreshView",
		true
	},
	[MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE] = {
		"refreshView",
		true
	}
}

function TeamRoomSelectComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function TeamRoomSelectComponent:registerObjects()
	function self.btnAllSelectedUButton.luaClick()
		self:onAutoAcceptClick()
	end
end

function TeamRoomSelectComponent:initView()
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("AUTO_ACCEPT_TEAM_INVITE"))
	self:refreshView()
end

function TeamRoomSelectComponent:isAutoAcceptTeamJoinRequest()
	local teamInfo = pg.me:getCurTeamInfo()

	return teamInfo and teamInfo.autoAcceptTeamJoinRequest == true
end

function TeamRoomSelectComponent:canSetAutoAcceptTeamJoinRequest()
	return pg.me:isInTeam() and pg.me:isTeamLeader() and not pg.me:isInTeamDungeonScene()
end

function TeamRoomSelectComponent:onAutoAcceptClick()
	if not self:canSetAutoAcceptTeamJoinRequest() then
		self:refreshView()

		return
	end

	pg.me:setAutoAcceptTeamJoinRequest(not self:isAutoAcceptTeamJoinRequest())
	self:refreshView()
end

function TeamRoomSelectComponent:refreshView()
	self.btnAllSelectedUButton.isSelected = self:isAutoAcceptTeamJoinRequest()

	self:refreshVisible()
end

function TeamRoomSelectComponent:refreshVisible()
	local visible = self:canSetAutoAcceptTeamJoinRequest()

	if pg.global.ui.tips and pg.global.ui.tips.teamMatchTip and pg.global.ui.tips.teamMatchTip.isCountDownPlaying then
		visible = false
	elseif pg.me.matchState ~= Const.PLAYER_MATCH_STATUS.IDLE then
		visible = false
	elseif pg.me:isInTeamDungeonScene() then
		visible = false
	end

	self.gameObject:SetActiveEx(visible)
end

return TeamRoomSelectComponent
