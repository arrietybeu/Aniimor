-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\ProductInformationComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SuitPowerInteractionComponent = require("Guis.Panels.CashShop.Component.SuitPowerInteractionComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local CashShopConst = require("Const.CashShopConst")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ItemSourceData = require("Data.item_source_data")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceFunctionData = require("Data.appearance_function_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local HomeObjectData = require("Data.home_object_data")
local ShopMallAppearance = require("Data.shopmall_appearance")
local ShopMallPetAppearance = require("Data.shopmall_pet_appearance")
local NoticeDef = require("Common.NoticeDef")
local ProductInformationComponent = Class.LightClass("ProductInformationComponent", UIComponent)

function ProductInformationComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnShoppingCart = objectReference:GetRefValue("btnShoppingCart")
	self.btnGift = objectReference:GetRefValue("btnGift")
	self.btnBuy = objectReference:GetRefValue("btnBuy")
	self.txtBtnBuyName = objectReference:GetRefValue("txtBtnBuyName")
	self.btnBuy1 = objectReference:GetRefValue("btnBuy1")
	self.btnObtain = objectReference:GetRefValue("btnObtain")
	self.txtObtain = objectReference:GetRefValue("txtObtain")
	self.txtObtainBtnName = objectReference:GetRefValue("txtObtainBtnName")
	self.btnReplaceUButton = objectReference:GetRefValue("btnReplaceUButton")
	self.txtLockD = objectReference:GetRefValue("txtLockD")
	self.txtSoldOut = objectReference:GetRefValue("txtSoldOut")
	self.txtDescNum = objectReference:GetRefValue("txtDescNum")
	self.txtDescType = objectReference:GetRefValue("txtDescType")
	self.txtName = objectReference:GetRefValue("txtName")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.txtPlayerTitle = objectReference:GetRefValue("txtPlayerTitle")
	self.txtPetTitle = objectReference:GetRefValue("txtPetTitle")
	self.txtRedirect = objectReference:GetRefValue("txtRedirect")
	self.btnRedirect = objectReference:GetRefValue("btnRedirect")
	self.btnChangePet = objectReference:GetRefValue("btnChangePet")
	self.imgPet = objectReference:GetRefValue("imgPet")
	self.inventoryUWidget = objectReference:GetRefValue("inventoryUWidget")
	self.txtInventory = objectReference:GetRefValue("txtInventory")
	self.rewardUWidget = objectReference:GetRefValue("rewardUWidget")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtDirectPurchase = objectReference:GetRefValue("txtDirectPurchase ")
	self.btnTriangle = objectReference:GetRefValue("btnTriangle")
	self.jumpUWidget = objectReference:GetRefValue("jumpUWidget")
	self.fashionUImage = objectReference:GetRefValue("fashionUImage")
	self.txtGotoWear = objectReference:GetRefValue("txtGotoWear")
	self.costItem = objectReference:GetRefValue("costItem")
	self.fashionShowUWidget = objectReference:GetRefValue("fashionShowUWidget")
	self.fashionShowUList = objectReference:GetRefValue("fashionShowUList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.btnPlayer = objectReference:GetRefValue("btnPlayer")
	self.btnPet = objectReference:GetRefValue("btnPet")
	self.foarregelfaasjeUWidget = objectReference:GetRefValue("foarregelfaasjeUWidget")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	self.foarregelfaasjeList = objectReference:GetRefValue("foarregelfaasjeList")
	self.petSwitchBtnUButton = objectReference:GetRefValue("petSwitchBtnUButton")
	self.petUImage = objectReference:GetRefValue("petUImage")

	self.btnShoppingCart:SetActive(false)

	if self.petSwitchBtnUButton then
		self.petSwitchBtnUButton.gameObject:SetActiveEx(false)
	end

	ClientTextUtils.setText(self.txtBtnBuyName, pg.getGameString("SHOP_BUY_ITEM"))
	ClientTextUtils.setText(self.txtRedirect, pg.getGameString("SHOP_JEWELRY_CHANGE"))
	ClientTextUtils.setText(self.txtSoldOut, pg.getGameString("SHOP_SELLOUT"))
	ClientTextUtils.setText(self.txtObtainBtnName, pg.getGameString("SHOP_GOGET"))
	ClientTextUtils.setText(self.txtPlayerTitle, pg.getGameString("SHOP_ROLE"))
	ClientTextUtils.setText(self.txtPetTitle, pg.getGameString("SHOP_PET"))
	ClientTextUtils.setText(self.txtGotoWear, pg.getGameString("SHOP_GOWEAR"))
end

function ProductInformationComponent:addListener()
	function self.listUList.luaRenderItem(button, index, data)
		self:_renderSuitAppearanceItem(button, index, data)
	end

	if self.fashionShowUList then
		function self.fashionShowUList.luaRenderItem(button, index, data)
			self:_renderGiftAppearanceItem(button, index, data)
		end
	end

	if self.foarregelfaasjeList and not self.suitPowerInteractionComponent then
		self.suitPowerInteractionComponent = SuitPowerInteractionComponent.new(self, self.foarregelfaasjeList.transform, {
			waitPlayerModelLoadedAfterSwitch = true,
			titleTextKey = "SHOP_PLAYER_PET",
			listInteraction = self.foarregelfaasjeList,
			txtInteraction = self.titleUBaseText,
			rootInteraction = self.foarregelfaasjeUWidget,
			getAvatarComponent = function()
				return self:_getAvatarPreviewComponent()
			end,
			isShowingPet = function()
				return self._showingPetView == true
			end,
			isInteractionBlocked = function()
				local cashShopCtrl = self.ctrl and self.ctrl.ctrl

				return cashShopCtrl and cashShopCtrl._cashShopExSceneActiveTimelineSerial ~= nil or false
			end,
			switchToPlayer = function(onLoaded)
				if not self.ctrl or not self.ctrl._switchToPlayer then
					return false
				end

				return self.ctrl:_switchToPlayer(onLoaded)
			end,
			switchToPet = function(petTemplateId, onLoaded)
				if not self.ctrl or not self.ctrl._switchToSuitPowerPet then
					return false
				end

				return self.ctrl:_switchToSuitPowerPet(petTemplateId, onLoaded)
			end
		})
	end

	local ctrlObj

	if self.ctrl and self.ctrl.showFriendList then
		ctrlObj = self.ctrl
	elseif self.ctrl.ctrl and self.ctrl.ctrl.showFriendList then
		ctrlObj = self.ctrl.ctrl
	end

	self._btnTriangleState = 0

	function self.btnTriangle.luaClick()
		self._btnTriangleState = 1 - self._btnTriangleState

		self.rootUComponent:TryChangePage("BtnTriangle", self._btnTriangleState)
	end

	if self.btnBuy then
		function self.btnBuy.luaClick()
			if self._recommendationShowModle == CashShopConst.ShowModle.Lottery then
				if self.ctrl and self.ctrl.onProductInformationDirectPurchase then
					self.ctrl:onProductInformationDirectPurchase(self._curCommodityId)
				end

				return
			end

			self:_onConfirmToBuy()
		end
	end

	if self.btnGift and ctrlObj then
		function self.btnGift.luaClick()
			ctrlObj:showFriendList(self._curCommodityId)
		end
	end

	self._cashCartCtrl = ctrlObj and ctrlObj.addCashCartCommodity and ctrlObj or nil

	if self.btnShoppingCart and self._cashCartCtrl then
		function self.btnShoppingCart.luaClick()
			if self._curCommodityId then
				self._cashCartCtrl:addCashCartCommodity(self._curCommodityId)
			end
		end
	end

	if self.btnChangePet then
		function self.btnChangePet.luaClick()
			local avatarComponent = self.ctrl.ctrl and self.ctrl.ctrl.avatarComponent

			if not avatarComponent then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_ACCESS_PET_BOX, {
				curPetId = avatarComponent.curPetId,
				sceneType = UISceneConst.CASH_SCENE,
				selectCallback = function(petId)
					avatarComponent:clearPetAccessoryPreviewList()
					avatarComponent:showPet(petId, function()
						self:refreshPetIcon(petId)

						if self:isGiftAppearanceCommodity() then
							self:applySelectedGiftAppearances(true)
						elseif self.ctrl and self.ctrl._resolveCommodityItemId and self.ctrl._showPetPreview then
							local itemId = self.ctrl:_resolveCommodityItemId(self.ctrl._currentData)

							if itemId then
								self.ctrl:_showPetPreview(itemId)
							end
						end
					end)
				end
			})
		end
	end

	if self.petSwitchBtnUButton and self.btnChangePet then
		self.petSwitchBtnUButton.luaClick = self.btnChangePet.luaClick
	end

	if self.btnPlayer then
		function self.btnPlayer.luaClick()
			self:_onPreviewTargetButtonClick(CashShopConst.AccessoryPreviewTarget.PLAYER)
		end
	end

	if self.btnPet then
		function self.btnPet.luaClick()
			self:_onPreviewTargetButtonClick(CashShopConst.AccessoryPreviewTarget.PET)
		end
	end

	if self.btnReplaceUButton then
		function self.btnReplaceUButton.luaClick()
			self:_gotoWearSuit()
		end
	end

	if self.btnRedirect then
		function self.btnRedirect.luaClick()
			self:_gotoWearSuit()
		end
	end
end

function ProductInformationComponent:_gotoWearSuit()
	local commodityInfo = self._curCommodityId and ClientCashShopUtils.getCommodityData(self._curCommodityId)

	if not commodityInfo then
		return
	end

	LuaUIUtils.openPlayerAppearancePanelAndSelectSuit(commodityInfo.itemId)
end

function ProductInformationComponent:_onReplaceClick()
	local ctrlObj

	if self.ctrl and self.ctrl.showFriendList then
		ctrlObj = self.ctrl
	elseif self.ctrl.ctrl and self.ctrl.ctrl.showFriendList then
		ctrlObj = self.ctrl.ctrl
	end

	if ctrlObj and ctrlObj.openAvatarAdjust then
		function self.btnRedirect.luaClick()
			ctrlObj:openAvatarAdjust()
		end
	end
end

function ProductInformationComponent:setBtnState(data)
	local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)

	if not commodityInfo then
		self._curBtnState = CashShopConst.BtnState.BUY

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.BUY)

		return
	end

	local jumpId = data.jump and data.jump > 0 and data.jump or commodityInfo.jump and commodityInfo.jump > 0 and commodityInfo.jump

	if jumpId then
		self._curBtnState = CashShopConst.BtnState.OBTAIN

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.OBTAIN)

		return
	end

	local stateData = {}

	for k, v in pairs(commodityInfo) do
		stateData[k] = v
	end

	stateData.commodityId = data.commodityId

	local COMMODITY_STATE = ClientCashShopUtils.COMMODITY_STATE
	local state = ClientCashShopUtils.getCommodityState(stateData)

	if state == COMMODITY_STATE.LOCKED then
		self._curBtnState = CashShopConst.BtnState.LOCKED

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.LOCKED)

		if self.txtLockD then
			ClientTextUtils.setText(self.txtLockD, LuaUIUtils.getConditionUnlockDesc(commodityInfo.condition))
		end
	elseif state == COMMODITY_STATE.SOLDOUT then
		self._curBtnState = CashShopConst.BtnState.SOLD_OUT

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.SOLD_OUT)
	elseif state == COMMODITY_STATE.POSSESS then
		self._curBtnState = CashShopConst.BtnState.PURCHASED

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.PURCHASED)
	else
		self._curBtnState = CashShopConst.BtnState.BUY

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.BUY)
	end
end

function ProductInformationComponent:setRecommendationBtnState(showModle)
	self._recommendationShowModle = showModle

	local isLottery = showModle == CashShopConst.ShowModle.Lottery

	if isLottery then
		self._curBtnState = CashShopConst.BtnState.BUY

		self.rootUComponent:TryChangePage("ButtonState", CashShopConst.BtnState.BUY)
	end

	local inventoryVisible = self.inventoryUWidget and self.inventoryUWidget.gameObject.activeSelf == true

	self.rootUComponent:TryChangePage("StateBtn", isLottery and 1 or 0)

	if self.inventoryUWidget then
		self.inventoryUWidget:SetActive(not isLottery and inventoryVisible)
	end

	local textId = isLottery and "SHOP_GO_GACHA" or "SHOP_BUY_ITEM"

	ClientTextUtils.setText(self.txtBtnBuyName, pg.getGameString(textId))
end

function ProductInformationComponent:setInfo(data, tabWidgetVisible)
	self:setBtnState(data)

	local commodityChanged = self._curCommodityId ~= data.commodityId

	if commodityChanged then
		self:_invalidateSuitPowerPreview()
	end

	local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)

	self._curAvatarType = commodityInfo and commodityInfo.avatarType or nil

	self:_refreshTabWidget(commodityInfo, tabWidgetVisible)

	if not commodityInfo then
		self:_refreshSuitPowerList(nil)
		self:_refreshGiftAppearanceList(nil, commodityChanged)

		return
	end

	if self.btnTriangle then
		self.btnTriangle.gameObject:SetActiveEx(ClientCashShopUtils.isSuitType(commodityInfo.avatarType))
	end

	local cost = ClientCashShopUtils.getCommodityPrimaryCost(data.commodityId, 1, {
		isInDiscount = data.isInDiscount
	})

	self._curCost = cost
	self._curCommodityId = data.commodityId

	if data.itemId then
		ClientTextUtils.setText(self.txtName, LuaUIUtils.getNameByItemId(data.itemId))
	else
		ClientTextUtils.setText(self.txtName, pg.getLocalizationText(data.name))
	end

	ClientTextUtils.setText(self.txtDirectPurchase, cost and cost[2] or 0)

	if data.dec then
		ClientTextUtils.setText(self.txtInventory, data.dec)
	elseif commodityInfo.limitNum and commodityInfo.limitNum > 0 then
		local limitTitle = LuaUIUtils.getLimitTitleString(commodityInfo.limitType)
		local limitNum = commodityInfo.limitNum or 1
		local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(self._curCommodityId)

		ClientTextUtils.setText(self.txtInventory, string.format("%s%d/%d", limitTitle, leftLimit, limitNum))
	end

	if self.costItem then
		ItemPropUIUtils.renderConsumeItem(self.costItem, cost, false)

		local costItemObjectReference = self.costItem:GetComponent("ObjectReference")
		local costIconUImage = LuaUIUtils.safeGetRefValue(costItemObjectReference, "imgIcon")

		if costIconUImage and cost and cost[1] then
			costIconUImage.url = LuaUIUtils.getIconByItemId(cost[1], LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)
		end
	end

	if self.btnShoppingCart then
		self.btnShoppingCart:SetActive(self._cashCartCtrl ~= nil and commodityInfo.noAdd ~= 1 and self._curBtnState == CashShopConst.BtnState.BUY)
	end

	local isLocked = self._curBtnState == CashShopConst.BtnState.LOCKED

	self.btnGift:SetActive(commodityInfo.noGift ~= 1 and not isLocked)
	self.inventoryUWidget:SetActive(data.dec or commodityInfo.limitNum and commodityInfo.limitNum > 0)

	local itemInfo = ClientCashShopUtils.getItemDataByCommodityId(data.commodityId)
	local quality = itemInfo and itemInfo.quality or 0

	self.rootUComponent:TryChangePage("Quality", quality)

	if data.avatarType then
		ClientTextUtils.setText(self.txtDescType, ClientCashShopUtils.getAvatarTypeText(data.avatarType))
	else
		local displayType = itemInfo and itemInfo.displayType

		ClientTextUtils.setText(self.txtDescType, ClientCashShopUtils.getAvatarTypeText(displayType))
	end

	self:_refreshSuitAppearanceList(commodityInfo)
	self:_refreshSuitLogo(commodityInfo)
	self:_refreshSuitPowerList(commodityInfo)
	self:_refreshGiftAppearanceList(commodityInfo, commodityChanged)
	self:_refreshJumpWidget()

	local jumpId = data.jump

	if jumpId and jumpId > 0 then
		local sourceData = ItemSourceData[jumpId]

		if sourceData then
			if self.txtObtain then
				ClientTextUtils.setText(self.txtObtain, pg.getLocalizationText(sourceData.buttonTxt))
			end

			if self.btnObtain then
				function self.btnObtain.luaClick()
					local clueData = {}

					table.merge(clueData, sourceData)

					clueData.clueSeekID = jumpId

					LuaUIUtils.clueSeek(clueData, nil, self.btnObtain)
				end
			end
		end
	end
end

function ProductInformationComponent:_refreshSuitLogo(commodityInfo)
	if not self.iconUImage then
		return
	end

	local logo

	if ClientCashShopUtils.isSuitType(commodityInfo.avatarType) then
		local containerCtrl = self.ctrl
		local gender = containerCtrl and containerCtrl._getOrInitCurrentGender and containerCtrl:_getOrInitCurrentGender()
		local suitItemId = ClientCashShopUtils.getGenderConvertedItemId(commodityInfo.itemId, gender) or commodityInfo.itemId
		local suitData = AppearanceSuitData[suitItemId] or AppearanceSuitData[commodityInfo.itemId]

		logo = suitData and suitData.logo
	end

	local hasLogo = logo ~= nil and logo ~= ""
	local isShowLogo = hasLogo and self._btnTriangleState ~= 1

	self.iconUImage.gameObject:SetActiveEx(isShowLogo)

	self.iconUImage.url = hasLogo and logo or ""
end

function ProductInformationComponent:_refreshSuitAppearanceList(commodityInfo)
	if not self.listUList then
		return
	end

	self._suitAppearanceTipSwitchFrame = nil

	if not ClientCashShopUtils.isSuitType(commodityInfo.avatarType) then
		self._btnTriangleState = 0

		self.rootUComponent:TryChangePage("BtnTriangle", self._btnTriangleState)

		return
	end

	local containerCtrl = self.ctrl
	local gender = containerCtrl and containerCtrl._getOrInitCurrentGender and containerCtrl:_getOrInitCurrentGender()
	local list = ClientCashShopUtils.getSuitAppearanceItems(commodityInfo.itemId, gender)

	if not list or #list == 0 then
		self._btnTriangleState = 0

		self.rootUComponent:TryChangePage("BtnTriangle", self._btnTriangleState)

		return
	end

	self.listUList:SetList(list)
end

function ProductInformationComponent:_renderSuitAppearanceItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	if itemIconUImage then
		itemIconUImage.url = LuaUIUtils.getIconByItemId(data.id)
	end

	if txtNumUText then
		ClientTextUtils.setText(txtNumUText, data.num or 1)
	end

	local itemConfig = ItemData[data.id]
	local quality = itemConfig and itemConfig.quality or 0

	button:TryChangePage("Quality", quality)

	function button.luaClick(navConfirm)
		LuaUIUtils.onRewardItemClick(button, data, nil, navConfirm)
	end

	function button.luaUnhover()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			self._suitAppearanceTipSwitchFrame = CS.UnityEngine.Time.frameCount
		else
			self._suitAppearanceTipSwitchFrame = nil
		end
	end

	function button.luaNavFocused()
		local shouldSwitchTip = self._suitAppearanceTipSwitchFrame == CS.UnityEngine.Time.frameCount

		self._suitAppearanceTipSwitchFrame = nil

		if shouldSwitchTip and not self:isAccessoryPackageCommodity() then
			LuaUIUtils.onRewardItemClick(button, data, nil, true)
		end
	end
end

function ProductInformationComponent:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, appearanceId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId or candidateIdMap[appearanceId] then
		return
	end

	candidateIdMap[appearanceId] = true
	candidateIds[#candidateIds + 1] = appearanceId
end

function ProductInformationComponent:_appendSuitPowerCandidateList(candidateIds, candidateIdMap, appearanceIds)
	if not Utils.isTable(appearanceIds) then
		return
	end

	for _, appearanceId in ipairs(appearanceIds) do
		self:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, appearanceId)
	end
end

function ProductInformationComponent:_getSuitPowerCandidateIds(commodityInfo)
	local candidateIds = {}
	local candidateIdMap = {}

	if not commodityInfo then
		return candidateIds
	end

	local gender = self.ctrl and self.ctrl._getOrInitCurrentGender and self.ctrl:_getOrInitCurrentGender()
	local commodityItemId = tonumber(commodityInfo.itemId)
	local suitItemId = ClientCashShopUtils.getGenderConvertedItemId(commodityItemId, gender) or commodityItemId

	self:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, suitItemId)

	local mappedAppearanceIds = ShopMallAppearance[suitItemId] or ShopMallAppearance[commodityItemId]

	if Utils.isTable(mappedAppearanceIds) then
		for _, mappedAppearanceId in ipairs(mappedAppearanceIds) do
			local convertedAppearanceId = ClientCashShopUtils.getGenderConvertedItemId(mappedAppearanceId, gender) or mappedAppearanceId

			self:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, convertedAppearanceId)
		end
	end

	local suitData = AppearanceSuitData[suitItemId] or AppearanceSuitData[commodityItemId]

	if not suitData then
		return candidateIds
	end

	self:_appendSuitPowerCandidateList(candidateIds, candidateIdMap, suitData.appearanceList)
	self:_appendSuitPowerCandidateList(candidateIds, candidateIdMap, suitData.jewelryList)
	self:_appendSuitPowerCandidateList(candidateIds, candidateIdMap, suitData.kit)
	self:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, suitData.hair)
	self:_appendSuitPowerCandidateId(candidateIds, candidateIdMap, suitData.makeup)

	return candidateIds
end

function ProductInformationComponent:_buildSuitPowerList(commodityInfo)
	local list = {}

	for _, appearanceId in ipairs(self:_getSuitPowerCandidateIds(commodityInfo)) do
		local functionData = AppearanceFunctionData[appearanceId]

		if functionData and tonumber(functionData.type) == 2 and Utils.isTable(functionData.suitPowerType) then
			for _, powerType in ipairs(functionData.suitPowerType) do
				powerType = tonumber(powerType)

				if powerType == CashShopConst.SuitPowerType.FASHION_SWITCH or powerType == CashShopConst.SuitPowerType.PET_IDLE or powerType == CashShopConst.SuitPowerType.PLAYER_PET_INTERACTION or powerType == CashShopConst.SuitPowerType.PLAYER_PET_TIPS then
					list[#list + 1] = {
						selected = false,
						appearanceId = appearanceId,
						powerType = powerType,
						functionData = functionData
					}
				end
			end
		end
	end

	return list
end

function ProductInformationComponent:_refreshSuitPowerList(commodityInfo)
	local interactionList = self:_buildSuitPowerList(commodityInfo)

	if self.suitPowerInteractionComponent then
		self.suitPowerInteractionComponent:setInteractionList(interactionList)
	end
end

function ProductInformationComponent:_invalidateSuitPowerPreview()
	if self.suitPowerInteractionComponent then
		self.suitPowerInteractionComponent:invalidatePreview()
	end
end

function ProductInformationComponent:_getAvatarPreviewComponent()
	return self.ctrl and self.ctrl.ctrl and self.ctrl.ctrl.avatarComponent or nil
end

function ProductInformationComponent:_resolveGiftAppearanceIds(itemId)
	local gender = self.ctrl and self.ctrl._getOrInitCurrentGender and self.ctrl:_getOrInitCurrentGender()
	local convertedItemId = ClientCashShopUtils.getGenderConvertedItemId(itemId, gender) or itemId
	local mappedInfo = ShopMallAppearance[convertedItemId] or ShopMallAppearance[itemId]
	local playerAppearanceId, petAppearanceId
	local playerData = AppearanceData[convertedItemId]

	if playerData and playerData.type == 1 then
		playerAppearanceId = convertedItemId
	elseif mappedInfo and mappedInfo[1] then
		local mappedPlayerId = ClientCashShopUtils.getGenderConvertedItemId(mappedInfo[1], gender) or mappedInfo[1]
		local mappedPlayerData = AppearanceData[mappedPlayerId]

		if mappedPlayerData and mappedPlayerData.type == 1 then
			playerAppearanceId = mappedPlayerId
		end
	end

	if AppearanceJewelryPetData[convertedItemId] then
		petAppearanceId = convertedItemId
	elseif mappedInfo and mappedInfo[2] and AppearanceJewelryPetData[mappedInfo[2]] then
		petAppearanceId = mappedInfo[2]
	else
		local mappedPetId = ShopMallPetAppearance[convertedItemId] or ShopMallPetAppearance[itemId]

		if mappedPetId and AppearanceJewelryPetData[mappedPetId] then
			petAppearanceId = mappedPetId
		end
	end

	return playerAppearanceId, petAppearanceId
end

function ProductInformationComponent:_buildGiftAppearanceList(giftItems)
	local list = {}

	self._giftHasPlayerAppearance = false
	self._giftHasPetAppearance = false
	self._giftHasFurniture = false

	for index, item in ipairs(giftItems or {}) do
		local itemId = item.id
		local playerAppearanceId, petAppearanceId = self:_resolveGiftAppearanceIds(itemId)
		local furnitureItemId = HomeObjectData[itemId] and itemId or nil

		if playerAppearanceId then
			self._giftHasPlayerAppearance = true
		end

		if petAppearanceId then
			self._giftHasPetAppearance = true
		end

		if furnitureItemId then
			self._giftHasFurniture = true
		end

		list[#list + 1] = {
			id = itemId,
			num = item.num or 1,
			giftItemIndex = index,
			playerAppearanceId = playerAppearanceId,
			petAppearanceId = petAppearanceId,
			furnitureItemId = furnitureItemId,
			selected = self._giftSelectedByItemId[itemId] == true
		}
	end

	return list
end

function ProductInformationComponent:_getGiftItemTarget(data)
	local target = CashShopConst.AccessoryPreviewTarget

	if data and data.playerAppearanceId then
		return target.PLAYER
	end

	if data and data.petAppearanceId then
		return target.PET
	end

	if data and data.furnitureItemId then
		return target.FURNITURE
	end

	return nil
end

function ProductInformationComponent:_hasAccessoryPackageTarget(target)
	local previewTarget = CashShopConst.AccessoryPreviewTarget

	if target == previewTarget.PLAYER then
		return self._giftHasPlayerAppearance == true
	end

	if target == previewTarget.PET then
		return self._giftHasPetAppearance == true
	end

	if target == previewTarget.FURNITURE then
		return self._giftHasFurniture == true
	end

	return false
end

function ProductInformationComponent:_getDefaultAccessoryPackageTarget()
	local target = CashShopConst.AccessoryPreviewTarget

	if self:_hasAccessoryPackageTarget(target.PLAYER) then
		return target.PLAYER
	end

	if self:_hasAccessoryPackageTarget(target.PET) then
		return target.PET
	end

	if self:_hasAccessoryPackageTarget(target.FURNITURE) then
		return target.FURNITURE
	end

	return nil
end

function ProductInformationComponent:_clearGiftAppearanceSelection()
	self._giftSelectedByItemId = self._giftSelectedByItemId or {}

	table.clear(self._giftSelectedByItemId)

	for _, data in ipairs(self._giftAppearanceList or {}) do
		data.selected = false
	end
end

function ProductInformationComponent:_setGiftAppearanceSelected(data, selected)
	if not data then
		return
	end

	self._giftSelectedByItemId = self._giftSelectedByItemId or {}
	data.selected = selected == true
	self._giftSelectedByItemId[data.id] = data.selected
end

function ProductInformationComponent:_isDefaultGiftAppearance(data, target)
	local previewTarget = CashShopConst.AccessoryPreviewTarget
	local configIndex

	if target == previewTarget.PLAYER then
		configIndex = 1
	elseif target == previewTarget.PET then
		configIndex = 2
	else
		return false
	end

	local defaultList = Utils.isTable(self._giftDefaultAvatar) and self._giftDefaultAvatar[configIndex] or nil

	if not Utils.isTable(defaultList) then
		return false
	end

	for _, itemId in ipairs(defaultList) do
		if tonumber(itemId) == tonumber(data.id) then
			return true
		end
	end

	return false
end

function ProductInformationComponent:_selectGiftDefaultsForTarget(target)
	self:_clearGiftAppearanceSelection()

	local previewTarget = CashShopConst.AccessoryPreviewTarget

	for _, data in ipairs(self._giftAppearanceList or {}) do
		if self:_getGiftItemTarget(data) == target then
			if target == previewTarget.FURNITURE then
				self:_setGiftAppearanceSelected(data, true)

				break
			elseif self:_isDefaultGiftAppearance(data, target) then
				self:_setGiftAppearanceSelected(data, true)
			end
		end
	end
end

function ProductInformationComponent:_selectFirstGiftAppearance()
	self:_clearGiftAppearanceSelection()

	local firstData = self._giftAppearanceList and self._giftAppearanceList[1]

	if not firstData then
		return nil, nil
	end

	self:_setGiftAppearanceSelected(firstData, true)

	return firstData, self:_getGiftItemTarget(firstData)
end

function ProductInformationComponent:_refreshGiftAppearanceSelection()
	if self.fashionShowUList then
		self.fashionShowUList:RefreshList()
	end
end

function ProductInformationComponent:_refreshGiftAppearanceList(commodityInfo, commodityChanged)
	local isAccessoryPackage = tonumber(commodityInfo and commodityInfo.avatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE
	local giftItems = isAccessoryPackage and LuaUIUtils.getRewardFixedItemsByDropId(commodityInfo.itemId) or {}
	local hasGiftItems = next(giftItems) ~= nil

	self._curGiftItems = hasGiftItems and giftItems or nil
	self._giftDefaultAvatar = commodityInfo and commodityInfo.defaultAvatar or nil

	if commodityChanged or not self._giftSelectedByItemId then
		self._giftSelectedByItemId = {}
	end

	if self.fashionShowUWidget then
		self.fashionShowUWidget:SetActive(isAccessoryPackage and hasGiftItems)
	end

	if self.fashionShowUList then
		self.fashionShowUList.gameObject:SetActiveEx(isAccessoryPackage and hasGiftItems)
	end

	if not hasGiftItems then
		self._giftAppearanceList = {}
		self._giftHasPlayerAppearance = false
		self._giftHasPetAppearance = false
		self._giftHasFurniture = false
		self._giftCurrentTarget = nil

		if self:isAccessoryPackageCommodity() then
			self:setPreviewTarget(nil)
		end

		if self.fashionShowUList then
			self.fashionShowUList:SetList({})
		end

		return
	end

	self._giftAppearanceList = self:_buildGiftAppearanceList(giftItems)

	if self:isAccessoryPackageCommodity() and (commodityChanged or not self:_hasAccessoryPackageTarget(self._giftCurrentTarget)) then
		local firstData, firstTarget = self:_selectFirstGiftAppearance()

		self._giftCurrentTarget = firstTarget

		self:setPreviewTarget(self._giftCurrentTarget)

		if firstData and firstTarget then
			self:_showAccessoryPackageTarget(firstTarget, firstData.furnitureItemId)
		end
	end

	if self.fashionShowUList then
		self.fashionShowUList:SetList(self._giftAppearanceList)
	end
end

function ProductInformationComponent:_renderGiftAppearanceItem(button, index, data)
	LuaUIUtils.renderItem(button, data)
	button:SetSelected(data.selected == true)

	local longPressTriggered = false

	button.enabledLongPress = true
	button.luaLongPress = nil

	function button.luaPress()
		longPressTriggered = false
	end

	function button.luaBeginLongPress()
		longPressTriggered = true

		self:_showGiftAppearanceItemTip(button, data)
	end

	function button.luaClick()
		if longPressTriggered then
			longPressTriggered = false

			return
		end

		self:_onGiftAppearanceItemClick(button, data)
	end

	if not IsNil(button) then
		button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, 0, function()
			self:_showGiftAppearanceItemTip(button, data)

			return false
		end)
	end
end

function ProductInformationComponent:_showGiftAppearanceItemTip(button, data)
	if not button or not data then
		return
	end

	LuaUIUtils.onRewardItemClick(button, data)
end

function ProductInformationComponent:_onGiftAppearanceItemClick(button, data)
	if not self:isAccessoryPackageCommodity() then
		LuaUIUtils.onRewardItemClick(button, data)

		return
	end

	local target = self:_getGiftItemTarget(data)

	if not target then
		LuaUIUtils.onRewardItemClick(button, data)

		return
	end

	local previewTarget = CashShopConst.AccessoryPreviewTarget
	local targetChanged = target ~= self._giftCurrentTarget
	local wasSelected = data.selected == true

	if target == previewTarget.FURNITURE then
		if not targetChanged and wasSelected then
			return
		end

		self:_clearGiftAppearanceSelection()
		self:_setGiftAppearanceSelected(data, true)
	elseif targetChanged then
		self:_selectGiftDefaultsForTarget(target)
		self:_setGiftAppearanceSelected(data, true)
	else
		self:_setGiftAppearanceSelected(data, not wasSelected)
	end

	self._giftCurrentTarget = target

	self:setPreviewTarget(target)
	self:_refreshGiftAppearanceSelection()

	if not targetChanged and target == previewTarget.PLAYER then
		if wasSelected then
			local avatarComponent = self:_getAvatarPreviewComponent()

			if avatarComponent then
				avatarComponent:hidePlayerGiftAccessory(data.playerAppearanceId)
			end
		else
			self:applySelectedGiftAppearances(false)
		end
	elseif not targetChanged and target == previewTarget.PET then
		if wasSelected then
			local avatarComponent = self:_getAvatarPreviewComponent()

			if avatarComponent then
				avatarComponent:hidePetGiftAccessory(data.petAppearanceId)
			end
		else
			self:applySelectedGiftAppearances(true)
		end
	else
		self:_showAccessoryPackageTarget(target, data.furnitureItemId)
	end
end

function ProductInformationComponent:isAccessoryPackageCommodity()
	return tonumber(self._curAvatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE
end

function ProductInformationComponent:isGiftAppearanceCommodity()
	return self:isAccessoryPackageCommodity() and (self._giftHasPlayerAppearance == true or self._giftHasPetAppearance == true or self._giftHasFurniture == true)
end

function ProductInformationComponent:hasGiftAppearanceForTarget(isPetView)
	if isPetView then
		return self._giftHasPetAppearance == true
	end

	return self._giftHasPlayerAppearance == true
end

function ProductInformationComponent:hasGiftFurniture()
	return self._giftHasFurniture == true
end

function ProductInformationComponent:getAccessoryPackageTarget()
	return self._giftCurrentTarget
end

function ProductInformationComponent:getSelectedGiftFurnitureId()
	for _, data in ipairs(self._giftAppearanceList or {}) do
		if data.selected and data.furnitureItemId then
			return data.furnitureItemId
		end
	end

	return nil
end

function ProductInformationComponent:getSelectedGiftAppearanceIds(isPetView)
	local ids = {}

	for _, data in ipairs(self._giftAppearanceList or {}) do
		if data.selected then
			local appearanceId = isPetView and data.petAppearanceId or data.playerAppearanceId

			if appearanceId then
				ids[#ids + 1] = appearanceId
			end
		end
	end

	return ids
end

function ProductInformationComponent:applySelectedGiftAppearances(isPetView)
	if not self:isGiftAppearanceCommodity() then
		return
	end

	local cashShopCtrl = self.ctrl and self.ctrl.ctrl
	local avatarComponent = cashShopCtrl and cashShopCtrl.avatarComponent

	if not avatarComponent then
		return
	end

	local appearanceIds = self:getSelectedGiftAppearanceIds(isPetView)

	if isPetView then
		avatarComponent:applyPetAccessoryPreviewList(appearanceIds)
	else
		avatarComponent:applyPlayerAccessoryPreviewList(appearanceIds, false)
	end
end

function ProductInformationComponent:_showAccessoryPackageTarget(target, furnitureItemId)
	local previewTarget = CashShopConst.AccessoryPreviewTarget

	if target == previewTarget.PLAYER and self.ctrl and self.ctrl._switchToPlayer then
		self.ctrl:_switchToPlayer()
	elseif target == previewTarget.PET and self.ctrl and self.ctrl._switchToPet then
		self.ctrl:_switchToPet()
	elseif target == previewTarget.FURNITURE and self.ctrl and self.ctrl._switchToFurniture then
		self.ctrl:_switchToFurniture(furnitureItemId)
	end
end

function ProductInformationComponent:_onPreviewTargetButtonClick(target)
	self:_invalidateSuitPowerPreview()

	local previewTarget = CashShopConst.AccessoryPreviewTarget

	if self:isAccessoryPackageCommodity() then
		if target == self._giftCurrentTarget then
			self:_selectGiftDefaultsForTarget(target)
			self:setPreviewTarget(self._giftCurrentTarget)
			self:_refreshGiftAppearanceSelection()
			self:_showAccessoryPackageTarget(target, self:getSelectedGiftFurnitureId())

			return
		end

		self._giftCurrentTarget = target

		self:_selectGiftDefaultsForTarget(target)
		self:setPreviewTarget(target)
		self:_refreshGiftAppearanceSelection()
		self:_showAccessoryPackageTarget(target, self:getSelectedGiftFurnitureId())

		return
	end

	if target == previewTarget.PLAYER and self.ctrl and self.ctrl._switchToPlayer then
		self.ctrl:_switchToPlayer()
	elseif target == previewTarget.PET and self.ctrl and self.ctrl._switchToPet then
		self.ctrl:_switchToPet()
	end
end

function ProductInformationComponent:_refreshJumpWidget()
	local isPetView = self._showingPetView or false
	local fashion = ClientCashShopUtils.getFashionByCommodityId(self._curCommodityId, isPetView) or 0
	local avatarType = self._curAvatarType
	local isAccessoryPackage = self:isAccessoryPackageCommodity()

	if NotNil(self.btnChangePet) then
		self.btnChangePet.gameObject:SetActiveEx(isPetView)
	end

	if NotNil(self.petSwitchBtnUButton) then
		self.petSwitchBtnUButton.gameObject:SetActiveEx(isAccessoryPackage and isPetView)
	end

	if fashion == 0 then
		if NotNil(self.jumpUWidget) then
			self.jumpUWidget:SetActive(false)
		end

		if NotNil(self.fashionUImage) then
			self.fashionUImage.gameObject:SetActiveEx(false)
		end

		if NotNil(self.txtDescNum) then
			self.txtDescNum.gameObject:SetActiveEx(false)
		end
	else
		if NotNil(self.fashionUImage) then
			self.fashionUImage.gameObject:SetActiveEx(true)
		end

		if NotNil(self.txtDescNum) then
			self.txtDescNum.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(self.txtDescNum, fashion)
		end

		if NotNil(self.jumpUWidget) then
			self.jumpUWidget:SetActive(not isAccessoryPackage and not ClientCashShopUtils.isSuitType(avatarType))
		end
	end
end

function ProductInformationComponent:setPreviewTarget(target)
	local previewTarget = CashShopConst.AccessoryPreviewTarget

	self._showingPetView = target == previewTarget.PET
	self._previewTarget = target

	if self:isAccessoryPackageCommodity() then
		self:setTabWidgetVisible(not self._tabWidgetForceHidden and target ~= previewTarget.FURNITURE)
	end

	if target ~= nil then
		self.rootUComponent:TryChangePage("Switch", target)
	end

	if self._showingPetView then
		local avatarComponent = self.ctrl and self.ctrl.ctrl and self.ctrl.ctrl.avatarComponent

		if avatarComponent then
			self:refreshPetIcon(avatarComponent.curPetId)
		end
	end

	self:_refreshJumpWidget()
end

function ProductInformationComponent:refreshPetIcon(petId)
	if not self.imgPet and not self.petUImage then
		return
	end

	if not petId then
		if self.imgPet then
			self.imgPet.url = ""
		end

		if self.petUImage then
			self.petUImage.url = ""
		end

		return
	end

	local pInfo = pg.me and pg.me:getPetInfo(petId)

	if not pInfo then
		return
	end

	if self.imgPet then
		local configData = PetResearchUtils.getPetResearchContent(pInfo.templateId)

		self.imgPet.url = configData and configData.bigIcon or ""
	end

	if self.petUImage then
		local petData = PetData[pInfo.templateId]

		self.petUImage.url = petData and LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, pInfo.label, pInfo.gender) or ""
	end
end

function ProductInformationComponent:_refreshTabWidget(commodityInfo, visible)
	local avatarType = tonumber(commodityInfo and commodityInfo.avatarType)
	local commodityAvatarType = CashShopConst.CommodityAvatarType

	self._tabWidgetForceHidden = visible == false
	visible = not self._tabWidgetForceHidden and (visible == true or avatarType == commodityAvatarType.ACCESSORY_PACKAGE)

	self:setTabWidgetVisible(visible)

	if not visible then
		self:setPreviewTarget(nil)
	elseif avatarType == commodityAvatarType.ACCESSORY_PACKAGE then
		self:setPreviewTarget(nil)
	else
		self:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PLAYER)
	end
end

function ProductInformationComponent:setTabWidgetVisible(visible)
	self._tabWidgetVisible = visible == true

	if self.tabUWidget then
		self.tabUWidget.gameObject:SetActiveEx(visible)
	end
end

function ProductInformationComponent:isTabWidgetVisible()
	return self._tabWidgetVisible == true
end

function ProductInformationComponent:_onConfirmToBuy()
	if not self._curCommodityId then
		return
	end

	local BtnState = CashShopConst.BtnState

	if self._curBtnState == BtnState.LOCKED or self._curBtnState == BtnState.SOLD_OUT or self._curBtnState == BtnState.PURCHASED then
		return
	end

	local commodityInfo = ClientCashShopUtils.getCommodityData(self._curCommodityId)
	local targetGender = ClientCashShopUtils.getPlayerGender()

	if commodityInfo and not ClientCashShopUtils.isItemMatchGender(commodityInfo.itemId, targetGender) then
		pg.global.showBubbleMessageById(NoticeDef.CASH_BUY_GENDER_ERROR)

		return
	end

	ClientCashShopUtils.openBuyConfirm(self._curCommodityId, self._curCost, 1)
end

function ProductInformationComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ProductInformationComponent
