-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankOverview\\GrabEggsSeasonRankOverviewCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local GrabEggsSeasonRankOverviewCtrl = Class.LightClass("GrabEggsSeasonRankOverviewCtrl", UICtrl)

GrabEggsSeasonRankOverviewCtrl.messages = {
	[MessageName.GRAB_EGG_RANK_CHANGED] = {
		"refresh",
		true
	},
	[MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED] = {
		"refresh",
		true
	}
}

local function setText(component, value)
	if component then
		ClientTextUtils.setText(component, value or "")
	end
end

function GrabEggsSeasonRankOverviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GrabEggsSeasonRankOverviewCtrl:claimAllRankRewards()
	if self.model:hasClaimableReward() then
		pg.me:serverMsg("RPC_CS_GetRobEggLevelReward", 0, 0, 0)
	end
end

function GrabEggsSeasonRankOverviewCtrl:setRewardItemRedDot(button, show)
	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_REWARD_ITEM, button.gameObject:GetInstanceID())

	self.rewardItemRedDotPaths = self.rewardItemRedDotPaths or {}
	self.rewardItemRedDotPaths[redDotPath] = true

	pg.global.setRedDot(redDotPath, button, show, RedDotConst.RedDotStyle.REWARD)
end

function GrabEggsSeasonRankOverviewCtrl:clearRewardItemRedDots()
	for redDotPath in pairs(self.rewardItemRedDotPaths or EMPTY_TABLE) do
		pg.global.setRedDot(redDotPath, nil, false, RedDotConst.RedDotStyle.NONE)
	end

	self.rewardItemRedDotPaths = nil
end

function GrabEggsSeasonRankOverviewCtrl:renderRankRewardItem(button, data)
	local canClaim = self.model:isRewardItemClaimable(data)

	if canClaim then
		function data.extraFunc()
			self:claimAllRankRewards()
		end
	else
		data.extraFunc = nil
	end

	LuaUIUtils.renderRewardItem(button, data)
	self:setRewardItemRedDot(button, canClaim)

	button.draggable = false
end

function GrabEggsSeasonRankOverviewCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:close()
		end

		self:bindCloseButton(self.view.btnBackUButton)
	end

	self.view.rankUList.cancelSupport = false

	function self.view.rankUList.luaRenderItem(button, _, data)
		self:renderRankItem(button, data)
	end

	function self.view.rankUList.luaSelectedChanged(uList)
		if IsNil(uList.selectedItem) then
			return
		end

		local success, button = uList:TryGetChildAt(uList.selectedIndex)

		if not success then
			return
		end

		CS.XGUI.Navigation.NavManager.Instance:FocusItem(button, CS.XGUI.Navigation.FocusEntryMode.Restore)

		self.selectedBigRank = uList.selectedItem.bigRank

		self:renderExpandedRank(button, uList.selectedItem)
	end

	self:bindGamepadScrollUList(self.view.rankUList, 200, false)
end

function GrabEggsSeasonRankOverviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openInfo = info or {}
end

function GrabEggsSeasonRankOverviewCtrl:onShow()
	self.selectedBigRank = self.openInfo.bigRank or self.model:getCurrentBigRank()

	self:refresh()
end

function GrabEggsSeasonRankOverviewCtrl:refresh()
	self.rankGroups = self.model:getRankGroups()

	setText(self.view.tMPUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_UPGRADE_REWARD_TITLE"))

	local selectedIndex

	for _, data in ipairs(self.rankGroups) do
		data.isSelected = data.bigRank == self.selectedBigRank
	end

	self.view.rankUList:SetList(self.rankGroups)

	for index, data in ipairs(self.rankGroups) do
		if data.isSelected then
			selectedIndex = index - 1

			break
		end
	end

	if selectedIndex then
		self.view.rankUList:GoToIndex(math.max(selectedIndex - 1, 0), true)
		self.view.rankUList:SelectItem(selectedIndex)
	end
end

function GrabEggsSeasonRankOverviewCtrl:renderRankItem(button, data)
	button:TryChangePage("LevelSize", data.bigRank - 1)
	button:TryChangePage("LevelState", data.levelState)

	local objectReference = button:GetComponent("ObjectReference")

	if objectReference == nil or IsNil(objectReference) then
		return
	end

	local foldName = objectReference:GetRefValue("textUSDFText")
	local foldIcon = objectReference:GetRefValue("iconUImage")
	local buttonUButton = objectReference:GetRefValue("buttonUButton")

	setText(foldName, data.name)

	if foldIcon then
		foldIcon.url = data.icon
	end

	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_OVERVIEW_ITEM, data.bigRank)

	self.rankItemRedDotPaths = self.rankItemRedDotPaths or {}
	self.rankItemRedDotPaths[redDotPath] = true

	pg.global.setRedDot(redDotPath, buttonUButton or button, self.model:hasClaimableReward(data.rewardNodes), RedDotConst.RedDotStyle.REWARD)

	local unfoldName = objectReference:GetRefValue("txtLevelUSDFText")
	local unfoldIcon = objectReference:GetRefValue("IconUnfoldUImage")

	setText(unfoldName, data.name)

	if unfoldIcon then
		unfoldIcon.url = data.icon
	end
end

function GrabEggsSeasonRankOverviewCtrl:renderExpandedRank(button, data)
	local objectReference = button:GetComponent("ObjectReference")

	if objectReference == nil or IsNil(objectReference) then
		return
	end

	local privilegeTitle = objectReference:GetRefValue("textVIPUSDFText")
	local rankRewardTitle = objectReference:GetRefValue("textRankUSDFText")
	local levelRewardTitle = objectReference:GetRefValue("textLevelUSDFText")
	local descList = objectReference:GetRefValue("listSkillLevelUList")
	local rewardList1 = objectReference:GetRefValue("listUList")
	local rewardList2 = objectReference:GetRefValue("list2UList")

	setText(privilegeTitle, pg.getGameString("GRAB_EGG_SEASON_RANK_PRIVILEGE"))
	setText(rankRewardTitle, pg.getGameString("GRAB_EGG_SEASON_RANK_REWARD_TAB"))
	setText(levelRewardTitle, pg.getGameString("GRAB_EGG_SEASON_STAGE_REWARD_TAB"))

	local function bindRewardList(list, rewards)
		if not list then
			return
		end

		function list.luaRenderItem(button, _, reward)
			self:renderRankRewardItem(button, reward)
		end

		list:SetList(rewards)
	end

	local rankRewardNode = data.rankRewardNodes and data.rankRewardNodes[1]
	local hasRankReward = rankRewardNode ~= nil and #(rankRewardNode.dropIds or {}) > 0

	if rankRewardTitle then
		rankRewardTitle:SetActive(hasRankReward)
	end

	if rewardList1 then
		rewardList1:SetActive(hasRankReward)
	end

	bindRewardList(rewardList1, data.rankRewards)
	bindRewardList(rewardList2, data.stageRewards)

	if descList then
		function descList.luaRenderItem(button, _, desc)
			local descObjectReference = button:GetComponent("ObjectReference")

			if descObjectReference == nil or IsNil(descObjectReference) then
				return
			end

			local text = descObjectReference:GetRefValue("txtInfoUSDFText")

			if text then
				text.supportRichText = true
			end

			setText(text, desc.text)
		end

		descList:SetList(data.descriptions)
	end
end

function GrabEggsSeasonRankOverviewCtrl:onDestroy()
	self:clearRewardItemRedDots()

	for redDotPath in pairs(self.rankItemRedDotPaths or EMPTY_TABLE) do
		pg.global.setRedDot(redDotPath, nil, false, RedDotConst.RedDotStyle.NONE)
	end

	self.rankItemRedDotPaths = nil

	UICtrl.onDestroy(self)
end

return GrabEggsSeasonRankOverviewCtrl
