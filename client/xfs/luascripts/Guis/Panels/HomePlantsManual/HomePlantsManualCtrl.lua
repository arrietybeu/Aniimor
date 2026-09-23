-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManual\\HomePlantsManualCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local HomePlantsManualCtrl = Class.LightClass("HomePlantsManualCtrl", UICtrl)

HomePlantsManualCtrl.messages = {
	[MessageName.ON_HOME_PLANT_PROCESS_REWARD_CHANGED] = {
		"onProcessRewardChanged",
		true
	},
	[MessageName.ON_HOME_PLANT_SINGLE_REWARD_CHANGED] = {
		"onSingleRewardChanged",
		true
	}
}

function HomePlantsManualCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomePlantsManualCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.plantUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local uINodePlantPokedexUWidget = objectReference:GetRefValue("uINodePlantPokedexUWidget")

		ClientTextUtils.setText(textNameUSDFText, ClientTextUtils.getLocalizationText(data.name))
		self:setImage(iconUImage, data.icon)

		local curHasNum = LuaUIUtils.HomePlantManual_getCurPlantsNumByFormulaId(data.formulaId)

		ClientTextUtils.setText(textUSDFText, string.format("%d/%d", curHasNum, data.numMax))

		if curHasNum == data.numMax then
			uINodePlantPokedexUWidget:TryChangePage("State", 1)
		else
			uINodePlantPokedexUWidget:TryChangePage("State", 0)
		end

		function button.luaClick()
			pg.global.ui.homePlantsManualDetail:open(data)
		end
	end

	function self.view.rewardList.luaRenderItem(button, index, data)
		self:renderOneReward(button, index, data)
	end

	function self.view.listPointUList.luaRenderItem(button, index, data)
		if index == self.curPageIndex then
			button:TryChangePage("State", 1)
		else
			button:TryChangePage("State", 0)
		end

		function button.luaClick()
			self:gotoPage(index)
		end
	end

	function self.view.btnArrow1UButton.luaClick()
		self:gotoPage(self.prePage)
	end

	function self.view.btnArrow2UButton.luaClick()
		self:gotoPage(self.nextPage)
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomePlantsManual_RewardListFocus", function()
			self:_onFocusCursorMovedForRewardList()
		end)
	end
end

function HomePlantsManualCtrl:_computePreferredRewardIndex0(rewardData)
	if not rewardData or #rewardData == 0 then
		return nil
	end

	local firstClaimable, lastClaimed

	for idx, d in ipairs(rewardData) do
		if d.numMax and self.curProcessNum >= d.numMax then
			if d.isGet == false then
				if firstClaimable == nil then
					firstClaimable = idx
				end
			else
				lastClaimed = idx
			end
		end
	end

	local one = firstClaimable or lastClaimed or 1

	return one - 1
end

function HomePlantsManualCtrl:_onFocusCursorMovedForRewardList()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local groupName = navMgr.CurrentFocusedGroupName
	local enteredRewardGroup = groupName == "ListWidget" and self._lastFocusGroupName ~= "ListWidget"

	self._lastFocusGroupName = groupName

	if not enteredRewardGroup then
		return
	end

	local targetIdx0 = self._preferredRewardIndex0

	if targetIdx0 == nil then
		return
	end

	if not self.view.rewardList then
		return
	end

	self.view.rewardList:GoToIndex(targetIdx0)

	local ok, cell = self.view.rewardList:TryGetChildAt(targetIdx0)

	if not ok or not cell then
		return
	end

	local objectReference = cell:GetComponent("ObjectReference")
	local rewardItemBtn = objectReference and objectReference:GetRefValue("rewardItemUButton")

	if not rewardItemBtn then
		return
	end

	local current = navMgr.CurrentFocusedUContent

	if current and current.gameObject == rewardItemBtn.gameObject then
		return
	end

	navMgr:FocusItem(rewardItemBtn)
end

function HomePlantsManualCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomePlantsManual_RewardListFocus")
	end

	UICtrl.onDestroy(self)
end

function HomePlantsManualCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.allNumUSDFText, self.model:getTotalProcessNum())
	self:refreshProcessReward()

	self.curPageIndex = 0

	local pageData = self.model:getPlantPageData()

	self.totalPage = #pageData

	self.view.listPointUList:SetActive(self.totalPage > 1)

	self.allPageData = self.model:getAllPlantListData(self.totalPage)

	self.view.listPointUList:SetList(pageData)
	self:gotoPage(self.curPageIndex)
end

function HomePlantsManualCtrl:onShow()
	return
end

function HomePlantsManualCtrl:onHide()
	return
end

function HomePlantsManualCtrl:refreshArrowTarget()
	self.view.btnArrow1UButton:SetActive(self.curPageIndex > 0)
	self.view.btnArrow2UButton:SetActive(self.curPageIndex < self.totalPage - 1)

	local endIndex = self.totalPage - 1

	self.nextPage = self.curPageIndex + 1

	for i = self.nextPage, endIndex do
		if self:checkPageHasReward(self.allPageData[i]) then
			self.nextPage = i

			break
		end
	end

	self.prePage = self.curPageIndex - 1

	for i = self.prePage, 0, -1 do
		if self:checkPageHasReward(self.allPageData[i]) then
			self.prePage = i

			break
		end
	end
end

function HomePlantsManualCtrl:checkPageHasReward(pageData)
	for _, v in ipairs(pageData) do
		if LuaUIUtils.HomePlantManual_HasPlantRewardCanGet(v.formulaId, v.numMax) == true then
			return true
		end
	end

	return false
end

function HomePlantsManualCtrl:refreshProcessReward()
	self.curProcessNum = Utils.getPlantBookSum(pg.me.plantBook)

	ClientTextUtils.setText(self.view.curNumUSDFText, self.curProcessNum)

	local rewardData = self.model:getRewardListDataNoLast()

	self.view.rewardList:SetList(rewardData)

	local lastRewardData = self.model:getRewardListLastData()

	self:renderOneReward(self.view.lastRewardUButton, 0, lastRewardData)
	self:refreshProcessIndex(rewardData)

	self._preferredRewardIndex0 = self:_computePreferredRewardIndex0(rewardData)
end

function HomePlantsManualCtrl:refreshProcessIndex(rewardData)
	local index = 0

	for k, v in ipairs(rewardData) do
		index = k - 1

		if self.curProcessNum > v.numMax and v.isGet == false then
			break
		end
	end

	self.view.rewardList:GoToIndex(index)
end

function HomePlantsManualCtrl:renderOneReward(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local progress2UProgress = objectReference:GetRefValue("progress2UProgress")

	progress2UProgress.maxValue = 1
	progress2UProgress.minValue = 0

	if self.curProcessNum >= data.numMax then
		progress2UProgress.value = 1
	elseif self.curProcessNum < data.numMin then
		progress2UProgress.value = 0
	else
		progress2UProgress.value = (self.curProcessNum - data.numMin) / (data.numMax - data.numMin)
	end

	local rewardList = LuaUIUtils.getRewardItemByDropId(data.rewardId)
	local renderData = rewardList[1]

	ClientTextUtils.setText(numUSDFText, data.numMax)

	local canReceive = self.curProcessNum >= data.numMax and data.isGet == false

	if canReceive then
		function renderData.extraFunc()
			self:reqGetReward()
		end
	else
		renderData.extraFunc = nil
	end

	local state = 0

	if self.curProcessNum >= data.numMax then
		state = data.isGet == true and 1 or 2
	end

	renderData.state = state

	LuaUIUtils.renderRewardItem(rewardItemUButton, renderData)
end

function HomePlantsManualCtrl:reqGetReward()
	local res, processId = self.model:getRewardListCanGet()

	if res then
		pg.me:reqGetPlantProcessReward(processId)
	end
end

function HomePlantsManualCtrl:gotoPage(pageIndex)
	if pageIndex < 0 or pageIndex >= self.totalPage then
		return
	end

	self.curPageIndex = pageIndex

	self:refreshPlantList(pageIndex)
	self.view.listPointUList:RefreshList()
	self:refreshArrowTarget()
end

function HomePlantsManualCtrl:refreshPlantList(pageIndex)
	local plantData = self.allPageData[pageIndex]

	self.view.plantUList:SetList(plantData)
end

function HomePlantsManualCtrl:setImage(img, url)
	if url == nil or url == "" then
		return
	end

	if not img then
		return
	end

	if string.startsWith(url, "http") then
		img:SetTextureByUrl(url)
	else
		img.url = url
	end
end

function HomePlantsManualCtrl:onProcessRewardChanged()
	local rewardData = self.model:getRewardListDataNoLast()

	self.view.rewardList:SetList(rewardData)

	local lastRewardData = self.model:getRewardListLastData()

	self:renderOneReward(self.view.lastRewardUButton, 0, lastRewardData)
	self:refreshProcessIndex(rewardData)

	self._preferredRewardIndex0 = self:_computePreferredRewardIndex0(rewardData)
end

function HomePlantsManualCtrl:onSingleRewardChanged()
	self:gotoPage(self.curPageIndex)
end

return HomePlantsManualCtrl
