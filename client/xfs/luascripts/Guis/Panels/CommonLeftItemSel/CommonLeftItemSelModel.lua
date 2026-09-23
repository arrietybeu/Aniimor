-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonLeftItemSel\\CommonLeftItemSelModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonLeftItemSelModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local CommonLeftItemSelModel = Class.LightClass("CommonLeftItemSelModel", UIModel)

function CommonLeftItemSelModel:getTakeAllInfo(fromType, tempItemList, tempItemCountMap)
	local itemCntMap = tempItemCountMap
	local itemList = tempItemList

	if not fromType then
		return itemList, itemCntMap
	end

	if fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		local gameId = pg.me:getCatchRogueCurGameId()

		if not gameId then
			return itemList, itemCntMap
		end

		local levelData = CatchRoguePhaseData[gameId]

		if not levelData then
			return itemList, itemCntMap
		end

		local maxCnt = levelData.maxCount
		local curCnt = 0

		for itemId, count in pairs(itemCntMap) do
			curCnt = curCnt + count
		end

		if curCnt == maxCnt then
			return itemList, itemCntMap
		end

		local ballTypeInfo = levelData.ballType

		for index, info in ipairs(ballTypeInfo) do
			local itemId = info[1]
			local limitNum = info[2]
			local hasCnt = ItemUtils.getItemCountById(pg.me, itemId)
			local oriCnt = itemCntMap[itemId] or 0
			local max = maxCnt - curCnt + oriCnt
			local realCnt = math.min(max, math.min(hasCnt, limitNum))

			if realCnt <= 0 then
				break
			end

			curCnt = curCnt + (realCnt - oriCnt)
			itemCntMap[itemId] = realCnt

			if not table.contains(itemList, itemId) then
				itemList[#itemList + 1] = itemId
			end
		end

		return itemList, itemCntMap
	end
end

return CommonLeftItemSelModel
