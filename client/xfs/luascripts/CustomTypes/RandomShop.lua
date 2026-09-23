-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RandomShop.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local RandomShopData = require("Data.random_shop_data")
local RandomShopPosData = require("Data.random_shop_pos_data")
local RandomShop = class.LiteClass("RandomShop", CustomDict)

function RandomShop:getShopId()
	return self.randomShopBase and self.randomShopBase:getShopId() or 0
end

function RandomShop:posIsLegal(pos)
	return self:getPosConfig(pos) ~= nil
end

function RandomShop:curLockCount()
	local lockCount = 0

	for _, locked in pairs(self.posUlockFlag) do
		if locked == true then
			lockCount = lockCount + 1
		end
	end

	return lockCount
end

function RandomShop:isLock(pos)
	return self.posUlockFlag[pos] == true
end

function RandomShop:lockPos(pos)
	if not self:posIsLegal(pos) or type(self.posUlockFlag) ~= "table" then
		return false
	end

	if self:isLock(pos) then
		return true
	end

	local lockFlags = {}

	for lockPos, isLocked in pairs(self.posUlockFlag) do
		if isLocked then
			lockFlags[lockPos] = true
		end
	end

	lockFlags[pos] = true
	self.posUlockFlag = lockFlags

	return true
end

function RandomShop:unlockPos(pos)
	if not self:posIsLegal(pos) or type(self.posUlockFlag) ~= "table" then
		return false
	end

	if not self:isLock(pos) then
		return true
	end

	local lockFlags = {}

	for lockPos, isLocked in pairs(self.posUlockFlag) do
		if isLocked and lockPos ~= pos then
			lockFlags[lockPos] = true
		end
	end

	self.posUlockFlag = lockFlags

	return true
end

function RandomShop:getPosConfig(pos)
	if type(pos) ~= "number" or pos <= 0 then
		return nil
	end

	local shopId = self:getShopId()

	if shopId <= 0 then
		return nil
	end

	local shopPosData = RandomShopPosData[shopId]

	if type(shopPosData) == "table" and shopPosData[pos] then
		return shopPosData[pos]
	end

	return nil
end

function RandomShop:getRefreshCount()
	return self.refreshCount
end

function RandomShop:curBuyCount(goodId)
	for id, count in pairs(self.buyCount) do
		if id == goodId then
			return count
		end
	end

	return 0
end

function RandomShop:getRefreshCost()
	local shopConfig = RandomShopData[self:getShopId()]

	if not shopConfig then
		return nil, nil
	end

	local refreshCost = shopConfig.refreshCost

	if type(refreshCost) ~= "table" then
		return nil, nil
	end

	local refreshCount = self:getRefreshCount()

	if type(refreshCount) ~= "number" or refreshCount < 0 or refreshCount ~= math.floor(refreshCount) then
		return nil, nil
	end

	local currentRefreshTimes = refreshCount + 1
	local matchedStartTimes, matchedCostConfig

	for startTimes, costConfig in pairs(refreshCost) do
		if type(startTimes) ~= "number" or startTimes <= 0 or startTimes ~= math.floor(startTimes) then
			return nil, nil
		end

		if startTimes <= currentRefreshTimes and (not matchedStartTimes or matchedStartTimes < startTimes) then
			matchedStartTimes = startTimes
			matchedCostConfig = costConfig
		end
	end

	if type(matchedCostConfig) ~= "table" then
		return nil, nil
	end

	local costItemId = matchedCostConfig[1]
	local costItemNum = matchedCostConfig[2]

	if type(costItemId) ~= "number" or costItemId <= 0 then
		return nil, nil
	end

	if type(costItemNum) ~= "number" or costItemNum <= 0 then
		return nil, nil
	end

	return costItemId, costItemNum
end

function RandomShop:hasBoughtPos(pos)
	if type(pos) ~= "number" or type(self.hasBuyPos) ~= "table" then
		return false
	end

	for _, boughtPos in ipairs(self.hasBuyPos) do
		if boughtPos == pos then
			return true
		end
	end

	return false
end

function RandomShop:curTopTier()
	return self.topTier
end

function RandomShop:getPityValue()
	return self.pity
end

return RandomShop
