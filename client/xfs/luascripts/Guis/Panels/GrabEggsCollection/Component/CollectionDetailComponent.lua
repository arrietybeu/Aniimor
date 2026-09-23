-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\Component\\CollectionDetailComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local RobEggCollectionCalcineRankData = require("Data.rob_egg_collection_calcine_rank_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")
local CollectionDetailComponent = Class.LightClass("CollectionDetailComponent")
local BASE_CASE_ID = 1001
local ANTIQUE_DATA_KEY = ItemConst.ItemPropertyDef.AntiqueData
local MIN_ANTIQUE_LEVEL = ItemConst.AntiqueLevel.LEVEL_C
local MAX_ANTIQUE_LEVEL = ItemConst.AntiqueLevel.LEVEL_SSS
local COLLECTION_ITEM_CLICK_SUPPRESS_DURATION = 0.2

function CollectionDetailComponent:ctor(rootTransform, ctrl, model)
	self.rootTransform = rootTransform
	self.ctrl = ctrl
	self.model = model
	self.selectedSlotTransform = nil
	self.selectedSlotData = nil
	self.suppressCollectionItemClickUntil = 0
end

function CollectionDetailComponent:init()
	self:findObjects()
	self:addListener()
end

function CollectionDetailComponent:findObjects()
	local objectReference = self.rootTransform:GetComponent("ObjectReference")

	self.detailPanel = objectReference:GetRefValue("detailPanel")

	if self.detailPanel then
		local detailPanelRef = self.detailPanel:GetComponent("ObjectReference")

		self.collectionList = detailPanelRef:GetRefValue("collectionList")
		self.emptyTitle = detailPanelRef:GetRefValue("emptyTitle")
		self.emptyDetail = detailPanelRef:GetRefValue("emptyDetail")
		self.BtnReview = detailPanelRef:GetRefValue("BtnReview")
		self.BtnReviewTxt = detailPanelRef:GetRefValue("BtnReviewTxt")
		self.tagPanel = detailPanelRef:GetRefValue("tagPanel")
		self.tagTxt = detailPanelRef:GetRefValue("tagTxt")
		self.weightTxt = detailPanelRef:GetRefValue("weightTxt")
		self.valueTxt = detailPanelRef:GetRefValue("valueTxt")
		self.pointTxt = detailPanelRef:GetRefValue("pointTxt")
		self.name = detailPanelRef:GetRefValue("name")
		self.btnRetrieve = detailPanelRef:GetRefValue("btnRetrieve")
		self.btnRetrieveTxt = detailPanelRef:GetRefValue("btnRetrieveTxt")
		self.btnReplace = detailPanelRef:GetRefValue("btnReplace")
		self.btnReplaceTxt = detailPanelRef:GetRefValue("btnReplaceTxt")

		ClientTextUtils.setText(self.emptyTitle, pg.getGameString("GRAB_EGG_Collection_Unkown_Title"))
		ClientTextUtils.setText(self.emptyDetail, pg.getGameString("GRAB_EGG_Collection_Unkown_Text"))
		ClientTextUtils.setText(self.BtnReviewTxt, pg.getGameString("GRAB_EGG_Collection_Button_Review"))
		ClientTextUtils.setText(self.btnRetrieveTxt, pg.getGameString("GRAB_EGG_Collection_Button_Retrieve"))
		ClientTextUtils.setText(self.btnReplaceTxt, pg.getGameString("GRAB_EGG_Collection_Button_Replace"))
	end
end

function CollectionDetailComponent:addListener()
	if self.collectionList then
		function self.collectionList.luaRenderItem(item, index, data)
			self:renderCollectionItem(item, index, data)
		end
	end

	if self.BtnReview then
		function self.BtnReview.luaClick()
			self:onReviewBtnClick()
		end
	end

	if self.btnRetrieve then
		function self.btnRetrieve.luaClick()
			self:onRetrieveBtnClick()
		end
	end

	if self.btnReplace then
		function self.btnReplace.luaClick()
			self:onReplaceBtnClick()
		end
	end
end

function CollectionDetailComponent:onReviewBtnClick()
	local slotId = self.selectedSlotData and self.selectedSlotData.slotId
	local slotItem = self:getShowCaseSlotItem(slotId)

	if not slotItem or not slotItem.id then
		return
	end

	local initialRotation, modelScale

	if self.ctrl and self.ctrl.modelComponent and self.ctrl.modelComponent.getSlotModelRotation then
		initialRotation = self.ctrl.modelComponent:getSlotModelRotation(self.selectedSlotTransform)
	end

	if self.ctrl and self.ctrl.modelComponent and self.ctrl.modelComponent.getSlotModelScale then
		modelScale = self.ctrl.modelComponent:getSlotModelScale(self.selectedSlotTransform)
	end

	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_COLLECTION_DETAIL, {
		slotId = slotId,
		item = slotItem,
		initialRotation = initialRotation,
		modelScale = modelScale
	})
end

function CollectionDetailComponent:onRetrieveBtnClick()
	local slotId = self.selectedSlotData and self.selectedSlotData.slotId
	local slotItem = self:getShowCaseSlotItem(slotId)

	if not slotItem or not slotItem.id then
		return
	end

	local itemConfig = ItemData[slotItem.id]
	local itemName = itemConfig and itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or ""
	local slotTransform = self.selectedSlotTransform
	local slotData = self.selectedSlotData
	local ctrl = self.ctrl

	pg.global.ui.commonUseConfirm:open({
		muteCheckEnough = true,
		hideCurrency = 1,
		type = 4,
		title = pg.getGameString("GRAB_EGG_Collection_Retrieve_popup_Title"),
		tipTop = string.format(pg.getGameString("GRAB_EGG_Collection_Retrieve_popup_Text"), itemName),
		data = {},
		confirmCb = function()
			if ctrl and ctrl.onCollectionRetrieveConfirm then
				ctrl:onCollectionRetrieveConfirm(slotTransform, slotData)
			end
		end
	})
end

function CollectionDetailComponent:onReplaceBtnClick()
	if not self.selectedSlotTransform or not self.selectedSlotData then
		return
	end

	if self.ctrl and self.ctrl.startCollectionReplace then
		self.ctrl:startCollectionReplace(self.selectedSlotTransform, self.selectedSlotData)
	end
end

function CollectionDetailComponent:setDetailPanelVisible(visible)
	self:setDetailNodeVisible(self.detailPanel, visible)
end

function CollectionDetailComponent:getCurrentTime()
	return Time.unscaledTime
end

function CollectionDetailComponent:suppressCollectionItemClick(duration)
	self.suppressCollectionItemClickUntil = self:getCurrentTime() + (duration or COLLECTION_ITEM_CLICK_SUPPRESS_DURATION)
end

function CollectionDetailComponent:isCollectionItemClickSuppressed()
	return self:getCurrentTime() < (self.suppressCollectionItemClickUntil or 0)
end

function CollectionDetailComponent:isSameSlotId(slotIdA, slotIdB)
	if slotIdA == nil or slotIdB == nil then
		return false
	end

	return tostring(slotIdA) == tostring(slotIdB)
end

function CollectionDetailComponent:getShowCaseSlotItem(slotId)
	if not slotId or not pg.me or not pg.me.showCases then
		return nil
	end

	local showCase = pg.me.showCases[BASE_CASE_ID]

	if not showCase then
		return nil
	end

	return showCase[slotId] or showCase[tonumber(slotId)] or showCase[tostring(slotId)]
end

function CollectionDetailComponent:getSlotConfig(slotId)
	if not slotId then
		return nil
	end

	return RobEggBookCollectionData[slotId] or RobEggBookCollectionData[tonumber(slotId)] or RobEggBookCollectionData[tostring(slotId)]
end

function CollectionDetailComponent:getCollectionSortValue(data)
	local slotConfig = data and (data.slotConfig or self:getSlotConfig(data.slotId))
	local sortValue = slotConfig and tonumber(slotConfig.sort)

	if sortValue ~= nil then
		return sortValue
	end

	return tonumber(data and data.slotId) or math.huge
end

function CollectionDetailComponent:sortCollectionList(list)
	table.sort(list, function(a, b)
		local sortA = self:getCollectionSortValue(a)
		local sortB = self:getCollectionSortValue(b)

		if sortA ~= sortB then
			return sortA < sortB
		end

		return (tonumber(a and a.slotId) or 0) < (tonumber(b and b.slotId) or 0)
	end)
end

function CollectionDetailComponent:resolveSelectedSlotData(slotTransform, slotData)
	if slotData and slotData.slotId then
		return slotData
	end

	local modelComponent = self.ctrl and self.ctrl.modelComponent
	local modelSlotData = modelComponent and modelComponent.slotModels and slotTransform and modelComponent.slotModels[slotTransform]

	if modelSlotData and modelSlotData.slotId then
		return modelSlotData
	end

	if modelComponent and modelComponent.getCollectionSlotList then
		for _, slotInfo in ipairs(modelComponent:getCollectionSlotList() or EMPTY_TABLE) do
			if slotInfo.slotTransform == slotTransform and slotInfo.slotId then
				return slotInfo.slotData or {
					slotId = slotInfo.slotId
				}
			end
		end
	end

	return slotData
end

function CollectionDetailComponent:refresh(slotTransform, slotData, scrollToSelected)
	if slotTransform then
		self.selectedSlotTransform = slotTransform
	end

	local selectedSlotData = self:resolveSelectedSlotData(self.selectedSlotTransform, slotData)

	if selectedSlotData then
		self.selectedSlotData = selectedSlotData
	end

	self:refreshCollectionList(scrollToSelected)
	self:refreshDetailDisplay()
end

function CollectionDetailComponent:refreshCollectionList(scrollToSelected)
	if not self.collectionList then
		return
	end

	local list = self:getCollectionListData()

	self.collectionList:SetList(list)

	if scrollToSelected then
		self:scrollCollectionListToSelected(list)
	end
end

function CollectionDetailComponent:getCollectionListData()
	local slotList = self:getSceneSlotList()
	local list = {}
	local selectedSlotId = self.selectedSlotData and self.selectedSlotData.slotId

	for _, slotInfo in ipairs(slotList) do
		local slotId = slotInfo.slotId
		local slotConfig = slotInfo.slotConfig or self:getSlotConfig(slotId)

		if slotId and slotConfig then
			local hasItem = slotInfo.hasItem == true

			table.insert(list, {
				slotId = slotId,
				slotConfig = slotConfig,
				slotTransform = slotInfo.slotTransform,
				slotData = slotInfo.slotData,
				name = slotConfig.name,
				point = slotConfig.point,
				listImage = slotConfig.listImage,
				isSelected = self:isSameSlotId(slotId, selectedSlotId),
				hasItem = hasItem,
				canPlace = not hasItem and self:hasAvailableBagItem(slotId)
			})
		end
	end

	self:sortCollectionList(list)

	return list
end

function CollectionDetailComponent:getSceneSlotList()
	if self.ctrl and self.ctrl.modelComponent and self.ctrl.modelComponent.getCollectionSlotList then
		local slotList = self.ctrl.modelComponent:getCollectionSlotList()

		if slotList and #slotList > 0 then
			return slotList
		end
	end

	local slotList = {}

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID then
			table.insert(slotList, {
				slotId = slotId,
				slotConfig = slotConfig,
				hasItem = self:hasCollectionItem(slotId)
			})
		end
	end

	self:sortCollectionList(slotList)

	return slotList
end

function CollectionDetailComponent:renderCollectionItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")

	if not objectReference or not data then
		return
	end

	local icon = objectReference:GetRefValue("icon")
	local iconEmpty = objectReference:GetRefValue("iconEmpty")
	local select = objectReference:GetRefValue("select")

	if icon then
		icon.url = data.listImage or ""
	end

	if iconEmpty then
		iconEmpty.url = data.listImage or ""
	end

	select:SetActive(data.isSelected == true)
	item:TryChangePage("Stage", data.hasItem and 0 or 1)

	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_COLLECTION_SLOT_PLACE, data.slotId)

	pg.global.setRedDot(redDotPath, item, data.canPlace == true, RedDotConst.RedDotStyle.POINT)

	function item.luaClick()
		self:onCollectionItemClick(data)
	end

	function item.luaNavFocused()
		self:onCollectionItemFocused(data)
	end
end

function CollectionDetailComponent:hasAvailableBagItem(slotId)
	local modelComponent = self.ctrl and self.ctrl.modelComponent

	if not modelComponent or not modelComponent.hasAvailableBagItem then
		return false
	end

	return modelComponent:hasAvailableBagItem(slotId)
end

function CollectionDetailComponent:scrollCollectionListToSelected(list)
	if not self.collectionList or not list then
		return
	end

	local selectedIndex

	for index, data in ipairs(list) do
		if data.isSelected then
			selectedIndex = index - 1

			break
		end
	end

	if not selectedIndex then
		return
	end

	self:goToCollectionListIndex(selectedIndex)
	self:focusCollectionListIndex(selectedIndex)
	TimerManager.addNextFrameCb(function()
		if self.collectionList then
			self:goToCollectionListIndex(selectedIndex)
			self:focusCollectionListIndex(selectedIndex)
		end
	end)
	TimerManager.addSpecificFrameCb(2, false, function()
		if self.collectionList then
			self:focusCollectionListIndex(selectedIndex)
		end
	end)
end

function CollectionDetailComponent:focusCollectionListIndex(index)
	if not self.collectionList or index == nil then
		return
	end

	local navMgr = pg and pg.global and pg.global.navMgr

	if navMgr and pg.game and pg.game.input and pg.game.input.isUsingGamepad and pg.game.input:isUsingGamepad() and navMgr.FocusItem then
		pcall(function()
			local success, item = self.collectionList:TryGetChildAt(index)

			if success and item then
				navMgr:FocusItem(item)
			end
		end)
	end
end

function CollectionDetailComponent:goToCollectionListIndex(index)
	if not self.collectionList or index == nil then
		return
	end

	local success = pcall(function()
		self.collectionList:RedirectToCenter(index, false, true)
	end)

	if not success then
		pcall(function()
			self.collectionList:GoToIndexMinCost(index, false, true)
		end)
	end
end

function CollectionDetailComponent:hasCollectionItem(slotId)
	local slotItem = self:getShowCaseSlotItem(slotId)

	return slotItem and slotItem.id and slotItem.id > 0
end

function CollectionDetailComponent:onCollectionItemClick(data)
	if self:isCollectionItemClickSuppressed() then
		return
	end

	local selectedSlotData = data.slotData or {
		slotId = data.slotId
	}

	if self.ctrl and self.ctrl.onCollectionDetailItemClick then
		local shouldContinue = self.ctrl:onCollectionDetailItemClick(data.slotTransform, selectedSlotData)

		if shouldContinue == false then
			return
		end
	end

	self.selectedSlotTransform = data.slotTransform
	self.selectedSlotData = selectedSlotData

	self:refreshCollectionList()
	self:refreshDetailDisplay()

	if self.ctrl and self.ctrl.onCollectionDetailSelectionChanged then
		self.ctrl:onCollectionDetailSelectionChanged(data.slotTransform, self.selectedSlotData)
	end

	if self.ctrl and self.ctrl.modelComponent and data.slotTransform then
		self.ctrl.modelComponent:focusSlot(data.slotTransform, self.selectedSlotData)
	end
end

function CollectionDetailComponent:onCollectionItemFocused(data)
	if not data then
		return
	end

	local selectedSlotData = data.slotData or {
		slotId = data.slotId
	}
	local isSameSelection = self.selectedSlotTransform == data.slotTransform and self:isSameSlotId(self.selectedSlotData and self.selectedSlotData.slotId, selectedSlotData.slotId)

	self.selectedSlotTransform = data.slotTransform
	self.selectedSlotData = selectedSlotData

	if not isSameSelection then
		self:refreshCollectionList()
		self:refreshDetailDisplay()
	end

	if self.ctrl and self.ctrl.onCollectionDetailSelectionChanged then
		self.ctrl:onCollectionDetailSelectionChanged(data.slotTransform, selectedSlotData)
	end
end

function CollectionDetailComponent:refreshDetailDisplay()
	if not self.detailPanel then
		return
	end

	local slotId = self.selectedSlotData and self.selectedSlotData.slotId
	local slotConfig = self:getSlotConfig(slotId)
	local slotItem = self:getShowCaseSlotItem(slotId)
	local hasItem = slotItem and slotItem.id and slotItem.id > 0
	local hasReplacement = hasItem and self.ctrl and self.ctrl.modelComponent and self.ctrl.modelComponent:hasAvailableBagItem(slotId) or false

	self.detailPanel:TryChangePage("Stage", hasItem and 0 or 1)
	self:setDetailNodeVisible(self.btnReplace, hasReplacement)

	if not hasItem then
		self:setDetailText(self.name, "")
		self:setDetailText(self.weightTxt, "")
		self:setDetailText(self.valueTxt, "")
		self:setDetailText(self.pointTxt, "")
		self:setDetailNodeVisible(self.tagPanel, false)
		self:setDetailText(self.tagTxt, "")

		return
	end

	local itemConfig = ItemData[slotItem.id] or {}
	local itemInData = RobEggItemOut[slotItem.id]
	local weightConfig = itemInData and ItemData[itemInData.inid] or itemConfig

	self:setDetailText(self.name, itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or "")
	self:setDetailText(self.weightTxt, string.format("%sKG", weightConfig.weight or 0))
	self:setDetailText(self.valueTxt, tostring(LuaUIUtils.getPropDecomposeNum({
		itemId = slotItem.id,
		packSlot = slotItem
	}, itemConfig.sellPrice or 0)))
	self:setDetailText(self.pointTxt, tostring(slotConfig and slotConfig.point or 0))

	local antiqueData = slotItem.props and slotItem.props[ANTIQUE_DATA_KEY]
	local isCalcined = antiqueData and (antiqueData.affix_num or 0) > 0

	self:setDetailNodeVisible(self.tagPanel, isCalcined)

	if isCalcined and self.tagPanel then
		local level = math.min(MAX_ANTIQUE_LEVEL, math.max(MIN_ANTIQUE_LEVEL, antiqueData.degree or MIN_ANTIQUE_LEVEL))
		local rankConfig = RobEggCollectionCalcineRankData[level]

		self.tagPanel:TryChangePage("Level", level - 1)
		self:setDetailText(self.tagTxt, rankConfig and pg.getLocalizationText(rankConfig.rankName) or "")
	else
		self:setDetailText(self.tagTxt, "")
	end
end

function CollectionDetailComponent:setDetailText(textNode, value)
	if textNode then
		ClientTextUtils.setText(textNode, value)
	end
end

function CollectionDetailComponent:setDetailNodeVisible(node, visible)
	if not node then
		return
	end

	if node.SetActive then
		node:SetActive(visible)
	elseif node.gameObject then
		node.gameObject:SetActive(visible)
	end
end

function CollectionDetailComponent:clear()
	self.selectedSlotTransform = nil
	self.selectedSlotData = nil
	self.suppressCollectionItemClickUntil = 0
end

function CollectionDetailComponent:destroy()
	self:clear()

	self.detailPanel = nil
	self.collectionList = nil
	self.btnRetrieve = nil
	self.btnReplace = nil
	self.emptyTitle = nil
	self.emptyDetail = nil
	self.rootTransform = nil
	self.ctrl = nil
	self.model = nil
end

return CollectionDetailComponent
