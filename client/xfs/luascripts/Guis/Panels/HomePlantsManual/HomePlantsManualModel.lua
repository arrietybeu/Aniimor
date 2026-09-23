-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManual\\HomePlantsManualModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RewardData = require("Data.book_progress_reward_data")
local PlantData = require("Data.plant_book_data")
local AllPlantsData = require("Data.homeland_formula_random_data")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local HomePlantsManualModel = Class.LightClass("HomePlantsManualModel", UIModel)

HomePlantsManualModel.CONST = {
	OnePageNum = 16
}

function HomePlantsManualModel:getTotalProcessNum()
	local count = 0

	for _, data in pairs(AllPlantsData or EMPTY_TABLE) do
		count = count + lume.tableLength(data)
	end

	return count
end

function HomePlantsManualModel:getRewardListDataNoLast()
	local cnt = #RewardData - 1
	local res = {}
	local preNum = 0

	for i = 1, cnt do
		local cfg = RewardData[i]

		if cfg then
			local data = {
				id = i,
				numMin = preNum,
				numMax = cfg.num,
				rewardId = cfg.reward,
				isGet = self.isProcessRewardGet(cfg.reward)
			}

			table.insert(res, data)

			preNum = cfg.num + 1
		end
	end

	return res
end

function HomePlantsManualModel:getRewardListLastData()
	local cnt = #RewardData
	local pre = RewardData[cnt - 1]
	local last = RewardData[cnt]

	return {
		id = cnt,
		numMin = pre.num + 1,
		numMax = last.num,
		rewardId = last.reward,
		isGet = self.isProcessRewardGet(last.reward)
	}
end

function HomePlantsManualModel:getRewardListCanGet()
	local processId = 1
	local hasReward = false
	local curNum = Utils.getPlantBookSum(pg.me.plantBook)

	for k, v in ipairs(RewardData) do
		if curNum >= v.num then
			local isGet = self.isProcessRewardGet(v.reward)

			if isGet == false then
				processId = k
				hasReward = true
			end
		else
			break
		end
	end

	return hasReward, processId
end

function HomePlantsManualModel.isProcessRewardGet(rewardId)
	return pg.me.plantBookRewardMap[rewardId] or false
end

function HomePlantsManualModel:getPlantPageData()
	local num = #PlantData
	local pageNum = math.floor(num / HomePlantsManualModel.CONST.OnePageNum)
	local remainder = num % HomePlantsManualModel.CONST.OnePageNum

	if remainder > 0 then
		pageNum = pageNum + 1
	end

	local res = {}

	for i = 1, pageNum do
		res[i] = {}
	end

	return res
end

function HomePlantsManualModel:getAllPlantListData(totalPage)
	local res = {}
	local endIndex = totalPage - 1

	for i = 0, endIndex do
		res[i] = self:getPlantListDataByPage(i)
	end

	return res
end

function HomePlantsManualModel:getPlantListDataByPage(pageIndex)
	local res = {}
	local totalNum = #PlantData
	local startIndex = pageIndex * HomePlantsManualModel.CONST.OnePageNum + 1
	local endIndex = startIndex + HomePlantsManualModel.CONST.OnePageNum - 1

	for i = startIndex, endIndex do
		if totalNum < i then
			table.insert(res, {
				tIndex = 1
			})
		else
			local v = PlantData[i]
			local data = {
				tIndex = 0,
				id = i,
				name = v.name,
				icon = v.icon,
				formulaId = v.fomulaId,
				numMax = v.num,
				rewardId = v.reward
			}

			table.insert(res, data)
		end
	end

	return res
end

return HomePlantsManualModel
