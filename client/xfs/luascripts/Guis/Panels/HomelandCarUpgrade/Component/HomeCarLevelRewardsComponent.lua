-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCarUpgrade\\Component\\HomeCarLevelRewardsComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelRewardsComponent")
local Class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local HomeCarLevelRewardsComponent = Class.LightClass("HomeCarLevelRewardsComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeCarUpgradeData = require("Data.home_car_upgrade_data")
local DropData = require("Data.drop_data")
local RedDotConst = require("Const.RedDotConst")

HomeCarLevelRewardsComponent.MAX_LIST_COUNT = 5
HomeCarLevelRewardsComponent.REWARD_STATE = {
	CANGET = 2,
	ISGET = 1,
	NORMAL = 0
}
HomeCarLevelRewardsComponent.messages = {
	[MessageName.UI_ON_SHOW] = {
		"onUIShow",
		true
	},
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	}
}
HomeCarLevelRewardsComponent.NAV_LISTENER_KEY = "HomeCarLevelRewards"

function HomeCarLevelRewardsComponent:findObjects()
	return
end

function HomeCarLevelRewardsComponent:initView()
	self.homeCarLevel = nil

	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPanel()
	end)
end

function HomeCarLevelRewardsComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function HomeCarLevelRewardsComponent:addListener()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("HOMECAR_LEVEL_REWARD_OVERVIEW"))
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("PET_REPORT_GET_ALL_REWARD"))

	self._itemFocusInfo = self._itemFocusInfo or {}

	function self.btnCloseUButton.luaClick()
		self.uWidget:SetActive(false)
		self:setConsoleBarKeyListState(false)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canClaimReward", false)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canViewReward", false)
	end

	function self.btnConfirmUButton.luaClick()
		local canGet = self.model:canGetHomeCarLevelReward()

		if not canGet then
			return
		end

		self.model:getHomeCarLevelReward(-1, function(noticeArg)
			local itemList = self:getRewardItemList(noticeArg)

			if itemList then
				pg.global.ui.itemObtain:open({
					itemList = itemList
				})
			end

			self:refreshPanel(true)
		end)
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
		local rewardListUList = objectReference:GetRefValue("rewardListUList")
		local txtClaimedUSDFText = objectReference:GetRefValue("txtClaimedUSDFText")

		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("HOMECAR_RV_LEVEL"))
		ClientTextUtils.setText(txtLvUSDFText, data.carLevel)
		ClientTextUtils.setText(txtClaimedUSDFText, pg.getGameString("HOMECAR_CLAIMED"))

		local state = self.REWARD_STATE.NORMAL

		if data.isGet then
			state = self.REWARD_STATE.ISGET
		elseif self.homeCarLevel and self.homeCarLevel >= data.carLevel then
			state = self.REWARD_STATE.CANGET
		end

		button:TryChangePage("State", state)

		rewardListUList.EnableDrag = #data.rewardInfo > self.MAX_LIST_COUNT

		function rewardListUList.luaRenderItem(itemButton, itemIndex, itemData)
			if itemData.tIndex == 1 then
				self._itemFocusInfo[itemButton] = nil

				return
			end

			LuaUIUtils.renderRewardItem(itemButton, itemData)
			itemButton:TryChangePage("State", state)

			self._itemFocusInfo[itemButton] = {
				state = state,
				carLevel = data.carLevel,
				id = itemData.id,
				num = itemData.num
			}

			function itemButton.luaClick(navConfirm)
				if state == self.REWARD_STATE.CANGET then
					if navConfirm then
						return
					end

					self.model:getHomeCarLevelReward(data.carLevel, function(noticeArg)
						local itemList = self:getRewardItemList(noticeArg)

						if itemList then
							pg.global.ui.itemObtain:open({
								itemList = itemList
							})
						end

						self:refreshPanel()
					end)
				else
					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						padding = 8,
						autoHor = true,
						id = itemData.id,
						num = itemData.num,
						targetRect = itemButton
					})
				end
			end
		end

		rewardListUList:SetList(data.rewardInfo)
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener(self.NAV_LISTENER_KEY, function()
			self:refreshConsoleBarHotkey()
		end)
	end
end

function HomeCarLevelRewardsComponent:refreshConsoleBarHotkey()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	if not CS.XGUI.Navigation.ConsoleBar then
		return
	end

	local canClaim, canView = false, false
	local item = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedItem

	if item and NotNil(item.Owner) and self._itemFocusInfo then
		local trans = item.Owner.transform

		while not IsNil(trans) do
			local btn = trans:GetComponent(typeof(CS.XGUI.UButton))

			if not IsNil(btn) and self._itemFocusInfo[btn] then
				local s = self._itemFocusInfo[btn].state

				if s == self.REWARD_STATE.CANGET then
					canClaim = true

					break
				end

				if s == self.REWARD_STATE.ISGET or s == self.REWARD_STATE.NORMAL then
					canView = true
				end

				break
			end

			trans = trans.parent
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canClaimReward", canClaim)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canViewReward", canView)
end

function HomeCarLevelRewardsComponent:onUIShow(uid)
	if uid == UIConst.UI_ID_COMMON_ITEM_TIP then
		self:setConsoleBarKeyListState(true)
	end
end

function HomeCarLevelRewardsComponent:onUIHide(uid)
	if uid == UIConst.UI_ID_COMMON_ITEM_TIP then
		self:setConsoleBarKeyListState(false)
	end
end

function HomeCarLevelRewardsComponent:getRewardItemList(noticeArg)
	if noticeArg and noticeArg.resItems then
		local instByItem = {}

		if noticeArg.resInstances then
			for _, inst in ipairs(noticeArg.resInstances) do
				if inst.itemId then
					instByItem[inst.itemId] = instByItem[inst.itemId] or {}

					table.insert(instByItem[inst.itemId], inst)
				end
			end
		end

		local itemList = {}

		for itemId, itemCount in pairs(noticeArg.resItems) do
			local instList = instByItem[itemId]

			if instList then
				for _, inst in ipairs(instList) do
					table.insert(itemList, {
						itemId = itemId,
						itemCount = inst.count,
						genID = inst.genID,
						invId = inst.invId
					})
				end
			else
				table.insert(itemList, {
					itemId = itemId,
					itemCount = itemCount
				})
			end
		end

		return itemList
	end
end

function HomeCarLevelRewardsComponent:refreshPanel(forceClear)
	if not self.uWidget:CheckURLLoaded() then
		return
	end

	local rewardList = self:getRewardData()
	local homeCarInfo = HomeLandUtils.getHomeCarInfo()

	self.homeCarLevel = homeCarInfo.level

	self.listRewardUList:SetList(rewardList)

	local rewardsReceived = pg.me.homeUpgradeRewardsReceived or {}
	local firstCanGet = self.homeCarLevel

	for i = 1, self.homeCarLevel do
		if rewardsReceived[i] ~= true then
			firstCanGet = i

			break
		end
	end

	self.listRewardUList:GoToIndex(firstCanGet - 1, true)

	local canGet = self.model:canGetHomeCarLevelReward()

	if forceClear then
		canGet = false
	end

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE_REWARD_BTN, self.btnConfirmUButton, canGet, RedDotConst.RedDotStyle.REWARD)

	self.btnConfirmUButton.interactable = canGet
end

function HomeCarLevelRewardsComponent:getRewardData()
	local rewardDatas = {}
	local rewardsReceived = pg.me.homeUpgradeRewardsReceived or {}

	for index, info in ipairs(HomeCarUpgradeData) do
		if info.reward then
			local dropData = DropData[info.reward]

			if dropData then
				local replaceIdMap

				if dropData.displayReward then
					local itemCountTable = {}

					for _, reward in ipairs(dropData.displayReward) do
						itemCountTable[reward[1]] = reward[2]
					end

					local _unused

					_unused, replaceIdMap = ItemUtils.getReplacedItemCountTable(pg.me, itemCountTable)
				end

				local datas = {}

				for _, reward in ipairs(dropData.displayReward) do
					if reward then
						local itemId = reward[1]

						if replaceIdMap and replaceIdMap[itemId] then
							itemId = replaceIdMap[itemId]
						end

						table.insert(datas, {
							tIndex = 0,
							id = itemId,
							num = reward[2]
						})
					end
				end

				table.insert(rewardDatas, {
					carLevel = index,
					rewardInfo = datas,
					isGet = rewardsReceived[index] == true
				})
			end
		end
	end

	table.sort(rewardDatas, function(a, b)
		return a.carLevel < b.carLevel
	end)

	return rewardDatas
end

function HomeCarLevelRewardsComponent:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener(self.NAV_LISTENER_KEY)
	end

	if CS.XGUI.Navigation.ConsoleBar then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canClaimReward", false)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canViewReward", false)
	end

	self._itemFocusInfo = nil

	UIComponent.onDestroy(self)
end

function HomeCarLevelRewardsComponent:onEnterPage()
	return
end

function HomeCarLevelRewardsComponent:setConsoleBarKeyListState(isEnable)
	if CS.XGUI.Navigation.ConsoleBar then
		CS.XGUI.Navigation.ConsoleBar.SetManualDimForAll(isEnable)
	end
end

return HomeCarLevelRewardsComponent
