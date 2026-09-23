-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\HomelandFoodComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandFoodComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local OpDef = require("Common.OpDef")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeFoodItemData = require("Data.homeland_food_item")
local HomelandConfigData = require("Data.homeland_config_data")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local HomelandFoodComponent = Class.LightClass("HomelandFoodComponent", UIComponent)
local MAX_SLOT_COUNT = 3

function HomelandFoodComponent:findObjects()
	return
end

function HomelandFoodComponent:initView()
	if not self.uWidget:CheckURLLoaded() then
		self.uWidget:LoadDefaultUrlManually(function()
			self:onContentLoaded()
		end)
	else
		self:onContentLoaded()
	end
end

function HomelandFoodComponent:onContentLoaded()
	local objectReference = self.uWidget.content:GetComponent("ObjectReference")

	self.btnGoBuyUButton = objectReference:GetRefValue("btnGoBuyUButton")
	self.foodListUList = objectReference:GetRefValue("foodListUList")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.txtCostTimeUSDFText = objectReference:GetRefValue("txtCostTimeUSDFText")
	self.txtFoodTotalUSDFText = objectReference:GetRefValue("txtFoodTotalUSDFText")
	self.button1 = objectReference:GetRefValue("button1UButton")
	self.button2 = objectReference:GetRefValue("button2UButton")
	self.button3 = objectReference:GetRefValue("button3UButton")

	for idx = 1, MAX_SLOT_COUNT do
		local btn = self["button" .. idx]
		local ojr = btn:GetComponent("ObjectReference")

		self["btnReduce" .. idx] = ojr:GetRefValue("btnReduceUButton")
		self["itemNum" .. idx] = ojr:GetRefValue("txtNumUSDFText")
		self["iconProp" .. idx] = ojr:GetRefValue("iconPropUImage")
		self["btnReduce" .. idx].luaClick = function()
			self:clearSLot(idx)
		end
	end

	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.timeUComponent = objectReference:GetRefValue("timeUComponent")

	function self.foodListUList.luaRenderItem(button, idx, data)
		self:renderFoodList(button, idx, data)
	end

	function self.btnAddUButton.luaClick()
		self:onClickToAdd(1)
	end

	function self.btnGoBuyUButton.luaClick()
		pg.me:doEvent(HomelandConfigData.homeFoodGetEvent)
	end

	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("HOME_LACK_FOOD_NOTICE"))
	self:refreshFoodInfo()
end

function HomelandFoodComponent:clearSLot(idx)
	local space = pg.space
	local ret, _ = space.homeFoodSlotList:checkOpClearSlot(space, idx)

	if ret then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_LAND_CONFIRM_CANCEL_FOOD"), function()
			pg.me:requestHomelandFoodOp(OpDef.OP.CS_HF_ClearSlot, {
				slotIndex = idx
			})
		end)
	end
end

function HomelandFoodComponent:onClickToAdd(index)
	if index > MAX_SLOT_COUNT then
		return
	end

	local homeList = pg.space.homeFoodSlotList
	local itemMap = pg.space.itemMap
	local slotInfo = homeList[index]

	if slotInfo then
		if slotInfo:isEmpty() then
			local productInfo = table.remove(self.productSort, 1)

			if productInfo then
				self:moveToFoodSlot(productInfo.id, productInfo.count, function(noticeId)
					self:onClickToAdd(index + 1)
				end)
			end
		else
			local itemId = slotInfo.itemId
			local count = itemMap[itemId] or 0
			local curCount = slotInfo.itemNum
			local putInCont = math.min(count, HomelandConfigData.foodItemMaxCount - curCount)

			self:moveToFoodSlot(itemId, putInCont, function(noticeId)
				self:onClickToAdd(index + 1)
			end)
		end
	end
end

function HomelandFoodComponent:refreshFoodInfo()
	if not self.uWidget:CheckURLLoaded() then
		return
	end

	self:refreshFoodList()
	self:refreshFoodSlot()
	self:refreshFoodBandInfo()
	self:refreshItemTip()
end

function HomelandFoodComponent:refreshFoodSlot()
	local homeList = pg.space.homeFoodSlotList
	local unlockNum = #pg.space.homeFoodSlotList

	self.txtNumUSDFText.text = unlockNum

	for idx = 1, MAX_SLOT_COUNT do
		self["button" .. idx]:TryChangePage("InUse", 0)

		if unlockNum < idx then
			self["button" .. idx]:TryChangePage("Type", 2)
		else
			local slotInfo = homeList[idx]

			if not slotInfo:isEmpty() then
				self["button" .. idx]:TryChangePage("Type", 1)

				local cur, max = slotInfo:getDisplayNum()

				self["itemNum" .. idx].text = cur .. "/" .. max
				self["iconProp" .. idx].url = ItemData[slotInfo.itemId].icon

				if idx == 1 then
					self["button" .. idx]:TryChangePage("InUse", 1)
				end
			else
				self["button" .. idx]:TryChangePage("Type", 0)
			end
		end
	end
end

function HomelandFoodComponent:renderFoodList(button, idx, data)
	LuaUIUtils.renderItem(button, {
		id = data.id,
		num = data.count,
		extraFunc = function()
			self.itemId = data.id
			self.selectBtn = button

			local maxNum = self:getCanAddNum(data.id, data.count)

			pg.global.ui.commonItemTip:open({
				fromParamCount = true,
				inHome = true,
				id = data.id,
				num = data.count,
				maxNum = maxNum,
				targetRect = button,
				confirmClick = function(itemInfo)
					for itemId, count in pairs(itemInfo) do
						self:moveToFoodSlot(itemId, count)
					end
				end,
				cancelClick = function(itemInfo)
					self.itemId = nil
					self.selectBtn = nil
				end
			})
		end
	})

	button.draggable = false
end

function HomelandFoodComponent:refreshItemTip()
	if pg.global.ui.commonItemTip:checkUIVisible() and self.itemId then
		local itemMap = pg.space.itemMap
		local ownCount = itemMap[self.itemId]

		if not ownCount or ownCount <= 0 then
			pg.global.ui.commonItemTip:close()

			self.itemId = nil
			self.selectBtn = nil

			return
		end

		local maxNum = self:getCanAddNum(self.itemId, ownCount)
		local tipData = {
			fromParamCount = true,
			inHome = true,
			id = self.itemId,
			itemId = self.itemId,
			num = ownCount,
			itemCount = ownCount,
			maxNum = maxNum,
			confirmClick = function(itemInfo)
				for itemId, count in pairs(itemInfo) do
					self:moveToFoodSlot(itemId, count)
				end
			end,
			cancelClick = function(itemInfo)
				self.itemId = nil
				self.selectBtn = nil
			end
		}

		LuaUIUtils.refreshItemInfo(pg.global.ui.commonItemTip.view.rootCmp, tipData)
	end
end

function HomelandFoodComponent:getCanAddNum(itemId, count)
	if not count then
		return
	end

	local homeList = pg.space.homeFoodSlotList
	local canAddCount = 0

	for i = 1, MAX_SLOT_COUNT do
		local slotInfo = homeList[i]

		if not slotInfo or slotInfo.itemId == 0 or slotInfo.itemId == itemId then
			local curCount = slotInfo and slotInfo.itemNum or 0

			canAddCount = canAddCount + (HomelandConfigData.foodItemMaxCount - curCount)
		end
	end

	canAddCount = math.min(canAddCount, count)

	return canAddCount
end

function HomelandFoodComponent:moveToFoodSlot(itemId, count, callback)
	local ret, _ = pg.space.homeFoodSlotList:checkOpAddItem(pg.space, itemId, count)

	if ret then
		pg.me:requestHomelandFoodOp(OpDef.OP.CS_HF_AddItem, {
			itemId = itemId,
			itemNum = count
		}, callback)
	end
end

function HomelandFoodComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function HomelandFoodComponent:refreshFoodBandInfo()
	local foodSlotList = pg.space.homeFoodSlotList
	local space = pg.space
	local speed = foodSlotList:_calcFoodCostSpeed(space)

	self.txtCostTimeUSDFText.text = speed
	self.txtFoodTotalUSDFText.text = foodSlotList:getTotalFood(space)

	local isWorking = foodSlotList:isWorking(space)

	self:clearTotalFoodTimer()

	if not isWorking then
		self.timeUComponent:TryChangePage("Empty", 1)
	else
		self.timeUComponent:TryChangePage("Empty", 0)

		local remainTime = foodSlotList:getEstimatedEndTs(space) - Time.secondCache

		if remainTime < Const.SECONDS_ONE_DAY then
			LuaUIUtils.setCountDownTime(self.countDownUCountDown, foodSlotList:getEstimatedEndTs(space), UIConst.TimeType.Short)
		else
			LuaUIUtils.setCountDownTime(self.countDownUCountDown, foodSlotList:getEstimatedEndTs(space), UIConst.TimeType.Full)
		end

		self.totalFoodTimer = self:startTimer(function()
			local foodSlotList = pg.space.homeFoodSlotList

			self.txtFoodTotalUSDFText.text = foodSlotList:getTotalFood(pg.space)
		end, 10, true)
	end

	local hasPet = space and HomeLandUtils.getPetCurCount(space) > 0

	pg.global.setRedDot(RedDotConst.RedDotPath.HOMELAND_FOOD_MANGE, self.timeUComponent, hasPet and not isWorking, RedDotConst.RedDotStyle.POINT)
end

function HomelandFoodComponent:clearTotalFoodTimer()
	if self.totalFoodTimer then
		self:killTimer(self.totalFoodTimer)
	end

	self.totalFoodTimer = nil
end

function HomelandFoodComponent:refreshFoodList()
	local foodDatas = self:getHomeFoodData()

	if #foodDatas <= 0 then
		self.uWidget.content:TryChangePage("Empty", 1)

		return
	end

	self.uWidget.content:TryChangePage("Empty", 0)
	self.foodListUList:SetList(foodDatas)
end

function HomelandFoodComponent:getHomeFoodData()
	local ret = {}
	local itemMap = pg.space.itemMap
	local maxCount = HomelandConfigData.foodItemMaxCount
	local productInfo = {}

	for id, product in pairs(HomeFoodItemData) do
		local count = itemMap[id]

		if count and count > 0 then
			ret[#ret + 1] = {
				id = id,
				count = count
			}

			while count > 0 do
				local productCount = math.min(count, maxCount)
				local productSum = product * productCount

				count = count - productCount
				productInfo[#productInfo + 1] = {
					id = id,
					count = productCount,
					productSum = productSum
				}
			end
		end
	end

	table.sort(productInfo, function(a, b)
		return a.productSum > b.productSum
	end)

	self.productSort = {}

	for idx = 1, MAX_SLOT_COUNT do
		if idx <= #productInfo then
			self.productSort[idx] = productInfo[idx]
		end
	end

	return ret
end

return HomelandFoodComponent
