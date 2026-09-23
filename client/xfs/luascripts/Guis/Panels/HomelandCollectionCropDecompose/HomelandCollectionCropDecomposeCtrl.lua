-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCropDecompose\\HomelandCollectionCropDecomposeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropDecomposeCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local HomeSeasonMutationCollectionData = require("Data.home_season_mutation_collection_data")
local HomelandCollectionCropDecomposeCtrl = Class.LightClass("HomelandCollectionCropDecomposeCtrl", UICtrl)

HomelandCollectionCropDecomposeCtrl.messages = {}

function HomelandCollectionCropDecomposeCtrl:getManagedBlurEffect()
	return self.view and self.view.transform:GetComponentInChildren(typeof(CS.UIBlurEffect))
end

function HomelandCollectionCropDecomposeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	self.seasonId = pg.me and pg.me.homeSeasonId or 1
	self.isDecomposing = false
	self.seasonCropListData = {}
	self.cropDataByItemId = {}
	self.selectedCountByItemId = {}
	self.currentItemId = nil

	self.view.selectorUWidget:SetActive(false)
	self:refreshCropListData()
	self:refreshCollectionCropDecompose()
end

function HomelandCollectionCropDecomposeCtrl:addListener()
	function self.view.btnClose1.luaClick()
		self:close()
	end

	function self.view.btnClose2.luaClick()
		self:close()
	end

	function self.view.btnCancel.luaClick()
		self:close()
	end

	function self.view.btnConfirm.luaClick()
		self:decomposeSelectedCrops()
	end

	function self.view.btnAllSelectedUButton.luaClick()
		self:setAllCropsSelected(not self.view.btnAllSelectedUButton.isSelected)
	end

	self.numSelector = self.view.btnInputUButton:GetComponentInParent(typeof(CS.XGUI.UNumSelector))

	function self.numSelector.luaValueChanged(value)
		self:setCurrentSelectedCount(value)
	end

	function self.view.listProp.luaRenderItem(button, index, data)
		self:renderCropItem(button, data)
	end

	function self.view.listReward.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.view.selectorUWidget.luaCloseAction()
		if self.view then
			self.view.selectorUWidget:SetActive(false)

			self.currentItemId = nil
		end
	end
end

function HomelandCollectionCropDecomposeCtrl:decomposeSelectedCrops()
	if self.isDecomposing or next(self.selectedCountByItemId) == nil then
		return
	end

	self.isDecomposing = true

	pg.me:reqDecomposeHomeSeasonMutationItems(self.selectedCountByItemId, function(result)
		self.isDecomposing = false

		if result ~= NoticeDef.SUCCESS or not self.view then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_DECOMPOSE_SUCCESS"))

		self.selectedCountByItemId = {}
		self.currentItemId = nil

		self.view.selectorUWidget:SetActive(false)
		self:refreshCropListData()
		self:refreshCollectionCropDecompose()
	end)
end

function HomelandCollectionCropDecomposeCtrl:refreshCollectionCropDecompose()
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_DECOMPOSE_TITLE"))
	ClientTextUtils.setText(self.view.txtLeftUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_DECOMPOSE_CROP"))
	ClientTextUtils.setText(self.view.txtRightUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_DECOMPOSE_REWARD"))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_DECOMPOSE_CONFIRM_DESC"))
	ClientTextUtils.setText(self.view.txtAllUSDFText, pg.getGameString("HOMELAND_PLOT_SELECT_ALL"))
	self.view.listReward:SetList(self:getRewardListData())
	self:refreshConfirmButtonState()
	self:refreshAllSelectedButtonState()
end

function HomelandCollectionCropDecomposeCtrl:refreshCropListData()
	self.seasonCropListData = {}
	self.cropDataByItemId = {}

	for itemId, collectionInfo in pairs(HomeSeasonMutationCollectionData) do
		if collectionInfo.seasonId == self.seasonId then
			local itemCount = ClientUtils.getItemCountById(itemId)

			if pg.me:isInSelfHomeland() then
				itemCount = itemCount + ClientUtils.getHomelandItemCountById(itemId)
			end

			if itemCount > 0 then
				local cropData = {
					itemId = itemId,
					itemCount = itemCount,
					rewardItemMap = collectionInfo.item
				}

				self.seasonCropListData[#self.seasonCropListData + 1] = cropData
				self.cropDataByItemId[itemId] = cropData
			end
		end
	end

	table.sort(self.seasonCropListData, function(a, b)
		return a.itemId < b.itemId
	end)
	self.view.listProp:SetList(self.seasonCropListData)
end

function HomelandCollectionCropDecomposeCtrl:renderCropItem(button, data)
	LuaUIUtils.renderItem(button, {
		id = data.itemId,
		num = data.itemCount
	})

	local objectReference = button:GetComponent("ObjectReference")
	local cancelUButton = objectReference:GetRefValue("cancelUButton")
	local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")

	selectedULayoutBox = selectedULayoutBox:GetComponent("UComponent")

	local selectedName = objectReference:GetRefValue("selectedName")
	local selectedCount = self.selectedCountByItemId[data.itemId] or 0
	local isSelected = selectedCount > 0

	button:TryChangePage("Cancel", isSelected and 1 or 0)
	selectedULayoutBox.gameObject:SetActiveEx(isSelected)
	ClientTextUtils.setText(selectedName, selectedCount)

	if isSelected then
		selectedULayoutBox:TryChangePage("Type", 1)
	end

	if isSelected then
		function cancelUButton.luaClick()
			self:cancelSelectedCrop(data.itemId)
		end
	else
		cancelUButton.luaClick = nil
	end

	function button.luaClick()
		self:openCropSelector(button, data.itemId)
	end
end

function HomelandCollectionCropDecomposeCtrl:setAllCropsSelected(isSelected)
	self.selectedCountByItemId = {}

	if isSelected then
		for _, cropData in ipairs(self.seasonCropListData) do
			self.selectedCountByItemId[cropData.itemId] = cropData.itemCount
		end
	else
		self.currentItemId = nil

		self.view.selectorUWidget:SetActive(false)
	end

	self:refreshSelectionInfo()
end

function HomelandCollectionCropDecomposeCtrl:isAllCropsSelected()
	if #self.seasonCropListData == 0 then
		return false
	end

	for _, cropData in ipairs(self.seasonCropListData) do
		if self.selectedCountByItemId[cropData.itemId] ~= cropData.itemCount then
			return false
		end
	end

	return true
end

function HomelandCollectionCropDecomposeCtrl:refreshAllSelectedButtonState()
	self.view.btnAllSelectedUButton:SetSelected(self:isAllCropsSelected())
end

function HomelandCollectionCropDecomposeCtrl:openCropSelector(button, itemId)
	self.currentItemId = itemId

	self:setSelectedCount(itemId, (self.selectedCountByItemId[itemId] or 0) + 1)
	self.view.selectorUWidget:SetActive(true)
	self.view.selectorUWidget:SetModal(false)
	self.view.selectorUWidget:OpenPopup(button)
	self:refreshNumSelectorInfo()
end

function HomelandCollectionCropDecomposeCtrl:setSelectedCount(itemId, count)
	local cropData = self.cropDataByItemId[itemId]

	if not cropData then
		return
	end

	count = math.max(0, math.min(math.floor(count), cropData.itemCount))

	if (self.selectedCountByItemId[itemId] or 0) == count then
		return
	end

	if count == 0 then
		self.selectedCountByItemId[itemId] = nil
	else
		self.selectedCountByItemId[itemId] = count
	end

	self:refreshSelectionInfo()
end

function HomelandCollectionCropDecomposeCtrl:setCurrentSelectedCount(count)
	if not self.currentItemId then
		return
	end

	self:setSelectedCount(self.currentItemId, count)
end

function HomelandCollectionCropDecomposeCtrl:refreshNumSelectorInfo()
	local cropData = self.cropDataByItemId[self.currentItemId]
	local selectedCount = self.selectedCountByItemId[self.currentItemId] or 0

	if not cropData then
		return
	end

	self.numSelector:SetAllValue(selectedCount, 0, cropData.itemCount, 1, false)

	local canIncrease = selectedCount < cropData.itemCount

	self.view.btnAddUButton.interactable = canIncrease
	self.view.btnMaxUButton.interactable = canIncrease
end

function HomelandCollectionCropDecomposeCtrl:cancelSelectedCrop(itemId)
	self.selectedCountByItemId[itemId] = nil

	if self.currentItemId == itemId then
		self.currentItemId = nil

		self.view.selectorUWidget:SetActive(false)
	end

	self:refreshSelectionInfo()
end

function HomelandCollectionCropDecomposeCtrl:getRewardListData()
	local rewardCountByItemId = {}

	for itemId, selectedCount in pairs(self.selectedCountByItemId) do
		local cropData = self.cropDataByItemId[itemId]

		for rewardItemId, rewardItemCount in pairs(cropData.rewardItemMap) do
			rewardCountByItemId[rewardItemId] = (rewardCountByItemId[rewardItemId] or 0) + rewardItemCount * selectedCount
		end
	end

	local rewardListData = {}

	for rewardItemId, rewardItemCount in pairs(rewardCountByItemId) do
		rewardListData[#rewardListData + 1] = {
			type = 0,
			tIndex = 0,
			id = rewardItemId,
			num = rewardItemCount
		}
	end

	table.sort(rewardListData, function(a, b)
		return a.id < b.id
	end)

	return rewardListData
end

function HomelandCollectionCropDecomposeCtrl:refreshSelectionInfo()
	self:refreshNumSelectorInfo()
	self.view.listProp:RefreshList()
	self.view.listReward:SetList(self:getRewardListData())
	self:refreshConfirmButtonState()
	self:refreshAllSelectedButtonState()
end

function HomelandCollectionCropDecomposeCtrl:refreshConfirmButtonState()
	self.view.btnConfirm.interactable = next(self.selectedCountByItemId) ~= nil
end

function HomelandCollectionCropDecomposeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandCollectionCropDecomposeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandCollectionCropDecomposeCtrl:onShow()
	return
end

function HomelandCollectionCropDecomposeCtrl:onHide()
	return
end

return HomelandCollectionCropDecomposeCtrl
