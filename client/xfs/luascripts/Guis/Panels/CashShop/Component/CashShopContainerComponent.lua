-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\CashShopContainerComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ProductInformationComponent = require("Guis.Panels.CashShop.Component.ProductInformationComponent")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CashShopConst = require("Const.CashShopConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ItemConditionConvertData = require("Data.item_condition_convert_data")
local UIConst = require("Const.UIConst")
local ShopConstantData = require("Data.shopmall_constant_data")
local ShopmallTabData = require("Data.shopmall_tab_data")
local ShopMallAppearance = require("Data.shopmall_appearance")
local ShopMallPetAppearance = require("Data.shopmall_pet_appearance")
local RedDotConst = require("Const.RedDotConst")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CashShopContainerComponent-------------")
local BODY_FEMALE = 11
local BODY_MALE = 21
local CONDITION_FEMALE = 7
local CONDITION_MALE = 6
local CashShopContainerComponent = Class.LightClass("CashShopContainerComponent", UIComponent)

CashShopContainerComponent.messages = {
	[MessageName.MONTH_CARD_ACTIVATE] = {
		"setMonthEventState",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"refreshCommodChangeInfo",
		true
	}
}

function CashShopContainerComponent:ctor(ctrl, refUContainer, categoryType)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self.categoryType = categoryType
	self.categoryId = nil
	self._contentLoaded = false
	self._contentLoading = false
	self._contentLoadToken = 0
	self._contentLoadTimerId = nil
	self._currentGroupId = nil
	self._appliedGroupId = nil
	self._pageApplied = false
	self._usePlayerMirror = false

	function self._onMonthCardActivate(...)
		self:monthCardActivate(...)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onMonthCardActivate)
	self:_startMonthCardExpireTimer()
end

function CashShopContainerComponent:_startMonthCardExpireTimer()
	self:startTimer(function()
		local expireTime = MonthCardUtils.getExpireTime()

		if expireTime <= 0 then
			return
		end

		if expireTime > Time.secondCache then
			self._waitingMonthCardExpire = true
		elseif self._waitingMonthCardExpire then
			self._waitingMonthCardExpire = false

			self:refreshCommodChangeInfo()
		end
	end, 1, true)
end

function CashShopContainerComponent:findObjects()
	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.btnEllipsesUButton = objectReference:GetRefValue("btnEllipsesUButton")
	self.productInformationUComponent = objectReference:GetRefValue("productInformationUComponent")
	self.listGroupTab = objectReference:GetRefValue("listGroupTab")
	self.imgBG = objectReference:GetRefValue("imgBG")
	self.monthlyCard = objectReference:GetRefValue("monthlyCard")

	if self.productInformationUComponent then
		self.productInformation = ProductInformationComponent.new(self, self.productInformationUComponent)
	end
end

function CashShopContainerComponent:addListener()
	if self.productInformation then
		self.productInformation:addListener()
	end

	if self.btnEllipsesUButton then
		self:_setupEllipsesTooltip(self.btnEllipsesUButton)
	end
end

function CashShopContainerComponent:onDestroy()
	self:_cancelContentLoadTimeout()

	self._contentLoadToken = (self._contentLoadToken or 0) + 1
	self._contentLoading = false

	UIComponent.onDestroy(self)

	if self._onMonthCardActivate then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onMonthCardActivate)

		self._onMonthCardActivate = nil
	end

	self.monthEventState = false
	self.refUContainer = nil
end

function CashShopContainerComponent:setMonthEventState()
	self.monthEventState = true
end

function CashShopContainerComponent:monthCardActivate()
	if not self.monthEventState then
		return
	end

	self.monthEventState = false

	local target = self:_getMonthCardInvokeTarget()

	if target then
		target:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function CashShopContainerComponent:_getMonthCardInvokeTarget()
	return self.monthlyCard
end

function CashShopContainerComponent:onEnterPage(tabId)
	self.categoryId = tabId

	self.refUContainer:SetActive(true)
	self:retryPage()
end

function CashShopContainerComponent:retryPage()
	if not self._contentLoaded then
		self:_requestContentLoad()
	else
		self:_setupGroupTabs()
	end
end

function CashShopContainerComponent:onExitPage()
	self:onBeforeExitPage()

	if self.ctrl and self.ctrl.switchCashShopExScene then
		self.ctrl:switchCashShopExScene(nil)
	end

	self.refUContainer:SetActive(false)
end

function CashShopContainerComponent:_cancelContentLoadTimeout()
	if not self._contentLoadTimerId then
		return
	end

	self:killTimer(self._contentLoadTimerId)

	self._contentLoadTimerId = nil
end

function CashShopContainerComponent:_requestContentLoad()
	if self._contentLoaded or self._contentLoading or not self.refUContainer then
		return
	end

	if self.refUContainer:CheckURLLoaded() then
		self:_onContentLoadResult(self._contentLoadToken, true)

		return
	end

	self._contentLoading = true
	self._contentLoadToken = (self._contentLoadToken or 0) + 1

	local loadToken = self._contentLoadToken

	self:_cancelContentLoadTimeout()

	self._contentLoadTimerId = self:startTimer(function()
		if self._contentLoadToken ~= loadToken or self._contentLoaded then
			return
		end

		self._contentLoadTimerId = nil
		self._contentLoading = false
		self._contentLoadToken = self._contentLoadToken + 1

		logger:error("CashShop container load timeout, categoryType=%s, container=%s", tostring(self.categoryType), tostring(self.refUContainer))
	end, 15)

	self.refUContainer:LoadDefaultUrlManually(function(content)
		self:_onContentLoadResult(loadToken, content ~= nil)
	end)
end

function CashShopContainerComponent:_onContentLoadResult(loadToken, success)
	if loadToken ~= self._contentLoadToken or self._contentLoaded then
		return
	end

	self:_cancelContentLoadTimeout()

	self._contentLoading = false

	if not success then
		logger:error("CashShop container load failed, categoryType=%s, container=%s", tostring(self.categoryType), tostring(self.refUContainer))

		return
	end

	self:_onContentLoaded()
end

function CashShopContainerComponent:onItemListReceived(itemList)
	self:refreshPage()
end

function CashShopContainerComponent:isShowingBP()
	return false
end

function CashShopContainerComponent:isSpecialSceneData(data)
	return false
end

function CashShopContainerComponent:_syncEnvironment(isBP)
	local avatarComponent = self.ctrl and self.ctrl.avatarComponent
	local avatarScene = avatarComponent and avatarComponent.avatarScene

	if avatarScene and avatarScene.switchEnvironment then
		avatarScene:switchEnvironment(isBP == true)
	end
end

function CashShopContainerComponent:_setAccessoryPackagePetPositionActive(active)
	local avatarComponent = self.ctrl and self.ctrl.avatarComponent
	local avatarScene = avatarComponent and avatarComponent.avatarScene

	if avatarScene and avatarScene.setAccessoryPackagePetPositionActive then
		avatarScene:setAccessoryPackagePetPositionActive(active == true)
	end
end

function CashShopContainerComponent:_onContentLoaded()
	self._contentLoaded = true

	self:findObjects()
	self:addListener()

	if self.ctrl and self.ctrl.curComponent == self then
		self:_setupGroupTabs()
	end
end

function CashShopContainerComponent:checkContentLoaded()
	return self._contentLoaded
end

function CashShopContainerComponent:checkPageReady()
	if not self._contentLoaded or not self._pageApplied then
		return false
	end

	if self._currentGroupId then
		return self._appliedGroupId == self._currentGroupId
	end

	return true
end

function CashShopContainerComponent:_setupGroupTabs()
	self._showingModel = false

	if not self.listGroupTab then
		local pendingNav = self.ctrl._pendingNav

		if pendingNav then
			pendingNav.groupId = nil

			if not pendingNav.commodityId then
				self.ctrl._pendingNav = nil
			end
		end

		self:_syncBackground()

		self._pageApplied = false

		self:refreshPage()

		self._appliedGroupId = nil
		self._pageApplied = true

		return
	end

	self._groupList = self.ctrl.model:getGroupListByTabId(self.categoryType)

	if not self._groupList or #self._groupList == 0 then
		self.listGroupTab.gameObject:SetActiveEx(false)

		self._currentGroupId = nil
		self._currentGroupData = nil

		self:_syncBackground()

		self._pageApplied = false

		self:refreshPage()

		self._appliedGroupId = nil
		self._pageApplied = true

		return
	end

	local initialGroup = self._groupList[1]
	local pendingNav = self.ctrl._pendingNav

	if pendingNav and pendingNav.groupId then
		for _, groupData in ipairs(self._groupList) do
			if groupData.id == pendingNav.groupId then
				initialGroup = groupData
				pendingNav.groupId = nil

				if not pendingNav.commodityId then
					self.ctrl._pendingNav = nil
				end

				break
			end
		end
	end

	self.listGroupTab.gameObject:SetActiveEx(true)

	self._currentGroupData = initialGroup
	self._currentGroupId = initialGroup.id
	self.categoryId = initialGroup.id

	self:_syncBackground(true)

	function self.listGroupTab.luaRenderItem(button, index, data)
		self:renderGroupTabItem(button, data, self._currentGroupId)
	end

	function self.listGroupTab.luaClick(button, data)
		self:_onGroupSelected(data)
	end

	self.listGroupTab:SetList(self._groupList)

	for i, groupData in ipairs(self._groupList) do
		if groupData.id == self._currentGroupId then
			self.listGroupTab:SelectItem(i - 1)

			break
		end
	end

	self._appliedGroupId = nil
	self._pageApplied = false

	self:refreshPage()

	self._appliedGroupId = self._currentGroupId
	self._pageApplied = true
end

function CashShopContainerComponent:_onGroupSelected(data)
	if self._currentGroupId == data.id and self._appliedGroupId == data.id then
		return
	end

	self._showingModel = false
	self._currentGroupData = data
	self._currentGroupId = data.id
	self.categoryId = data.id

	self:_syncBackground(true)

	self._showingPet = false

	if self.productInformation then
		self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PLAYER)
	end

	local avatarComponent = self.ctrl.avatarComponent

	if avatarComponent then
		avatarComponent:playAnimation(self:_getDefaultShopAction())
	end

	function self.listGroupTab.luaRenderItem(button, index, data)
		self:renderGroupTabItem(button, data, self._currentGroupId)
	end

	self.listGroupTab:RefreshList()

	self._appliedGroupId = nil
	self._pageApplied = false

	self:refreshPage()

	self._appliedGroupId = data.id
	self._pageApplied = true
end

function CashShopContainerComponent:_syncBackground(skipImgBg, itemUIBack)
	local bgType, uiBack = self:_resolveSceneBg(skipImgBg and itemUIBack or nil)

	self:_applySceneBg(bgType, uiBack, skipImgBg)
end

function CashShopContainerComponent:_pickSceneBgFromCfg(cfg)
	local SceneBgType = CashShopConst.SceneBgType

	if not Utils.isTable(cfg) or not cfg.bgType then
		return nil
	end

	if cfg.bgType == SceneBgType.SPECIAL_3D then
		return SceneBgType.SPECIAL_3D, nil
	end

	if (cfg.bgType == SceneBgType.IMG_2D or cfg.bgType == SceneBgType.SCENE_3D) and cfg.uiBack then
		return cfg.bgType, cfg.uiBack
	end

	return nil
end

function CashShopContainerComponent:_resolveSceneBg(itemUIBack)
	local SceneBgType = CashShopConst.SceneBgType

	if itemUIBack then
		return SceneBgType.SCENE_3D, itemUIBack
	end

	local bgType, uiBack = self:_pickSceneBgFromCfg(self._currentGroupData)

	if bgType then
		return bgType, uiBack
	end

	bgType, uiBack = self:_pickSceneBgFromCfg(ShopmallTabData[self.categoryType])

	if bgType then
		return bgType, uiBack
	end

	return SceneBgType.SPECIAL_3D, nil
end

function CashShopContainerComponent:_applySceneBg(bgType, uiBack, skipImgBg)
	local SceneBgType = CashShopConst.SceneBgType
	local avatarComponent = self.ctrl and self.ctrl.avatarComponent
	local avatarScene = avatarComponent and avatarComponent.avatarScene
	local is3DBg = bgType ~= SceneBgType.IMG_2D

	if bgType == SceneBgType.IMG_2D then
		if not skipImgBg and self.imgBG then
			self.imgBG:SetActive(true)

			self.imgBG.url = uiBack
		end

		if avatarScene and avatarScene.switchBackground then
			avatarScene:switchBackground(nil)
		end
	else
		if not skipImgBg and self.imgBG then
			self.imgBG:SetActive(false)
		end

		if avatarScene and avatarScene.switchBackground then
			avatarScene:switchBackground(bgType == SceneBgType.SPECIAL_3D and 3 or uiBack)
		end
	end

	if avatarScene and avatarScene.syncLight then
		avatarScene:syncLight(is3DBg and self._showingModel == true)
	end
end

function CashShopContainerComponent:renderGroupTabItem(button, data, currentGroupId)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	if textUBaseText then
		ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.tabName))
	end

	if iconUImage then
		iconUImage.url = data.tabIcon
	end

	button:SetSelected(data.id == currentGroupId)

	local tabId = self.categoryType

	if tabId and data.id then
		local treePath = string.format(RedDotConst.RedDotPath.CASH_SHOP_GROUP_LIST_ITEM, tabId, data.id)

		pg.global.setPreViewRedDot(treePath, button, function()
			return CashShopRedDotUtils.getCashShopGroupRedDotStyle(tabId, data.id)
		end)
	end
end

function CashShopContainerComponent:_switchSubContainer(showType, callback)
	if not self._subContainers then
		if callback then
			callback()
		end

		return
	end

	for _, info in pairs(self._subContainers) do
		info.ref:SetActive(false)
	end

	local info = self._subContainers[showType]

	if not info then
		if callback then
			callback()
		end

		return
	end

	info.ref:SetActive(true)

	if info.loaded then
		self.listUList = info.listUList

		if callback then
			callback()
		end
	else
		local function onLoaded()
			info.loaded = true
			info.objectReference = info.ref.transform:GetChild(0):GetComponent("ObjectReference")
			info.listUList = info.objectReference:GetRefValue("listUList")
			self.listUList = info.listUList

			function self.listUList.luaRenderItem(button, index, data)
				self:renderItem(button, index, data)
			end

			if callback then
				callback()
			end
		end

		if info.ref:CheckURLLoaded() then
			onLoaded()
		else
			info.ref:LoadDefaultUrlManually(onLoaded)
		end
	end
end

function CashShopContainerComponent:_getDisplayCommodityList()
	local list = ClientCashShopUtils.getCommodityListByGroupId(self.categoryId)

	list = self:_filterListByGender(list)
	list = self:_sortSoldOutToEnd(list)

	return list
end

function CashShopContainerComponent:_findCommodityIndex(list, commodityId)
	if not list or not commodityId then
		return nil
	end

	for index, item in ipairs(list) do
		if item.commodityId == commodityId then
			return index
		end
	end

	return nil
end

function CashShopContainerComponent:_findCommodityById(list, commodityId)
	local index = self:_findCommodityIndex(list, commodityId)

	return index and list[index] or nil
end

function CashShopContainerComponent:_syncCommoditySelection(list, commodityId)
	if not commodityId then
		return
	end

	self._selectedCommodityId = commodityId

	local targetIndex = self:_findCommodityIndex(list, commodityId)

	self._selectedListIndex = targetIndex and targetIndex - 1 or nil

	if self.listUList then
		self.listUList:RefreshList()

		if targetIndex then
			self:startFrameTimer(function()
				if self.listUList then
					self.listUList:GoToIndex(targetIndex - 1, true)
				end
			end, 1)
		end
	end
end

function CashShopContainerComponent:_refreshSelectionElements(oldIndex, newIndex)
	if not self.listUList then
		return
	end

	if oldIndex ~= nil and oldIndex >= 0 and oldIndex ~= newIndex then
		self.listUList:RefreshElement(oldIndex)
	end

	if newIndex ~= nil and newIndex >= 0 then
		self.listUList:RefreshElement(newIndex)
	end
end

function CashShopContainerComponent:refreshPage()
	if not self.listUList then
		return
	end

	local list = self:_getDisplayCommodityList()

	if #list > 0 then
		local selectedData = self:_consumePendingCommodity(list)

		if not selectedData then
			local currentCommodityId = self._currentData and self._currentData.commodityId or self._selectedCommodityId

			selectedData = self:_findCommodityById(list, currentCommodityId) or list[1]
		end

		self.listUList:SetList(list)
		self:_syncCommoditySelection(list, selectedData.commodityId)
		self:refreshCommodInfo(selectedData)
	else
		self._selectedCommodityId = nil
		self._selectedListIndex = nil

		self.listUList:SetList(list)
		self:_syncBackground()
	end
end

function CashShopContainerComponent:refreshCommodChangeInfo()
	if self._currentData then
		self:refreshCommodInfo(self._currentData)
	elseif self.categoryType == CashShopConst.CategoryType.MONTHLYCARD then
		self:refreshPage()
	end
end

function CashShopContainerComponent:_consumePendingCommodity(list)
	local pendingNav = self.ctrl._pendingNav

	if not pendingNav or not pendingNav.commodityId then
		return nil
	end

	local targetId = pendingNav.commodityId

	pendingNav.commodityId = nil

	if not pendingNav.groupId then
		self.ctrl._pendingNav = nil
	end

	for _, item in ipairs(list) do
		if item.commodityId == targetId then
			return item
		end
	end

	return nil
end

function CashShopContainerComponent:selectGroup(groupId)
	if not self._groupList or not groupId then
		local pendingNav = self.ctrl._pendingNav

		if pendingNav and pendingNav.commodityId then
			local commodityId = pendingNav.commodityId

			self.ctrl._pendingNav = nil

			self:selectCommodity(commodityId)
		end

		return
	end

	for _, groupData in ipairs(self._groupList) do
		if groupData.id == groupId then
			if self._currentGroupId ~= groupId then
				self:_onGroupSelected(groupData)
			else
				local pendingNav = self.ctrl._pendingNav

				if pendingNav and pendingNav.commodityId then
					local commodityId = pendingNav.commodityId

					self.ctrl._pendingNav = nil

					self:selectCommodity(commodityId)
				end
			end

			return
		end
	end

	local pendingNav = self.ctrl._pendingNav

	if pendingNav and pendingNav.commodityId then
		local commodityId = pendingNav.commodityId

		self.ctrl._pendingNav = nil

		self:selectCommodity(commodityId)
	end
end

function CashShopContainerComponent:selectCommodity(commodityId)
	if not commodityId then
		return
	end

	local list = self:_getDisplayCommodityList()

	for _, item in ipairs(list) do
		if item.commodityId == commodityId then
			self:_syncCommoditySelection(list, commodityId)
			self:refreshCommodInfo(item)

			return
		end
	end

	self:_onSelectCommodityNotFound(commodityId)
end

function CashShopContainerComponent:_onSelectCommodityNotFound(commodityId)
	return false
end

function CashShopContainerComponent:_shouldUseFacePreviewUndyedLook()
	return self.categoryType == CashShopConst.CategoryType.AVATAR
end

function CashShopContainerComponent:_syncFacePreviewUndyedMode(data)
	local avatarComponent = self.ctrl and self.ctrl.avatarComponent

	if not avatarComponent or not avatarComponent.setFacePreviewUndyedMode then
		return
	end

	avatarComponent:setFacePreviewUndyedMode(self:_shouldUseFacePreviewUndyedLook())
end

function CashShopContainerComponent:_resolveCommodityItemId(data)
	local itemId = data and data.itemId

	if not itemId and data and data.commodityId then
		local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)

		itemId = commodityInfo and commodityInfo.itemId
	end

	return itemId
end

function CashShopContainerComponent:_getPreviewItemId(itemId)
	if not itemId then
		return nil
	end

	return self:_getGenderConvertedItemId(itemId, self:_getOrInitCurrentGender())
end

function CashShopContainerComponent:_getAppearanceInfoByGender(itemId)
	if not itemId then
		return nil, nil
	end

	local previewItemId = self:_getPreviewItemId(itemId) or itemId
	local mappedInfo = ShopMallAppearance[previewItemId] or ShopMallAppearance[itemId]
	local appearanceInfo = {}

	if AppearanceSuitData[previewItemId] or AppearanceData[previewItemId] then
		appearanceInfo[1] = previewItemId
	elseif mappedInfo and mappedInfo[1] and (AppearanceSuitData[mappedInfo[1]] or AppearanceData[mappedInfo[1]]) then
		appearanceInfo[1] = self:_getGenderConvertedItemId(mappedInfo[1], self:_getOrInitCurrentGender())
	end

	if mappedInfo then
		if mappedInfo[2] and AppearanceJewelryPetData[mappedInfo[2]] then
			appearanceInfo[2] = mappedInfo[2]
		elseif mappedInfo[1] and AppearanceJewelryPetData[mappedInfo[1]] then
			appearanceInfo[2] = mappedInfo[1]
		end
	end

	if appearanceInfo[2] == nil then
		local mappedPetId = ShopMallPetAppearance[previewItemId] or ShopMallPetAppearance[itemId]

		if mappedPetId and AppearanceJewelryPetData[mappedPetId] then
			appearanceInfo[2] = mappedPetId
		end
	end

	if appearanceInfo[2] == nil then
		if AppearanceJewelryPetData[previewItemId] then
			appearanceInfo[2] = previewItemId
		elseif AppearanceJewelryPetData[itemId] then
			appearanceInfo[2] = itemId
		end
	end

	if appearanceInfo[1] == nil and appearanceInfo[2] == nil then
		return nil, previewItemId
	end

	return appearanceInfo, previewItemId
end

function CashShopContainerComponent:_showPetPreview(itemId)
	local avatarComponent = self.ctrl.avatarComponent

	if not avatarComponent then
		return
	end

	if self.productInformation and self.productInformation:isGiftAppearanceCommodity() then
		self.productInformation:applySelectedGiftAppearances(true)

		return
	end

	local appearanceInfo = self:_getAppearanceInfoByGender(itemId)
	local petId = appearanceInfo and appearanceInfo[2]

	if petId then
		avatarComponent:equipPetAccessory(petId)
	else
		avatarComponent:unEquipPetAccessory()
	end
end

function CashShopContainerComponent:_getDefaultShopAction()
	local gender = self:_getOrInitCurrentGender()

	if gender == BODY_MALE then
		return ShopConstantData.default_action_man and ShopConstantData.default_action_man.number
	else
		return ShopConstantData.default_action_woman and ShopConstantData.default_action_woman.number
	end
end

function CashShopContainerComponent:_sortSoldOutToEnd(list)
	local COMMODITY_STATE = ClientCashShopUtils.COMMODITY_STATE
	local normal = {}
	local back = {}

	for _, item in ipairs(list) do
		local state = ClientCashShopUtils.getCommodityState(item)

		if state == COMMODITY_STATE.SOLDOUT or state == COMMODITY_STATE.POSSESS then
			back[#back + 1] = item
		else
			normal[#normal + 1] = item
		end
	end

	for _, item in ipairs(back) do
		normal[#normal + 1] = item
	end

	return normal
end

function CashShopContainerComponent:_clearPreviewBeforeDisplaySwitch(mode)
	local avatarComponent = self.ctrl.avatarComponent

	if avatarComponent then
		avatarComponent:clearPreviewState(mode or "current")
	end
end

function CashShopContainerComponent:_getBodyMappedValue(map, body)
	if not map or not body then
		return nil
	end

	local value = map[body] or map[tostring(body)]

	if value ~= nil then
		return value
	end

	for _, entry in pairs(map) do
		if type(entry) == "table" and tonumber(entry[1]) == body then
			return entry[2]
		end
	end

	return nil
end

function CashShopContainerComponent:_getCommodityTemplatePresetKey(gender)
	if not gender or not self._currentData then
		return nil
	end

	local commodityInfo = self._currentData

	commodityInfo = commodityInfo.commodityId and ClientCashShopUtils.getCommodityData(commodityInfo.commodityId) or commodityInfo

	local presetKey = tonumber(self:_getBodyMappedValue(commodityInfo.avatarId, gender))

	if presetKey and AvatarPresetData[presetKey] then
		return presetKey
	end

	return nil
end

function CashShopContainerComponent:_getShopTemplatePresetKey(gender)
	if not gender then
		return nil
	end

	local commodityPresetKey = self:_getCommodityTemplatePresetKey(gender)

	if commodityPresetKey then
		return commodityPresetKey
	end

	local cfgKey = gender == BODY_MALE and "template_preset_man" or "template_preset_woman"
	local cfg = ShopConstantData[cfgKey]
	local presetKey = cfg and tonumber(cfg.number)

	if presetKey and AvatarPresetData[presetKey] then
		return presetKey
	end

	local fallbackKey = gender * 10000 + 1

	if AvatarPresetData[fallbackKey] then
		return fallbackKey
	end

	return nil
end

function CashShopContainerComponent:_getPlayerBody()
	local avatarComponent = self.ctrl.avatarComponent

	if not avatarComponent then
		return nil
	end

	local presetData = pg.game.avatar:getAvatarPresetData(avatarComponent.curPresetKey)

	return presetData and presetData.body
end

function CashShopContainerComponent:_canSwitchToPlayerMirror()
	local currentGender = self:_getOrInitCurrentGender()
	local playerBody = self:_getPlayerBody()

	return playerBody ~= nil and currentGender == playerBody
end

function CashShopContainerComponent:isPlayerMirrorPreviewMode()
	return self._usePlayerMirror == true and self:_canSwitchToPlayerMirror()
end

function CashShopContainerComponent:_showPreviewModel(itemId, onLoaded)
	local avatarComponent = self.ctrl.avatarComponent

	if not avatarComponent then
		return
	end

	if self.productInformation and self.productInformation:isGiftAppearanceCommodity() and self.productInformation:hasGiftAppearanceForTarget(false) then
		local shopAction = self:_getDefaultShopAction()

		avatarComponent:showPlayer(shopAction, function()
			avatarComponent:clearPreviewState("player")
			self.productInformation:applySelectedGiftAppearances(false)

			if onLoaded then
				onLoaded()
			end
		end)

		self._currentDisplayBody = self:_getPlayerGender()

		return
	end

	local appearanceInfo = self:_getAppearanceInfoByGender(itemId)
	local playerId = appearanceInfo and appearanceInfo[1]

	if not playerId then
		avatarComponent:hideAllEntities()

		local avatarScene = avatarComponent.avatarScene

		if avatarScene and avatarScene.hideAllRoleLights then
			avatarScene:hideAllRoleLights()
		end

		return
	end

	local currentGender = self:_getOrInitCurrentGender()
	local appearanceId = self:_getGenderConvertedItemId(playerId, currentGender)
	local suitData = AppearanceSuitData[appearanceId]
	local shopAction = suitData and suitData.shopAction ~= "" and suitData.shopAction or self:_getDefaultShopAction()

	if self:isPlayerMirrorPreviewMode() then
		avatarComponent:showPlayerWithPreview(appearanceId, shopAction, onLoaded)
	else
		local presetKey = self:_getShopTemplatePresetKey(currentGender)

		if not presetKey then
			avatarComponent:hideAllEntities()

			return
		end

		avatarComponent:showTemplateAvatar(presetKey, shopAction, function()
			avatarComponent:templateEquip(appearanceId)

			if onLoaded then
				onLoaded()
			end
		end)
	end

	self._currentDisplayBody = currentGender
end

function CashShopContainerComponent:_shouldShowProductTabWidget(data, commodityInfo)
	return tonumber(commodityInfo and commodityInfo.avatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE
end

function CashShopContainerComponent:_resolveModelUIBack(data, commodityInfo, playerAppId, petAppId)
	local uiBack = commodityInfo and commodityInfo.uiBack

	if not uiBack and playerAppId then
		local suitData = AppearanceSuitData[playerAppId]

		uiBack = suitData and suitData.uiBack
	end

	if not uiBack and petAppId then
		local petData = AppearanceJewelryPetData[petAppId]

		uiBack = petData and petData.uiBack
	end

	local isAccessoryPackage = tonumber(commodityInfo and commodityInfo.avatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE

	if not uiBack and self.categoryType == CashShopConst.CategoryType.RECOMMEND and isAccessoryPackage and data.bgType == CashShopConst.BgType.IMAGE then
		uiBack = data.showPic
	end

	return uiBack
end

function CashShopContainerComponent:refreshCommodInfo(data, previewLoadedCallback)
	if not data then
		return
	end

	self._currentData = data

	self:_syncFacePreviewUndyedMode(data)

	local commodityInfo = data.commodityId and ClientCashShopUtils.getCommodityData(data.commodityId) or nil
	local isAccessoryPackageConfig = tonumber(commodityInfo and commodityInfo.avatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE

	if isAccessoryPackageConfig then
		self._currentGender = self:_getPlayerGender()
	end

	if self.productInformation then
		self.productInformation:setInfo(data, self:_shouldShowProductTabWidget(data, commodityInfo))
	end

	local isGiftAppearance = self.productInformation and self.productInformation:isGiftAppearanceCommodity()
	local isAccessoryPackage = self.productInformation and self.productInformation:isAccessoryPackageCommodity()
	local previewTarget = isAccessoryPackage and self.productInformation:getAccessoryPackageTarget() or nil

	if isAccessoryPackage then
		self._showingPet = previewTarget == CashShopConst.AccessoryPreviewTarget.PET
	elseif self.productInformation and self.productInformation:isTabWidgetVisible() then
		self._showingPet = false
	end

	if not isAccessoryPackage or previewTarget ~= CashShopConst.AccessoryPreviewTarget.PET then
		self:_setAccessoryPackagePetPositionActive(false)
	end

	local avatarComponent = self.ctrl.avatarComponent

	self:_syncEnvironment(data.showModle == CashShopConst.ShowModle.BattlePass)

	local selectedAccessoryId, selectedSlotId, selectedPetAccessoryId, selectedPetGenId
	local selectedPetSlotIdx = 1

	do
		local itemId = self:_resolveCommodityItemId(data)
		local appearanceInfo = self:_getAppearanceInfoByGender(itemId)
		local playerAppearanceId = appearanceInfo and appearanceInfo[1] or nil
		local playerAppearanceData = playerAppearanceId and AppearanceData[playerAppearanceId] or nil

		if playerAppearanceData and playerAppearanceData.type == 1 then
			selectedAccessoryId = playerAppearanceId
			selectedSlotId = playerAppearanceData.partId
		end

		selectedPetAccessoryId = appearanceInfo and appearanceInfo[2] or nil

		if selectedPetAccessoryId and self.ctrl and self.ctrl.avatarComponent and self.ctrl.avatarComponent.curPetId then
			local petId = self.ctrl.avatarComponent.curPetId
			local petJewelryInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[petId]
			local genId = petJewelryInfo and petJewelryInfo.customShow and petJewelryInfo.customShow[selectedPetSlotIdx]

			if genId and genId ~= 0 then
				local bag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PET_JEWELRY)
				local item = bag and bag:get(genId)

				if item and item.id == selectedPetAccessoryId then
					selectedPetGenId = genId
				end
			end
		end
	end

	if self.ctrl and self.ctrl.updateAdjustContext then
		self.ctrl:updateAdjustContext(selectedAccessoryId, selectedSlotId, selectedPetAccessoryId, selectedPetGenId, selectedPetSlotIdx)
	end

	if self.monthlyCard then
		local isSpecialMode = data.showModle == CashShopConst.ShowModle.MonthCard or data.showModle == CashShopConst.ShowModle.BattlePass

		self.monthlyCard.gameObject:SetActiveEx(data.showModle == CashShopConst.ShowModle.MonthCard)
		self.btnEllipsesUButton:SetActive(data.showModle ~= CashShopConst.ShowModle.MonthCard)
		self.productInformationUComponent:SetActive(not isSpecialMode)

		if not isSpecialMode and pg.global.ui:checkUIOpen(UIConst.UI_ID_MONTHLY_CARD_REWARD) then
			pg.global.ui:close(UIConst.UI_ID_MONTHLY_CARD_REWARD)
		end
	end

	if data.bgType and data.bgType ~= CashShopConst.BgType.MODLE and not isGiftAppearance and not self:isSpecialSceneData(data) then
		self:_clearPreviewBeforeDisplaySwitch("all")

		if avatarComponent then
			avatarComponent:hideAllEntities()
		end

		self._showingModel = false

		if data.showModle == CashShopConst.ShowModle.MonthCard then
			self:_syncBackground()
		else
			self:_syncBackground(true, data.showPic)
		end
	else
		local avatarType = commodityInfo and commodityInfo.avatarType or data.avatarType
		local itemId = self:_resolveCommodityItemId(data)
		local appearanceInfo = self:_getAppearanceInfoByGender(itemId)
		local playerAppId = appearanceInfo and appearanceInfo[1]
		local petAppId = appearanceInfo and appearanceInfo[2]
		local hasPlayerAppearance = playerAppId ~= nil or isGiftAppearance and self.productInformation:hasGiftAppearanceForTarget(false)
		local hasPetAppearance = petAppId ~= nil or isGiftAppearance and self.productInformation:hasGiftAppearanceForTarget(true)
		local hasFurniture = isGiftAppearance and self.productInformation:hasGiftFurniture()
		local showFurniture = isAccessoryPackage and previewTarget == CashShopConst.AccessoryPreviewTarget.FURNITURE and hasFurniture
		local furnitureModelShown = false

		if itemId and (hasPlayerAppearance or hasPetAppearance or hasFurniture) and (avatarType or isGiftAppearance) then
			if self.imgBG then
				self.imgBG:SetActive(false)
			end

			if showFurniture then
				furnitureModelShown = self:_showFurniturePreview(self.productInformation:getSelectedGiftFurnitureId())

				self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.FURNITURE)
			elseif hasPetAppearance and (self._showingPet or not hasPlayerAppearance) then
				self:_clearPreviewBeforeDisplaySwitch("player")

				if (isGiftAppearance or not hasPlayerAppearance) and avatarComponent then
					avatarComponent:showPet(nil, function()
						self:_showPetPreview(itemId)
					end)
				else
					self:_showPetPreview(itemId)
				end

				self:_setAccessoryPackagePetPositionActive(isAccessoryPackage)

				if self.productInformation then
					self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PET)
				end
			else
				self:_clearPreviewBeforeDisplaySwitch("pet")
				self:_showPreviewModel(itemId, previewLoadedCallback)

				if self.productInformation then
					self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PLAYER)
				end
			end

			local uiBack = self:_resolveModelUIBack(data, commodityInfo, playerAppId, petAppId)

			self._showingModel = not showFurniture or furnitureModelShown

			self:_syncBackground(true, uiBack)
		else
			self:_clearPreviewBeforeDisplaySwitch("all")

			if avatarComponent then
				avatarComponent:hideAllEntities()
			end

			self._showingModel = false

			self:_syncBackground()
		end
	end

	if self.ctrl and self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end
end

function CashShopContainerComponent:_showFurniturePreview(furnitureItemId)
	self:_setAccessoryPackagePetPositionActive(false)
	self:_clearPreviewBeforeDisplaySwitch("all")

	local avatarComponent = self.ctrl.avatarComponent

	self._previewFurnitureItemId = furnitureItemId

	if not avatarComponent then
		return false
	end

	if furnitureItemId and avatarComponent.showFurniture then
		return avatarComponent:showFurniture(furnitureItemId)
	end

	avatarComponent:hideAllEntities()

	return false
end

function CashShopContainerComponent:_refreshCurrentPreviewScene()
	local commodityInfo = self._currentData and self._currentData.commodityId and ClientCashShopUtils.getCommodityData(self._currentData.commodityId) or nil
	local itemId = self:_resolveCommodityItemId(self._currentData)
	local appearanceInfo = self:_getAppearanceInfoByGender(itemId)
	local uiBack = self:_resolveModelUIBack(self._currentData, commodityInfo, appearanceInfo and appearanceInfo[1], appearanceInfo and appearanceInfo[2])

	self:_syncBackground(true, uiBack)

	if self.ctrl and self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end
end

function CashShopContainerComponent:_switchToPlayer(onLoaded)
	if not self.ctrl.avatarComponent or not self._currentData then
		return false
	end

	self:_setAccessoryPackagePetPositionActive(false)

	self._showingPet = false

	self:_clearPreviewBeforeDisplaySwitch()

	local itemId = self:_resolveCommodityItemId(self._currentData)

	self:_showPreviewModel(itemId, onLoaded)

	if self.productInformation then
		self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PLAYER)
	end

	self._showingModel = true

	self:_refreshCurrentPreviewScene()

	return true
end

function CashShopContainerComponent:_switchToSuitPowerPet(petTemplateId, onLoaded)
	local avatarComponent = self.ctrl.avatarComponent

	if not avatarComponent or not self._currentData or not petTemplateId then
		return false
	end

	self:_setAccessoryPackagePetPositionActive(false)

	self._showingPet = true

	self:_clearPreviewBeforeDisplaySwitch("all")

	local entity = avatarComponent:showPetByModelingId(petTemplateId, nil, nil, nil, nil, onLoaded)

	if not entity then
		return false
	end

	if self.productInformation then
		self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PET)
	end

	self._showingModel = true

	self:_refreshCurrentPreviewScene()

	return true
end

function CashShopContainerComponent:_switchToPet()
	local avatarComponent = self.ctrl.avatarComponent

	if not avatarComponent or not self._currentData then
		return
	end

	local itemId = self:_resolveCommodityItemId(self._currentData)
	local isGiftAppearance = self.productInformation and self.productInformation:isGiftAppearanceCommodity()
	local isAccessoryPackage = self.productInformation and self.productInformation:isAccessoryPackageCommodity()
	local appearanceInfo = not isGiftAppearance and self:_getAppearanceInfoByGender(itemId) or nil
	local canShowPet = isAccessoryPackage or isGiftAppearance and self.productInformation:hasGiftAppearanceForTarget(true) or appearanceInfo and appearanceInfo[2] ~= nil

	if not canShowPet then
		self:_setAccessoryPackagePetPositionActive(false)

		if self.productInformation then
			self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PLAYER)
		end

		return
	end

	self._showingPet = true

	self:_clearPreviewBeforeDisplaySwitch()
	avatarComponent:showPet(nil, function()
		if itemId then
			self:_showPetPreview(itemId)
		end
	end)
	self:_setAccessoryPackagePetPositionActive(isAccessoryPackage)

	if self.productInformation then
		self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.PET)
		self.productInformation:refreshPetIcon(avatarComponent.curPetId)
	end

	self._showingModel = true

	self:_refreshCurrentPreviewScene()
end

function CashShopContainerComponent:_switchToFurniture(furnitureItemId)
	if not self._currentData or not self.productInformation or not self.productInformation:isAccessoryPackageCommodity() then
		return
	end

	self:_setAccessoryPackagePetPositionActive(false)

	self._showingPet = false

	local furnitureModelShown = self:_showFurniturePreview(furnitureItemId)

	self.productInformation:setPreviewTarget(CashShopConst.AccessoryPreviewTarget.FURNITURE)

	self._showingModel = furnitureModelShown

	self:_refreshCurrentPreviewScene()
end

function CashShopContainerComponent:renderItem(button, index, data)
	ClientCashShopUtils.renderCommodityItem(button, data)
	button:SetSelected(self._selectedCommodityId ~= nil and data.commodityId == self._selectedCommodityId)

	function button.luaClick()
		if data.commodityId and self._selectedCommodityId == data.commodityId and self._currentData and self._currentData.commodityId == data.commodityId then
			button:SetSelected(true)

			return
		end

		local oldIndex = self._selectedListIndex

		self._selectedCommodityId = data.commodityId
		self._selectedListIndex = index

		if not data._bannerIndex then
			self:_refreshSelectionElements(oldIndex, index)
		end

		self:refreshCommodInfo(data)
		LuaUIUtils.sendCustomLog(Const.BILogName.SHOPPING_MALL_ITEM_DISPLAY, {
			item_id = data.commodityId,
			tab = self.categoryType,
			sub_tab = self._currentGroupId or 0
		})
	end
end

function CashShopContainerComponent:onBuyItemResult(result)
	if result.success then
		self.model:clearItemCache()
		self:refreshPage()
	end
end

function CashShopContainerComponent:_setupEllipsesTooltip(btnEllipses)
	function btnEllipses.luaRenderTooltip(_, tipItem)
		local objectReference = tipItem:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")
		local tooltipData = self:_buildEllipsesTooltipData()

		function listUList.luaRenderItem(subButton, index, subData)
			local subObjectReference = subButton:GetComponent("ObjectReference")
			local txtName = subObjectReference:GetRefValue("txtUText")
			local iconUImage = subObjectReference:GetRefValue("iconUImage")

			if iconUImage then
				local hasIcon = subData and not string.isNilOrEmpty(subData.icon)

				iconUImage.gameObject:SetActiveEx(hasIcon)

				if hasIcon then
					iconUImage.url = subData.icon
				end
			end

			ClientTextUtils.setText(txtName, pg.getGameString(subData.label))

			function subButton.luaClick()
				btnEllipses:ClosePopup()
				subData.onClick()
			end
		end

		listUList:SetList(tooltipData)
	end
end

function CashShopContainerComponent:_buildEllipsesTooltipData()
	local data = {}

	if self.categoryType == CashShopConst.CategoryType.AVATAR then
		local currentGender = self:_getOrInitCurrentGender()
		local genderLabel = currentGender ~= BODY_MALE and "SHOP_MAN" or "SHOP_WOMAN"
		local genderIcon = currentGender ~= BODY_MALE and ShopConstantData.boy_icon and ShopConstantData.boy_icon.number or ShopConstantData.girl_icon and ShopConstantData.girl_icon.number

		data[#data + 1] = {
			label = genderLabel,
			icon = genderIcon,
			onClick = function()
				self:_switchGender()
			end
		}

		if self:_canSwitchToPlayerMirror() then
			local mirrorLabel = self._usePlayerMirror and "SHOP_PREVIEW_TEMPLATE" or "SHOP_PREVIEW_SELF"

			data[#data + 1] = {
				label = mirrorLabel,
				icon = ShopConstantData.switch_template_icon and ShopConstantData.switch_template_icon.number,
				onClick = function()
					self:_switchPreviewModelMode()
				end
			}
		end
	end

	data[#data + 1] = {
		label = "SHOP_HIDE_UI",
		icon = ShopConstantData.hide_icon and ShopConstantData.hide_icon.number,
		onClick = function()
			self:_hideUI()
		end
	}

	return data
end

function CashShopContainerComponent:_switchGender()
	local currentGender = self:_getOrInitCurrentGender()

	self._currentGender = currentGender == BODY_FEMALE and BODY_MALE or BODY_FEMALE
	self._usePlayerMirror = false

	self:refreshPage()
end

function CashShopContainerComponent:_switchPreviewModelMode()
	if not self:_canSwitchToPlayerMirror() then
		return
	end

	self._usePlayerMirror = not self._usePlayerMirror

	self:_clearPreviewBeforeDisplaySwitch("player")

	if self._currentData then
		self:refreshCommodInfo(self._currentData)
	end
end

function CashShopContainerComponent:_getPlayerGender()
	local avatarComponent = self.ctrl.avatarComponent

	if avatarComponent then
		local presetData = pg.game.avatar:getAvatarPresetData(avatarComponent.curPresetKey)

		return presetData and presetData.body or BODY_FEMALE
	end

	return BODY_FEMALE
end

function CashShopContainerComponent:_getOrInitCurrentGender()
	if not self._currentGender then
		local avatarComponent = self.ctrl.avatarComponent

		if avatarComponent then
			local presetData = pg.game.avatar:getAvatarPresetData(avatarComponent.curPresetKey)

			self._currentGender = presetData and presetData.body or BODY_FEMALE
		else
			return BODY_FEMALE
		end
	end

	return self._currentGender
end

function CashShopContainerComponent:_itemSupportsGender(itemId, gender)
	if not gender or not itemId then
		return true
	end

	local convertData = ItemConditionConvertData[itemId]

	if convertData and convertData.targetItem then
		local targetCondition = gender == BODY_FEMALE and CONDITION_FEMALE or CONDITION_MALE

		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == targetCondition then
				return true
			end
		end

		return false
	end

	local suitData = AppearanceSuitData[itemId]

	if suitData and suitData.body then
		for _, body in ipairs(suitData.body) do
			if body == gender then
				return true
			end
		end

		return false
	end

	return true
end

function CashShopContainerComponent:_getGenderConvertedItemId(itemId, gender)
	if not itemId or not gender then
		return itemId
	end

	local convertData = ItemConditionConvertData[itemId]

	if convertData and convertData.targetItem then
		local targetCondition = gender == BODY_FEMALE and CONDITION_FEMALE or CONDITION_MALE

		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == targetCondition then
				return entry[2]
			end
		end
	end

	return itemId
end

function CashShopContainerComponent:_filterListByGender(list)
	local gender = self:_getOrInitCurrentGender()

	if not gender then
		return list
	end

	local result = {}

	for _, item in ipairs(list) do
		if self:_itemSupportsGender(item.itemId, gender) then
			result[#result + 1] = item
		end
	end

	return result
end

function CashShopContainerComponent:_hideUI()
	if self.ctrl and self.ctrl.setUIShow then
		self.ctrl:setUIShow(false)
	end
end

function CashShopContainerComponent:onBeforeExitPage()
	local avatarComponent = self.ctrl and self.ctrl.avatarComponent

	if avatarComponent and avatarComponent.setFacePreviewUndyedMode then
		avatarComponent:setFacePreviewUndyedMode(false)
	end

	local avatarScene = avatarComponent and avatarComponent.avatarScene

	self:_setAccessoryPackagePetPositionActive(false)
	self:_syncEnvironment(false)

	if avatarScene then
		if avatarScene.curCameraMode then
			if avatarScene.enableCameraMode and avatarScene.CAMERA then
				avatarScene:enableCameraMode(avatarScene.CAMERA.SIMPLE)
			end

			if avatarScene.setAvatarCameraModeFar then
				avatarScene:setAvatarCameraModeFar()
			end
		end

		self:_clearPreviewBeforeDisplaySwitch("all")
		avatarComponent:hideAllEntities()

		if avatarScene.hideAllRoleLights then
			avatarScene:hideAllRoleLights()
		end
	end

	self._currentData = nil
	self._appliedGroupId = nil
	self._pageApplied = false
	self._showingModel = false
	self._showingPet = false
	self._currentGender = nil
	self._selectedListIndex = nil
end

return CashShopContainerComponent
