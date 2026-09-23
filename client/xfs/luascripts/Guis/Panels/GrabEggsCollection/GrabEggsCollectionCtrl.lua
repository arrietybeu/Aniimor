-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\GrabEggsCollectionCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsCollectionCtrl = Class.LightClass("GrabEggsCollectionCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local TimerManager = require("Core.Timer.TimerManager")
local BaseCollectionRewardComponent = require("Guis.Panels.GrabEggsCollection.Component.BaseCollectionRewardComponent")
local CollectionDetailComponent = require("Guis.Panels.GrabEggsCollection.Component.CollectionDetailComponent")
local CollectionGamepadComponent = require("Guis.Panels.GrabEggsCollection.Component.CollectionGamepadComponent")
local CollectionModelComponent = require("Guis.Panels.GrabEggsCollection.Component.CollectionModelComponent")
local PopUpComponent = require("Guis.Panels.GrabEggsCollection.Component.PopUpComponent")
local BASE_CASE_ID = 1001
local POP_UP_MODE_REPLACE = "replace"
local PageEnum = {
	SeasonMode = 1,
	BaseMode = 0
}
local PAGE_MAX = PageEnum.SeasonMode
local PageTxtMap = {
	[PageEnum.BaseMode] = "",
	[PageEnum.SeasonMode] = ""
}
local StageEnum = {
	Normal = 0,
	CollectionDetail = 1
}

GrabEggsCollectionCtrl.messages = {}

function GrabEggsCollectionCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.currentPage = PageEnum.BaseMode
	self.currentStage = StageEnum.Normal
	self.isReplacingCollection = false
	self.replaceSlotTransform = nil
	self.replaceSlotData = nil
	self.pageList = {}

	for i = 0, PAGE_MAX do
		local a = {
			i
		}

		table.insert(self.pageList, a)
	end

	self.baseRewardComponent = BaseCollectionRewardComponent.new(self.view.transform, self, self.model)

	self.baseRewardComponent:init()

	self.collectionDetailComponent = CollectionDetailComponent.new(self.view.transform, self, self.model)

	self.collectionDetailComponent:init()
	self:refreshDetailPanelVisibility()

	self.popUpComponent = PopUpComponent.new(self.view.transform, self, self.model)

	self.popUpComponent:init()

	if self.uiScene then
		self.modelComponent = CollectionModelComponent.new(self.uiScene, self)

		self.modelComponent:init()

		self.collectionGamepadComponent = CollectionGamepadComponent.new(self.view.transform, self, self.modelComponent)

		self.collectionGamepadComponent:init()
	end

	self:initView()
end

function GrabEggsCollectionCtrl:initView()
	self:refreshBackButtonTitle()
	self:refreshSeasonList()
end

function GrabEggsCollectionCtrl:isCollectionDetailStage()
	return self.currentStage == StageEnum.CollectionDetail
end

function GrabEggsCollectionCtrl:refreshBackButtonTitle()
	ClientTextUtils.setText(self.view.btnBackUButtonTxt, pg.getGameString(self.currentStage == StageEnum.CollectionDetail and "GRAB_EGG_Collection_Title_Detail" or "GRAB_EGG_Collection_Title_Main"))
end

function GrabEggsCollectionCtrl:refreshSeasonList()
	local seasonData = self.model:getSeason()

	self.view.seasonList:SetList(seasonData)
end

function GrabEggsCollectionCtrl:renderSeasonItem(item, index, data)
	return
end

function GrabEggsCollectionCtrl:renderSwitchLine(item, index)
	local isActive = index == self.currentPage

	item:TryChangePage("Switch", isActive and 0 or 1)
end

function GrabEggsCollectionCtrl:applyState()
	self.view.panel:TryChangePage("Page", self.currentPage)
	self.view.panel:TryChangePage("Stage", self.currentStage)
	self:refreshDetailPanelVisibility()
	self:refreshBackButtonTitle()
	self:refreshSwitchBar()
	self:refreshCurrentPageComponent()
end

function GrabEggsCollectionCtrl:setStage(stage)
	self.currentStage = stage

	self.view.panel:TryChangePage("Stage", self.currentStage)
	self:refreshDetailPanelVisibility()
	self:refreshBackButtonTitle()

	if self.collectionGamepadComponent and self.collectionGamepadComponent.refreshArrowVisibility then
		self.collectionGamepadComponent:refreshArrowVisibility()
	end

	if self.currentStage == StageEnum.CollectionDetail and self.popUpComponent then
		self.popUpComponent:clear()
	end
end

function GrabEggsCollectionCtrl:refreshDetailPanelVisibility()
	if not self.collectionDetailComponent then
		return
	end

	local visible = self.currentStage == StageEnum.CollectionDetail and not self.isReplacingCollection

	self.collectionDetailComponent:setDetailPanelVisible(visible)
end

function GrabEggsCollectionCtrl:refreshCurrentPageComponent()
	if self.currentStage == StageEnum.CollectionDetail then
		if self.collectionDetailComponent then
			self.collectionDetailComponent:refresh()
		end
	elseif self.currentPage == PageEnum.BaseMode and self.baseRewardComponent then
		self.baseRewardComponent:refresh()
	end

	self:refreshScene()
end

function GrabEggsCollectionCtrl:refreshScene()
	if self.modelComponent then
		self.modelComponent:refreshAllSlots()
	end
end

function GrabEggsCollectionCtrl:refreshSwitchBar()
	ClientTextUtils.setText(self.view.switchTitle, PageTxtMap[self.currentPage])
	self.view.switchLineList:SetList(self.pageList)
end

function GrabEggsCollectionCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:onBackBtnClick()
	end

	self:bindCloseButton()

	function self.view.switchLineList.luaRenderItem(item, index, _data)
		self:renderSwitchLine(item, index)
	end

	function self.view.seasonList.luaRenderItem(item, index, data)
		self:renderSeasonItem(item, index, data)
	end

	function self.view.preBtn.luaClick()
		self:onPreBtnClick()
	end

	function self.view.nextBtn.luaClick()
		self:onNextBtnClick()
	end
end

function GrabEggsCollectionCtrl:onBackBtnClick()
	if self.popUpComponent and self.popUpComponent:isVisible() then
		self:closePlacePopUp()

		return
	end

	if self.currentStage == StageEnum.CollectionDetail then
		self:returnToNormalFromDetail()

		return
	end

	self:close()
end

function GrabEggsCollectionCtrl:returnToNormalFromDetail(callback)
	self:setStage(StageEnum.Normal)

	if self.collectionDetailComponent then
		self.collectionDetailComponent:clear()
	end

	if self.modelComponent then
		self.modelComponent:resetAllSlotPresentationStates()
		self.modelComponent:resetCamera(function()
			if self.modelComponent then
				self.modelComponent:refreshPlaceTips()
				self.modelComponent:setInteractionEnabled(true)
			end

			if callback then
				callback()
			end
		end)

		return
	end

	if callback then
		callback()
	end
end

function GrabEggsCollectionCtrl:onCollectionSlotClick(slotTransform, slotData)
	if self.currentStage == StageEnum.CollectionDetail then
		return false
	end

	if self:shouldShowPlacePopUp(slotData) then
		self:showPlacePopUp(slotTransform, slotData)

		return false
	end

	if self.popUpComponent then
		self.popUpComponent:clear()
	end

	self:setStage(StageEnum.CollectionDetail)

	if self.collectionDetailComponent then
		self.collectionDetailComponent:refresh(slotTransform, slotData, true)
	end

	if self.modelComponent then
		self.modelComponent:setPlaceTipsVisible(false)
		self.modelComponent:setInteractionEnabled(false)
	end

	return true
end

function GrabEggsCollectionCtrl:onCollectionDetailItemClick(slotTransform, slotData)
	if not self:shouldShowPlacePopUp(slotData) then
		return true
	end

	self:returnToNormalFromDetail(function()
		self:showPlacePopUp(slotTransform, slotData)
	end)

	return false
end

function GrabEggsCollectionCtrl:onCollectionDetailSelectionChanged(slotTransform, slotData)
	if self.collectionGamepadComponent and slotTransform then
		self.collectionGamepadComponent:setSelectedSlot(slotTransform)
	end
end

function GrabEggsCollectionCtrl:showPlacePopUp(slotTransform, slotData)
	if self.modelComponent then
		self.modelComponent:setInteractionEnabled(false)
	end

	if self.popUpComponent then
		self.popUpComponent:show(slotTransform, slotData)
	end
end

function GrabEggsCollectionCtrl:closePlacePopUp()
	if self.isReplacingCollection then
		self:finishCollectionReplace()

		return
	end

	if self.popUpComponent then
		self.popUpComponent:clear()
	end

	if self.currentStage == StageEnum.Normal and self.modelComponent then
		self.modelComponent:setInteractionEnabled(true)
	end
end

function GrabEggsCollectionCtrl:startCollectionReplace(slotTransform, slotData)
	local slotId = slotData and slotData.slotId

	if self.currentStage ~= StageEnum.CollectionDetail or not slotTransform or not slotId then
		return
	end

	if not self.modelComponent or not self.modelComponent:hasAvailableBagItem(slotId) then
		return
	end

	self.isReplacingCollection = true
	self.replaceSlotTransform = slotTransform
	self.replaceSlotData = slotData

	if self.collectionDetailComponent then
		self.collectionDetailComponent:setDetailPanelVisible(false)
	end

	self.modelComponent:setInteractionEnabled(false)
	self.modelComponent:focusSlotForReplace(slotTransform, slotData)

	if self.popUpComponent then
		self.popUpComponent:show(slotTransform, slotData, POP_UP_MODE_REPLACE)
	end
end

function GrabEggsCollectionCtrl:finishCollectionReplace()
	local slotTransform = self.replaceSlotTransform
	local slotData = self.replaceSlotData

	self.isReplacingCollection = false
	self.replaceSlotTransform = nil
	self.replaceSlotData = nil

	if self.popUpComponent then
		self.popUpComponent:clear()
	end

	if self.collectionDetailComponent then
		self.collectionDetailComponent:setDetailPanelVisible(true)
		self.collectionDetailComponent:refresh(slotTransform, slotData, true)
	end

	if self.modelComponent and slotTransform then
		self.modelComponent:setInteractionEnabled(false)
		self.modelComponent:focusSlot(slotTransform, slotData)
	end
end

function GrabEggsCollectionCtrl:onPlacePopUpConfirm(slotTransform, slotData, bagItemData)
	local item = bagItemData and bagItemData.item
	local genId = bagItemData and bagItemData.genId or item and (item.genID or item.genId)
	local slotId = slotData and slotData.slotId

	if not genId or not slotId then
		return
	end

	pg.me:serverMsg("RPC_CS_PutIntoShowCase", genId, BASE_CASE_ID, slotId, function(noticeId)
		if noticeId ~= nil and noticeId ~= 0 then
			return
		end

		self:closePlacePopUp()
		TimerManager.addTimer(0.2, function()
			self:refreshAfterPlacePopUpConfirm()

			if self.modelComponent then
				self.modelComponent:playSlotAppearEffect(slotId)
			end
		end)
	end)
end

function GrabEggsCollectionCtrl:onReplacePopUpConfirm(slotTransform, slotData, bagItemData)
	local item = bagItemData and bagItemData.item
	local genId = bagItemData and bagItemData.genId or item and (item.genID or item.genId)
	local slotId = slotData and slotData.slotId
	local expectedItemCount = self.popUpComponent and #self.popUpComponent.bagCollectionItems or nil

	if not genId or not slotId then
		return
	end

	pg.me:serverMsg("RPC_CS_PutIntoShowCase", genId, BASE_CASE_ID, slotId, function(noticeId)
		if noticeId ~= nil and noticeId ~= 0 then
			return
		end

		TimerManager.addTimer(0.2, function()
			self:refreshAfterCollectionReplace(slotTransform, slotData, genId, expectedItemCount)

			if self.modelComponent then
				self.modelComponent:playSlotAppearEffect(slotId)
			end
		end)
	end)
end

function GrabEggsCollectionCtrl:refreshAfterPlacePopUpConfirm()
	if not self.model then
		return
	end

	self.model:refreshSlotItemData()

	if self.modelComponent then
		self.modelComponent:refreshAllSlots()
	end

	if self.baseRewardComponent then
		self.baseRewardComponent:refresh()
	end

	self:refreshCollectionEntryRedDots()
end

function GrabEggsCollectionCtrl:refreshCollectionEntryRedDots()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_COLLECTION)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE)
end

function GrabEggsCollectionCtrl:refreshAfterCollectionReplace(slotTransform, slotData, replacedGenId, expectedItemCount)
	self:refreshAfterPlacePopUpConfirm()

	if not self.isReplacingCollection or self.replaceSlotTransform ~= slotTransform then
		return
	end

	if self.collectionDetailComponent then
		self.collectionDetailComponent:refresh(slotTransform, slotData)
		self.collectionDetailComponent:setDetailPanelVisible(false)
	end

	self:refreshCollectionReplacePopUp(slotData, replacedGenId, expectedItemCount, 0)
end

function GrabEggsCollectionCtrl:refreshCollectionReplacePopUp(slotData, replacedGenId, expectedItemCount, retryCount)
	if not self.isReplacingCollection or not self.model then
		return
	end

	self.model:refreshSlotItemData()

	if self.popUpComponent then
		self.popUpComponent:refresh()
	end

	local slotId = slotData and slotData.slotId
	local slotItems = slotId and self.model:getSlotItemData(slotId) or nil
	local isWaitingForBagSync = false

	for _, slotItem in ipairs(slotItems or EMPTY_TABLE) do
		if slotItem.genId == replacedGenId then
			isWaitingForBagSync = true

			break
		end
	end

	if expectedItemCount and expectedItemCount > #(slotItems or {}) then
		isWaitingForBagSync = true
	end

	if isWaitingForBagSync and retryCount < 20 then
		TimerManager.addTimer(0.1, function()
			self:refreshCollectionReplacePopUp(slotData, replacedGenId, expectedItemCount, retryCount + 1)
		end)

		return
	end

	if not isWaitingForBagSync then
		self:refreshAfterPlacePopUpConfirm()

		if self.collectionDetailComponent then
			self.collectionDetailComponent:refresh(self.replaceSlotTransform, self.replaceSlotData)
			self.collectionDetailComponent:setDetailPanelVisible(false)
		end
	end
end

function GrabEggsCollectionCtrl:onCollectionRetrieveConfirm(slotTransform, slotData)
	local slotId = slotData and slotData.slotId

	if not slotId then
		return
	end

	pg.me:serverMsg("RPC_CS_PutOutSideShowCase", BASE_CASE_ID, slotId, function(noticeId)
		if noticeId ~= nil and noticeId ~= 0 then
			return
		end

		TimerManager.addTimer(0.2, function()
			self:refreshAfterCollectionRetrieve()
		end)
	end)
end

function GrabEggsCollectionCtrl:refreshAfterCollectionRetrieve()
	if not self.model then
		return
	end

	self.model:refreshSlotItemData()

	if self.modelComponent then
		self.modelComponent:refreshAllSlots()
	end

	if self.baseRewardComponent then
		self.baseRewardComponent:refresh()
	end

	self:refreshCollectionEntryRedDots()
	self:returnToNormalFromDetail()
end

function GrabEggsCollectionCtrl:shouldShowPlacePopUp(slotData)
	local slotId = slotData and slotData.slotId

	if not slotId or not self.modelComponent then
		return false
	end

	return not self.modelComponent:hasPlacedItem(slotId) and self.modelComponent:hasAvailableBagItem(slotId)
end

function GrabEggsCollectionCtrl:onPreBtnClick()
	self.currentPage = (self.currentPage - 1 + PAGE_MAX + 1) % (PAGE_MAX + 1)

	self:applyState()
end

function GrabEggsCollectionCtrl:onNextBtnClick()
	self.currentPage = (self.currentPage + 1) % (PAGE_MAX + 1)

	self:applyState()
end

function GrabEggsCollectionCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info then
		if info.page then
			self.currentPage = info.page
		end

		if info.stage then
			self.currentStage = info.stage
		end
	end

	self.model:refreshSlotItemData()

	self.isReplacingCollection = false
	self.replaceSlotTransform = nil
	self.replaceSlotData = nil

	if self.popUpComponent then
		self.popUpComponent:clear()
	end

	self:applyState()
end

function GrabEggsCollectionCtrl:onDestroy()
	if self.baseRewardComponent then
		self.baseRewardComponent:destroy()

		self.baseRewardComponent = nil
	end

	if self.collectionDetailComponent then
		self.collectionDetailComponent:destroy()

		self.collectionDetailComponent = nil
	end

	if self.popUpComponent then
		self.popUpComponent:destroy()

		self.popUpComponent = nil
	end

	if self.collectionGamepadComponent then
		self.collectionGamepadComponent:destroy()

		self.collectionGamepadComponent = nil
	end

	if self.modelComponent then
		self.modelComponent:destroy()

		self.modelComponent = nil
	end

	UICtrl.onDestroy(self)
end

function GrabEggsCollectionCtrl:onShow()
	self:refreshCurrentPageComponent()
end

function GrabEggsCollectionCtrl:onHide()
	return
end

return GrabEggsCollectionCtrl
