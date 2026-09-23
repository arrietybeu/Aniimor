-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\Component\\PopUpComponent.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local RobEggCollectionCalcineRankData = require("Data.rob_egg_collection_calcine_rank_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")
local POP_UP_MODE_PLACE = "place"
local POP_UP_MODE_REPLACE = "replace"
local ANTIQUE_DATA_KEY = ItemConst.ItemPropertyDef.AntiqueData
local MIN_ANTIQUE_LEVEL = ItemConst.AntiqueLevel.LEVEL_C
local MAX_ANTIQUE_LEVEL = ItemConst.AntiqueLevel.LEVEL_SSS
local PopUpComponent = Class.LightClass("PopUpComponent")

function PopUpComponent:ctor(rootTransform, ctrl, model)
	self.rootTransform = rootTransform
	self.ctrl = ctrl
	self.model = model
	self.popUp = nil
	self.selectedSlotTransform = nil
	self.selectedSlotData = nil
	self.bagCollectionItems = {}
	self.selectedBagItemIndex = nil
	self.selectedBagItemData = nil
	self.mode = POP_UP_MODE_PLACE
end

function PopUpComponent:init()
	self:findObjects()
	self:addListener()
	self:clear()
end

function PopUpComponent:findObjects()
	local objectReference = self.rootTransform:GetComponent("ObjectReference")

	self.popUp = objectReference:GetRefValue("popUp")

	if self.popUp then
		local objectReference = self.popUp:GetComponent("ObjectReference")

		self.btnClose = objectReference:GetRefValue("btnClose")
		self.btnBack = objectReference:GetRefValue("btnBack")
		self.title = objectReference:GetRefValue("title")
		self.confirmBtn = objectReference:GetRefValue("confirmBtn")
		self.confirmBtnTxt = objectReference:GetRefValue("confirmBtnTxt")
		self.bagCollectionList = objectReference:GetRefValue("bagCollectionList")
		self.emptyPanel = objectReference:GetRefValue("emptyPanel")
		self.emptyTxt = objectReference:GetRefValue("emptyTxt")
	end

	ClientTextUtils.setText(self.title, pg.getGameString("GRAB_EGG_Collection_Unlock_List_Title"))
	ClientTextUtils.setText(self.emptyTxt, "无")
	ClientTextUtils.setText(self.confirmBtnTxt, pg.getGameString("GRAB_EGG_Collection_Button_Confirm"))
end

function PopUpComponent:addListener()
	if self.btnClose then
		function self.btnClose.luaClick()
			self:onCloseBtnClick()
		end
	end

	if self.btnBack then
		function self.btnBack.luaClick()
			self:onCloseBtnClick()
		end
	end

	if self.confirmBtn then
		function self.confirmBtn.luaClick()
			self:onConfirmBtnClick()
		end
	end

	if self.bagCollectionList then
		function self.bagCollectionList.luaRenderItem(item, index, data)
			self:renderBagCollectionItem(item, index, data)
		end
	end
end

function PopUpComponent:refresh()
	local slotId = self.selectedSlotData and self.selectedSlotData.slotId
	local slotItems = self:getSlotItems(slotId)
	local isEmpty = not slotItems or #slotItems <= 0

	self:refreshBagCollectionList(slotItems)
	self:setNodeVisible(self.emptyPanel, isEmpty)
end

function PopUpComponent:refreshBagCollectionList(slotItems)
	if not self.bagCollectionList then
		return
	end

	self.bagCollectionItems = self:buildBagCollectionListData(slotItems)

	if #self.bagCollectionItems <= 0 then
		self.selectedBagItemIndex = nil
		self.selectedBagItemData = nil
	elseif not self.selectedBagItemIndex or not self.bagCollectionItems[self.selectedBagItemIndex] then
		self.selectedBagItemIndex = 1
		self.selectedBagItemData = self.bagCollectionItems[1]
	else
		self.selectedBagItemData = self.bagCollectionItems[self.selectedBagItemIndex]
	end

	for index, itemData in ipairs(self.bagCollectionItems) do
		itemData.isSelected = index == self.selectedBagItemIndex
	end

	self.bagCollectionList:SetList(self.bagCollectionItems)
end

function PopUpComponent:buildBagCollectionListData(slotItems)
	local list = {}

	if not slotItems then
		return list
	end

	local slotId = self.selectedSlotData and self.selectedSlotData.slotId
	local slotConfig = self:getSlotConfig(slotId)

	for index, slotItem in ipairs(slotItems) do
		local item = slotItem and (slotItem.item or slotItem)
		local genId = slotItem and slotItem.genId

		if type(genId) == "function" then
			genId = nil
		end

		local itemId = item and item.id

		if itemId then
			table.insert(list, {
				index = index,
				slotId = slotId,
				slotConfig = slotConfig,
				item = item,
				itemId = itemId,
				genId = genId or self:getItemGenId(item),
				count = self:getItemCount(item),
				listImage = slotConfig and slotConfig.listImage,
				isSelected = index == self.selectedBagItemIndex
			})
		end
	end

	return list
end

function PopUpComponent:renderBagCollectionItem(itemView, index, data)
	if not itemView or not data then
		return
	end

	local objectReference = itemView:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local rewardItem = objectReference:GetRefValue("rewardItem")

	if rewardItem then
		local rewardData = {
			id = data.itemId,
			itemId = data.itemId,
			genID = data.genId,
			num = data.count,
			packSlot = data.item
		}

		LuaUIUtils.renderRewardItem(rewardItem, rewardData)
		LuaUIUtils.refreshGrabEggAntiqueTags(rewardItem, rewardData)

		function rewardItem.luaClick()
			self:openBagCollectionItemTip(rewardItem, data)
		end
	end

	local select = objectReference:GetRefValue("select")

	self:setNodeVisible(select, data.isSelected == true)

	local name = objectReference:GetRefValue("name")

	if name then
		ClientTextUtils.setText(name, self:getItemName(data.itemId))
	end

	local antiqueData = data.item and data.item.props and data.item.props[ANTIQUE_DATA_KEY]
	local isCalcined = antiqueData and (antiqueData.affix_num or 0) > 0
	local point = objectReference:GetRefValue("point")
	local tagPanel = objectReference:GetRefValue("tagPanel")

	self:setNodeVisible(point, not isCalcined)
	self:setNodeVisible(tagPanel, isCalcined)

	local pointNum = objectReference:GetRefValue("pointNum")

	if pointNum then
		ClientTextUtils.setText(pointNum, tostring(data.slotConfig and data.slotConfig.point or 0))
	end

	if isCalcined and tagPanel then
		local level = math.min(MAX_ANTIQUE_LEVEL, math.max(MIN_ANTIQUE_LEVEL, antiqueData.degree or MIN_ANTIQUE_LEVEL))
		local rankConfig = RobEggCollectionCalcineRankData[level]

		tagPanel:TryChangePage("Level", level - 1)

		local tagTxt = objectReference:GetRefValue("tagTxt")

		if tagTxt then
			ClientTextUtils.setText(tagTxt, rankConfig and pg.getLocalizationText(rankConfig.rankName) or "")
		end
	end

	function itemView.luaClick()
		self:onBagCollectionItemClick(data)
	end
end

function PopUpComponent:openBagCollectionItemTip(target, data)
	if not target or not data or not data.item then
		return
	end

	local itemConfig = ItemData[data.itemId] or {}
	local itemInData = RobEggItemOut[data.itemId]
	local weightConfig = itemInData and ItemData[itemInData.inid] or itemConfig
	local itemData = {
		itemId = data.itemId,
		genID = data.genId,
		invId = ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE,
		packSlot = data.item,
		count = data.count,
		num = data.count,
		type = itemConfig.type,
		quality = itemConfig.quality
	}

	LuaUIUtils.popupPropTip({
		durableText = "",
		showGrabEgg = true,
		showLock = false,
		fromParamCount = true,
		id = data.itemId,
		num = data.count,
		targetRect = target,
		itemId = data.itemId,
		itemCount = data.count,
		invId = itemData.invId,
		genID = data.genId,
		btnDataList = {},
		weight = weightConfig.weight or 0,
		oriData = itemData
	})
end

function PopUpComponent:getItemName(itemId)
	local itemConfig = itemId and ItemData[itemId]

	if not itemConfig then
		return ""
	end

	if pg and pg.getLocalizationText then
		return pg.getLocalizationText(itemConfig.itemName)
	end

	return itemConfig.itemName or ""
end

function PopUpComponent:onBagCollectionItemClick(data)
	if not data then
		return
	end

	self.selectedBagItemIndex = data.index
	self.selectedBagItemData = data

	self:refreshBagCollectionList(self:getSlotItems(data.slotId))
end

function PopUpComponent:getSlotConfig(slotId)
	if not slotId then
		return nil
	end

	return RobEggBookCollectionData[slotId]
end

function PopUpComponent:getItemCount(item)
	if not item then
		return 1
	end

	return item.num or item.count or item.amount or item.itemNum or 1
end

function PopUpComponent:getItemGenId(item)
	if not item then
		return nil
	end

	local fieldNames = {
		"genID",
		"genId",
		"index"
	}

	for _, fieldName in ipairs(fieldNames) do
		local value = item[fieldName]

		if value and type(value) ~= "function" then
			return value
		end
	end

	local methodNames = {
		"genID",
		"genId"
	}

	for _, methodName in ipairs(methodNames) do
		local method = item[methodName]

		if type(method) == "function" then
			local success, value = pcall(function()
				return method(item)
			end)

			if success and value then
				return value
			end
		end
	end

	return nil
end

function PopUpComponent:getSlotItems(slotId)
	if not slotId or not self.model or not self.model.getSlotItemData then
		return nil
	end

	return self.model:getSlotItemData(slotId)
end

function PopUpComponent:onCloseBtnClick()
	if self.ctrl and self.ctrl.closePlacePopUp then
		self.ctrl:closePlacePopUp()

		return
	end

	self:clear()
end

function PopUpComponent:onConfirmBtnClick()
	if not self.selectedSlotData or not self.selectedBagItemData then
		return
	end

	local ctrl = self.ctrl

	if not ctrl then
		return
	end

	local slotTransform = self.selectedSlotTransform
	local slotData = self.selectedSlotData
	local bagItemData = self.selectedBagItemData

	if self.mode == POP_UP_MODE_REPLACE then
		if ctrl.onReplacePopUpConfirm then
			pg.global.ui.commonUseConfirm:open({
				hideCurrency = 1,
				muteCheckEnough = true,
				type = 1,
				title = pg.getGameString("GRAB_EGG_Collection_Replace_popup_Title"),
				tipTop = string.format(pg.getGameString("GRAB_EGG_Collection_Replace_popup_Text"), self:getItemName(bagItemData.itemId)),
				data = {
					{
						bagItemData.itemId,
						1,
						hideNum = true,
						hideOwnNum = true,
						ownNum = 1
					}
				},
				confirmCb = function()
					ctrl:onReplacePopUpConfirm(slotTransform, slotData, bagItemData)
				end
			})
		end

		return
	end

	if not ctrl.onPlacePopUpConfirm then
		return
	end

	pg.global.ui.commonUseConfirm:open({
		hideCurrency = 1,
		muteCheckEnough = true,
		type = 1,
		title = pg.getGameString("GRAB_EGG_Collection_Unlock_popup_Title"),
		tipTop = pg.getGameString("GRAB_EGG_Collection_Unlock_popup_Text"),
		data = {
			{
				bagItemData.itemId,
				1,
				hideNum = true,
				hideOwnNum = true,
				ownNum = 1
			}
		},
		confirmCb = function()
			ctrl:onPlacePopUpConfirm(slotTransform, slotData, bagItemData)
		end
	})
end

function PopUpComponent:show(slotTransform, slotData, mode)
	self.selectedSlotTransform = slotTransform
	self.selectedSlotData = slotData
	self.selectedBagItemIndex = nil
	self.selectedBagItemData = nil
	self.mode = mode == POP_UP_MODE_REPLACE and POP_UP_MODE_REPLACE or POP_UP_MODE_PLACE

	ClientTextUtils.setText(self.title, pg.getGameString(self.mode == POP_UP_MODE_REPLACE and "GRAB_EGG_Collection_Replace_List_Title" or "GRAB_EGG_Collection_Unlock_List_Title"))
	self:refresh()
	self:setVisible(true)
end

function PopUpComponent:isVisible()
	if not self.popUp then
		return false
	end

	local gameObject = self:getPopUpGameObject()

	if gameObject then
		return gameObject.activeSelf == true
	end

	return self.popUp.activeSelf == true
end

function PopUpComponent:getPopUpGameObject()
	if not self.popUp then
		return nil
	end

	if self.popUp.gameObject then
		return self.popUp.gameObject
	end

	return self.popUp
end

function PopUpComponent:setVisible(visible)
	if not self.popUp then
		return
	end

	visible = visible == true

	if self.popUp.SetActiveEx then
		self.popUp:SetActiveEx(visible)

		return
	end

	local gameObject = self:getPopUpGameObject()

	if gameObject and gameObject.SetActiveEx then
		gameObject:SetActiveEx(visible)
	elseif gameObject and gameObject.SetActive then
		gameObject:SetActive(visible)
	end
end

function PopUpComponent:setNodeVisible(node, visible)
	if not node then
		return
	end

	visible = visible == true

	local gameObject = node.gameObject or node

	if node.SetActiveEx then
		node:SetActiveEx(visible)
	elseif gameObject and gameObject.SetActiveEx then
		gameObject:SetActiveEx(visible)
	elseif gameObject and gameObject.SetActive then
		gameObject:SetActive(visible)
	end
end

function PopUpComponent:clear()
	self.selectedSlotTransform = nil
	self.selectedSlotData = nil
	self.bagCollectionItems = {}
	self.selectedBagItemIndex = nil
	self.selectedBagItemData = nil
	self.mode = POP_UP_MODE_PLACE

	ClientTextUtils.setText(self.title, pg.getGameString("GRAB_EGG_Collection_Unlock_List_Title"))

	if self.bagCollectionList then
		self.bagCollectionList:SetList({})
	end

	self:setNodeVisible(self.emptyPanel, false)
	self:setVisible(false)
end

function PopUpComponent:destroy()
	self:clear()

	self.popUp = nil
	self.selectedSlotTransform = nil
	self.selectedSlotData = nil
	self.bagCollectionList = nil
	self.bagCollectionItems = nil
	self.selectedBagItemIndex = nil
	self.selectedBagItemData = nil
	self.rootTransform = nil
	self.ctrl = nil
	self.model = nil
end

return PopUpComponent
