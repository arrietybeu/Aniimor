-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ActiveDungeon\\Component\\BossListComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossListComponent")
local LevelDataMap = require("Data.level_data_mapping")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffConfigData = require("Data.buff_config_data")
local LevelData = require("Data.level_data")
local ItemData = require("Data.item_data")
local AddressDataConst = require("Const.AddressDataConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Utils = require("Common.Utils.Utils")
local UI_BOSS_DUNGEON_BOSS_ICON = AddressDataConst.UI_BOSS_DUNGEON_BOSS_ICON
local BossListComponent = Class.LightClass("BossListComponent", UIComponent)

function BossListComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.numUSDFText = self.objectReference:GetRefValue("numUSDFText")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.refreshTxt = self.objectReference:GetRefValue("refreshTxt")
end

function BossListComponent:initView()
	function self.listUList.luaRenderItem(button, idx, data)
		self:renderBossList(button, idx, data)
	end

	function self.listUList.luaSelectedChanged(ulist, selected)
		if selected then
			self.selectedSceneId = ulist.selectedItem.sceneId

			self.ctrl:setActiveInfo(ulist.selectedItem)
		end
	end

	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("BOSS_CHALLENGE_TEXT1"))
	self.listUList:SetList(self:getBossData())
	self:setRewardRefreshTime()
end

function BossListComponent:setRewardRefreshTime()
	local curCount = pg.me.activityRewardCounts[self.ctrl.activeId] or 0

	ClientTextUtils.setText(self.numUSDFText, curCount .. "/" .. self.ctrl.activeConfig.rewardTimes)

	if self.ctrl.activeConfig.rewardRefresh == Const.LIMIT_DAY then
		ClientTextUtils.setText(self.refreshTxt, pg.getGameString("REMAIN_REWARD_DAY"))
		LuaUIUtils.setCountDownTime(self.countDownUCountDown, TimeUtils.getNextDayBegin(self.ctrl.activityRefreshTime + Utils.getSecondsDayStart()), UIConst.TimeType.Short)
	else
		local nextTime = TimeUtils.getNextWeekBegin(self.ctrl.activityRefreshTime + Utils.getSecondsDayStart())
		local remainTime = nextTime - Time.getSecond()

		if remainTime > 86400 then
			LuaUIUtils.setCountDownTime(self.countDownUCountDown, nextTime, UIConst.TimeType.Full)
		else
			LuaUIUtils.setCountDownTime(self.countDownUCountDown, nextTime, UIConst.TimeType.Short)
		end

		ClientTextUtils.setText(self.refreshTxt, pg.getGameString("REMAIN_REWARD_WEEK"))
	end
end

function BossListComponent:renderBossList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")

	iconUImage.url = string.format(UI_BOSS_DUNGEON_BOSS_ICON, data.bossIcon)

	ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(data.name))

	if self.isMatching then
		button.interactable = data.isMatchingScene
	else
		button.interactable = true
	end
end

function BossListComponent:onTeamMatchedStatusChange()
	self.listUList:SetList(self:getBossData())
end

function BossListComponent:getBossData()
	local ret = {}

	self.isMatching = false

	if pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON or pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCH_TEAM then
		self.isMatching = true
	end

	local dungeonSceneId = pg.me:getCurTeamInfo().dungeonSceneId
	local hasSelected = false

	for sceneId, buffId in pairs(self.ctrl.activeInfo) do
		local data = {}

		sceneId = tonumber(sceneId)

		local dungeonInfo = LevelData[sceneId]

		data.sceneId = sceneId
		data.name = dungeonInfo.name
		data.desc = dungeonInfo.describe
		data.pic = dungeonInfo.pic
		data.bossIcon = dungeonInfo.BossTemplateId

		if self.isMatching and sceneId == dungeonSceneId then
			data.selected = true
			data.isMatchingScene = true
			hasSelected = true
		elseif not self.isMatching and self.selectedSceneId == sceneId then
			data.selected = true
			hasSelected = true
		end

		if buffId ~= 0 then
			data.buffId = buffId

			local buffInfo = BuffConfigData[buffId]

			data.buffName = buffInfo.buffName
			data.buffDesc = buffInfo.buffDesc
		end

		data.bossElement = dungeonInfo.BossElement
		data.playerMaxNum = dungeonInfo.playerNumMax
		data.playerMinNum = dungeonInfo.playerNumMin
		data.rewardDatas = self:getRewardDatas(dungeonInfo)
		ret[#ret + 1] = data
	end

	if not hasSelected then
		ret[1].selected = true
	end

	return ret
end

function BossListComponent:getRewardDatas(dungeonInfo)
	local notFirstTimeRewardId = dungeonInfo.notFirstTimeRewardId
	local rareRewardId = dungeonInfo.RareRewardId
	local ret = LuaUIUtils.getRewardItemByDropId(rareRewardId)
	local ret2 = LuaUIUtils.getRewardItemByDropId(notFirstTimeRewardId)
	local appendRet = {}

	for _, v2 in ipairs(ret2) do
		local hasReward = false

		for _, v in ipairs(ret) do
			if v.id == v2.id then
				hasReward = true

				break
			end
		end

		if not hasReward then
			appendRet[#appendRet + 1] = v2
		end
	end

	lume.append(ret, appendRet)

	for _, v in pairs(ret) do
		v.num = 1
	end

	table.sort(ret, function(a, b)
		local quA = ItemData[a.id].quality or 0
		local quB = ItemData[b.id].quality or 0

		return quB < quA
	end)

	return ret
end

function BossListComponent:onOpen(info)
	UIComponent.onOpen(self, info)
end

function BossListComponent:onDestroy()
	UIComponent.onDestroy(self)

	self.selectedSceneId = nil
end

return BossListComponent
