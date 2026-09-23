-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFurnitureStore\\HomelandFurnitureStoreCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandItemListComponent = require("Guis.Panels.HomelandEditor.Component.HomelandItemListComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local RevertHomePlaceData = require("Data.revert_home_place_data")
local ItemSourceData = require("Data.item_source_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local HomelandConfigData = require("Data.homeland_config_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeObjectPlaceData = require("Data.home_object_place_data")
local HomeTypeData = require("Data.home_type_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomelandFurnitureStoreCtrl = Class.LightClass("HomelandFurnitureStoreCtrl", UICtrl)

HomelandFurnitureStoreCtrl.messages = {
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"refreshCurrencyList",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemChanged",
		true
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onItemChanged",
		true
	},
	[MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED] = {
		"onItemChanged",
		true
	}
}

function HomelandFurnitureStoreCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.carGroup = info and info.carGroup
	self.isCarGroupMode = info and info.isCarGroupMode == true or not not self.carGroup
	self.curItemId = info and info.curItemId

	if self.curItemId and not ClientHomelandUtils.isFurnitureAvailableInArea(self.curItemId) then
		self.curItemId = nil
	end

	local initTypeIndex = info and info.curTypeIndex or 0
	local initSubTypeIndex = info and info.curSubTypeIndex or 0
	local locateItemById = self.curItemId and (not info or info.curTypeIndex == nil)

	self.itemListComponent = HomelandItemListComponent(self, self.view.bottomUComponent, {
		isFurnitureStore = true,
		carGroup = self.carGroup,
		isCarGroupMode = self.isCarGroupMode,
		itemId = self.curItemId
	})
	self.itemViewerScene = self.uiScene

	self.itemViewerScene:setGestureOptions("GestureRayBox", false, function()
		if self.view then
			self:showOrHideFoldOutList()
		end
	end)
	self.itemViewerScene:setRawImage(self.view.modelURawImage)

	self.prefabResIdCache = nil

	local initSelectedIndex = 0
	local curObjectInfo = locateItemById and HomeObjectData[self.curItemId]

	if curObjectInfo then
		for index, typeInfo in ipairs(self.itemListComponent.typeInfo or EMPTY_TABLE) do
			if typeInfo.typeId == curObjectInfo.type then
				initTypeIndex = index - 1

				break
			end
		end
	end

	if not self.itemListComponent.typeInfo or initTypeIndex >= #self.itemListComponent.typeInfo then
		initTypeIndex = 0
		initSubTypeIndex = 0
	end

	self.itemListComponent.typeList:SelectItem(initTypeIndex)

	if self.itemListComponent.curType ~= self.itemListComponent.FavoriteTypeIndex then
		if curObjectInfo then
			for index, subTypeInfo in ipairs(self.itemListComponent.subTypeInfo or EMPTY_TABLE) do
				if subTypeInfo.subTypeId == curObjectInfo.subType then
					initSubTypeIndex = index - 1

					break
				end
			end
		end

		if not self.itemListComponent.subTypeInfo or initSubTypeIndex >= #self.itemListComponent.subTypeInfo then
			initSubTypeIndex = 0
		end

		self.itemListComponent.subTypeList:SelectItem(initSubTypeIndex)
	end

	if self.curItemId then
		local curPlaceId = HomeObjectData[self.curItemId] and HomeObjectData[self.curItemId].placeId

		for index, data in pairs(self.itemListComponent.itemList.itemData) do
			if self.itemListComponent.curType ~= self.itemListComponent.FavoriteTypeIndex and data.placeId and curPlaceId then
				if curPlaceId == data.placeId then
					initSelectedIndex = index

					break
				end
			elseif self.curItemId == data.itemId then
				initSelectedIndex = index

				break
			end
		end
	end

	local selectedData = self.itemListComponent.itemList:GetData(initSelectedIndex)

	if selectedData then
		self.itemListComponent:selectItem(selectedData, true)

		self.itemListComponent.itemListSelectedIndex = initSelectedIndex

		self.itemListComponent.itemList:SelectItem(initSelectedIndex, false)
		self.itemListComponent.itemList:RedirectToCenter(initSelectedIndex, false, true)
		self.itemListComponent:expandFoldPopup(initSelectedIndex)
	else
		self:onSelectItem(nil)
	end

	self.itemListComponent.selectItemWhenTypeChange = true

	self:refreshItemInfo()
end

function HomelandFurnitureStoreCtrl:addListener()
	function self.view.btnBuyUButton.luaClick()
		self:onBtnBuyClick()
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.numSelectorUNumSelector.luaValueChanged()
		self:refreshConsumeInfo()
	end

	function self.view.redeemListUList.luaRenderItem(button, index, data)
		local rewardItemCount = ItemUtils.getItemCountById(pg.me, data.id) or 0

		if pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
			rewardItemCount = rewardItemCount + ClientUtils.getHomelandItemCountById(data.id)
		end

		local needNum = data.num * self.view.redeemUNumSelector.value
		local itemText = LuaUIUtils.formatStyledItemNum(rewardItemCount, needNum)

		LuaUIUtils.renderRewardItem(button, {
			num = data.num * self.view.redeemUNumSelector.value,
			id = data.id
		}, itemText)
	end

	function self.view.redeemUNumSelector.luaValueChanged()
		self:refreshRedeemInfo()
	end

	function self.view.btnRedeemUButton.luaClick()
		self:onButtonRedeemClick()
	end

	function self.view.sourceList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUSDFText = objectReference:GetRefValue("nameUSDFText")

		ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(data.buttonTxt))
		LuaUIUtils.itemSourceTrigger(button, data)
	end

	function self.view.drawingSourceListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUSDFText = objectReference:GetRefValue("nameUSDFText")

		ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(data.buttonTxt))
		LuaUIUtils.itemSourceTrigger(button, data, nil, data.clueSeekID)
	end

	function self.view.btnFavoriteUButton.luaClick()
		self:onFavoriteButtonClick()
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("HomelandFurnitureStore", function()
			self:refreshConsoleBarState()
		end)
	end

	self:bindGamepadRotation()
end

function HomelandFurnitureStoreCtrl:bindGamepadRotation()
	if not self.view or not self.view.widget then
		return
	end

	local binding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "furnitureStoreRotateGamepad")

	binding.isVirtual = true
	binding.priority = -1
	binding.actionPath = "Raw/GamepadRightStickMove"

	function binding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.gamepadRotateDelta = inputInfo.valueVec2

			if self.gamepadRotateTimer == nil and self.itemViewerScene then
				self.gamepadRotateTimer = self:startTimer(function()
					if self.itemViewerScene and self.gamepadRotateDelta then
						local fakeDelta = Vector2.New(self.gamepadRotateDelta.x * 10, self.gamepadRotateDelta.y * 10)

						self.itemViewerScene:onSwipeModel(fakeDelta)
					end
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			if self.gamepadRotateTimer then
				self:killTimer(self.gamepadRotateTimer)

				self.gamepadRotateTimer = nil
			end

			self.gamepadRotateDelta = nil
		end

		return true
	end
end

function HomelandFurnitureStoreCtrl:refreshConsoleBarState()
	local currentFocusedUContent = pg.global.navMgr.CurrentFocusedUContent
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local isInFurnitureMode = currentFocusedGroupName == "ListItem" or currentFocusedGroupName == "ListItemFold"

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomelandFurniture_Select", isInFurnitureMode)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomelandFurniture_View", isInFurnitureMode)
end

function HomelandFurnitureStoreCtrl:onSelectItem(itemId)
	self.curItemId = itemId

	if not itemId then
		self.objectInfo = nil

		self:refreshItemInfo()

		return
	end

	self.objectInfo = HomeObjectData[self.curItemId] or {}

	local needLoadNewModel = self.prefabResIdCache == nil or self.prefabResIdCache ~= self.objectInfo.prefabResID

	if needLoadNewModel then
		self.isLoadingModel = true

		if self.view and self.view.rightUComponent then
			self.view.rightUComponent:SetActive(false)
		end
	end

	self:refreshItemInfo()

	if needLoadNewModel then
		local res = self:getResData()

		if res then
			self.prefabResIdCache = res.modelResId

			self.itemViewerScene:showModel(res, function()
				self.isLoadingModel = false

				if self.view and self.view.rightUComponent then
					local hasItem = self.curItemId ~= nil and self.objectInfo ~= nil and ClientHomelandUtils.isFurnitureAvailableInArea(self.curItemId)

					self.view.rightUComponent:SetActive(hasItem)
				end
			end)
		end
	end
end

function HomelandFurnitureStoreCtrl:refreshItemInfo()
	self:refreshCurrencyList()

	local hasItem = self.curItemId ~= nil and self.objectInfo ~= nil and ClientHomelandUtils.isFurnitureAvailableInArea(self.curItemId)

	self.view.leftUComponent:SetActive(hasItem)

	if not self.isLoadingModel then
		self.view.rightUComponent:SetActive(hasItem)
	end

	self.view.modelURawImage:SetActive(hasItem)

	if not hasItem then
		return
	end

	self:refreshItemNum()
	self:refreshLeftInfo()
	self:refreshRightInfo()
end

function HomelandFurnitureStoreCtrl:refreshItemNum()
	self.ownNum = ClientUtils.getItemCountById(self.curItemId)

	if pg.me:isInSelfHomeland() then
		self.ownNum = self.ownNum + ClientUtils.getHomelandItemCountById(self.curItemId)
	end

	local homePlaceTable = pg.me.statHomelandOrnament

	self.homePlaceNum = homePlaceTable[self.curItemId] or 0

	local carPlaceTable = pg.me.statHomeCarOrnament

	self.carGroupPlaceNum = carPlaceTable[self.curItemId] or 0
	self.homePlaceAllNum = pg.me:getOrnamentHomelandCurPlaceNum(self.curItemId)
	self.carGroupPlaceAllNum = pg.me:getOrnamentCarCurPlaceNum(self.curItemId)
	self.maxPlaceNum = self:getOrnamentMaxPlaceNum(self.curItemId)
end

function HomelandFurnitureStoreCtrl:getOrnamentMaxPlaceNum(templateId)
	if self.isCarGroupMode then
		return pg.me:getOrnamentMaxPlaceNum(templateId)
	end

	return pg.me:getOrnamentTotalMaxPlaceNum(templateId)
end

function HomelandFurnitureStoreCtrl:getOrnamentCurPlaceNum(templateId)
	if self.isCarGroupMode then
		return pg.me:getOrnamentCarCurPlaceNum(templateId)
	end

	return pg.me:getOrnamentCurPlaceNum(templateId)
end

function HomelandFurnitureStoreCtrl:getOrnamentPlaceIdCurPlaceNum(templateId)
	local homeObjectInfo = HomeObjectData[templateId]

	if not homeObjectInfo then
		return true
	end

	local count = self:getOrnamentCurPlaceNum(templateId)

	if not homeObjectInfo.placeId then
		count = count + ClientUtils.getItemCountById(templateId)

		if pg.me:isInSelfHomeland() then
			count = count + ClientUtils.getHomelandItemCountById(templateId)
		end
	else
		local relatedTemplateIds = RevertHomePlaceData[homeObjectInfo.placeId]

		for _, relatedTemplateId in ipairs(relatedTemplateIds) do
			count = count + ClientUtils.getItemCountById(relatedTemplateId)

			if pg.me:isInSelfHomeland() then
				count = count + ClientUtils.getHomelandItemCountById(relatedTemplateId)
			end
		end
	end

	return count
end

function HomelandFurnitureStoreCtrl:refreshLeftInfo()
	local itemData = ItemData[self.curItemId] or {}

	ClientTextUtils.setText(self.view.txtLoadNumUSDFText, ClientHomelandUtils.getLoadValueById(self.curItemId))
	ClientTextUtils.setText(self.view.txtLiveNumUSDFText, ClientHomelandUtils.getLoadValueById(self.curItemId))
	self.view.leftUComponent:TryChangePage("Quality", itemData.quality or 0)
	ClientTextUtils.setText(self.view.textNameUSDFText, pg.getLocalizationText(self.objectInfo.name))
	ClientTextUtils.setText(self.view.txtDescUSDFText, pg.getLocalizationText(self.objectInfo.desc or ""))
	ClientTextUtils.setText(self.view.textOwnUSDFText, string.format(pg.getGameString("ALREADY_OWNED"), self.ownNum + self.homePlaceNum + self.carGroupPlaceNum))

	local curPlaceAllNum = self.isCarGroupMode and self.carGroupPlaceAllNum or self.homePlaceAllNum + self.carGroupPlaceAllNum
	local maxCountText = string.format("%d/%d", curPlaceAllNum, self.maxPlaceNum)

	ClientTextUtils.setText(self.view.textMaxUSDFText, string.format("%s: %s", pg.getGameString("HOMELAND_MAX_PLACE_NUM"), maxCountText))

	self.isFavorite = false

	if pg.me.favoriteOrnamentList then
		for _, favItemId in pairs(pg.me.favoriteOrnamentList) do
			if favItemId == self.curItemId then
				self.isFavorite = true

				break
			end
		end
	end

	local objectInfo = HomeObjectData[self.curItemId]
	local homeTypeData = HomeTypeData[objectInfo.type]

	if homeTypeData.disableFav then
		self.view.btnFavoriteUButton:SetActive(false)
	else
		self.view.btnFavoriteUButton:SetActive(true)
	end

	self.view.btnFavoriteUButton:TryChangePage("enable", self.isFavorite and 1 or 0)
	self.view.scrollRectDescUScrollRect:GoToPos(Vector2.zero, true)
end

function HomelandFurnitureStoreCtrl:refreshRightInfo()
	local canObtain = true

	ClientTextUtils.setText(self.view.btnTipsUSDFText, pg.getGameString("CONSOLE_BAR_VIEW_DETAILS"))

	local curOrnamentPlaceIdCurPlaceNum = self:getOrnamentPlaceIdCurPlaceNum(self.curItemId)
	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(self.curItemId, false)

	if unlockState.conditionLocked then
		self.view.rightUComponent:TryChangePage("GetType", 2)
		self.view.emptySoldOutUComponent:TryChangePage("Status", 0)
		ClientTextUtils.setText(self.view.lockUSDFText, pg.getGameString("HOMELAND_ITEM_UNLOCK_NOT_MET"))
		ClientTextUtils.setText(self.view.unlockDescUSDFText, unlockState.lockText)

		canObtain = false
	elseif unlockState.drawingLocked then
		self.view.rightUComponent:TryChangePage("GetType", 3)
		ClientTextUtils.setText(self.view.drawingNameUSDFText, unlockState.lockText)
		ClientTextUtils.setText(self.view.TextTitleGetUSDFText, ClientHomelandUtils.getDrawingSourceTitle(true))

		local sourceList = ClientHomelandUtils.getDrawingSourceList(unlockState.unlockItemId)

		self.view.drawingSourceTitleUWidget:SetActive(#sourceList > 0)
		self.view.drawingSourceListUList:SetActive(#sourceList > 0)
		self.view.drawingSourceListUList:SetList(sourceList)

		canObtain = false
	elseif curOrnamentPlaceIdCurPlaceNum >= self.maxPlaceNum then
		self.view.rightUComponent:TryChangePage("GetType", 2)
		self.view.emptySoldOutUComponent:TryChangePage("Status", 1)

		canObtain = false
	end

	if not canObtain then
		return
	end

	self.view.rightUComponent:TryChangePage("GetType", self.objectInfo.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.ACTIVITY and 1 or 0)
	self.view.buyRedeemUComponent:TryChangePage("Status", self.objectInfo.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.BUY and 0 or 1)

	if self.objectInfo.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.BUY then
		self.view.numSelectorUNumSelector:SetAllValue(1, 1, self.maxPlaceNum - curOrnamentPlaceIdCurPlaceNum, 1)
		self:refreshConsumeInfo()
	elseif self.objectInfo.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.REDEEM then
		self.view.redeemUNumSelector:SetAllValue(1, 1, self.maxPlaceNum - curOrnamentPlaceIdCurPlaceNum, 1)
		self:refreshRedeemInfo()
	elseif self.objectInfo.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.ACTIVITY then
		if self.objectInfo.buySource == nil then
			return
		end

		local sourceInfos = {}

		for _, id in pairs(self.objectInfo.buySource) do
			local sourceInfo = {}

			sourceInfo.clueSeekID = id

			table.merge(sourceInfo, ItemSourceData[id])
			table.insert(sourceInfos, sourceInfo)
		end

		self.view.sourceList:SetList(sourceInfos)
	end
end

function HomelandFurnitureStoreCtrl:checkFurnitureUnlocked()
	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(self.curItemId, false)

	if unlockState.conditionLocked then
		pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_UNLOCKED)

		return false
	end

	if unlockState.drawingLocked then
		pg.global.showBubbleMessage(unlockState.lockText)

		return false
	end

	return true
end

function HomelandFurnitureStoreCtrl:refreshConsumeInfo()
	local costItemId = self.objectInfo.buyMoneyType
	local costItemNum = self.objectInfo.buyMoneyNum

	if not costItemId or not costItemNum then
		return
	end

	self.view.btnBuyUButton.interactable = pg.me:getItemCountById(costItemId) >= costItemNum * self.view.numSelectorUNumSelector.value

	ClientTextUtils.setText(self.view.textCostUSDFText, LuaUIUtils.getItemCountConsumeShowColorRedOnlyText(costItemId, costItemNum * self.view.numSelectorUNumSelector.value, false))
end

function HomelandFurnitureStoreCtrl:refreshRedeemInfo()
	self.view.redeemListUList:SetList(self:getRedeemListInfo())
end

function HomelandFurnitureStoreCtrl:refreshCurrencyList()
	local currencyItemList = {}
	local panelConfig = UIConst.UI_CONFIGS[UIConst.UI_ID_HOMELAND_FURNITURE_STORE]

	for _, itemId in ipairs(panelConfig and panelConfig.coin_Line or EMPTY_TABLE) do
		table.insert(currencyItemList, itemId)
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_HOMELAND_FURNITURE_STORE, currencyItemList)
end

function HomelandFurnitureStoreCtrl:onItemChanged()
	local currentSelectedId = self.itemListComponent.curSelectItemId or self.curItemId

	self.itemListComponent:refreshItemList()
	self.itemListComponent:refreshFoldList()

	for i, info in pairs(self.itemListComponent.itemList.itemData) do
		if currentSelectedId == info.itemId then
			self.itemListComponent.itemList:SelectItem(i)

			break
		end
	end

	self:refreshItemInfo()
end

function HomelandFurnitureStoreCtrl:onBtnBuyClick()
	if not self:checkFurnitureUnlocked() then
		return
	end

	local costItemId = self.objectInfo.buyMoneyType
	local costItemNum = self.objectInfo.buyMoneyNum

	if not costItemId or not costItemNum then
		return
	end

	local costText = LuaUIUtils.getItemCountConsumeShowText(costItemId, costItemNum * self.view.numSelectorUNumSelector.value, true)

	if pg.game.home.curLoginShowConfirmHint then
		pg.global.ui.commonUseConfirm:open({
			showHint = true,
			type = 4,
			title = pg.getGameString("CONFIRM_BUY"),
			tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
			data = {
				{
					costItemId,
					costItemNum * self.view.numSelectorUNumSelector.value
				}
			},
			notEnoughCallback = function(itemId, itemNum)
				if costItemId == HomelandConfigData.homeCurrencyId then
					pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK)
				elseif costItemId == HomelandConfigData.homeVoucherId then
					pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK_VOUCHER)
				end
			end,
			confirmCb = function()
				pg.global.ui.commonUseConfirm:close()
				pg.me:serverMsg("RPC_CS_BuyMultiOrnament", self.curItemId, self.view.numSelectorUNumSelector.value, function(returnCode)
					if returnCode == 0 then
						pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
						self:refreshItemInfo()
					else
						self:showBuyRetNotice(returnCode, costItemId)
					end
				end)
			end,
			cancelCb = function()
				pg.global.ui.commonUseConfirm:close()
			end,
			hintText = pg.getGameString("LOGIN_NOT_SHOW_HINT"),
			hintCb = function(isSelected)
				pg.game.home.curLoginShowConfirmHint = not isSelected
			end
		})
	else
		pg.me:serverMsg("RPC_CS_BuyMultiOrnament", self.curItemId, self.view.numSelectorUNumSelector.value, function(returnCode)
			if returnCode == 0 then
				pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
				self:refreshItemInfo()
			else
				self:showBuyRetNotice(returnCode, costItemId)
			end
		end)
	end
end

function HomelandFurnitureStoreCtrl:onButtonRedeemClick()
	if not self:checkFurnitureUnlocked() then
		return
	end

	local redeemCount = self.view.redeemUNumSelector.value

	if pg.game.home.curLoginShowConfirmHint then
		local buyData = {}

		if self.objectInfo.buyItemId1 then
			local ownNum = ItemUtils.getItemCountById(pg.me, self.objectInfo.buyItemId1)

			if pg.me:isInSelfHomeland() then
				ownNum = ownNum + ClientUtils.getHomelandItemCountById(self.objectInfo.buyItemId1)
			end

			table.insert(buyData, {
				self.objectInfo.buyItemId1,
				self.objectInfo.buyItemNum1 * redeemCount,
				ownNum = ownNum
			})
		end

		if self.objectInfo.buyItemId2 then
			local ownNum = ItemUtils.getItemCountById(pg.me, self.objectInfo.buyItemId2)

			if pg.me:isInSelfHomeland() then
				ownNum = ownNum + ClientUtils.getHomelandItemCountById(self.objectInfo.buyItemId2)
			end

			table.insert(buyData, {
				self.objectInfo.buyItemId2,
				self.objectInfo.buyItemNum2 * redeemCount,
				ownNum = ownNum
			})
		end

		pg.global.ui.commonUseConfirm:open({
			showHint = true,
			hideCurrency = 1,
			type = 1,
			title = pg.getGameString("CONFIRM_BUY"),
			tipTop = pg.getGameString("HOME_REDEEM_DESC"),
			data = buyData,
			notEnoughCallback = function(itemId, itemNum)
				pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)
			end,
			confirmCb = function()
				pg.global.ui.commonUseConfirm:close()
				pg.me:serverMsg("RPC_CS_RedeemMultiOrnament", self.curItemId, redeemCount, function(returnCode)
					if returnCode == 0 then
						pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
						self:refreshItemInfo()
					else
						self:showRedeemRetNotice(returnCode)
					end
				end)
			end,
			cancelCb = function()
				pg.global.ui.commonUseConfirm:close()
			end,
			hintCb = function(isSelected)
				pg.game.home.curLoginShowConfirmHint = not isSelected
			end,
			hintText = pg.getGameString("LOGIN_NOT_SHOW_HINT")
		})
	else
		pg.me:serverMsg("RPC_CS_RedeemMultiOrnament", self.curItemId, redeemCount, function(returnCode)
			if returnCode == 0 then
				pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
				self:refreshItemInfo()
			else
				self:showRedeemRetNotice(returnCode)
			end
		end)
	end
end

function HomelandFurnitureStoreCtrl:showRedeemRetNotice(returnCode)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_BUY_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

		return
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)

		return
	end

	pg.global.showBubbleMessage(NoticeDef.BUY_FAILED)
end

function HomelandFurnitureStoreCtrl:getFavOrnamentRPCName()
	if self.isCarGroupMode then
		return "RPC_CS_FavoriteCarOrnament"
	end

	return "RPC_CS_FavoriteOrnament"
end

function HomelandFurnitureStoreCtrl:onFavoriteButtonClick()
	local maxFavoriteOrnamentCount = HomelandConfigData.maxFavoriteOrnamentCount or 20
	local favoriteOrnamentCount = #pg.me.favoriteOrnamentList

	if not self.isFavorite and maxFavoriteOrnamentCount <= favoriteOrnamentCount then
		pg.global.showBubbleMessage(NoticeDef.ADD_FAVORITE_ORNAMENT_ERROR)

		return
	end

	self.isFavorite = not self.isFavorite

	self.view.btnFavoriteUButton:TryChangePage("enable", self.isFavorite and 1 or 0)
	pg.me:serverMsg(self:getFavOrnamentRPCName(), self.curItemId, self.isFavorite and 1 or 0, function(returnCode)
		if returnCode == 0 then
			if self.itemListComponent.curType ~= self.itemListComponent.FavoriteTypeIndex then
				local favoritePlaceIds = self.itemListComponent:getFavPlaceIds()

				self.itemListComponent:refreshFavState(self.itemListComponent.itemList, self.itemListComponent.itemList.selectedIndex, HomeObjectData[self.curItemId].placeId == nil and self.isFavorite or favoritePlaceIds[HomeObjectData[self.curItemId].placeId] ~= nil)
				self.itemListComponent:refreshFavState(self.itemListComponent.foldListUList, self.itemListComponent.foldListUList.selectedIndex, self.isFavorite)
			else
				self.itemListComponent:refreshItemList()
			end
		end
	end)
end

function HomelandFurnitureStoreCtrl:getRedeemListInfo()
	local redeemInfos = {}

	if self.objectInfo.buyItemId1 and self.objectInfo.buyItemNum1 then
		local info = {
			num = self.objectInfo.buyItemNum1,
			id = self.objectInfo.buyItemId1
		}

		table.insert(redeemInfos, info)
	end

	if self.objectInfo.buyItemId2 and self.objectInfo.buyItemNum2 then
		local info = {
			num = self.objectInfo.buyItemNum2,
			id = self.objectInfo.buyItemId2
		}

		table.insert(redeemInfos, info)
	end

	local rewardItemCount1 = ItemUtils.getItemCountById(pg.me, self.objectInfo.buyItemId1) or 0
	local rewardItemCount2 = self.objectInfo.buyItemId2 and ItemUtils.getItemCountById(pg.me, self.objectInfo.buyItemId2) or 0

	if pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
		rewardItemCount1 = rewardItemCount1 + ClientUtils.getHomelandItemCountById(self.objectInfo.buyItemId1)

		if self.objectInfo.buyItemId2 then
			rewardItemCount2 = rewardItemCount2 + ClientUtils.getHomelandItemCountById(self.objectInfo.buyItemId2)
		end
	end

	local state1 = true

	if self.objectInfo.buyItemId1 and self.objectInfo.buyItemNum1 then
		state1 = rewardItemCount1 >= self.objectInfo.buyItemNum1 * self.view.redeemUNumSelector.value
	end

	local state2 = true

	if self.objectInfo.buyItemId2 and self.objectInfo.buyItemNum2 then
		state2 = rewardItemCount2 >= self.objectInfo.buyItemNum2 * self.view.redeemUNumSelector.value
	end

	local btnRedeemUButtonState = state1 and state2

	self.view.btnRedeemUButton.interactable = btnRedeemUButtonState

	return redeemInfos
end

function HomelandFurnitureStoreCtrl:showBuyRetNotice(returnCode, costItemId)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_BUY_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

		return
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		return
	end

	if costItemId == HomelandConfigData.homeCurrencyId then
		pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK)
	elseif costItemId == HomelandConfigData.homeVoucherId then
		pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK_VOUCHER)
	end
end

function HomelandFurnitureStoreCtrl:onDestroy()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("HomelandFurnitureStore")
	end

	if self.gamepadRotateTimer then
		self:killTimer(self.gamepadRotateTimer)

		self.gamepadRotateTimer = nil
	end

	self.gamepadRotateDelta = nil

	self.itemListComponent:setExpand(false)
	self.itemListComponent:onDestroy()

	self.itemListComponent = nil

	UICtrl.onDestroy(self)
end

function HomelandFurnitureStoreCtrl:getResData()
	return ClientHomelandUtils.getPreviewDataByConfig(self.objectInfo, self.objectInfo.prefabResID)
end

function HomelandFurnitureStoreCtrl:showOrHideFoldOutList(showFoldOutList)
	if self.itemListComponent and self.itemListComponent.uWidget then
		self.itemListComponent.uWidget:TryChangePage("FoldList", showFoldOutList and 1 or 0)
	end
end

return HomelandFurnitureStoreCtrl
