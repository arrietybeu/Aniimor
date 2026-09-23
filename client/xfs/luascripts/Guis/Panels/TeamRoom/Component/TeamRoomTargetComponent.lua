-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomTargetComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LevelData = require("Data.level_data")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local TeamRoomTargetComponent = Class.LightClass("TeamRoomTargetComponent", UIComponent)

TeamRoomTargetComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"onTeamRoomTargetStateChanged",
		true
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamRoomTargetStateChanged",
		true
	}
}

function TeamRoomTargetComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTargetName = objectReference:GetRefValue("txtTargetName")
	self.txtPlayerNum = objectReference:GetRefValue("txtPlayerNum")
	self.btnSelectUButton = objectReference:GetRefValue("btnSelectUButton")
	self.txtNoTarget = objectReference:GetRefValue("txtNoTarget")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
end

function TeamRoomTargetComponent:initView()
	ClientTextUtils.setText(self.txtNoTarget, pg.getGameString("TEAM_NO_TARGET"))
	self:bindTargetSelectButton()
	self:refreshTargetState()
end

function TeamRoomTargetComponent:getDungeonId(dungeonId)
	if dungeonId then
		return dungeonId
	end

	if self.ctrl and self.ctrl.getTeamRoomFrameDungeonId then
		return self.ctrl:getTeamRoomFrameDungeonId()
	end

	return pg.me:getCurTeamInfo().dungeonSceneId
end

function TeamRoomTargetComponent:getDungeonHardLv()
	if self.ctrl and self.ctrl.getTeamRoomFrameHardLv then
		return self.ctrl:getTeamRoomFrameHardLv()
	end

	local teamInfo = pg.me.getShowTeamInfo and pg.me:getShowTeamInfo() or pg.me:getCurTeamInfo()

	return teamInfo and teamInfo.hardLv or 0
end

function TeamRoomTargetComponent:isMatchingTarget(dungeonId)
	if not dungeonId then
		return false
	end

	local status = pg.me.matchState

	if status ~= Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON and status ~= Const.PLAYER_MATCH_STATUS.MATCH_TEAM then
		return false
	end

	return pg.me:getMatchDungeonId() == dungeonId
end

function TeamRoomTargetComponent:refreshTargetData(dungeonId)
	self.dungeonId = self:getDungeonId(dungeonId)
	self.dungeonConfig = self.dungeonId and LevelData[self.dungeonId]
end

function TeamRoomTargetComponent:refreshTargetViewState()
	self.rootUComponent:TryChangePage("ViewState", not pg.me:isInTeamDungeonScene() and pg.me:isTeamLeader() and 0 or 1)
end

function TeamRoomTargetComponent:refreshTargetPageState()
	local hasTarget = self.dungeonConfig ~= nil

	self.rootUComponent:TryChangePage("Target", hasTarget and (self:isMatchingTarget(self.dungeonId) and 2 or 1) or 0)
end

function TeamRoomTargetComponent:getDungeonNameText()
	local title = pg.getLocalizationText(self.dungeonConfig.name)
	local hardLv = tonumber(self:getDungeonHardLv() or 0)

	if hardLv > 0 and DungeonDifficultLevelData[self.dungeonId] and DungeonDifficultLevelData[self.dungeonId][hardLv] then
		return ClientTextUtils.concatByLanguage(title, pg.getGameString("DUNGEON_DIFFICUITY_" .. hardLv))
	end

	return title
end

function TeamRoomTargetComponent:refreshTargetNameText()
	if self.dungeonConfig then
		ClientTextUtils.setText(self.txtTargetName, self:getDungeonNameText())
	end
end

function TeamRoomTargetComponent:refreshTargetPlayerNumText()
	if self.dungeonConfig then
		ClientTextUtils.setText(self.txtPlayerNum, pg.getFormatText(pg.getGameString("TEAM_ROOM_PLAYER_NUM_RANGE"), self.dungeonConfig.playerNumMin, self.dungeonConfig.playerNumMax))
	end
end

function TeamRoomTargetComponent:bindTargetSelectButton()
	function self.btnSelectUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM_DUNGEON_SELECT)
	end
end

function TeamRoomTargetComponent:refreshTargetState(dungeonId)
	self:refreshTargetData(dungeonId)
	self:refreshTargetViewState()
	self:refreshTargetPageState()
	self:refreshTargetNameText()
	self:refreshTargetPlayerNumText()
end

function TeamRoomTargetComponent:refreshView(dungeonId)
	self:refreshTargetState(dungeonId)
end

function TeamRoomTargetComponent:onTeamRoomTargetStateChanged()
	self:refreshTargetState()
end

return TeamRoomTargetComponent
