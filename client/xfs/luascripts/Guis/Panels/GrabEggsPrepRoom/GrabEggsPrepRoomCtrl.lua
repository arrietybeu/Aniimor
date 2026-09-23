-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\GrabEggsPrepRoomCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("GrabEggsPrepRoomCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsPrepRoomCtrl = Class.LightClass("GrabEggsPrepRoomCtrl", UICtrl)
local GrabEggTeamSceneComponent = require("Guis.Panels.GrabEggsPrepRoom.Component.GrabEggTeamSceneComponent")
local GrabEggChatComponent = require("Guis.Panels.GrabEggsPrepRoom.Component.GrabEggChatComponent")
local GrabEggGameplayComponent = require("Guis.Panels.GrabEggsPrepRoom.Component.GrabEggGameplayComponent")
local TeamPrepRoomCommonComponent = require("Guis.Panels.TeamRoom.Component.TeamPrepRoomCommonComponent")
local TeamDungeonComponent = require("Guis.Panels.TeamRoom.Component.TeamDungeonComponent")
local TeamMatchEntryComponent = require("Guis.Panels.ActiveDungeon.Component.TeamMatchEntryComponent")
local UICardRenderUtils = require("Guis.Utils.UICardRenderUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ConstData = require("Common.Const.Const")
local HotKeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")

GrabEggsPrepRoomCtrl.messages = {
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"event_teamMatchStateChange",
		true
	},
	[MessageName.EGG_MATCH_STATE_CHANGE] = {
		"event_teamMatchStateChange",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"event_syncTeamInfo",
		true
	},
	[MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE] = {
		"refreshView",
		true
	}
}

function GrabEggsPrepRoomCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.commonCmp = TeamPrepRoomCommonComponent.new(self, nil, {
		navListenerName = "GrabEggsPrepRoom",
		useCSConsoleBar = true,
		logger = logger
	})
	self.uiSceneCmp = GrabEggTeamSceneComponent.new(self)
	self.chatCmp = GrabEggChatComponent.new(self, self.view.chatUContainer)
	self.gameplayCmp = GrabEggGameplayComponent.new(self)
	self.dungeonCmp = TeamDungeonComponent.new(self)

	local dungeonId = info and info.dungeonId
	local difficultLv = info and info.difficultLv

	if not dungeonId then
		local teamInfo = pg.me:getShowTeamInfo()

		dungeonId = teamInfo.dungeonSceneId
	end

	if not difficultLv then
		local teamInfo = pg.me:getShowTeamInfo()

		difficultLv = teamInfo.hardLv
	end

	self.model:setDungeonInfo(dungeonId, difficultLv)

	self.matchCom = TeamMatchEntryComponent.new(self, self.view.funOc, {
		dungeonId = dungeonId,
		dungeonType = Const.CUR_DUNGEON_TYPE.Egg
	})
end

function GrabEggsPrepRoomCtrl:addListener(info)
	UICtrl.addListener(self)

	function self.view.btnBack.luaClick()
		self:onBtnBackToMode()
	end

	self:bindCloseButton()
end

function GrabEggsPrepRoomCtrl:initConsoleBarStateKeys()
	if self.commonCmp then
		self.commonCmp:initConsoleBarStateKeys()
	end
end

function GrabEggsPrepRoomCtrl:closePanel()
	self:onBtnClosePanel()
end

function GrabEggsPrepRoomCtrl:refreshConsoleBarState()
	if self.commonCmp then
		self.commonCmp:refreshConsoleBarState()
	end
end

function GrabEggsPrepRoomCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GrabEggsPrepRoomCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.exitBtnName, pg.getGameString("GRAB_EGG_NAME"))
end

function GrabEggsPrepRoomCtrl:onShow()
	self:refreshView()
	self:event_teamMatchStateChange()
end

function GrabEggsPrepRoomCtrl:refreshView()
	if not pg.me:isInTeam() then
		return
	end

	self.teamData = self.model:tryParseTeamInfo()

	local data = self.teamData

	if self.dungeonCmp then
		self.dungeonCmp:refreshView(self:getDungeonViewData(data))
	end

	if self.gameplayCmp then
		self.gameplayCmp:refreshView(data)
	end

	for i, v in ipairs(self.view.uiCardList) do
		local member = data.members[i]

		if member then
			v:SetActive(true)
			self:renderPetUICard(v, member)
		else
			v:SetActive(false)
		end
	end
end

function GrabEggsPrepRoomCtrl:renderPetUICard(item, data)
	item.transform:GetComponent("ObjectReference"):GetRefValue("btnVoiceUButton"):SetHotkeyConsoleBar("CONSOLE_BAR_MUTE_VOICE", -99)

	function data.switchPetsFunc()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
			isDelayShowBlur = true,
			onePlusThreeMode = true,
			tab = 1,
			isPvp = Utils.getPvpMatchMode() == Const.PvpMatchMode.Double,
			closeAction = function()
				return
			end
		})
	end

	function data.onNavFocused(uid)
		if self.commonCmp then
			self.commonCmp:onMemberNavFocused(uid)
		end
	end

	function data.onNavUnfocused(uid)
		if self.commonCmp then
			self.commonCmp:onMemberNavUnfocused()
		end
	end

	UICardRenderUtils.render1Plus3RoomCard(item, data)
end

function GrabEggsPrepRoomCtrl:getDungeonViewData(data)
	data = data or {}

	return {
		modeName = pg.global.ui.grabEggsMode.model:getDifficultName(self.model:getDifficultLv()),
		modeType = pg.me.teamInfo.dungeonSceneId == ConstData.ROB_EGG_SCENE_CLIP_ID and 0 or 1,
		mapName = data.mapName,
		isLeader = data.isLeader
	}
end

function GrabEggsPrepRoomCtrl:onBtnBackToMode()
	self:checkAutoLeaveTeam()
	self:close()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_MODE)
end

function GrabEggsPrepRoomCtrl:onBtnClosePanel()
	self:checkAutoLeaveTeam()
	self:close()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_MODE)
end

function GrabEggsPrepRoomCtrl:onBtnSwitchMode()
	self:checkAutoLeaveTeam()
	self:close()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_MODE)
end

function GrabEggsPrepRoomCtrl:onBtnModeSwitch()
	self:onBtnSwitchMode()
end

function GrabEggsPrepRoomCtrl:onHide()
	return
end

function GrabEggsPrepRoomCtrl:event_syncTeamInfo()
	local teamInfo = pg.me:getShowTeamInfo()

	if teamInfo.dungeonSceneId then
		if pg.me:isInTeam() then
			self.model:setDungeonInfo(teamInfo.dungeonSceneId, teamInfo.hardLv)
			self:refreshView()
			self.uiScene:refreshModels()
		else
			self:close()

			return
		end

		if self.matchCom then
			self.matchCom:refreshView(teamInfo.dungeonSceneId, teamInfo.hardLv)
		end
	else
		self:close()
	end
end

function GrabEggsPrepRoomCtrl:event_teamMatchStateChange()
	if self.matchCom then
		self.matchCom:onTeamMatchedStatusChange()
	end
end

function GrabEggsPrepRoomCtrl:checkAutoLeaveTeam()
	local txtCount = pg.me:isInTeam() and pg.me:getTeamMemberCount(true) or 1

	if not pg.me:isInMatching() then
		if txtCount == 1 then
			pg.me:leaveTeam()
		elseif pg.me:isTeamLeader() then
			pg.me:cancelTeamDungeon()
		end
	end
end

return GrabEggsPrepRoomCtrl
