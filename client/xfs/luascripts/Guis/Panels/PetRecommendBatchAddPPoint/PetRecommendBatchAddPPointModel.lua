-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchAddPPoint\\PetRecommendBatchAddPPointModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchAddPPointModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetRecommendBatchAddPPointModel = Class.LightClass("PetRecommendBatchAddPPointModel", UIModel)
local RecommendData = require("Data.pet_strength_recommend_data")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local Const = require("Common.Const.Const")
local FormulaData = require("Data.formula_data")
local math_floor = math.floor

function PetRecommendBatchAddPPointModel:getPetRecommendList(petId)
	self.recommendSuitInfos = PetManagementUtils.getPetRecommendList(petId) or {}

	return self.recommendSuitInfos
end

function PetRecommendBatchAddPPointModel:getUsedPPointSum(data)
	if not data or not data.detailPropInfos then
		return 0
	end

	local usedPPointSum = 0

	for _, v in ipairs(data.detailPropInfos or EMPTY_TABLE) do
		usedPPointSum = usedPPointSum + (v.m_usedPotentialPointSum or 0)
	end

	return usedPPointSum
end

function PetRecommendBatchAddPPointModel:isPetNewPropApplied(petId, checkSuitInfo)
	return PetManagementUtils.isPetNewPropApplied(petId, checkSuitInfo)
end

return PetRecommendBatchAddPPointModel
