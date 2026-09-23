-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankMain\\GrabEggsSeasonRankMainCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Object = CS.UnityEngine.Object
local Vector2 = CS.UnityEngine.Vector2
local GrabEggsSeasonRankMainCtrl = Class.LightClass("GrabEggsSeasonRankMainCtrl", UICtrl)
local REWARD_POPUP_TAB_RANK = 0
local REWARD_POPUP_TAB_STAGE = 1
local REWARD_POPUP_MIN_REWARD_COUNT = 5

GrabEggsSeasonRankMainCtrl.messages = {
	[MessageName.GRAB_EGG_RANK_CHANGED] = {
		"refresh",
		true
	},
	[MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED] = {
		"refresh",
		true
	}
}

local function setText(textComponent, value)
	if textComponent then
		ClientTextUtils.setText(textComponent, value or "")
	end
end

local function setList(list, data)
	if list then
		list:SetList(data or {})
	end
end

local function setActive(widget, active)
	if widget then
		widget:SetActive(active)
	end
end

function GrabEggsSeasonRankMainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GrabEggsSeasonRankMainCtrl:claimAllRankRewards()
	if self.model:hasClaimableReward() then
		pg.me:serverMsg("RPC_CS_GetRobEggLevelReward", 0, 0, 0)
	end
end

function GrabEggsSeasonRankMainCtrl:setRewardItemRedDot(button, show)
	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_REWARD_ITEM, button.gameObject:GetInstanceID())

	self.rewardItemRedDotPaths = self.rewardItemRedDotPaths or {}
	self.rewardItemRedDotPaths[redDotPath] = true

	pg.global.setRedDot(redDotPath, button, show, RedDotConst.RedDotStyle.REWARD)
end

function GrabEggsSeasonRankMainCtrl:clearRewardItemRedDots()
	for redDotPath in pairs(self.rewardItemRedDotPaths or EMPTY_TABLE) do
		pg.global.setRedDot(redDotPath, nil, false, RedDotConst.RedDotStyle.NONE)
	end

	self.rewardItemRedDotPaths = nil
end

function GrabEggsSeasonRankMainCtrl:setRewardPopupTabRedDot(button, tabType, show)
	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_REWARD_TAB, tabType)

	self.rewardPopupTabRedDotPaths = self.rewardPopupTabRedDotPaths or {}
	self.rewardPopupTabRedDotPaths[redDotPath] = true

	pg.global.setRedDot(redDotPath, button, show, RedDotConst.RedDotStyle.REWARD)
end

function GrabEggsSeasonRankMainCtrl:clearRewardPopupTabRedDots()
	for redDotPath in pairs(self.rewardPopupTabRedDotPaths or EMPTY_TABLE) do
		pg.global.setRedDot(redDotPath, nil, false, RedDotConst.RedDotStyle.NONE)
	end

	self.rewardPopupTabRedDotPaths = nil
end

function GrabEggsSeasonRankMainCtrl:renderRankRewardItem(button, data)
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

function GrabEggsSeasonRankMainCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:onBackClick()
		end

		self:bindCloseButton(self.view.btnBackUButton)
	end

	local rewardPopupCloseBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rewardPopupCloseBind")

	rewardPopupCloseBind.isVirtual = true
	rewardPopupCloseBind.priority = 1
	rewardPopupCloseBind.actionPath = "Common/ClosePanelCommon"

	function rewardPopupCloseBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:tryCloseRewardPopup() then
			return false
		end

		return true
	end

	if self.view.btnOverviewUButton then
		function self.view.btnOverviewUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASON_RANK_OVERVIEW)
		end
	end

	if self.view.btnRewardOverviewUButton then
		function self.view.btnRewardOverviewUButton.luaClick()
			self:claimAllRankRewards()
		end

		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_REWARD, self.view.btnRewardOverviewUButton, function()
			if self.model:hasClaimableReward() then
				return RedDotConst.RedDotStyle.REWARD
			end

			return RedDotConst.RedDotStyle.NONE
		end)
	end

	if self.view.btnSearchUButton then
		function self.view.btnSearchUButton.luaClick()
			self:setRewardPopupVisible(true)
		end
	end

	if self.view.btnInfoUButton then
		self.view.btnInfoUButton.enabledTooltip = false

		function self.view.btnInfoUButton.luaClick()
			pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_SEASON_INFO)
		end
	end

	if self.view.rewardPopupCloseUButton then
		function self.view.rewardPopupCloseUButton.luaClick()
			self:setRewardPopupVisible(false)
		end
	end

	if self.view.eggUList then
		self.view.eggUList:SetEnableCustomInterval(false)

		function self.view.eggUList.luaRenderItem(button, _, data)
			button:TryChangePage("Stage", data.filled and 1 or 0, true)
		end
	end

	if self.view.descUList then
		function self.view.descUList.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")

			if objectReference ~= nil and not IsNil(objectReference) then
				local text = objectReference:GetRefValue("txtInfoUSDFText")

				if text then
					text.supportRichText = true
				end

				setText(objectReference:GetRefValue("txtInfoUSDFText"), data.text)
			end
		end
	end

	local function bindRewardList(list)
		if not list then
			return
		end

		function list.luaRenderItem(button, _, data)
			self:renderRankRewardItem(button, data)
		end
	end

	bindRewardList(self.view.currentRewardUList)
	bindRewardList(self.view.reward1UList)
	bindRewardList(self.view.reward2UList)

	if self.view.rewardPopupUList then
		function self.view.rewardPopupUList.luaRenderItem(button, _, data)
			self:renderRewardOverviewItem(button, data)
		end
	end

	if self.view.listTab3thUList then
		function self.view.listTab3thUList.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")

			if objectReference ~= nil and not IsNil(objectReference) then
				setText(objectReference:GetRefValue("txtNameUBaseText"), pg.getGameString(data.textKey))
			end

			self:setRewardPopupTabRedDot(button, data.tabType, data.tabType ~= self.rewardPopupTabType and data.hasClaimableReward)
		end

		function self.view.listTab3thUList.luaClick(_, data)
			self:setRewardPopupTab(data.tabType)
		end
	end
end

function GrabEggsSeasonRankMainCtrl:tryCloseRewardPopup()
	if self.rewardPopupCloseGuard then
		return true
	end

	if not self.view.rewardPopupUWidget or not self.view.rewardPopupUWidget.gameObject.activeSelf then
		return false
	end

	self.rewardPopupCloseGuard = true

	TimerManager.addNextFrameCb(function()
		self.rewardPopupCloseGuard = false
	end)
	self:setRewardPopupVisible(false)

	return true
end

function GrabEggsSeasonRankMainCtrl:onBackClick()
	if self:tryCloseRewardPopup() then
		return
	end

	self:close()
end

function GrabEggsSeasonRankMainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openInfo = info or {}
end

function GrabEggsSeasonRankMainCtrl:onShow()
	self:refresh()
	self:setRewardPopupVisible(self.openInfo.showRewardOverview == true)
	self:refreshSeasonInfo()
end

function GrabEggsSeasonRankMainCtrl:refreshRankCutLines(smallRankCount, visible)
	local template = self.view.cutLineUWidget

	if not template or not self.view.scoreUProgress then
		return
	end

	smallRankCount = math.max(1, smallRankCount or 1)

	template:SetActive(false)

	self.rankCutLines = self.rankCutLines or {}

	local lineCount = visible and math.max(0, smallRankCount - 1) or 0
	local progressRect = self.view.scoreUProgress.gameObject:GetComponent("RectTransform")
	local templateRect = template.gameObject:GetComponent("RectTransform")
	local progressWidth = progressRect.rect.width
	local templateY = templateRect.anchoredPosition.y

	for index = 1, lineCount do
		local line = self.rankCutLines[index]

		if not line or IsNil(line.widget) then
			local gameObject = Object.Instantiate(template.gameObject)
			local rectTransform = gameObject:GetComponent("RectTransform")
			local widget = gameObject:GetComponent(typeof(CS.XGUI.UWidget))

			rectTransform:SetParent(progressRect, false)

			line = {
				gameObject = gameObject,
				rectTransform = rectTransform,
				widget = widget
			}
			self.rankCutLines[index] = line
		end

		line.gameObject.name = string.format("CutLine_%d", index)
		line.rectTransform.anchoredPosition = Vector2(progressWidth * (index / smallRankCount - 0.5), templateY)

		line.widget:SetActive(true)
	end

	for index = lineCount + 1, #self.rankCutLines do
		local line = self.rankCutLines[index]

		if line and not IsNil(line.widget) then
			line.widget:SetActive(false)
		end
	end
end

function GrabEggsSeasonRankMainCtrl:refresh()
	local data = self.model:getPageData()

	if not data then
		return
	end

	self.pageData = data

	setText(self.view.btnRewardOverviewUSDFText, pg.getGameString("OBTAIN_ALL"))
	setActive(self.view.btnRewardOverviewUButton, data.hasClaimableReward)
	setText(self.view.rewardPopupTitleUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_REWARD_OVERVIEW_TITLE"))
	setText(self.view.tMPUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_TITLE"))
	setText(self.view.rankScoretextUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_SCORE"))
	setText(self.view.VIPtextUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_PRIVILEGE"))
	setText(self.view.NowRewardtextUSDFText, pg.getGameString(data.rewardPageState == 0 and "GRAB_EGG_SEASON_RANK_CURRENT_REWARD" or "GRAB_EGG_SEASON_RANK_NEXT_REWARD"))
	setText(self.view.rankDetailtxtNameUSDFText, pg.getGameString("GRAB_EGG_SEASON_RANK_OVERVIEW"))

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("TopRank", data.current.isTopRank and 1 or 0)
		self.view.rootUComponent:TryChangePage("State", data.rewardPageState)
	end

	setText(self.view.rankNameUSDFText, data.current.name)
	setText(self.view.rankLevelUSDFText, data.current.roman)
	setText(self.view.eggNumUSDFText, data.eggStar)

	if self.view.rankIconUImage then
		self.view.rankIconUImage.url = data.current.icon
	end

	setActive(self.view.iconBoardUImage, not data.current.isTopRank)

	if self.view.iconBoardUImage and not data.current.isTopRank then
		self.view.iconBoardUImage.url = self.model:getRankIconBoardUrl(data.current.bigRank)
	end

	local showRankProgress = not data.current.isTopRank and data.next ~= nil

	setActive(self.view.rankScoretextUSDFText, showRankProgress)
	setActive(self.view.scoreNumUSDFText, showRankProgress)
	setActive(self.view.scoreUProgress, showRankProgress)

	if showRankProgress then
		setText(self.view.scoreNumUSDFText, string.format("%d/%d", data.eggAllScore, data.nextBigRankStartScore))

		self.view.scoreUProgress.minValue = 0
		self.view.scoreUProgress.maxValue = 1
		self.view.scoreUProgress.value = data.rankProgressValue
	end

	self:refreshRankCutLines(#data.smallRankStartScores, showRankProgress)

	local eggs = {}

	for index = 1, data.current.upNumber do
		eggs[index] = {
			filled = index <= data.eggStar
		}
	end

	setList(self.view.eggUList, eggs)
	setList(self.view.descUList, data.descriptions)
	setList(self.view.currentRewardUList, data.currentRewards)

	local showRewardBlocks = data.rewardPageState ~= 0
	local rewardBlockVisible = {}

	for index = 1, 2 do
		local rewardBlock = data.rewardBlocks[index] or {}

		rewardBlockVisible[index] = self:refreshRewardBlock(index, rewardBlock.rankInfo, rewardBlock.nodes, rewardBlock.rewards, showRewardBlocks)
	end

	setActive(self.view.panelLineUWidget, rewardBlockVisible[1] and rewardBlockVisible[2])

	if self.rewardPopupTabType ~= nil and self.view.rewardPopupUWidget and self.view.rewardPopupUWidget.gameObject.activeSelf then
		self:refreshRewardPopupTabs()
		self:refreshRewardPopupList()
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK_REWARD)
end

function GrabEggsSeasonRankMainCtrl:refreshRewardBlock(index, rankInfo, rewardNodes, rewards, visible)
	local root = self.view["reward" .. index .. "UWidget"]
	local title = self.view["reward" .. index .. "TitleUSDFText"]
	local list = self.view["reward" .. index .. "UList"]
	local pointNum = self.view["reward" .. index .. "PointNumUSDFText"]
	local rewardNode = rewardNodes and rewardNodes[1]
	local hasContent = visible and rewardNode ~= nil

	setActive(root, hasContent)

	if not hasContent then
		setList(list, {})

		return false
	end

	local titleName = self.view["title" .. index .. "NameUSDFText"]

	setText(titleName, self.pageData.current.isTopRank and pg.getGameString("GRAB_EGG_SEASON_RANK_REACH") or "")

	local displayTitle

	if self.pageData.current.isTopRank then
		displayTitle = ""
	elseif index == 2 then
		displayTitle = pg.getGameString("GRAB_EGG_SEASON_RANK_NEXT_RANK")
	else
		local displayRank = rankInfo or self.pageData.current
		local roman = displayRank.roman or ""
		local displayName = displayRank.name or ""

		displayTitle = roman ~= "" and displayName .. roman or displayName
	end

	setText(title, displayTitle)
	setText(pointNum, rewardNode and rewardNode.param > 0 and rewardNode.param or "")
	setList(list, rewards)

	return true
end

function GrabEggsSeasonRankMainCtrl:setRewardPopupVisible(visible)
	if not self.view.rewardPopupUWidget then
		return
	end

	self.view.rewardPopupUWidget:SetActive(visible)

	if visible then
		self.rewardPopupTabType = REWARD_POPUP_TAB_RANK

		self:refreshRewardPopupTabs()
		self:refreshRewardPopupList()
	else
		self:clearRewardPopupTabRedDots()
	end
end

function GrabEggsSeasonRankMainCtrl:setRewardPopupTab(tabType)
	if self.rewardPopupTabType == tabType then
		return
	end

	self.rewardPopupTabType = tabType

	self:refreshRewardPopupTabs()
	self:refreshRewardPopupList()
end

function GrabEggsSeasonRankMainCtrl:refreshRewardPopupTabs()
	local claimableState = self.model:getRewardOverviewTabClaimableState()

	self.rewardPopupTabs = {
		{
			tIndex = 0,
			textKey = "GRAB_EGG_SEASON_RANK_REWARD_TAB",
			tabType = REWARD_POPUP_TAB_RANK,
			hasClaimableReward = claimableState[REWARD_POPUP_TAB_RANK]
		},
		{
			tIndex = 1,
			textKey = "GRAB_EGG_SEASON_STAGE_REWARD_TAB",
			tabType = REWARD_POPUP_TAB_STAGE,
			hasClaimableReward = claimableState[REWARD_POPUP_TAB_STAGE]
		}
	}

	setList(self.view.listTab3thUList, self.rewardPopupTabs)

	if self.view.listTab3thUList and self.rewardPopupTabType ~= nil then
		self.view.listTab3thUList:SelectItem(self.rewardPopupTabType, false)
	end
end

function GrabEggsSeasonRankMainCtrl:refreshRewardPopupList()
	setList(self.view.rewardPopupUList, self.model:getRewardOverviewData(self.rewardPopupTabType))
end

function GrabEggsSeasonRankMainCtrl:renderRewardOverviewItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")

	if objectReference == nil or IsNil(objectReference) then
		return
	end

	local title = objectReference:GetRefValue("txtTitleUSDFText")
	local tag = objectReference:GetRefValue("tagUWidget")
	local tagText = objectReference:GetRefValue("textUSDFText")
	local icon = objectReference:GetRefValue("iconUImage")
	local rewardList = objectReference:GetRefValue("listUList")

	setText(title, data.name)

	if tag then
		tag:SetActive(data.isCurrent)
		setText(tagText, pg.getGameString("GRAB_EGG_SEASON_RANK_CURRENT"))
	end

	if icon then
		icon.url = data.icon
	end

	if rewardList then
		function rewardList.luaRenderItem(rewardButton, _, rewardData)
			rewardButton.interactable = rewardData.tIndex ~= 1

			if rewardData.tIndex == 1 then
				rewardButton.luaClick = nil
				rewardButton.draggable = false

				return
			end

			self:renderRankRewardItem(rewardButton, rewardData)
		end

		local rewards = {}

		for _, reward in ipairs(data.rewards or EMPTY_TABLE) do
			rewards[#rewards + 1] = reward
		end

		for i = #rewards + 1, REWARD_POPUP_MIN_REWARD_COUNT do
			rewards[i] = {
				tIndex = 1
			}
		end

		rewardList:SetList(rewards)
		rewardList:StopScroll()
		rewardList:SetCurrentScrollPositionEx(0, 0)
	end
end

function GrabEggsSeasonRankMainCtrl:refreshSeasonInfo()
	if not self.view.seasonTimeUWidget then
		return
	end

	local seasonInfo = self.model:getSeasonDisplayInfo()

	self.view.seasonTimeUWidget:SetActive(seasonInfo ~= nil)

	if not seasonInfo then
		return
	end

	setText(self.view.seasonNameUSDFText, seasonInfo.name)
	setText(self.view.seasonTimeUSDFText, seasonInfo.timeText)
end

function GrabEggsSeasonRankMainCtrl:onDestroy()
	self:clearRewardItemRedDots()
	self:clearRewardPopupTabRedDots()

	if self.rankCutLines then
		for _, line in ipairs(self.rankCutLines) do
			if line.gameObject and not IsNil(line.gameObject) then
				Object.Destroy(line.gameObject)
			end
		end

		self.rankCutLines = nil
	end

	UICtrl.onDestroy(self)
end

return GrabEggsSeasonRankMainCtrl
