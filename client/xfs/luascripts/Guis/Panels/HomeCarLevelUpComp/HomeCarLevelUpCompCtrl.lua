-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUpComp\\HomeCarLevelUpCompCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpCompCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCarLevelUpCompCtrl = Class.LightClass("HomeCarLevelUpCompCtrl", UICtrl)
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
local HomeCarUpgradeData = require("Data.home_car_upgrade_data")
local HomeCarComponentTabData = require("Data.home_car_component_tab_data")
local HomeCarComponentData = require("Data.home_car_component_data")
local HomelandConfigData = require("Data.homeland_config_data")
local ItemSourceData = require("Data.item_source_data")

HomeCarLevelUpCompCtrl.messages = {}

function HomeCarLevelUpCompCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.carScene = self.uiScene
	self.carLevel = 1

	if not self.carScene then
		self:close()
	end

	if info and info.homeMainPage then
		self.homeMainPage = info.homeMainPage
	end

	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()
	self.componentTabList = self:getComponentTabList()
	self.componentInfoList = self:getComponentInfoList()

	self:setCoinList()
	self.carScene:changeCarRotate(true)
	self:onComponentUpgradeClick()
end

function HomeCarLevelUpCompCtrl:addListener()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMCAR_COMPONENT_UPGRADE"))
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("LEVEL_UP_CONDITION"))
	ClientTextUtils.setText(self.view.titleTextPlus, pg.getGameString("HOMCAR_UNLOCK_CONTENT"))
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("CONSUME_LABEL"))
	ClientTextUtils.setText(self.view.textNoFillUSDFText, pg.getGameString("HOMCAR_NOTMEET_CONDITION"))

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

		local selectItem = self.view.listItemUList.selectedItem

		if not selectItem then
			return
		end

		local oldLevel = self.homeCarBaseInfo.carCompsLevel[selectItem.tabId] or 0

		self.model:upgradeHomeCarComp(selectItem.tabId, function()
			self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

			self.view.listItemUList:RefreshList()

			local res, button = self.view.listItemUList:TryGetChildAt(self.view.listItemUList.selectedIndex)

			if res then
				button:OnClickSimulate()
			end

			self.view.listCurrencyUList:RefreshList()
			pg.global.ui:open(UIConst.UI_ID_HOMELAND_LEVEL_UP_RESULT, self:getLevelUpSucessInfo(oldLevel, selectItem.tabId))
		end)
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

	function self.view.listItemTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))
		button:TryChangePage("Locked", data.unLock and 0 or 1)

		if not data.unLock then
			button.buttonType = CS.XGUI.EButtonType.Default
		end

		function button.luaClick()
			if data.unLock then
				local componentTabInfoList = self.componentInfoList[data.tabId]

				self.view.listItemUList:SetList(componentTabInfoList)

				local res, button = self.view.listItemUList:TryGetChildAt(0)

				if res then
					button:OnClickSimulate()
				end
			else
				pg.global.showBubbleMessage(NoticeDef.HOME_CAR_COMPONENT_NOT_UNLOCK)
			end
		end
	end

	function self.view.listItemUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local txtNum = objectReference:GetRefValue("txtNum")
		local levelText = objectReference:GetRefValue("levelText")
		local lockText = objectReference:GetRefValue("lockText")

		txtNum:SetActive(false)

		button.buttonType = CS.XGUI.EButtonType.Radio

		local curLevel = self.homeCarBaseInfo.carCompsLevel[data.tabId] or 0
		local maxLevel = self.model:getHomeCarComponentMaxLevel(data.tabId)
		local redDotPath = string.format(RedDotConst.RedDotPath.HOMECAR_COMPONENT_UPGRADE_ITEM, data.tabId)
		local redDotStyle = self.model:redDot_GetComponentUpgradeState(data.tabId, self.homeCarBaseInfo)

		pg.global.setRedDot(redDotPath, button, redDotStyle ~= RedDotConst.RedDotStyle.NONE, redDotStyle)
		button:TryChangePage("state", curLevel > 0 and 0 or 2)

		icon.url = data.partIcon or AddressDataConst.UI_HOME_PLOT_NORMAL_ICON

		if curLevel == 0 or maxLevel == 1 then
			levelText:SetActive(false)
		else
			levelText:SetActive(true)
			ClientTextUtils.setText(levelText, "Lv." .. curLevel)
		end

		lockText:SetActive(false)

		function button.luaClick()
			local showLevel = math.min(curLevel + 1, maxLevel)
			local showComponentInfo = HomeLandUtils.getHomeCarComponentInfo(data.tabId, showLevel)

			self:refreshDetailsInfo(showComponentInfo, curLevel)

			if curLevel == 0 then
				if showComponentInfo.minShowCarLevel <= self.homeCarBaseInfo.level then
					local viewBasicInfo = Utils.deepCopyTable(self.homeCarBaseInfo)

					viewBasicInfo.carCompsLevel[data.tabId] = 1

					self.carScene:refreshHomeCarDecoration(viewBasicInfo, showComponentInfo.floor)
					self.carScene:showHomeCarDecorationNotObtained(showComponentInfo.carModuleResId)
				else
					pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CANNOT_PREVIEWED)
				end

				self.carScene:setSingleDecorationOutline(false)
			else
				self.carScene:refreshHomeCarDecoration(self.homeCarBaseInfo, showComponentInfo.floor)
				self.carScene:showHomeCarDecorationNotObtained()

				local curComponentInfo = HomeLandUtils.getHomeCarComponentInfo(data.tabId, curLevel)

				self.carScene:setSingleDecorationOutline(true, curComponentInfo.carModuleResId)
			end

			self.view.listLelLevelUList:SetActive(maxLevel > 1)

			if maxLevel > 1 then
				local levelList = self:getLevelListInfo(data.tabId, maxLevel, curLevel)

				self.view.listLelLevelUList:SetList(levelList)

				local res, button = self.view.listLelLevelUList:TryGetChildAt(curLevel)

				if not res then
					res, button = self.view.listLelLevelUList:TryGetChildAt(curLevel - 1)
				end

				if res then
					button:OnClickSimulate()
				end
			end
		end
	end

	function self.view.listLelLevelUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		button:TryChangePage("IsLast", data.isLast and 1 or 0)
		button:TryChangePage("State", data.isUpgrade and 1 or 0)
		ClientTextUtils.setText(txtNameUSDFText, data.level)

		function button.luaClick()
			local selectItem = self.view.listLelLevelUList.selectedItem

			if selectItem and selectItem.level ~= data.level then
				local curLevel = self.homeCarBaseInfo.carCompsLevel[data.tabId] or 0
				local showComponentInfo = HomeLandUtils.getHomeCarComponentInfo(data.tabId, data.level)

				self:refreshDetailsInfo(showComponentInfo, curLevel)
			end
		end

		function button.luaSelectChanged(isSelected)
			if not data.isUpgrade then
				button:TryChangePage("State", isSelected and 2 or 0)
			end
		end
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomeCarLevelUpComp", function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomeCarLevelUpCompCtrl:isFocusInsideNamedAncestor(targetName)
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

function HomeCarLevelUpCompCtrl:refreshConsoleBarState()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local inContentUpgrade = self:isFocusInsideNamedAncestor("ContentUpgrade")
	local inContentUnlock = self:isFocusInsideNamedAncestor("ContentUnlock")
	local canRightStickMove = inContentUnlock and not inContentUpgrade

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canRightStickMove", canRightStickMove)

	if inContentUpgrade and not self._prevInContentUpgrade and self.view and not IsNil(self.view.scrollRectUScrollRect) then
		self.view.scrollRectUScrollRect:GoToPos(Vector2.zero, true)
	end

	self._prevInContentUpgrade = inContentUpgrade
end

function HomeCarLevelUpCompCtrl:setCoinList()
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

function HomeCarLevelUpCompCtrl:getLevelUpSucessInfo(oldLevel, tabId)
	local attributeData = {}
	local newLevel = oldLevel + 1
	local functionUnlockDes
	local componentInfo = HomeLandUtils.getHomeCarComponentInfo(tabId, newLevel) or {}

	functionUnlockDes = pg.getLocalizationText(componentInfo.functionUnlockDes)

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

function HomeCarLevelUpCompCtrl:getLevelListInfo(tabId, maxLevel, curLevel)
	local list = {}

	for i = 1, maxLevel do
		table.insert(list, {
			isLast = i == maxLevel,
			isUpgrade = i <= curLevel,
			level = i,
			tabId = tabId
		})
	end

	return list
end

function HomeCarLevelUpCompCtrl:refreshDetailsInfo(data, curLevel)
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

	if #levelUnlockList > 0 then
		self.view.listUList:SetList(levelUnlockList)
		self.view.contentUpgradeUWidget:SetActive(true)
	else
		self.view.contentUpgradeUWidget:SetActive(false)
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

	local buttonMode = self.model:getCanUpgradeMode(data, curLevel, data.levelId)

	if buttonMode == self.model.UpgradeMode.Normal then
		self.view.btnComfirmUButton.interactable = true
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

	self.view.scrollRectUScrollRect:GoToPos(Vector2.zero, true)
end

function HomeCarLevelUpCompCtrl:getComponentTabList()
	local list = {}

	for tabId, info in pairs(HomeCarComponentTabData) do
		table.insert(list, {
			tIndex = 1,
			tabId = tabId,
			name = info.name,
			unLock = info.homeLevel <= self.homeCarBaseInfo.level
		})
	end

	table.sort(list, function(a, b)
		return a.tabId < b.tabId
	end)

	if #list > 1 then
		list[1].tIndex = 0
		list[#list].tIndex = 2
	end

	return list
end

function HomeCarLevelUpCompCtrl:getComponentInfoList()
	local list = {}

	for tabId, info in pairs(HomeCarComponentTabData) do
		list[tabId] = {}
	end

	for tabId, info in pairs(HomeCarComponentData) do
		if info.partTypeId and list[info.partTypeId] then
			table.insert(list[info.partTypeId], {
				tabId = tabId,
				partIcon = info.partIcon
			})
		end
	end

	for tabId, t in pairs(list) do
		table.sort(t, function(a, b)
			return a.tabId < b.tabId
		end)
	end

	return list
end

function HomeCarLevelUpCompCtrl:getComponentLevelList(index)
	local list = {}
	local componentLevel = 1

	for i = 1, 5 do
		table.insert(list, {
			tIndex = i == 1 and 0 or 1,
			isUpgrade = componentLevel <= i
		})
	end

	return list
end

function HomeCarLevelUpCompCtrl:onComponentUpgradeClick()
	self.carScene:changeHomeCarUpgradeMode(UIConst.HOMECAR_UPGRADE_TYPE.Decoration)
	self.view.listItemTabUList:SetList(self.componentTabList)

	local res, button = self.view.listItemTabUList:TryGetChildAt(0)

	if res then
		button:OnClickSimulate()
	end

	self.carScene:switchCamera(UIConst.HOMECAR_MODE_IDX.DECORATION, self.homeCarBaseInfo.modelLevel)
end

function HomeCarLevelUpCompCtrl:closePanel()
	if self.homeMainPage and not IsNil(self.homeMainPage.view.widget) then
		self.homeMainPage:refreshHomeCarInfo()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CLUE_SEEK_TIP) then
		pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
	end

	self.view.btnBackUButton:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self:close()
	end)
end

function HomeCarLevelUpCompCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomeCarLevelUpComp")
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CLUE_SEEK_TIP) then
		pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
	end

	UICtrl.onDestroy(self)

	self.homeMainPage = nil
	self.carScene = nil
end

function HomeCarLevelUpCompCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomeCarLevelUpCompCtrl:onShow()
	return
end

function HomeCarLevelUpCompCtrl:onHide()
	return
end

return HomeCarLevelUpCompCtrl
