-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameDungeonInfo\\GameDungeonInfoCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HotkeyConst = require("Const.HotkeyConst")
local lume = require("Core.Common.lume")
local GameDungeonInfoCtrl = Class.LightClass("GameDungeonInfoCtrl", UICtrl)
local Const = require("Common.Const.Const")
local TeamMatchEntryComponent = require("Guis.Panels.ActiveDungeon.Component.TeamMatchEntryComponent")
local GameDungeonInfoChatComponent = require("Guis.Panels.GameDungeonInfo.Component.GameDungeonInfoChatComponent")
local GameDungeonInfoContentComponent = require("Guis.Panels.GameDungeonInfo.Component.GameDungeonInfoContentComponent")

GameDungeonInfoCtrl.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	}
}

function GameDungeonInfoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.dungeonId = info and info.dungeonId
	self.showCurrencyId = 2
	self.canChallenge = true

	self:initDungeonInfo()

	self.matchCom = TeamMatchEntryComponent.new(self, self.view.btnMatchUComponent, {
		dungeonId = self.dungeonId,
		dungeonType = Const.CUR_DUNGEON_TYPE.Dungeon
	})

	self.matchCom:bindTeamRoomFrameStartButton()
	self.matchCom:refreshTeamRoomFrameMatchEntryState(self.dungeonId)
	self:initChatComponent()
end

function GameDungeonInfoCtrl:addListener()
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:challengeDungeon()
	end
end

function GameDungeonInfoCtrl:refreshTeamInfo()
	if self.matchCom then
		self.matchCom:refreshView()
	end

	if self.chatCom then
		self.chatCom:refreshTeamInfo()
	end

	if self.isSingle and self.matchStatus == Const.DUNGEON_CHANGE_STATUS.WaitChange then
		self:startDungeon()

		self.matchStatus = nil
	end
end

function GameDungeonInfoCtrl:initChatComponent()
	if not self.view.chatUContainer then
		return
	end

	self.view.chatUContainer:LoadDefaultUrlManually(function(content)
		if not content or IsNil(content) or not self.view then
			return
		end

		self.chatCom = GameDungeonInfoChatComponent.new(self, content, {
			dungeonSceneId = self.dungeonId
		})
	end)
end

function GameDungeonInfoCtrl:onTeamMatchedStatusChange()
	if self.isSingle and self.matchStatus == Const.DUNGEON_CHANGE_STATUS.WaitChange and not pg.me:isInTeam() then
		self:startDungeon()

		self.matchStatus = nil
	end

	if self.matchCom then
		self.matchCom:onTeamMatchedStatusChange()
	end

	if self.chatCom then
		self.chatCom:refreshTeamInfo()
	end
end

function GameDungeonInfoCtrl:challengeDungeon()
	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if pg.me:isInTeam() and lume.getMapLen(pg.me.teamInfo.playerInDungeon) > 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_HAS_PLAYER_IN_DUNGEON"))

		return
	end

	self.matchStatus = pg.me:tryStartDungeon(self.dungeonId)

	if self.matchStatus == Const.DUNGEON_CHANGE_STATUS.PASS then
		self:startDungeon()
	end
end

function GameDungeonInfoCtrl:startDungeon()
	pg.me:doEventByData({
		"challengeDungeon",
		{
			self.dungeonId
		}
	})

	if self.canChallenge then
		self:close()
	end
end

function GameDungeonInfoCtrl:initDungeonInfo()
	self.dungeonInfoCom = GameDungeonInfoContentComponent.new(self, self.view.transform, {
		showCurrencyId = self.showCurrencyId
	})

	self:refreshDungeonInfo(self.dungeonId)
end

function GameDungeonInfoCtrl:refreshDungeonInfo(dungeonId)
	if not self.dungeonInfoCom then
		return
	end

	self.dungeonId = dungeonId or self.dungeonId
	self.dungeonConfig, self.canChallenge, self.isSingle = self.dungeonInfoCom:refreshByDungeonId(self.dungeonId)

	if self.dungeonConfig and not self.isSingle then
		self:onTeamMatchedStatusChange()
	end

	if self.matchCom then
		self.matchCom:refreshTeamRoomFrameMatchEntryState(self.dungeonId)
	end

	if self.chatCom then
		self.chatCom:refreshTeamInfo()
	end
end

function GameDungeonInfoCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GameDungeonInfoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info and info.dungeonId and info.dungeonId ~= self.dungeonId then
		self:refreshDungeonInfo(info.dungeonId)
	end
end

function GameDungeonInfoCtrl:onShow()
	return
end

function GameDungeonInfoCtrl:onHide()
	return
end

return GameDungeonInfoCtrl
