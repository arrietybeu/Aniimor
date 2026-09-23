-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUp\\HomeCarLevelUpCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpCtrl")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCarLevelUpCtrl = Class.LightClass("HomeCarLevelUpCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Time = require("Core.Common.Time")
local HomeCarLevelRewardsComponent = require("Guis.Panels.HomelandCarUpgrade.Component.HomeCarLevelRewardsComponent")
local HomeCarUpgradeData = require("Data.home_car_upgrade_data")
local HomeCarComponentTabData = require("Data.home_car_component_tab_data")
local HomeCarComponentData = require("Data.home_car_component_data")
local HomelandConfigData = require("Data.homeland_config_data")
local ItemSourceData = require("Data.item_source_data")

HomeCarLevelUpCtrl.messages = {
	[MessageName.HOME_CAR_UPGRADE_STATE_CHANGED] = {
		"onHomeCarUpgradeStateChanged",
		true
	}
}

function HomeCarLevelUpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.carScene = self.uiScene
	self.carLevel = 1
	self.blameInTime = 0.5

	if not self.carScene then
		self:close()
	end

	if info and info.homeMainPage then
		self.homeMainPage = info.homeMainPage
	else
		self.homeMainPage = pg.global.ui.homelandMainPage
	end

	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()
	self.homeCarUpgradeList = self:getHomeCarUpgradeList()

	self:setCoinList()
	ClientTextUtils.setText(self.view.txtNumUSDFText, self.homeCarBaseInfo.level)
	self.carScene:changeCarRotate(true)
	self:onHomeCarExpandClick()

	if info and info.openReward then
		self.view.btnLvRewardUButton:OnClickSimulate()
	end
end

function HomeCarLevelUpCtrl:onHomeCarUpgradeStateChanged()
	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE_REWARD)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)

	if not self.view or not self.carScene or not self.homeCarUpgradeList then
		return
	end

	ClientTextUtils.setText(self.view.txtNumUSDFText, self.homeCarBaseInfo.level)
	self.view.listUpgradeUList:RefreshList()

	local res, button = self.view.listUpgradeUList:TryGetChildAt(self.view.listUpgradeUList.selectedIndex)

	if res then
		button:OnClickSimulate()
	end

	local shownLevel = self:tryShowPendingUpgradeResult()

	if shownLevel then
		local pendingAiNoticeLevel = pg.me:getClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_ai_notice_level") or 0

		if pendingAiNoticeLevel == shownLevel then
			pg.me:setClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_ai_notice_level", 0)
		end
	end
end

function HomeCarLevelUpCtrl:tryShowPendingUpgradeResult()
	if not self:checkUIShow() or not self.homeCarUpgradeList then
		return
	end

	local pendingLevel = pg.me:getClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_result_level") or 0

	if pendingLevel <= 0 then
		return
	end

	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

	if pendingLevel > self.homeCarBaseInfo.level or self.homeCarBaseInfo.upgradeEndTs > 0 then
		return
	end

	pg.me:setClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_result_level", 0)
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_LEVEL_UP_RESULT, self:getLevelUpSucessInfo(pendingLevel - 1))

	return pendingLevel
end

function HomeCarLevelUpCtrl:addListener()
	self.levelRewardsComponent = HomeCarLevelRewardsComponent.new(self, self.view.levelRewardsUContainer)

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMCAR_EXPANSION"))
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("LEVEL_UP_CONDITION"))
	ClientTextUtils.setText(self.view.titleTextPlus, pg.getGameString("HOMCAR_UNLOCK_CONTENT"))
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("CONSUME_LABEL"))
	ClientTextUtils.setText(self.view.textNoFillUSDFText, pg.getGameString("HOMCAR_NOTMEET_CONDITION"))
	ClientTextUtils.setText(self.view.btnLvRewardText, pg.getGameString("HOMECAR_LEVEL_REWARD"))

	function self.view.btnLvRewardUButton.luaClick()
		self.view.levelRewardsUContainer:SetActive(true)
		self.levelRewardsComponent:refreshPanel()
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE_REWARD, self.view.btnLvRewardUButton, function()
		return self.model:redDot_GetLevelRewardState()
	end)

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnComfirmUButton.luaClick()
		if self.lackItem then
			if pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
				pg.global.showBubbleMessage(NoticeDef.HOME_CAR_UPGRADE_ITEM_LACK_INHOME)
			else
				pg.global.showBubbleMessage(NoticeDef.HOME_CAR_UPGRADE_ITEM_LACK_NOTHOME)
			end

			return
		end

		local oldLevel = self.homeCarBaseInfo.level
		local targetLevel = oldLevel + 1
		local upgradeInfo = HomeCarUpgradeData[targetLevel] or {}
		local upgradeTime = upgradeInfo.upgradeTime or 0

		self.model:upgradeHomeCar(function()
			pg.me:setClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_result_level", targetLevel)
			pg.me:setClientInfo(Const.CLIENT_KEY.HOME_CAR_UPGRADE, "pending_ai_notice_level", targetLevel)
			pg.me:tryNotifyHomeCarUpgradeFinished()

			if upgradeTime > 0 then
				pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_UPGRADE_START)
			end

			if not self.view then
				return
			end

			self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

			self.view.listUpgradeUList:RefreshList()

			local level = self.homeCarBaseInfo.level
			local res, button = self.view.listUpgradeUList:TryGetChildAt(level)

			if not res then
				res, button = self.view.listUpgradeUList:TryGetChildAt(oldLevel)
			end

			if res then
				button:OnClickSimulate()
			end

			self.view.listCurrencyUList:RefreshList()
			ClientTextUtils.setText(self.view.txtNumUSDFText, self.homeCarBaseInfo.level)
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE_REWARD)
			self:tryShowPendingUpgradeResult()
		end)
	end

	function self.view.listUpgradeUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local iconSelUImage = objectReference:GetRefValue("iconSelUImage")
		local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
		local isUpgrade = self.homeCarBaseInfo.level >= data.levelId
		local needPhantom = data.carModelLevel > self.homeCarBaseInfo.modelLevel

		if data.iconImage then
			iconUImage.url = data.iconImage
			iconSelUImage.url = data.iconImage
		end

		if data.tIndex == 0 then
			local imgTagUImage = objectReference:GetRefValue("imgTagUImage")
			local imgTagSelUImage = objectReference:GetRefValue("imgTagSelUImage")
			local tagUWidget = objectReference:GetRefValue("tagUWidget")

			if data.iconImageMini then
				imgTagUImage.url = data.iconImageMini
				imgTagSelUImage.url = data.iconImageMini
			end

			tagUWidget:SetActive(data.iconImageMini ~= nil)
		end

		button:TryChangePage("State", isUpgrade and 1 or 0)
		ClientTextUtils.setText(txtLvUSDFText, "Lv." .. data.levelId)

		local canUpgrade = self.model:getCanUpgradeMode(data, self.homeCarBaseInfo.level) == self.model.UpgradeMode.Normal
		local redDotPath = string.format(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE_LEVEL, data.levelId)

		pg.global.setRedDot(redDotPath, button, canUpgrade, RedDotConst.RedDotStyle.UP_HIGH)

		local upgradeMode = self.model:getCanUpgradeMode(data, self.homeCarBaseInfo.level)
		local canUpgrade = upgradeMode == self.model.UpgradeMode.Normal

		function button.luaClick()
			self:refreshDetailsInfo(data, self.homeCarBaseInfo.level)

			local viewBasicInfo = Utils.deepCopyTable(self.homeCarBaseInfo)

			viewBasicInfo.level = data.levelId
			viewBasicInfo.modelLevel = data.carModelLevel
			viewBasicInfo.needUpgradeEffect = self.homeCarBaseInfo.upgradeEndTs > 0 and data.levelId <= self.homeCarBaseInfo.level + 1

			self.carScene:refreshHomeCar(viewBasicInfo, {
				needPhantom = needPhantom
			})
			self.carScene:switchCamera(UIConst.HOMECAR_MODE_IDX.UPGRADE, data.carModelLevel, self.blameInTime)
			self.carScene:showHomeCarNotObtained(needPhantom)
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local conDesc = pg.getLocalizationText(data.upgradeConditionsDes)

		if pg.game.setting:getShowDebugId() then
			conDesc = string.format("%s-%s", tostring(data.upgradeConditions), conDesc)
		end

		ClientTextUtils.setText(txtNameUSDFText, conDesc)

		local isCompleted = pg.me.triggerMap:isCompleteOrMeetCondition(data.upgradeConditions)

		button:TryChangePage("State", isCompleted and 1 or 0)

		button.interactable = not isCompleted

		function button.luaClick()
			local sourceId = data.sourceId

			if sourceId then
				local itemSourceConfig = ItemSourceData[sourceId]

				if itemSourceConfig then
					local data = {}

					data.clueSeekID = sourceId

					table.merge(data, itemSourceConfig)
					LuaUIUtils.clueSeek(data, nil, button)
				end
			end
		end
	end

	function self.view.listUnlockUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		LuaUIUtils.customSetText(txtNameUSDFText, data.name, true)
	end

	function self.view.listCostUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconImg = objectReference:GetRefValue("itemIconUImage")
		local numTxt = objectReference:GetRefValue("txtNumUText")
		local itemCount = ItemUtils.getItemCountById(pg.me, data.id)

		if pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
			local homelandItemCount = ClientUtils.getHomelandItemCountById(data.id)

			itemCount = itemCount + homelandItemCount
		end

		LuaUIUtils.renderConsumeText(numTxt, itemCount, data.num, UIConst.ITEM_STATE.FULL)

		iconImg.url = LuaUIUtils.getIconByItemId(data.id)

		local itemConfig = ItemData[data.id]

		if itemConfig then
			button:TryChangePage("Quality", itemConfig.quality)
		end

		button:TryChangePage("State", 0)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				padding = 8,
				autoHor = true,
				id = data.id,
				num = data.num,
				targetRect = button
			})
		end
	end

	function self.view.costCoinListUList.luaRenderItem(button, index, data)
		LuaUIUtils.setCostCurrencyItem(button, data.itemId, data.itemCount, true)
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomeCarLevelUp", function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomeCarLevelUpCtrl:isFocusInsideNamedAncestor(targetName)
	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if not navManager then
		return false
	end

	local item = navManager.CurrentFocusedItem

	if not item or IsNil(item.Owner) then
		return false
	end

	local trans = item.Owner.transform

	while not IsNil(trans) do
		if trans.name == targetName then
			return true
		end

		trans = trans.parent
	end

	return false
end

function HomeCarLevelUpCtrl:refreshConsoleBarState()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
	local inContentUpgrade = self:isFocusInsideNamedAncestor("ContentUpgrade")
	local inContentUnlock = self:isFocusInsideNamedAncestor("ContentUnlock")
	local inCostItem = self:isFocusInsideNamedAncestor("CostItem")
	local canRightStickMove = groupName == "ListExpansion" or inContentUnlock or inCostItem

	if inContentUpgrade then
		canRightStickMove = false
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canRightStickMove", canRightStickMove)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelectCostItem", inCostItem)

	self._suppressRightStickScroll = inContentUpgrade
	self._prevInContentUpgrade = inContentUpgrade
end

function HomeCarLevelUpCtrl:setCoinList()
	local iconId1 = HomelandConfigData.homeCurrencyId or 1010
	local iconId2 = HomelandConfigData.homeVoucherId or 1011
	local iconList = {}

	table.insert(iconList, {
		itemId = iconId1
	})
	table.insert(iconList, {
		itemId = iconId2
	})
	self.view.listCurrencyUList:SetList(iconList)
end

function HomeCarLevelUpCtrl:getUpgradeTimeText(totalSeconds)
	totalSeconds = math.max(0, math.floor(tonumber(totalSeconds) or 0))

	local parts = {}
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor(totalSeconds % 3600 / 60)
	local seconds = totalSeconds % 60

	if hours > 0 then
		parts[#parts + 1] = hours
		parts[#parts + 1] = pg.getGameString("HOUR")
	end

	if minutes > 0 then
		parts[#parts + 1] = minutes
		parts[#parts + 1] = pg.getGameString("MINUTE")
	end

	if seconds > 0 then
		parts[#parts + 1] = seconds
		parts[#parts + 1] = pg.getGameString("SECOND")
	end

	return ClientTextUtils.concatCountDownUnitsByLanguage(table.unpack(parts))
end

function HomeCarLevelUpCtrl:stopUpgradeCountDown()
	local countDown = self.view and self.view.countDownUCountDown

	if not countDown or IsNil(countDown) then
		return
	end

	countDown.luaFinished = nil
	countDown.onGetBaseText = nil

	countDown:Stop()
end

function HomeCarLevelUpCtrl:refreshUpgradeTimeInfo(data, buttonMode)
	self:stopUpgradeCountDown()

	local countDown = self.view.countDownUCountDown
	local upgradeEndTs = tonumber(self.homeCarBaseInfo.upgradeEndTs) or 0
	local currentTs = Time.getSecond()
	local isUpgraded = buttonMode == self.model.UpgradeMode.IsUpgraded
	local isUpgrading = buttonMode == self.model.UpgradeMode.Upgrading
	local isUpgradeFinished = isUpgrading and upgradeEndTs <= currentTs

	countDown:SetActive(false)

	if isUpgraded or isUpgradeFinished then
		self.view.upgradeTimeUWidget:SetActive(false)

		return
	end

	if not isUpgrading then
		self.view.upgradeTimeUWidget:SetActive(false)

		return
	end

	self.view.upgradeTimeUWidget:SetActive(true)
	ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getGameString("HOME_CAR_UPGRADING"))
	countDown:SetActive(true)

	function countDown.onGetBaseText(day, hour, minute, second)
		return self:getUpgradeTimeText(day * 86400 + hour * 3600 + minute * 60 + second)
	end

	function countDown.luaFinished()
		if self.view then
			self.view.upgradeTimeUWidget:SetActive(false)
		end
	end

	countDown:Play(upgradeEndTs - currentTs)
end

function HomeCarLevelUpCtrl:getLevelUpSucessInfo(oldLevel, tabId)
	local attributeData = {}
	local newLevel = oldLevel + 1
	local functionUnlockDes
	local newHomeCarInfo = self.homeCarUpgradeList[newLevel] or {}

	functionUnlockDes = pg.getLocalizationText(newHomeCarInfo.functionUnlockDes)

	if functionUnlockDes and functionUnlockDes ~= "" then
		local upgradeDesc = string.split(functionUnlockDes, "\n")

		for i, str in ipairs(upgradeDesc) do
			table.insert(attributeData, {
				tIndex = 2,
				name = str
			})
		end
	end

	local info = {
		oldLv = oldLevel,
		newLv = newLevel,
		carryAttrs = attributeData,
		title = pg.getGameString("HOME_FACILITY_UPGRADE")
	}

	return info
end

function HomeCarLevelUpCtrl:refreshDetailsInfo(data, curLevel)
	ClientTextUtils.setText(self.view.textNameUSDFText, data.name)
	ClientTextUtils.setText(self.view.textLevelUSDFText, "Lv." .. data.levelId)
	ClientTextUtils.setText(self.view.textDetailUSDFText, pg.getLocalizationText(data.detailInfo))

	local unlockList = {}
	local functionUnlockDes = pg.getLocalizationText(data.functionUnlockDes)

	if functionUnlockDes and functionUnlockDes ~= "" then
		local unlockDesc = string.split(functionUnlockDes, "\n")

		for _, str in ipairs(unlockDesc) do
			table.insert(unlockList, {
				name = str
			})
		end
	end

	self.view.listUnlockUList:SetList(unlockList)

	local levelUnlockList = {}

	for i = 1, 5 do
		if data["upgradeConditions" .. i] and data["upgradeConditionsDes" .. i] then
			table.insert(levelUnlockList, {
				upgradeConditions = data["upgradeConditions" .. i],
				upgradeConditionsDes = data["upgradeConditionsDes" .. i],
				sourceId = data["source" .. i]
			})
		end
	end

	self.view.uIPanelUWidget:TryChangePage("HaveCondition", #levelUnlockList > 0 and 0 or 1)

	if #levelUnlockList > 0 then
		self.view.listUList:SetList(levelUnlockList)
	end

	local unlockItemList = {}

	for _, info in ipairs(data.unlockItem) do
		table.insert(unlockItemList, {
			id = info[1],
			num = info[2]
		})
	end

	self.view.listCostUList:SetList(unlockItemList)
	self.view.costItemUWidget:SetActive(#unlockItemList > 0)
	ClientTextUtils.setText(self.view.txtTimeCostUSDFText, self:getUpgradeTimeText(data.upgradeTime))

	if data.unlockCost then
		local unlockCoinList = {}

		table.insert(unlockCoinList, {
			itemId = data.unlockCost[1],
			itemCount = data.unlockCost[2]
		})
		self.view.costCoinListUList:SetList(unlockCoinList)
	end

	self.view.btnComfirmUButton:SetActive(true)
	self.view.btnReadyUWidget:SetActive(false)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("UPGRADE"))

	self.view.btnComfirmUButton.interactable = false
	self.lackItem = false

	self.view.costCoinListUList:SetActive(true)
	self.view.textNoFillUSDFText:SetActive(false)

	local buttonMode = self.model:getCanUpgradeMode(data, curLevel)

	if buttonMode == self.model.UpgradeMode.Normal then
		self.view.btnComfirmUButton.interactable = true
	elseif buttonMode == self.model.UpgradeMode.Upgrading then
		self.view.btnComfirmUButton:SetActive(false)
		self.view.costCoinListUList:SetActive(false)
		self.view.costItemUWidget:SetActive(false)
	elseif buttonMode == self.model.UpgradeMode.CanNotUpgraded then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMCAR_NOTMEET_CONDITION"))
	elseif buttonMode == self.model.UpgradeMode.IsUpgraded then
		self.view.btnComfirmUButton:SetActive(false)
		self.view.btnReadyUWidget:SetActive(true)
		self.view.costCoinListUList:SetActive(false)
		self.view.costItemUWidget:SetActive(false)
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMCAR_IS_UPGRADED"))
	elseif buttonMode == self.model.UpgradeMode.LackCondition then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMCAR_NOTMEET_CONDITION"))
	elseif buttonMode == self.model.UpgradeMode.LackCoin then
		-- block empty
	elseif buttonMode == self.model.UpgradeMode.LackItem then
		self.view.btnComfirmUButton.interactable = true
		self.lackItem = true
	end

	if curLevel == 0 then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("ACCESSORY_UNLOCK"))
	end

	self:refreshUpgradeTimeInfo(data, buttonMode)
end

function HomeCarLevelUpCtrl:getHomeCarUpgradeList()
	local list = {}

	for levelId, info in pairs(HomeCarUpgradeData) do
		local isBig = info.isBig == 1 or levelId == 1

		table.insert(list, {
			name = pg.getGameString("HOMCAR_NAME"),
			detailInfo = info.levelDes,
			unlockItem = info.unlockItem or {},
			unlockCost = info.unlockCost,
			upgradeTime = info.upgradeTime or 0,
			upgradeConditionsDes1 = info.upgradeConditionsDes1,
			upgradeConditions1 = info.upgradeConditions1,
			source1 = info.source1,
			upgradeConditionsDes2 = info.upgradeConditionsDes2,
			upgradeConditions2 = info.upgradeConditions2,
			source2 = info.source2,
			upgradeConditionsDes3 = info.upgradeConditionsDes3,
			upgradeConditions3 = info.upgradeConditions3,
			source3 = info.source3,
			upgradeConditionsDes4 = info.upgradeConditionsDes4,
			upgradeConditions4 = info.upgradeConditions4,
			source4 = info.source4,
			upgradeConditionsDes5 = info.upgradeConditionsDes5,
			upgradeConditions5 = info.upgradeConditions5,
			source5 = info.source5,
			functionUnlockDes = info.functionUnlockDes,
			levelId = levelId,
			iconImage = info.iconImage,
			iconImageMini = info.iconImageMini,
			carModelLevel = info.carModelLevel,
			isBig = isBig,
			carResId = info.carResId,
			tIndex = isBig and 0 or 1
		})
	end

	table.sort(list, function(a, b)
		return a.levelId < b.levelId
	end)

	return list
end

function HomeCarLevelUpCtrl:onHomeCarExpandClick()
	self.view.btnLvRewardUButton:SetActive(true)
	self.carScene:changeHomeCarUpgradeMode(UIConst.HOMECAR_UPGRADE_TYPE.HomeCar)
	self.view.listUpgradeUList:SetList(self.homeCarUpgradeList)

	local level = math.min(self.homeCarBaseInfo.level, #self.homeCarUpgradeList - 1)
	local res, button = self.view.listUpgradeUList:TryGetChildAt(level)

	if not res then
		level = 0
		res, button = self.view.listUpgradeUList:TryGetChildAt(level)
	end

	if res then
		button:OnClickSimulate()
		self.view.listUpgradeUList:GoToIndex(level, true)
	end
end

function HomeCarLevelUpCtrl:closePanel()
	if self.homeMainPage and self.homeMainPage.view and not IsNil(self.homeMainPage.view.widget) then
		self.homeMainPage:refreshHomeCarInfo()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CLUE_SEEK_TIP) then
		pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
	end

	self.view.btnBackUButton:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self:close()
	end)
end

function HomeCarLevelUpCtrl:onDestroy()
	self:stopUpgradeCountDown()

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomeCarLevelUp")
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CLUE_SEEK_TIP) then
		pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
	end

	UICtrl.onDestroy(self)

	self.homeMainPage = nil
	self.carScene = nil
end

function HomeCarLevelUpCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:tryShowPendingUpgradeResult()
end

function HomeCarLevelUpCtrl:onShow()
	return
end

function HomeCarLevelUpCtrl:onHide()
	return
end

return HomeCarLevelUpCtrl
