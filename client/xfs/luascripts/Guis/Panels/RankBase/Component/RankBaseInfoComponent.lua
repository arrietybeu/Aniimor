-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\RankBaseInfoComponent.lua

local Class = require("Core.Framework.Class")
local RankConst = require("Const.RankConst")
local RankDisplayValueData = require("Data.rank_display_value_data")
local UIComponent = require("Guis.Helper.UIComponent")
local RankBaseDisplayRegistry = require("Guis.Panels.RankBase.Component.RankBaseDisplayRegistry")
local PetInfoTipPresenter = require("Guis.Utils.PetInfoTipPresenter")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RankBaseInfoComponent = Class.LightClass("RankBaseInfoComponent", UIComponent)
local CURRENT_PERIOD_THIRD_TAB = {
	textKey = "RANK_CURRENT_PERIOD",
	tIndex = 0,
	clickCallback = "onCurrentPeriodRankClick"
}
local PREVIOUS_PERIOD_THIRD_TAB = {
	textKey = "RANK_PREVIOUS_PERIOD",
	tIndex = 2,
	clickCallback = "onPreviousPeriodRankClick"
}
local DEFAULT_THIRD_TAB_LIST = {
	CURRENT_PERIOD_THIRD_TAB,
	PREVIOUS_PERIOD_THIRD_TAB
}
local BUTTON_STATE_NORMAL = 0
local BUTTON_STATE_SELECTED = 5
local RANKING_TYPE_ONE_TEAM = 0
local RANKING_TYPE_TWO_NUM = 1
local RANKING_ITEM_BTN_INFO_RES_ID = "$UI_Node_RankingItem_BtnInfo.prefab"

local function hasDisplayInfo(displayId)
	return displayId ~= nil and displayId ~= 0
end

local function getDisplayData(displayId)
	return RankDisplayValueData[displayId]
end

local function getRankingType(config)
	return hasDisplayInfo(config.extraInfo4) and RANKING_TYPE_TWO_NUM or RANKING_TYPE_ONE_TEAM
end

local function checkHasReward(config)
	return config.rewardId ~= nil and #config.rewardId > 0
end

local function getCurrentPeriodRankId(rankTabData)
	return pg.game.rank:getCurrentRankId(rankTabData.rankId, rankTabData.tab1, rankTabData.tab2)
end

local function getPreviousPeriodRankId(rankTabData)
	return pg.game.rank:getPreviousRankId(rankTabData.rankId, rankTabData.tab1, rankTabData.tab2)
end

function RankBaseInfoComponent:renderRankInfoTooltip(tooltip)
	local objectReference = tooltip:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function RankBaseInfoComponent:refreshUI(info, rankTabData)
	self.rankPageInfo = info
	self.rankTabData = rankTabData

	self:setRankTitle(info)

	local rankingType = getRankingType(info)

	self.rankingType = rankingType

	self.view.widget:TryChangePage("RankingType", rankingType)
	self:setRankHeaderInfo(info, rankingType)
	self:setRankActionButtons(checkHasReward(info))
	self:refreshThirdTab()
end

function RankBaseInfoComponent:setRankTitle(info)
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getLocalizationText(info.rankName))
end

function RankBaseInfoComponent:refreshThirdTab()
	local hasPreviousRankData = self:hasPreviousRankData()

	self.view.tab2thUWidget:SetActive(hasPreviousRankData)

	if not hasPreviousRankData then
		return
	end

	self.view.nameUWidget:SetActive(false)
	self.view.listTab3thUList:SetActive(true)
	self:setThirdTabList(DEFAULT_THIRD_TAB_LIST)
end

function RankBaseInfoComponent:hasPreviousRankData()
	return getPreviousPeriodRankId(self.rankTabData) ~= nil
end

function RankBaseInfoComponent:setThirdTabList(tabList)
	function self.view.listTab3thUList.luaRenderItem(button, _, data)
		self:renderThirdTabItem(button, data)
	end

	function self.view.listTab3thUList.luaSelectedChanged(uList, selected)
		if selected then
			uList:RefreshList()
		end
	end

	function self.view.listTab3thUList.luaClick(_, data)
		self[data.clickCallback](self)
	end

	self.view.listTab3thUList:SetList(tabList)
	self.view.listTab3thUList:SelectItem(0, false)
	self.view.listTab3thUList:RefreshList()
end

function RankBaseInfoComponent:renderThirdTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUBaseText")
	local isSelected = data == self.view.listTab3thUList.selectedItem

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.textKey))
	button:TryChangePage("button", isSelected and BUTTON_STATE_SELECTED or BUTTON_STATE_NORMAL)
end

function RankBaseInfoComponent:onCurrentPeriodRankClick()
	self.ctrl:onRankPeriodSelected(getCurrentPeriodRankId(self.rankTabData))
end

function RankBaseInfoComponent:onPreviousPeriodRankClick()
	self.ctrl:onRankPeriodSelected(getPreviousPeriodRankId(self.rankTabData))
end

function RankBaseInfoComponent:setRankHeaderInfo(info, rankingType)
	ClientTextUtils.setText(self.view.txtRankingTitleUSDFText, pg.getGameString("RANK_DEFAULT_TITLE"))
	ClientTextUtils.setText(self.view.txtNameTitleUSDFText, self:getNameTitle(info.extraInfo1))

	if rankingType == RANKING_TYPE_ONE_TEAM then
		self:setOneValueHeader(info)

		return
	end

	self:setTwoValueHeader(info)
end

function RankBaseInfoComponent:getNameTitle(displayId)
	return RankBaseDisplayRegistry.getTitle(displayId, "")
end

function RankBaseInfoComponent:setOneValueHeader(info)
	ClientTextUtils.setText(self.view.txtOneteamTitleUSDFText, RankBaseDisplayRegistry.getTitle(info.extraInfo2, ""))
	ClientTextUtils.setText(self.view.txtScoreTitleUSDFText, RankBaseDisplayRegistry.getTitle(info.extraInfo3, ""))
end

function RankBaseInfoComponent:setTwoValueHeader(info)
	ClientTextUtils.setText(self.view.txtTwoNum1TitleUSDFText, RankBaseDisplayRegistry.getTitle(info.extraInfo2, ""))
	ClientTextUtils.setText(self.view.txtTwoNum2TitleUSDFText, RankBaseDisplayRegistry.getTitle(info.extraInfo3, ""))
	ClientTextUtils.setText(self.view.txtScoreTitleUSDFText, RankBaseDisplayRegistry.getTitle(info.extraInfo4, ""))
end

function RankBaseInfoComponent:setRankActionButtons(hasReward)
	self.view.btnInfoUButton:SetActive(not hasReward)
	self.view.btnRewardUButton:SetActive(hasReward)
end

function RankBaseInfoComponent:renderRankItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	self:renderRankData(button, objectReference, data, false)
end

function RankBaseInfoComponent:renderRankData(widget, objectReference, data, isSelf)
	local layoutLeftULayoutBox = objectReference:GetRefValue("layoutLeftULayoutBox")
	local layoutMid1ULayoutBox = objectReference:GetRefValue("layoutMid1ULayoutBox")
	local layoutMid2ULayoutBox = objectReference:GetRefValue("layoutMid2ULayoutBox")
	local layoutRightULayoutBox = objectReference:GetRefValue("layoutRightULayoutBox")

	widget:TryChangePage("Order", self:getOrderState(data.Rank))
	widget:TryChangePage("Self", isSelf and 1 or 0)
	self:renderRankColumn(objectReference, data)
	self:renderDisplayColumn(layoutLeftULayoutBox, self.rankPageInfo.extraInfo1, data)
	self:renderDisplayColumn(layoutMid1ULayoutBox, self.rankPageInfo.extraInfo2, data)

	local mid2DisplayId = self.rankingType == RANKING_TYPE_TWO_NUM and self.rankPageInfo.extraInfo3 or nil

	self:renderDisplayColumn(layoutMid2ULayoutBox, mid2DisplayId, data)
	self:renderScoreColumn(layoutRightULayoutBox, data)
end

function RankBaseInfoComponent:renderDisplayColumn(layoutBox, displayId, rankData)
	self:hideColumnNodes(layoutBox)

	if not hasDisplayInfo(displayId) then
		return
	end

	local displayData = getDisplayData(displayId)
	local handler, displayValue = RankBaseDisplayRegistry.resolve(displayId, displayData, rankData)

	if handler == nil then
		return
	end

	local resId = RankConst.DisplayNodeResIds[handler.targetType]

	if resId == nil then
		return
	end

	local target = self:showColumnNode(layoutBox, resId)

	if target == nil then
		return
	end

	local rendered = RankBaseDisplayRegistry.render(handler, target.objectReference, rankData, displayValue, self.petInfoTipPresenter)

	target.gameObject:SetActiveEx(rendered)

	local shouldShowAdditionalEntry = rendered and handler.supportsAdditionalEntry and displayData.additional == 1

	if shouldShowAdditionalEntry then
		self:showColumnInfoButton(layoutBox)
	end

	layoutBox:ForceRebuildLayoutImmediate()
end

function RankBaseInfoComponent:renderScoreColumn(layoutBox, rankData)
	local displayId = self.rankingType == RANKING_TYPE_TWO_NUM and self.rankPageInfo.extraInfo4 or self.rankPageInfo.extraInfo3

	self:renderDisplayColumn(layoutBox, displayId, rankData)
end

function RankBaseInfoComponent:showColumnInfoButton(layoutBox)
	local target = self:showColumnNode(layoutBox, RANKING_ITEM_BTN_INFO_RES_ID)

	if target == nil then
		return
	end

	local btnInfoUButton = target.objectReference:GetRefValue("btnInfoUButton")

	btnInfoUButton:SetActive(true)
end

function RankBaseInfoComponent:renderRankColumn(objectReference, rankData)
	local txtOrderNumUSDFText = objectReference:GetRefValue("txtOrderNumUSDFText")

	if rankData.Rank <= 0 then
		ClientTextUtils.setText(txtOrderNumUSDFText, pg.getGameString("RANK_NOT_LISTED"))

		return
	end

	ClientTextUtils.setText(txtOrderNumUSDFText, rankData.Rank)
end

function RankBaseInfoComponent:getOrderState(rank)
	if rank >= 1 and rank <= 3 then
		return rank - 1
	end

	return 3
end

function RankBaseInfoComponent:isSelfRankData(rankData)
	return rankData.MemberId == pg.me.uid
end

function RankBaseInfoComponent:isFriendRankData(rankData)
	local isRankOwnerVisible = self:isSelfRankData(rankData) or pg.game.chat:checkFriendList(rankData.MemberId)

	if isRankOwnerVisible then
		return true
	end

	local teamInfo = rankData.Info[tostring(RankConst.DisplayInfoType.TEAM_INFO)]

	if teamInfo == nil then
		return false
	end

	for _, memberInfo in ipairs(teamInfo.members) do
		local isMemberVisible = memberInfo.uid == pg.me.uid or pg.game.chat:checkFriendList(memberInfo.uid)

		if isMemberVisible then
			return true
		end
	end

	return false
end

function RankBaseInfoComponent:setSelfRankData(selfRankData)
	selfRankData = selfRankData or self:createEmptySelfRankData()

	local objectReference = self.view.rankingSelfObjectReference
	local widget = objectReference.gameObject:GetComponent(typeof(CS.XGUI.UWidget))

	objectReference.gameObject:SetActiveEx(true)
	self:renderRankData(widget, objectReference, selfRankData, true)
end

function RankBaseInfoComponent:createEmptySelfRankData()
	return {
		Rank = 0,
		MemberId = pg.me.uid,
		Info = {}
	}
end

function RankBaseInfoComponent:onCtor()
	self.columnNodeCaches = {}
	self.petInfoTipPresenter = PetInfoTipPresenter.new(self.ctrl.module, function(open)
		self:setRankListScrollDisabled(open)
	end)
end

function RankBaseInfoComponent:setRankListScrollDisabled(disabled)
	self.view.listRankingUList:SetScrollDisabled(disabled)
end

function RankBaseInfoComponent:showColumnNode(layoutBox, resId)
	local target = self:getOrCreateColumnNode(layoutBox, resId)

	if target == nil then
		return
	end

	target.gameObject:SetActiveEx(true)
	target.transform:SetAsLastSibling()

	return target
end

function RankBaseInfoComponent:getOrCreateColumnNode(layoutBox, resId)
	local nodeCache = self:getColumnNodeCache(layoutBox)
	local target = nodeCache[resId]

	if target ~= nil and NotNil(target.gameObject) then
		return target
	end

	local item = self.view:addPrefabWithPathSync(layoutBox.transform, resId)

	if item == nil or IsNil(item.gameObject) then
		return
	end

	target = {
		gameObject = item.gameObject,
		transform = item.transform,
		objectReference = item.gameObject:GetComponent("ObjectReference")
	}
	nodeCache[resId] = target

	return target
end

function RankBaseInfoComponent:getColumnNodeCache(layoutBox)
	local instanceId = layoutBox.gameObject:GetInstanceID()
	local nodeCache = self.columnNodeCaches[instanceId]

	if nodeCache == nil then
		nodeCache = {}
		self.columnNodeCaches[instanceId] = nodeCache
	end

	return nodeCache
end

function RankBaseInfoComponent:hideColumnNodes(layoutBox)
	local nodeCache = self:getColumnNodeCache(layoutBox)

	for _, target in pairs(nodeCache) do
		if NotNil(target.gameObject) then
			target.gameObject:SetActiveEx(false)
		end
	end
end

function RankBaseInfoComponent:onDestroy()
	self.columnNodeCaches = nil

	self.petInfoTipPresenter:destroy()

	self.petInfoTipPresenter = nil
end

return RankBaseInfoComponent
