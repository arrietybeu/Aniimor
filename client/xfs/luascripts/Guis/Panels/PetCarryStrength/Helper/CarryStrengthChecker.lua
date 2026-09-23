-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrength\\Helper\\CarryStrengthChecker.lua

local class = require("Core.Framework.Class")
local CarryStrengthChecker = class.LightClass("CarryStrengthChecker")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local CoreCarryLevelData = require("Data.core_carry_level_data")

function CarryStrengthChecker:ctor()
	return
end

function CarryStrengthChecker.checkCanAddMaxExp(data)
	return data.maxExp - data.curExp
end

function CarryStrengthChecker.autoAddCarries(data, dataList)
	local maxCanAddExp = data.totalCanAddExp - data.addExp

	for _, v in ipairs(dataList) do
		if v.type == ItemConst.ITEM_TYPE.CoreCarryCost then
			v.selectedAsExp = true

			local oneAddExp = ItemUtils.getCoreCarryConvertExpByItemId(v.itemId)
			local addNum = math.ceil(maxCanAddExp / oneAddExp)

			if addNum <= v.ownNum then
				v.selectedNum = addNum
			else
				v.selectedNum = v.ownNum
			end

			maxCanAddExp = maxCanAddExp - oneAddExp * v.selectedNum

			if maxCanAddExp <= 0 then
				break
			end
		else
			local oneAddExp = ItemUtils.getCoreCarryConvertExp(v.sourceItem)

			if maxCanAddExp > 0 then
				maxCanAddExp = maxCanAddExp - oneAddExp
				v.selectedAsExp = true
			else
				break
			end
		end
	end
end

function CarryStrengthChecker.checkAddExpAndLv(data, dataList)
	if #dataList == 0 then
		return 0, 0, data.isMaxLv
	end

	if data.isMaxLv then
		return 0, 0, true
	end

	local allAddExp = 0

	for _, v in ipairs(dataList) do
		if v.type == ItemConst.ITEM_TYPE.CoreCarryCost then
			local oneAddExp = ItemUtils.getCoreCarryConvertExpByItemId(v.itemId)

			allAddExp = allAddExp + oneAddExp * v.selectedNum
		else
			local oneAddExp = ItemUtils.getCoreCarryConvertExp(v.sourceItem)

			allAddExp = allAddExp + oneAddExp
		end
	end

	local tmpExp = allAddExp
	local maxLevel = data.mLevel
	local nextLv = data.cLevel + 1
	local needExp = CoreCarryLevelData[nextLv].needExp

	needExp = needExp - data.curExp

	while tmpExp > 0 and nextLv <= maxLevel do
		tmpExp = tmpExp - needExp

		if tmpExp >= 0 then
			nextLv = nextLv + 1
			needExp = CoreCarryLevelData[nextLv] and CoreCarryLevelData[nextLv].needExp or 0
		end
	end

	nextLv = nextLv - 1

	return allAddExp, nextLv, nextLv >= data.mLevel
end

return CarryStrengthChecker
