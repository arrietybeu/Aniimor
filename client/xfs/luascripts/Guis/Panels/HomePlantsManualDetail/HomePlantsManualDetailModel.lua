-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManualDetail\\HomePlantsManualDetailModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualDetailModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AllPlantsData = require("Data.homeland_formula_random_data")
local ItemData = require("Data.item_data")
local lume = require("Core.Common.lume")
local PlantData = require("Data.plant_book_data")
local HomePlantsManualDetailModel = Class.LightClass("HomePlantsManualDetailModel", UIModel)

function HomePlantsManualDetailModel:getAllPlantsByFormulaId(formulaId, totalNum)
	local allData = AllPlantsData[formulaId]
	local res = {}

	if allData == nil then
		return res
	end

	local endIndex = totalNum - 1

	for i = 0, endIndex do
		local v = allData[i]

		if v then
			table.insert(res, {
				name = v.name,
				type = i,
				itemId = v.output
			})
		end
	end

	return res
end

function HomePlantsManualDetailModel.getPlantInfo(plantId)
	local cfgData = PlantData[plantId]

	if cfgData then
		return plantId, cfgData.fomulaId, cfgData.num, cfgData.reward, cfgData.icon
	end
end

return HomePlantsManualDetailModel
