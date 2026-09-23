-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\TradeMarket\\TradeMarketPetListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local TradeMarketSubPageComponent = require("Guis.Panels.CashShop.Component.TradeMarket.TradeMarketSubPageComponent")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local TradeMarketPetListComponent = Class.LightClass("TradeMarketPetListComponent", TradeMarketSubPageComponent)

TradeMarketPetListComponent.messages = {
	[MessageName.ON_GET_TRADE_OVERVIEW] = {
		"onGetTradeOverview",
		true
	},
	[MessageName.ON_TRADE_FOLLOW_CHANGED] = {
		"onTradeFollowChanged",
		true
	}
}

function TradeMarketPetListComponent:enterPage()
	TradeMarketSubPageComponent.enterPage(self)
	pg.me:reqGetTradeOverview(TradeMarketUtils.SubPageType.Pet, 0, function()
		return
	end)
end

function TradeMarketPetListComponent:onTradeFollowChanged()
	if self._entered and self._contentLoaded and self._currentSubTabData then
		self:refreshPetData(self._currentSubTabData)
	end
end

function TradeMarketPetListComponent:onGetTradeOverview(data)
	if not data or data.displayType ~= TradeMarketUtils.SubPageType.Pet or (data.displaySubType or 0) ~= 0 then
		return
	end

	self.tradeOverviewData = data.items or {}

	if self._entered and self._contentLoaded then
		self:refreshPage()
	end
end

function TradeMarketPetListComponent:_findObjectRef()
	local objectReference = self.refUContainer.content and self.refUContainer.content:GetComponent("ObjectReference")

	self.btnSellUButton = objectReference:GetRefValue("btnSellUButton")
	self.btnSortUButton = objectReference:GetRefValue("btnSortUButton")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.listPetUList = objectReference:GetRefValue("listPetUList")

	local btnOC = self.btnSellUButton:GetComponent("ObjectReference")
	local btnSellTxtNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnSellTxtNameUText, pg.getGameString("CONSIGNMENT"))
end

function TradeMarketPetListComponent:_addObjectListener()
	function self.btnSellUButton.luaClick()
		self:openSellPetUI()
	end

	function self.btnSortUButton.luaClick()
		self:openPetFilterPanel()
	end

	function self.listTab3thUList.luaRenderItem(button, index, data)
		self:onRenderSubTabItem(button, index, data)
	end

	function self.listTab3thUList.luaClick(button, data)
		self:switchSubTab(data)
	end

	function self.listPetUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end

	function self.listPetUList.luaClick(button, data)
		TradeMarketUtils.openBuyPetDetailUI(data.id)
	end

	self.subTabData = TradeMarketUtils.getInnerTabDat(TradeMarketUtils.SubPageType.Pet)

	self.listTab3thUList:SetList(self.subTabData)
end

function TradeMarketPetListComponent:refreshPage()
	self.petsData = TradeMarketUtils.getPetData()

	local initIndex = self._currentSubTabIndex or 1

	self:switchSubTab(self.subTabData[initIndex])
end

function TradeMarketPetListComponent:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
	local imgBg2UImage = objectReference:GetRefValue("imgBg2UImage")
	local imgBg1UImage = objectReference:GetRefValue("imgBg1UImage")
	local btnAttentionUButton = objectReference:GetRefValue("btnAttentionUButton")
	local progressAttentionUProgress = objectReference:GetRefValue("progressAttentionUProgress")
	local petData = PetData[data.id]

	if not petData then
		return
	end

	imgPetUImage.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

	if data.isFollow then
		btnAttentionUButton:SetActiveFastest(true)
	else
		btnAttentionUButton:SetActiveFastest(false)
	end
end

function TradeMarketPetListComponent:onRenderSubTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))
	button:SetSelected(data.subIndex == self._currentSubTabIndex)
end

function TradeMarketPetListComponent:switchSubTab(data)
	self._currentSubTabData = data

	if self._currentSubTabIndex == data.subIndex then
		self:refreshPetData(data)

		return
	end

	self._currentSubTabIndex = data.subIndex

	self:_selectSubTab(data.subIndex)
	self:refreshPetData(data)
end

function TradeMarketPetListComponent:refreshPetData(data)
	local petsData

	if data.isFollow then
		petsData = self:getFollowPetData()
	else
		petsData = TradeMarketUtils.getPetData(data.subIndex, data.isFollow)
	end

	self.curPetsData = self:filterPetData(petsData)

	for _, petData in ipairs(self.curPetsData) do
		local tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Pet, petData.id)
		local overviewData = self.tradeOverviewData and self.tradeOverviewData[tradeItemKey]

		petData.count = overviewData and overviewData.count or 0
		petData.minPrice = overviewData and overviewData.minPrice or 0
		petData.maxPrice = overviewData and overviewData.maxPrice or 0
		petData.isFollow = pg.me:isTradeItemFollow(tradeItemKey)
	end

	self:refreshPetsList()
end

function TradeMarketPetListComponent:filterPetData(petsData)
	local filter = self.petOverviewFilter

	if not filter then
		return petsData or {}
	end

	local hasElementFilter = filter.elements and next(filter.elements) ~= nil
	local hasRoleFilter = filter.isDPS or filter.isSup or filter.isHeal or filter.isBreak or filter.isEnergy
	local selectedFormTypeMap, hasFormFilter = PetManagementDataHelper.getSelectedFormTypeMap(filter)
	local ret = {}

	for _, tradePetData in ipairs(petsData or EMPTY_TABLE) do
		local petConfig = PetData[tradePetData.id]
		local isMatched = petConfig ~= nil

		if isMatched and not string.isNilOrEmpty(filter.keyword) then
			local petName = TradeMarketUtils.getPetName(tradePetData.id)

			isMatched = string.find(petName, filter.keyword, 1, true) ~= nil
		end

		if isMatched and hasElementFilter then
			local elementMatched = false
			local _, elementNames = LuaUIUtils.getElementInfo(petConfig.elementType)

			for _, elementData in ipairs(elementNames or EMPTY_TABLE) do
				if filter.elements[elementData.element] ~= nil then
					elementMatched = true

					break
				end
			end

			isMatched = elementMatched
		end

		if isMatched and hasRoleFilter then
			local petType = petConfig.functionId

			isMatched = filter.isDPS and Utils.isMatchPetFuncType(petType, UIConst.NEW_PET_BATTLE_TYPE.DPS) or filter.isSup and Utils.isMatchPetFuncType(petType, UIConst.NEW_PET_BATTLE_TYPE.SUP) or filter.isHeal and Utils.isMatchPetFuncType(petType, UIConst.NEW_PET_BATTLE_TYPE.HEAL) or filter.isBreak and Utils.isMatchPetFuncType(petType, UIConst.NEW_PET_BATTLE_TYPE.BREAK) or filter.isEnergy and Utils.isMatchPetFuncType(petType, UIConst.NEW_PET_BATTLE_TYPE.ENERGY) or false
		end

		if isMatched and hasFormFilter then
			local formTypeId = Utils.getPetFormIdByTemplateId(tradePetData.id)

			isMatched = selectedFormTypeMap[formTypeId] == true
		end

		if isMatched then
			ret[#ret + 1] = tradePetData
		end
	end

	return ret
end

function TradeMarketPetListComponent:openPetFilterPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
		disableSessionCache = true,
		noTab = true,
		filterType = UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPetOverview,
		filter = self.petOverviewFilter,
		doFilterCallback = function(filter)
			self.petOverviewFilter = Utils.deepCopyTable(filter)

			if self._entered and self._currentSubTabData then
				self:refreshPetData(self._currentSubTabData)
			end
		end
	})
end

function TradeMarketPetListComponent:getFollowPetData()
	local ret = {}

	for _, subTabData in ipairs(self.subTabData or EMPTY_TABLE) do
		if not subTabData.isFollow then
			for _, petData in ipairs(TradeMarketUtils.getPetData(subTabData.subIndex)) do
				local tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Pet, petData.id)

				if pg.me:isTradeItemFollow(tradeItemKey) then
					petData.isFollow = true
					ret[#ret + 1] = petData
				end
			end
		end
	end

	return ret
end

function TradeMarketPetListComponent:refreshPetsList()
	self.listPetUList:SetList(self.curPetsData)
end

function TradeMarketPetListComponent:_selectSubTab(subTabIndex)
	for index, data in ipairs(self.subTabData) do
		if data.subIndex == subTabIndex then
			self.listTab3thUList:SelectItem(index - 1, false)

			return
		end
	end
end

function TradeMarketPetListComponent:onDestroy()
	if self._contentLoaded then
		self.btnSellUButton.luaClick = nil
		self.btnSortUButton.luaClick = nil
		self.listTab3thUList.luaRenderItem = nil
		self.listTab3thUList.luaClick = nil
		self.listPetUList.luaRenderItem = nil
	end

	self.petOverviewFilter = nil

	TradeMarketSubPageComponent.onDestroy(self)
end

function TradeMarketPetListComponent:openSellPetUI()
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_SELL_PET)
end

return TradeMarketPetListComponent
