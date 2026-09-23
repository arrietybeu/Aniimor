-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankReward\\RankRewardCtrl.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local UICtrl = require("Guis.UICtrl")
local RankRewardData = require("Data.rank_reward_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RankRewardCtrl = Class.LightClass("RankRewardCtrl", UICtrl)

RankRewardCtrl.messages = {
	[MessageName.RANK_DATA_UPDATED] = {
		"onRankDataUpdated",
		true
	}
}

local SETTLE_TYPE_TEXT_KEYS = {
	"RANK_REWARD_TODAY",
	"RANK_REWARD_MONTHLY",
	"RANK_REWARD_QUARTERLY",
	"RANK_REWARD_HALF_SEASON",
	"RANK_REWARD_OVERALL"
}
local BUTTON_STATE_NORMAL = 0
local BUTTON_STATE_SELECTED = 5

function RankRewardCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.listTab3thUList.luaRenderItem(button, _, data)
		self:renderTabItem(button, data)
	end

	function self.view.listTab3thUList.luaSelectedChanged(uList, selected)
		if selected then
			self:refreshRewardList(uList.selectedItem)
			uList:RefreshList()
		end
	end

	function self.view.listUList.luaRenderItem(button, _, data)
		self:renderRewardGroup(button, data)
	end
end

function RankRewardCtrl:renderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local isSelected = data == self.view.listTab3thUList.selectedItem

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.textKey))
	button:TryChangePage("button", isSelected and BUTTON_STATE_SELECTED or BUTTON_STATE_NORMAL)
end

function RankRewardCtrl:refreshRewardList(data)
	self.view.listUList:SetList(self.model:getRewardList(data.rewardId, self.currentRank))
end

function RankRewardCtrl:renderRewardGroup(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtNowUSDFText = objectReference:GetRefValue("txtNowUSDFText")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local tagNowUWidget = objectReference:GetRefValue("tagNowUWidget")

	ClientTextUtils.setText(txtTitleUSDFText, data.title)
	ClientTextUtils.setText(txtNowUSDFText, pg.getGameString("CURRENT"))
	tagNowUWidget:SetActive(data.isCurrent)

	function listRewardUList.luaRenderItem(rewardButton, _, rewardData)
		self:renderRewardItem(rewardButton, rewardData)
	end

	listRewardUList:SetList(data.rewards)
end

function RankRewardCtrl:renderRewardItem(button, data)
	LuaUIUtils.renderRewardItem(button, data, nil, nil, nil, nil, function()
		self:close()
	end)
end

function RankRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.rankId = info.rankId
	self.tab1 = info.tab1
	self.tab2 = info.tab2

	self:refreshCurrentRank()

	local tabList = self:getRewardTabList(info.rewardIds)

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("RANK_REWARD_TITLE"))
	ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getLocalizationText(info.rewardDes))
	self.view.listTab3thUList:SetList(tabList)
	self.view.listTab3thUList:DeselectAll()
	self.view.listTab3thUList:SelectItem(0)
	self.view.tabUWidget:SetActive(#tabList > 1)
end

function RankRewardCtrl:refreshCurrentRank()
	local selfRankData = pg.game.rank:getCachedSelfRankData(self.rankId, self.tab1, self.tab2)

	self.currentRank = selfRankData and selfRankData.Rank or 0
end

function RankRewardCtrl:getRewardTabList(rewardIds)
	local tabList = {}
	local lastIndex = #rewardIds

	for index, rewardId in ipairs(rewardIds) do
		local rewardData = RankRewardData[rewardId]

		tabList[index] = {
			tIndex = index == 1 and 0 or index == lastIndex and 2 or 1,
			textKey = SETTLE_TYPE_TEXT_KEYS[rewardData.settleType],
			rewardId = rewardId
		}
	end

	return tabList
end

function RankRewardCtrl:onRankDataUpdated(rankId)
	if self.rankId ~= rankId then
		return
	end

	self:refreshCurrentRank()
	self:refreshRewardList(self.view.listTab3thUList.selectedItem)
end

return RankRewardCtrl
