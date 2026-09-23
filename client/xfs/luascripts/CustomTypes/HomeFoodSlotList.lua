-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomeFoodSlotList.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local TimeUtils = require("Common.Utils.TimeUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local PetData = require("Data.pet_data")
local ItemData = require("Data.item_data")
local HomeFoodSlotList = class.LiteClass("HomeFoodSlotList", CustomList)

function HomeFoodSlotList:checkOpAddItem(home, itemId, itemNum)
	local idd = ItemData[itemId]

	if not idd or ToInt(idd.homeFoodAdd) == 0 then
		return false, "Invalid itemId"
	end

	local insertInfos = self:calcAddItemInsertInfos(itemId, itemNum)

	if not insertInfos then
		return false, "Not enough space"
	end

	if pg.component == "game" then
		if not home:checkWarehouseItems({
			[itemId] = itemNum
		}) then
			return false, "Not enough items in warehouse"
		end
	else
		local currentNum = home.itemMap[itemId] or 0

		if currentNum < itemNum then
			return false, "Not enough items in warehouse"
		end
	end

	return true
end

function HomeFoodSlotList:opAddItem(home, itemId, itemNum)
	local ok, err = self:checkOpAddItem(home, itemId, itemNum)

	if not ok then
		return NoticeDef.FAIL, {
			err
		}
	end

	local oldTotalFood = self:getTotalFood(home)
	local insertInfos = self:calcAddItemInsertInfos(itemId, itemNum)

	if home:reduceWarehouseItems({
		[itemId] = itemNum
	}) then
		for _, info in ipairs(insertInfos) do
			local index, addNum = info[1], info[2]
			local slotInfo = self[index]

			slotInfo.itemId = itemId
			slotInfo.itemNum = slotInfo.itemNum + addNum
		end

		home:refreshFoodSlotWorking()

		local newTotalFood = self:getTotalFood(home)

		if home.ownerPlayer then
			home.ownerPlayer.triggerMap:onTrigger(TriggerConst.TRIGGER_TARGET_HOME_ADD_FEED, itemId, itemNum)
			home.ownerPlayer.BILogger:customeLog("add_food", {
				id = itemId,
				num = itemNum,
				energy = newTotalFood - oldTotalFood,
				total_energy = newTotalFood
			})
		end

		home.logger:info("homeFood addItem, itemId=%d, itemNum=%d, insertInfos=%s", itemId, itemNum, inspect(insertInfos), home:repr())
	end

	return NoticeDef.SUCCESS
end

function HomeFoodSlotList:checkOpClearSlot(home, slotIndex)
	local slotInfo = self[slotIndex]

	if not slotInfo then
		return false, "Invalid slot index"
	end

	if slotInfo:isEmpty() then
		return false, "Slot is already empty"
	end

	return true
end

function HomeFoodSlotList:opClearSlot(home, slotIndex)
	local ok, err = self:checkOpClearSlot(home, slotIndex)

	if not ok then
		return NoticeDef.FAIL, {
			err
		}
	end

	local oldTotalFood = self:getTotalFood(home)
	local slotInfo = self:remove(slotIndex)
	local addedItems

	if slotInfo then
		addedItems = self:payBackSlotItems(home, slotInfo)

		self:insert(#self + 1, {})
	end

	if slotIndex == 1 then
		home.foodSlotCurSpeed = 0
		home.foodSlotNextRefreshTs = 0
		home.foodSlotPauseSaveFood = 0
	end

	home:refreshFoodSlotWorking()

	local newTotalFood = self:getTotalFood(home)

	if home.ownerPlayer then
		local itemId, itemNum = next(addedItems or EMPTY_TABLE)

		home.ownerPlayer.BILogger:customeLog("reduce_food", {
			id = itemId,
			num = itemNum,
			energy = oldTotalFood - newTotalFood,
			total_energy = newTotalFood
		})
	end

	home.logger:info("homeFood clearSlot, slotIndex=%d", slotIndex, home:repr())

	return NoticeDef.SUCCESS
end

function HomeFoodSlotList:calcAddItemInsertInfos(itemId, itemNum)
	local remainNum, insertInfos = itemNum, {}

	for i = 1, #self do
		local slotInfo = self[i]

		if slotInfo and not slotInfo:isFull() then
			local canAddNum = slotInfo:getCanAddNum(itemId, remainNum)

			if canAddNum > 0 then
				remainNum = remainNum - canAddNum
				insertInfos[#insertInfos + 1] = {
					i,
					canAddNum
				}

				if remainNum == 0 then
					break
				end
			end
		end
	end

	return remainNum == 0 and insertInfos or nil
end

function HomeFoodSlotList:getPayBackItems(home, slotInfo)
	if not slotInfo or slotInfo:isEmpty() then
		return nil, false
	end

	local hasLoss = home.foodSlotNextRefreshTs > 0 and slotInfo._name == 1
	local items = {
		[slotInfo.itemId] = hasLoss and slotInfo.itemNum - 1 or slotInfo.itemNum
	}

	return items, hasLoss
end

function HomeFoodSlotList:payBackSlotItems(home, slotInfo)
	local toAddItems, hasLoss = self:getPayBackItems(home, slotInfo)

	if not toAddItems then
		return
	end

	local addOk = home:addWarehouseItems(toAddItems)

	home.logger:info("homeFood payBackSlotItems, toAddItems=%s, hasLoss=%s, addOK=%s", inspect(toAddItems), tostring(hasLoss), tostring(addOk), home:repr())

	return toAddItems
end

function HomeFoodSlotList:getEstimatedEndTs(home)
	local totalSeconds = self:getTotalFood(home) * 60 / home.foodSlotCurSpeed

	return Time.secondCache + totalSeconds, totalSeconds
end

function HomeFoodSlotList:getCurSpeed(home)
	return home.foodSlotCurSpeed or 0
end

function HomeFoodSlotList:getTotalFood(home)
	local total = 0

	for _, slotInfo in ipairs(self) do
		local idd = ItemData[slotInfo.itemId]

		total = total + (idd and idd.homeFoodAdd or 0) * slotInfo.itemNum
	end

	total = total - self:getCurSettledFood(home)

	return total
end

function HomeFoodSlotList:getSettlingItemFoodNum()
	local slotInfo = self[1]

	if not slotInfo or slotInfo:isEmpty() then
		return 0
	end

	local idd = ItemData[slotInfo.itemId]

	return idd and idd.homeFoodAdd or 0
end

function HomeFoodSlotList:getCurSettledSeconds(home, sinceTs)
	if home.foodSlotNextRefreshTs <= 0 or home.foodSlotCurSpeed <= 0 then
		return 0
	end

	local startTs = home.foodSlotNextRefreshTs - self:getSettlingItemFoodNum() * 60 / home.foodSlotCurSpeed

	startTs = math.max(startTs, sinceTs or 0)

	local endTs = math.min(Time.secondCache, home.foodSlotNextRefreshTs)

	return math.max(0, endTs - startTs)
end

function HomeFoodSlotList:getCurSettledFood(home)
	return self:getSettlingItemFoodNum() - self:getCurRemainingFood(home)
end

function HomeFoodSlotList:getCurRemainingFood(home)
	if home.foodSlotNextRefreshTs < 0 then
		return home.foodSlotPauseSaveFood
	elseif home.foodSlotNextRefreshTs == 0 then
		return self:getSettlingItemFoodNum()
	else
		local remainSeconds = home.foodSlotNextRefreshTs - Time.secondCache

		return math.max(0, math.floor(remainSeconds * home.foodSlotCurSpeed / 60))
	end
end

function HomeFoodSlotList:isWorking(home)
	return home.foodSlotNextRefreshTs > 0
end

function HomeFoodSlotList:_calcFoodCostSpeed(home)
	local speed = 0

	for _, petInfo in pairs(home.pets) do
		local pdd = PetData[petInfo.templateId]

		speed = speed + (pdd and pdd.homeFoodCostSpeed or 0)
	end

	return speed
end

function HomeFoodSlotList:_consumeItem()
	if self[1] and not self[1]:isEmpty() then
		local slotInfo = self[1]

		slotInfo.itemNum = slotInfo.itemNum - 1

		if slotInfo.itemNum <= 0 and self:remove(1) then
			self:insert(#self + 1, {})
		end

		return true
	end

	return false
end

function HomeFoodSlotList:repr(home)
	if not home then
		return "(error no home)"
	end

	return string.format("(totalFood=%d, curSpeed=%d, ts=%s, slots=%d)", self:getTotalFood(home), home.foodSlotCurSpeed, self:isWorking(home) and string.format("%s/%s", TimeUtils.timeStampToUtcString(home.foodSlotNextRefreshTs), TimeUtils.timeStampToUtcString(self:getEstimatedEndTs(home))) or "not working", #self)
end

function HomeFoodSlotList:pauseWorking(home)
	if home.foodSlotNextRefreshTs > 0 then
		local remainFood = self:getCurRemainingFood(home)

		home.foodSlotCurSpeed = 0
		home.foodSlotNextRefreshTs = -1
		home.foodSlotPauseSaveFood = remainFood

		home.logger:debug("homeFood pauseWorking, remainFood=%d", remainFood, self:repr(home))
	end
end

function HomeFoodSlotList:resumeWorking(home)
	local speed = self:_calcFoodCostSpeed(home)

	if speed > 0 then
		if home.foodSlotNextRefreshTs == -1 then
			local remainFood = home.foodSlotPauseSaveFood

			home.foodSlotCurSpeed = speed
			home.foodSlotNextRefreshTs = Time.secondCache + math.round(remainFood * 60 / speed)

			home.logger:debug("homeFood resumeWorking, remainFood=%d, %s", remainFood, self:repr(home))
		elseif home.foodSlotNextRefreshTs == 0 then
			local remainFood = self:getSettlingItemFoodNum()

			if remainFood > 0 then
				home.foodSlotCurSpeed = speed
				home.foodSlotNextRefreshTs = Time.secondCache + math.round(remainFood * 60 / speed)

				home.logger:debug("homeFood resumeWorking initial, remainFood=%d, %s", remainFood, self:repr(home))
			end
		end
	end
end

function HomeFoodSlotList:refreshWorking(home, offlineFromTs)
	if home.foodSlotNextRefreshTs > 0 then
		local validSeconds = self:getCurSettledSeconds(home, offlineFromTs)

		if Time.secondCache >= home.foodSlotNextRefreshTs then
			local speed = home.foodSlotCurSpeed
			local refreshTs = home.foodSlotNextRefreshTs

			while refreshTs <= Time.secondCache and self[1] and not self[1]:isEmpty() do
				if self:_consumeItem() then
					local remainFood = self:getSettlingItemFoodNum()

					if remainFood > 0 then
						local itemEndTs = refreshTs + remainFood * 60 / speed
						local settledStartTs = math.max(refreshTs, offlineFromTs or 0)

						validSeconds = validSeconds + math.max(0, math.min(Time.secondCache, itemEndTs) - settledStartTs)
						refreshTs = itemEndTs

						if refreshTs > Time.secondCache then
							home.foodSlotCurSpeed = speed
							home.foodSlotNextRefreshTs = Time.secondCache + math.round(refreshTs - Time.secondCache)
						end

						if not offlineFromTs and refreshTs > Time.secondCache then
							home.logger:debug("homeFood refreshWorking consumeItem, remainFood=%d, %s", remainFood, self:repr(home))
						end
					else
						home.foodSlotCurSpeed = 0
						home.foodSlotNextRefreshTs = 0

						home.logger:debug("homeFood refreshWorking consumeItem end, no more item, %s", self:repr(home))
					end
				else
					home.foodSlotCurSpeed = 0
					home.foodSlotNextRefreshTs = 0

					home.logger:error("homeFood refreshWorking consumeItem failed, no item to consume, %s", self:repr(home))

					break
				end
			end
		end

		if home.foodSlotNextRefreshTs > 0 then
			local curSpeed = home.foodSlotCurSpeed
			local newSpeed = self:_calcFoodCostSpeed(home)

			if curSpeed ~= newSpeed then
				if newSpeed > 0 then
					local remainFood = self:getCurRemainingFood(home)

					home.foodSlotCurSpeed = newSpeed
					home.foodSlotNextRefreshTs = Time.secondCache + math.round(remainFood * 60 / newSpeed)

					home.logger:debug("homeFood refreshWorking speed change, remainFood=%d, oldSpeed=%d, newSpeed=%d, %s", remainFood, curSpeed, newSpeed, self:repr(home))
				else
					self:pauseWorking(home)
				end
			end
		end

		return math.round(validSeconds)
	else
		return 0
	end
end

return HomeFoodSlotList
