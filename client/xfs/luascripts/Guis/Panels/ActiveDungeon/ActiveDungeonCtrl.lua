-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ActiveDungeon\\ActiveDungeonCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ActiveDungeonCtrl")
local MessageName = require("Const.MessageName")
local ElementAgainstData = require("Data.element_against_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ActiveData = require("Data.activity_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MatchConst = require("Common.Const.MatchConst")
local BossListComponent = require("Guis.Panels.ActiveDungeon.Component.BossListComponent")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local ActiveDungeonCtrl = Class.LightClass("ActiveDungeonCtrl", UICtrl)

ActiveDungeonCtrl.messages = {
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.TEAM_MATCH_START_TIME_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onTeleport",
		false
	}
}

function ActiveDungeonCtrl:onCreate(info)
	self:initActiveInfo(info)
	UICtrl.onCreate(self, info)
end

function ActiveDungeonCtrl:initActiveInfo(info)
	self.activeId = info.activityId
	self.activeInfo = info.activityInfo
	self.activeParam = info.activityParam
	self.activityRefreshTime = info.activityRefreshTime
	self.activeConfig = ActiveData[self.activeId]
	self.name = self.activeConfig.name
end

function ActiveDungeonCtrl:onTeleport()
	self:dismiss()
end

function ActiveDungeonCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnMatchUButton.luaClick()
		self:startMatch()
	end

	function self.view.recommendEleList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	function self.view.rewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewards(button, index, data)
	end

	self.view.picUImage.url = ActiveData[self.activeId].pic

	self:initBossTitleList(self.view.bossDungeonContainerUContainer.content)

	function self.view.btnCancelUButton.luaClick()
		self:cancelMatch()
	end

	function self.view.btnPlayTeamFullUButton.luaClick()
		self:startPlay()
	end

	function self.view.btnPlayUButton.luaClick()
		self:startPlay()
	end

	function self.view.btnCancelUButton.luaClick()
		self:cancelMatch()
	end

	ClientTextUtils.setText(self.view.backTitle, pg.getLocalizationText(self.name))
	self:onTeamMatchedStatusChange()
end

function ActiveDungeonCtrl:startMatch()
	pg.me:startMatch(self.sceneId, nil, MatchConst.MATCH_TEAM_MEMBER_TYPE.MATCH_MEMBER_ENTER)
end

function ActiveDungeonCtrl:onTeamMatchedStatusChange()
	local status = pg.me.matchState

	if status == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON or status == Const.PLAYER_MATCH_STATUS.MATCH_TEAM then
		self.view.teamBtnBoxUComponent:TryChangePage("MatchState", 1)

		local startTs = pg.me.matchStartTime

		self.view.countDownUCountDown.positiveTiming = true

		if startTs and startTs > 0 then
			self.view.countDownUCountDown:Play(math.max(0, Time.secondCache - startTs), 3600)
		else
			self.view.countDownUCountDown:Stop()
		end
	else
		self.view.teamBtnBoxUComponent:TryChangePage("MatchState", 0)
		self.view.countDownUCountDown:Stop()
	end

	self.bossListComponent:onTeamMatchedStatusChange()
end

function ActiveDungeonCtrl:cancelMatch()
	pg.me:cancelTeamMatching()
end

function ActiveDungeonCtrl:startPlay()
	pg.me:applyTeamDungeon(self.sceneId)
end

function ActiveDungeonCtrl:initBossTitleList(content)
	self.bossListComponent = BossListComponent.new(self, content)
end

function ActiveDungeonCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.bossListComponent = nil
end

function ActiveDungeonCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ActiveDungeonCtrl:onShow()
	return
end

function ActiveDungeonCtrl:onHide()
	return
end

function ActiveDungeonCtrl:setActiveInfo(activeData)
	ClientTextUtils.setText(self.view.dungeonNameUText, pg.getLocalizationText(self.name), "·", pg.getLocalizationText(activeData.name))
	ClientTextUtils.setText(self.view.dungeonDetailUText, pg.getLocalizationText(activeData.desc))

	if activeData.buffId then
		ClientTextUtils.setText(self.view.textPanelTxtName, pg.getLocalizationText(activeData.buffName))
		ClientTextUtils.setText(self.view.textPanelDesc, pg.getLocalizationText(activeData.buffDesc))
		self.view.textPanelUWidget:SetActive(true)
	else
		self.view.textPanelUWidget:SetActive(false)
	end

	self.sceneId = activeData.sceneId

	self:setRecommendEleList(activeData.bossElement)
	self.view.rewardUList:SetList(activeData.rewardDatas)

	if activeData.playerMaxNum > 1 then
		self.view.widget:TryChangePage("DungType", 1)
	else
		self.view.widget:TryChangePage("DungType", 0)
	end

	ClientTextUtils.setText(self.view.peopleNumUBaseText, activeData.playerMinNum .. "-" .. activeData.playerMaxNum)

	local player = pg.me

	if not player:isInTeam() then
		self.view.teamBtnBoxUComponent:TryChangePage("TeamState", 0)
	else
		local memberCount = player:getTeamMemberCount()

		if memberCount >= activeData.playerMaxNum then
			self.view.teamBtnBoxUComponent:TryChangePage("TeamState", 2)
		else
			self.view.teamBtnBoxUComponent:TryChangePage("TeamState", 1)
		end
	end
end

function ActiveDungeonCtrl:setRecommendEleList(bossElement)
	local ret = {}

	for elementName, info in pairs(ElementAgainstData) do
		if info[bossElement] > 1 then
			ret[#ret + 1] = {
				element = elementName
			}
		end
	end

	self.view.recommendEleList:SetList(ret)
end

return ActiveDungeonCtrl
