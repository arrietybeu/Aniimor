-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\Common\\RightInfoComponent.lua

local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local AppearancePurchaseUtils = require("Utils.AppearancePurchaseUtils")
local AppearanceFunctionData = require("Data.appearance_function_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local RightInfoComponent = Class.LightClass("RightInfoComponent", UIComponent)

RightInfoComponent.DETAIL_PAGE_INDEX = {
	source = 1,
	setting = 0,
	buy = 2
}
RightInfoComponent.BTN_TYPE_PAGE_INDEX = {
	accessory = 1,
	normal = 0,
	none = 3,
	accessoryAdjust = 2
}
RightInfoComponent.TAB_PAGE_INDEX = {
	set = 2,
	info = 1
}
RightInfoComponent.INFO_KIND = {
	HAIR = 3,
	ACCESSORY = 2,
	CLOTH = 1
}

function RightInfoComponent:onCtor()
	self.itemId = nil
	self.extra = nil
	self.itemIdHolder = nil
	self.refreshCallback = nil
	self.tabGroup = {}
	self.selectedPage = 1
	self.avatarScene = self.ctrl.avatarScene
	self.presetKey = self.ctrl.curPresetKey
end

function RightInfoComponent:findObjects()
	return
end

function RightInfoComponent:initView()
	return
end

function RightInfoComponent:setupButtonTexts(btnPresetUButton, btnDesignUButton, btnColorfulUButton, btnAdjustUButton, btnBuyUButton)
	local objectReference1, txtNameUText

	objectReference1 = btnPresetUButton:GetComponent("ObjectReference")
	txtNameUText = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("APPEARANCE_PRESET"))

	objectReference1 = btnDesignUButton:GetComponent("ObjectReference")
	txtNameUText = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("APPEARANCE_WORK_SHOP"))

	objectReference1 = btnColorfulUButton:GetComponent("ObjectReference")
	txtNameUText = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("COLORFUL"))

	objectReference1 = btnAdjustUButton:GetComponent("ObjectReference")
	txtNameUText = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("ACCESSORY_ADJUST"))

	btnBuyUButton.luaClick = nil
	objectReference1 = btnBuyUButton:GetComponent("ObjectReference")
	txtNameUText = objectReference1:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("SHOP_BUY"))
end

function RightInfoComponent:setBtnGroupPage(newCmp, detailPage, btnTypePage)
	if detailPage == RightInfoComponent.DETAIL_PAGE_INDEX.setting then
		if btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.normal then
			newCmp:TryChangePage("BtnGroup", 0)
		elseif btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.accessory then
			newCmp:TryChangePage("BtnGroup", 1)
		elseif btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.accessoryAdjust then
			newCmp:TryChangePage("BtnGroup", 2)
		else
			newCmp:TryChangePage("BtnGroup", 5)
		end
	elseif detailPage == RightInfoComponent.DETAIL_PAGE_INDEX.source then
		if btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.normal then
			newCmp:TryChangePage("BtnGroup", 0)
		elseif btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.accessory then
			newCmp:TryChangePage("BtnGroup", 1)
		elseif btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.accessoryAdjust then
			newCmp:TryChangePage("BtnGroup", 2)
		else
			newCmp:TryChangePage("BtnGroup", 5)
		end
	else
		newCmp:TryChangePage("BtnGroup", 3)
	end
end

function RightInfoComponent:setupTextInfo(itemName, fashionValue, itemDesc, extra)
	if not extra then
		return
	end

	if extra.name then
		ClientTextUtils.setText(itemName, extra.name)
	end

	if extra.fashion then
		ClientTextUtils.setText(fashionValue, extra.fashion)
	end

	if extra.desc then
		ClientTextUtils.setText(itemDesc, extra.desc)
	end
end

function RightInfoComponent:setupBuyButton(btnBuyUButton)
	local canPurchase = AppearancePurchaseUtils.CanPurchase(self.itemId)

	if not canPurchase then
		return false
	end

	local purchaseInfo = AppearancePurchaseUtils.GetPurchaseInfo(self.itemId)

	if not purchaseInfo then
		return false
	end

	function btnBuyUButton.luaClick()
		self:onBuyButtonClick(purchaseInfo)
	end

	return true
end

function RightInfoComponent:onBuyButtonClick(purchaseInfo)
	local commodityId = purchaseInfo.commodityId
	local rewardItems = AppearancePurchaseUtils.GetPurchaseRewardItems(self.itemId)

	if not rewardItems or #rewardItems == 0 then
		return
	end

	local requiredItems = AppearancePurchaseUtils.GetRequiredItems(self.itemId)

	if not requiredItems or #requiredItems == 0 then
		return
	end

	local mainCost = requiredItems[1]
	local costItemId = mainCost.itemId
	local costCount = mainCost.count
	local ownNum = ClientUtils.getItemCountById(costItemId)
	local costCountText = LuaUIUtils.formatStyledItemNum(nil, costCount, nil, ownNum < costCount)
	local tipFormat = string.gsub(pg.getGameString("APPEARANCE_DIRECT_BUY"), "%%d", "%%s", 1)
	local tipTop = string.format(tipFormat, costItemId, costCountText)

	pg.global.ui.commonUseConfirm:open({
		type = 1,
		muteCheckEnough = true,
		hideCurrency = false,
		title = pg.getGameString("SHOP_BUY"),
		tipTop = tipTop,
		data = rewardItems,
		costId = costItemId,
		confirmCb = function()
			self:doPurchase(commodityId)
		end,
		cancelCb = function()
			pg.global.ui.commonUseConfirm:close()
		end,
		notEnoughCallback = function()
			pg.global.ui.tips:showTextTip(pg.getGameString("APPEARANCE_PAY_FAIL"))
		end
	})
end

function RightInfoComponent:doPurchase(commodityId)
	pg.me:serverMsg("RPC_CS_ShopMallBuyCommodity", commodityId, 1, {}, function(retStatus, _)
		if retStatus == 0 then
			if self.refreshCallback then
				self.refreshCallback()
			end
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_BUY_FAIL"))
		end
	end)
	pg.global.ui.commonUseConfirm:close()
end

function RightInfoComponent:setupRequiredItemsList(btnBuyUButton)
	local requiredItems = AppearancePurchaseUtils.GetRequiredItems(self.itemId)

	if not requiredItems then
		return
	end

	local objectReference2 = btnBuyUButton:GetComponent("ObjectReference")
	local listUList = objectReference2:GetRefValue("listUList")

	function listUList.luaRenderItem(button, _, data)
		local objectReference3 = button:GetComponent("ObjectReference")
		local imgIcon = objectReference3:GetRefValue("imgIcon")
		local txtNum = objectReference3:GetRefValue("txtNum")
		local btnClick = objectReference3:GetRefValue("btnClick")

		imgIcon.url = LuaUIUtils.getIconByItemId(data.itemId)

		local ownNum = ClientUtils.getItemCountById(data.itemId)

		ClientTextUtils.setText(txtNum, LuaUIUtils.formatStyledItemNum(nil, data.count, nil, ownNum < data.count))

		btnClick.enabledTooltip = false

		function btnClick.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.itemId,
				targetRect = btnClick
			})
		end
	end

	listUList:SetList(requiredItems)
end

function RightInfoComponent:selectSingleTab(newCmp)
	if not self.selectedPage then
		return
	end

	if not self.tabGroup or #self.tabGroup <= 0 then
		return
	end

	if self.selectedPage <= 0 or self.selectedPage > #self.tabGroup then
		return
	end

	for page, tabBtn in pairs(self.tabGroup) do
		if page == self.selectedPage then
			tabBtn.isSelected = true
		else
			tabBtn.isSelected = false
		end
	end

	newCmp:TryChangePage("State", self.selectedPage - 1)
end

function RightInfoComponent:setTabBtnsEvent(newCmp)
	if not self.selectedPage then
		return
	end

	if not self.tabGroup or #self.tabGroup <= 0 then
		return
	end

	if self.selectedPage <= 0 or self.selectedPage > #self.tabGroup then
		if self.selectedPage > #self.tabGroup then
			self.tabGroup[RightInfoComponent.TAB_PAGE_INDEX.info].luaClick()
		end

		return
	end

	for page, tabBtn in pairs(self.tabGroup) do
		function tabBtn.luaClick()
			self.selectedPage = page

			self:selectSingleTab(newCmp)
		end
	end

	self.tabGroup[self.selectedPage].luaClick()
end

function RightInfoComponent:isClothesPartInSuit(itemId)
	local AppearanceData = require("Data.appearance_data")
	local config = AppearanceData[itemId]

	if not config or config.type ~= 2 then
		return false
	end

	return config.suit ~= nil
end

function RightInfoComponent:dealPassedControllers(detailPage, btnTypePage, newCmp, rolePanelObjectReference, extra)
	if extra and extra.id then
		self.itemId = extra.id
		self.extra = extra
	else
		self.itemIdHolder = self.itemId
	end

	if extra and extra.refreshCallback then
		self.refreshCallback = extra.refreshCallback
	end

	local rightTransform = rolePanelObjectReference:GetRefValue("rightTransform")
	local rightTransformObjectReference = rightTransform:GetComponent("ObjectReference")
	local presetUButton = rolePanelObjectReference:GetRefValue("presetUButton")
	local workshopUButton = rightTransformObjectReference:GetRefValue("workshopUButton")
	local colorAccessoryUButton = rightTransformObjectReference:GetRefValue("colorAccessoryUButton")
	local designUButton = rightTransformObjectReference:GetRefValue("designUButton")
	local objectReference = newCmp:GetComponent("ObjectReference")
	local btnPresetUButton = objectReference:GetRefValue("btnPresetUButton")
	local btnDesignUButton = objectReference:GetRefValue("btnDesignUButton")
	local btnColorfulUButton = objectReference:GetRefValue("btnColorfulUButton")
	local btnAdjustUButton = objectReference:GetRefValue("btnAdjustUButton")
	local btnBuyUButton = objectReference:GetRefValue("btnBuyUButton")
	local itemName = objectReference:GetRefValue("itemName")
	local fashionValue = objectReference:GetRefValue("fashionValue")
	local itemDesc = objectReference:GetRefValue("itemDesc")
	local listUList = objectReference:GetRefValue("listUList")
	local tab01UButton = objectReference:GetRefValue("tab01UButton")
	local tab02UButton = objectReference:GetRefValue("tab02UButton")
	local tab03UButton = objectReference:GetRefValue("tab03UButton")
	local setUList = objectReference:GetRefValue("sourceListUList")
	local btnFashionValueIconUButton = objectReference:GetRefValue("btnFashionValueIconUButton")

	if extra and extra.fashion then
		function btnFashionValueIconUButton.luaRenderTooltip(_, prop)
			self.view:renderFashionTips(prop, extra.fashion)
		end
	else
		btnFashionValueIconUButton.luaRenderTooltip = nil
	end

	tab03UButton.gameObject:SetActiveEx(false)

	self.isClothesSuit = AppearancePurchaseUtils.isItemClothesSuit(self.itemId)
	self.isClothesPart = self:isClothesPartInSuit(self.itemId)

	if self.isClothesSuit or self.isClothesPart then
		tab02UButton.gameObject:SetActiveEx(true)

		self.tabGroup = {
			tab01UButton,
			tab02UButton
		}

		self:renderSetList(setUList, self.itemId, newCmp)
		newCmp:TryChangePage("Tab", 1)
		tab01UButton:TryChangePage("Bg", 0)
		tab02UButton:TryChangePage("Bg", 2)
	else
		self.tabGroup = {
			tab01UButton
		}

		tab02UButton.gameObject:SetActiveEx(false)
		newCmp:TryChangePage("Tab", 0)
	end

	self:setTabBtnsEvent(newCmp)

	btnPresetUButton.luaClick = presetUButton.luaClick
	btnDesignUButton.luaClick = workshopUButton.luaClick
	btnColorfulUButton.luaClick = colorAccessoryUButton.luaClick
	btnAdjustUButton.luaClick = designUButton.luaClick

	self:setupButtonTexts(btnPresetUButton, btnDesignUButton, btnColorfulUButton, btnAdjustUButton, btnBuyUButton)
	self:setBtnGroupPage(newCmp, detailPage, btnTypePage)
	self:setupTextInfo(itemName, fashionValue, itemDesc, extra)
	self:refreshAffinityPrivilegeSection(objectReference, self.itemId)

	if extra and not extra.claimed or self.itemId == self.itemIdHolder and self.extra and not self.extra.claimed then
		newCmp:TryChangePage("BtnState", 0)

		local canSetupBuy = self:setupBuyButton(btnBuyUButton)

		if canSetupBuy then
			if detailPage == RightInfoComponent.DETAIL_PAGE_INDEX.source and btnTypePage == RightInfoComponent.BTN_TYPE_PAGE_INDEX.accessoryAdjust then
				newCmp:TryChangePage("BtnGroup", 4)
			else
				newCmp:TryChangePage("BtnGroup", 3)
			end

			self:setupRequiredItemsList(btnBuyUButton)
		else
			local sourceData = AppearancePurchaseUtils.getItemSourceData(self.itemId)

			if sourceData and #sourceData > 0 then
				newCmp:TryChangePage("BtnState", 2)
				AppearancePurchaseUtils.renderAppearanceItemSourceList(listUList, sourceData)
			end
		end
	elseif extra then
		newCmp:TryChangePage("BtnState", 0)
	end
end

function RightInfoComponent:refreshAffinityPrivilegeSection(objectReference, itemId)
	local foarregelfaasjeTransform = objectReference:GetRefValue("foarregelfaasjeTransform")

	if not foarregelfaasjeTransform then
		return
	end

	local show = AppearancePurchaseUtils.isItemClothesSuit(itemId) and AppearanceFunctionData[itemId] ~= nil and AppearanceFunctionData[itemId].suitPowerType and LuaUIUtils.tableContains(AppearanceFunctionData[itemId].suitPowerType, 4)

	foarregelfaasjeTransform.gameObject:SetActiveEx(show)

	if not show then
		return
	end

	local foarregelfaasjeObjectReference = foarregelfaasjeTransform:GetComponent("ObjectReference")
	local titleUSDFText = foarregelfaasjeObjectReference:GetRefValue("titleUSDFText")
	local affinityListUList = foarregelfaasjeObjectReference:GetRefValue("listUList")

	ClientTextUtils.setText(titleUSDFText, pg.getGameString("APPEARANCE_PLAYER_PET_PRIVILEGE"))

	local affinityList = {}
	local functionData = AppearanceFunctionData[itemId]
	local affinityIds = functionData and functionData.Affinity

	if Utils.isTable(affinityIds) then
		for _, entryId in ipairs(affinityIds) do
			affinityList[#affinityList + 1] = {
				entryId = entryId
			}
		end
	end

	function affinityListUList.luaRenderItem(button, _, data)
		local entry = AttributeEntryData[data.entryId]
		local desc = ""

		if entry and entry.desc then
			desc = pg.getLocalizationText(entry.desc)
		end

		button.enabledTooltip = true

		function button.luaRenderTooltip(_, tooltip)
			if not tooltip then
				return
			end

			tooltip:TryChangePage("headTitle", 0)
			tooltip:TryChangePage("Btn", 0)

			local tooltipObjectReference = tooltip:GetComponent("ObjectReference")
			local txtDesc = tooltipObjectReference:GetRefValue("txtDesc")

			ClientTextUtils.setText(txtDesc, desc)
		end

		function button.luaClick()
			button:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)
		end
	end

	affinityListUList:SetList(affinityList)
end

function RightInfoComponent:forceRenderSetList(newCmp)
	if not self.itemId then
		return
	end

	local objectReference = newCmp:GetComponent("ObjectReference")
	local setUList = objectReference:GetRefValue("sourceListUList")

	self:renderSetList(setUList, self.itemId, newCmp)
end

function RightInfoComponent:renderSetList(list, itemId, newCmp)
	local AppearanceData = require("Data.appearance_data")
	local AppearanceSuitData = require("Data.appearance_suit_data")
	local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
	local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
	local sets = {}
	local clothesSuitId, hairSuitId
	local entity = self.avatarScene:getCurEntity()

	if AppearancePurchaseUtils.isItemClothesSuit(itemId) then
		clothesSuitId = itemId

		local suitInfo = AppearanceSuitData[itemId]

		if suitInfo and suitInfo.hair then
			hairSuitId = suitInfo.hair
		end
	elseif AppearancePurchaseUtils.isItemHairSuit(itemId) then
		hairSuitId = itemId

		for suitId, suitInfo in pairs(AppearanceSuitData) do
			if suitInfo.hair == itemId then
				clothesSuitId = suitId

				break
			end
		end
	elseif AppearanceData[itemId] then
		local appearanceInfo = AppearanceData[itemId]

		if appearanceInfo.type == 2 and appearanceInfo.suit then
			clothesSuitId = appearanceInfo.suit

			local suitInfo = AppearanceSuitData[clothesSuitId]

			if suitInfo and suitInfo.hair then
				hairSuitId = suitInfo.hair
			end
		elseif appearanceInfo.type == 3 and appearanceInfo.hairId then
			hairSuitId = appearanceInfo.hairId

			for suitId, suitInfo in pairs(AppearanceSuitData) do
				if suitInfo.hair == hairSuitId then
					clothesSuitId = suitId

					break
				end
			end
		end
	elseif AppearanceJewelryPetData[itemId] then
		for suitId, suitInfo in pairs(AppearanceSuitData) do
			if suitInfo.jewelryList then
				for _, jewelryId in ipairs(suitInfo.jewelryList) do
					if jewelryId == itemId then
						clothesSuitId = suitId

						if suitInfo.hair then
							hairSuitId = suitInfo.hair
						end

						break
					end
				end
			end

			if clothesSuitId then
				break
			end
		end
	end

	local clothes = {}

	if clothesSuitId then
		local suitInfo = AppearanceSuitData[clothesSuitId]

		if suitInfo and suitInfo.appearanceList then
			for _, appearanceId in ipairs(suitInfo.appearanceList) do
				table.insert(clothes, {
					itemId = appearanceId,
					resId = AppearanceData[appearanceId] and AppearanceData[appearanceId].res or nil,
					kind = RightInfoComponent.INFO_KIND.CLOTH
				})
			end
		end
	end

	if #clothes > 0 then
		table.insert(sets, {
			title = pg.getGameString("APPEARANCE_CLOTHES"),
			data = clothes
		})
	end

	local accessories = {}

	if clothesSuitId then
		local suitInfo = AppearanceSuitData[clothesSuitId]

		if suitInfo and suitInfo.jewelryList then
			for _, jewelryId in ipairs(suitInfo.jewelryList) do
				table.insert(accessories, {
					itemId = jewelryId,
					resId = AppearanceData[jewelryId] and AppearanceData[jewelryId].res or nil,
					kind = RightInfoComponent.INFO_KIND.ACCESSORY
				})
			end
		end
	end

	if #accessories > 0 then
		table.insert(sets, {
			title = pg.getGameString("APPEARANCE_ACCESSORY"),
			data = accessories
		})
	end

	local hairs = {}

	if hairSuitId then
		local hairSuitInfo = AvatarHairSuitData[hairSuitId]

		if hairSuitInfo and hairSuitInfo.appearanceList then
			for _, hairPartId in ipairs(hairSuitInfo.appearanceList) do
				table.insert(hairs, {
					itemId = hairPartId,
					resId = AppearanceData[hairPartId] and AppearanceData[hairPartId].res or nil,
					kind = RightInfoComponent.INFO_KIND.HAIR
				})
			end
		end
	end

	if #hairs > 0 then
		table.insert(sets, {
			title = pg.getGameString("APPEARANCE_HAIR"),
			data = hairs
		})
	end

	function list.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.title)

		function listUList.luaRenderItem(b, _, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local itemIconUImage = objectReference1:GetRefValue("itemIconUImage")
			local txtNumUText = objectReference1:GetRefValue("txtNumUText")
			local imgBatchUImage = objectReference1:GetRefValue("imgBatchUImage")

			ClientTextUtils.setText(txtNumUText, "")

			itemIconUImage.url = LuaUIUtils.getIconByItemId(d.itemId)

			local itemConfig = ItemData[d.itemId]

			if itemConfig then
				b:TryChangePage("Quality", itemConfig.quality or 0)
			end

			local appearanceConfig = AppearanceData[d.itemId]
			local jewelryConfig = AppearanceJewelryPetData[d.itemId]

			if appearanceConfig and appearanceConfig.type == 1 or jewelryConfig then
				imgBatchUImage.gameObject:SetActiveEx(self:checkAccessoryExists(entity, d.itemId))
			else
				imgBatchUImage.gameObject:SetActiveEx(self.avatarScene:checkPartItemExists(entity, d.resId))
			end

			if self.isClothesSuit then
				b.enabledLongPress = false
				b.luaLongPress = nil
				b.luaPress = nil
				b.luaBeginLongPress = nil

				function b.luaClick()
					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						id = d.itemId,
						targetRect = b
					})
				end
			else
				b.enabledLongPress = true
				b.luaLongPress = nil

				local longPressFired = false

				function b.luaPress()
					longPressFired = false
				end

				function b.luaBeginLongPress()
					longPressFired = true

					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						id = d.itemId,
						targetRect = b
					})
				end

				function b.luaClick()
					if longPressFired then
						longPressFired = false

						return
					end

					self:handleItemWearOrPreview(d.itemId, d.resId)
					self:forceRenderSetList(newCmp)
				end
			end
		end

		listUList:SetList(data.data)
	end

	list:SetList(sets)
end

function RightInfoComponent:isHairBodyPart(itemId)
	local AppearanceData = require("Data.appearance_data")
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local config = AppearanceData[itemId]

	if not config or config.type ~= 3 then
		return false
	end

	if not config.points or #config.points == 0 then
		return false
	end

	return config.points[1] == AppearancePointEnum.Body
end

function RightInfoComponent:hasOtherHairPartsEquipped(entity)
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local otherHairPartSlots = {
		AppearancePointEnum.Fringe,
		AppearancePointEnum.Temples,
		AppearancePointEnum.Tail,
		AppearancePointEnum.Plait
	}

	for _, slotId in ipairs(otherHairPartSlots) do
		local configId = entity:getAppearanceConfigId(slotId, true)

		if configId and configId ~= 0 then
			return true
		end
	end

	return false
end

function RightInfoComponent:handleItemWearOrPreview(itemId, resId)
	if not itemId then
		return
	end

	require("Guis.Utils.AvatarUtils").cancelHairTie()

	local AppearanceData = require("Data.appearance_data")
	local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local isClaimed = pg.me.appearanceInfo[itemId] ~= nil
	local appearanceConfig = AppearanceData[itemId]
	local jewelryConfig = AppearanceJewelryPetData[itemId]
	local ignoreSelectFirst = true

	if appearanceConfig then
		local appearanceType = appearanceConfig.type

		if appearanceType == 1 then
			self:handleJewelryWearOrPreview(entity, itemId, isClaimed)
		elseif appearanceType == 2 then
			self:handleClothesWearOrPreview(entity, itemId, isClaimed, appearanceConfig, function()
				self.ctrl:refreshPage(ignoreSelectFirst, itemId)
			end)

			return
		elseif appearanceType == 3 then
			local isEquipped = self.avatarScene:checkPartItemExists(entity, resId)

			if isEquipped and self:isHairBodyPart(itemId) and self:hasOtherHairPartsEquipped(entity) then
				pg.global.ui.tips:showTextTip(pg.getGameString("APPEARANCE_HAIR_BODY_CANNOT_UNEQUIP"))

				return
			end

			self:handleHairWearOrPreview(entity, itemId, isClaimed, appearanceConfig)
		end
	elseif jewelryConfig then
		self:handleJewelryWearOrPreview(entity, itemId, isClaimed)
	end

	self.ctrl:refreshPage(ignoreSelectFirst, itemId)
end

function RightInfoComponent:handleClothesWearOrPreview(entity, itemId, isClaimed, config, onComplete)
	if not config or not config.points or #config.points == 0 then
		if onComplete then
			onComplete()
		end

		return
	end

	local AvatarUtils = require("Guis.Utils.AvatarUtils")
	local AppearanceData = require("Data.appearance_data")
	local slotId = LuaUIUtils.getClothesPrimarySlot(itemId) or config.points[1]
	local isPreview = not isClaimed

	local function finishWear(didChange)
		if didChange then
			self:refreshClothes(entity, isPreview)
		end

		if onComplete then
			onComplete()
		end
	end

	local curClothesId = self.avatarScene:getCurClothesId(self.presetKey, slotId)

	if curClothesId == itemId then
		if isPreview then
			local data = AppearanceData[itemId] or {}

			if data.points then
				for _, point in ipairs(data.points) do
					entity:cancelCustomShowPreview(point)
				end
			end
		else
			entity:setCustomShow(itemId, false)
		end

		finishWear(true)
	elseif isPreview then
		entity:setCustomShowPreview(itemId, true)
		finishWear(true)
	else
		AvatarUtils.tryEquipClothesWithConflictConfirm(entity, itemId, false, function()
			local data = AppearanceData[itemId] or {}

			if data.points then
				for _, point in ipairs(data.points) do
					entity:cancelCustomShowPreview(point)
				end
			end

			entity:setCustomShow(itemId, true)
			finishWear(true)
		end)
	end
end

function RightInfoComponent:refreshClothes(entity, isPreview)
	local AppearanceData = require("Data.appearance_data")
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId, true, true)
		local data = AppearanceData[clothesId]

		ClientModelUtils.applyAppearancePart(entity, partId, clothesId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:applyClothesStainForEntity(entity, isPreview)
end

function RightInfoComponent:applyClothesStainForEntity(entity, isPreview)
	local ClientModelUtils = require("Utils.ClientModelUtils")
	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	if entity.previewOutfitId then
		ClientModelUtils.applyOutfitClothesStain(entity, entity.previewOutfitId)
	elseif isPreview and entity.customShowPreview and next(entity.customShowPreview) then
		AvatarUtils.applyEquippedClothesStain(entity, true, true)
	else
		ClientModelUtils.applyClothesStainInfo(entity, entity.curShow)
	end
end

function RightInfoComponent:handleHairWearOrPreview(entity, itemId, isClaimed, config)
	if not config or not config.points or #config.points == 0 then
		return
	end

	if not config.hairId then
		return
	end

	local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
	local CallbackHandler = require("Core.Common.CallbackHandler")
	local hairSuitId = config.hairId
	local hairSuitConfig = AvatarHairSuitData[hairSuitId]

	if not hairSuitConfig then
		return
	end

	local slotId = config.points[1]
	local isPreview = not isClaimed
	local curHairSuitId = self.avatarScene:getCurHairSuitId(self.presetKey)
	local modifyCurrentHairSuit = curHairSuitId == hairSuitId
	local currentConfigId = entity:getAppearanceConfigId(slotId, true, true)
	local isEquipped = currentConfigId == itemId

	if not modifyCurrentHairSuit then
		self:equipHairSuit(entity, hairSuitId, isPreview)
	end

	local restoredWorldHair = false

	if isEquipped then
		if self:isHairBodyPart(itemId) then
			self.ctrl.model:clearCacheHairSuitId()

			restoredWorldHair = self:unEquipHairSuit(entity, hairSuitId)
		else
			self:unEquipHair(entity, itemId, slotId, isPreview)
		end
	else
		self:equipHair(entity, itemId, slotId, isPreview)
	end

	if restoredWorldHair then
		function entity.modelPartModelAllLoaded()
			if entity.applyPlayerHairCustomData then
				entity:applyPlayerHairCustomData()
			end

			entity.modelPartModelAllLoaded = nil
		end

		self:refreshHair(entity, false)
	else
		self:refreshHair(entity, isPreview)
	end

	if modifyCurrentHairSuit then
		return
	end

	if not isPreview then
		local AvatarUtils = require("Guis.Utils.AvatarUtils")

		AvatarUtils.applyHairPresetOrRuntimeDefault(hairSuitId, CallbackHandler(self, "refreshHairByCustom"))
	end
end

function RightInfoComponent:unEquipHair(entity, configId, slotId, isPreview)
	if isPreview then
		entity:cancelCustomShowPreview(slotId)
	else
		entity:cancelCustomShowPreview(slotId)
		entity:setCustomShow(configId, false, slotId)
	end
end

function RightInfoComponent:unEquipHairSuit(entity, hairSuitId)
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
	local worldCustomShow = pg.me.curShow and pg.me.curShow.customShow or {}
	local worldHairSuitId = LuaUIUtils.tryGetHairSuitId(worldCustomShow)

	if hairSuitId and worldHairSuitId and hairSuitId == worldHairSuitId then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)

			local configId = entity:getAppearanceConfigId(partId)

			if configId and configId ~= 0 then
				entity:setCustomShow(configId, false, partId)
			end
		end

		return false
	end

	local hairSuitInfo = worldHairSuitId and AvatarHairSuitData[worldHairSuitId] or {}

	if hairSuitInfo.assetId then
		pg.global.avatarMgr.avatarHair:OnHairSuitChanged(nil, hairSuitInfo.assetId)
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity:cancelCustomShowPreview(partId)
		entity:cancelCustomShow(partId, true)

		local worldConfigId = worldCustomShow[partId]

		if worldConfigId and worldConfigId ~= 0 then
			entity:setCustomShow(worldConfigId, true, partId)
		end
	end

	if entity.curShow and pg.me.curShow then
		if not entity.curShow.customShow then
			entity.curShow.customShow = {}
		end

		if not entity.curShow.hairInfo then
			entity.curShow.hairInfo = {}
		end

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity.curShow.customShow[partId] = worldCustomShow[partId]

			if pg.me.curShow.hairInfo then
				entity.curShow.hairInfo[partId] = pg.me.curShow.hairInfo[partId]
			end
		end
	end

	return true
end

function RightInfoComponent:equipHairSuit(entity, suitId, isPreview)
	local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local modelInfo = entity.eModel.modelModelView.modelInfo
	local oldAssetId = modelInfo:GetOriginHairAssetId()
	local modelSuitId = self.avatarScene:getCurHairSuitId(self.presetKey)
	local modelSuitInfo = modelSuitId and AvatarHairSuitData[modelSuitId] or nil
	local currentAssetId = modelSuitInfo and modelSuitInfo.assetId
	local partItems = LuaUIUtils.getAllPartInSuit(suitId, oldAssetId, currentAssetId)
	local hairSuitInfo = AvatarHairSuitData[suitId] or {}
	local newAssetId = hairSuitInfo.assetId

	if newAssetId then
		pg.global.avatarMgr.avatarHair:OnHairSuitChanged(nil, newAssetId)
	end

	if isPreview then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShowPreview(newConfigId, true, partId)
			end
		end
	else
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)
			entity:cancelCustomShow(partId, true)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShow(newConfigId, true, partId)
			end
		end
	end
end

function RightInfoComponent:equipHair(entity, configId, slotId, isPreview)
	if isPreview then
		entity:setCustomShowPreview(configId, true, slotId)
	else
		entity:cancelCustomShowPreview(slotId)
		entity:setCustomShow(configId, true, slotId)
	end
end

function RightInfoComponent:refreshHairByCustom()
	local AvatarUtils = require("Guis.Utils.AvatarUtils")

	AvatarUtils.refreshHairByCustom()
end

function RightInfoComponent:refreshHair(entity, isPreview)
	local AppearanceData = require("Data.appearance_data")
	local AppearancePointEnum = require("Data.appearance_point_enum")

	require("Guis.Utils.AvatarUtils").cancelHairTie()

	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = entity:getAppearanceConfigId(partId, isPreview)
		local data = AppearanceData[configId]

		ClientModelUtils.applyAppearancePart(entity, partId, configId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function RightInfoComponent:handleJewelryWearOrPreview(entity, itemId, isClaimed)
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local isPreview = not isClaimed
	local isEquipped, equippedSlotId = self:isAccessoryEquipped(entity, itemId)

	if isEquipped then
		self:unEquipAccessory(entity, equippedSlotId, itemId, isPreview)

		return
	end

	local targetSlotId

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if not LuaUIUtils.isAppearancePointHidden(slotId) then
			local currentJewelryId = entity:getAppearanceConfigId(slotId)
			local unlocked = pg.me.curShow.customShow[slotId] ~= nil

			if (not currentJewelryId or currentJewelryId == 0) and unlocked then
				targetSlotId = slotId

				break
			end
		end
	end

	if not targetSlotId then
		for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			if not LuaUIUtils.isAppearancePointHidden(slotId) then
				targetSlotId = slotId

				break
			end
		end
	end

	if targetSlotId then
		if isPreview then
			entity:setCustomShowPreview(itemId, true, targetSlotId)
		else
			entity:cancelCustomShowPreview(targetSlotId)
			entity:setCustomShow(itemId, true, targetSlotId)
		end

		self:refreshAccessory(entity)
		entity:refreshAppearanceFunction()
	end
end

function RightInfoComponent:isAccessoryEquipped(entity, accessoryId)
	local AppearancePointEnum = require("Data.appearance_point_enum")

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local id = entity:getAppearanceConfigId(slotId, true, true)

		if id == accessoryId then
			return true, slotId
		end
	end

	return false
end

function RightInfoComponent:unEquipAccessory(entity, slotId, accessoryId, isPreview)
	if isPreview then
		entity:cancelCustomShowPreview(slotId)
	else
		entity:setCustomShow(accessoryId, false, slotId)
	end

	self:refreshAccessory(entity)
end

function RightInfoComponent:refreshAccessory(entity)
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:RemoveAllAttach()

	local attachList = {}

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId = entity:getAppearanceConfigId(partId, true, true)
		local reactionKey = ClientModelUtils.selectAppearanceAccessory(entity, partId, accessoryId)

		if accessoryId and accessoryId ~= 0 then
			attachList[#attachList + 1] = {
				accessoryId = accessoryId,
				reactionKey = reactionKey
			}
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)

	for _, attachInfo in ipairs(attachList) do
		self:refreshAttachByServer(attachInfo.accessoryId, attachInfo.reactionKey)
	end
end

function RightInfoComponent:refreshAttachByServer(accessoryId, reactionKey)
	local AppearanceJewelryInfo = require("CustomTypes.AppearanceJewelryInfo")
	local ColorJewelryData = require("Data.appearance_color_jewelry_data")
	local avatarMgr = pg.global.avatarMgr
	local lastInfoStr = pg.me.jewelryLastInfos[accessoryId]

	if not reactionKey or not lastInfoStr then
		return
	end

	local jewelryInfo = AppearanceJewelryInfo.new()

	jewelryInfo:toTable(accessoryId, lastInfoStr)

	local overrideResId = jewelryInfo.colorJewelryId == 0 and "" or ColorJewelryData[jewelryInfo.colorJewelryId].res

	avatarMgr.avatarMakeup:RefreshAttachByServer(reactionKey, jewelryInfo, overrideResId)
end

function RightInfoComponent:checkAccessoryExists(entity, itemId)
	if not entity or not itemId then
		return false
	end

	if not entity.getAppearanceConfigId then
		return false
	end

	local AppearancePointEnum = require("Data.appearance_point_enum")

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local configId = entity:getAppearanceConfigId(slotId, true, true)

		if itemId == configId then
			return true
		end
	end

	return false
end

function RightInfoComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return RightInfoComponent
