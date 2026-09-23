-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PetResearchUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetTraitData = require("Data.pet_trait_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetResearchUtils = {}

function PetResearchUtils.genPetHandbookInitDict(petPrototypeId)
	local Globals = require("Globals")

	if Globals.cachePetHandbookInitDict[petPrototypeId] then
		return Globals.cachePetHandbookInitDict[petPrototypeId]
	end

	local traitResearchMap = {}

	for traitId, _ in pairs(PetTraitData[petPrototypeId] or EMPTY_TABLE) do
		traitResearchMap[traitId] = PetResearchUtils.genTraitResearchInfoInitDict(petPrototypeId, traitId)
	end

	local evolveResearchMap = {}

	for evolveId, _ in pairs(PetEvolveData[petPrototypeId] or EMPTY_TABLE) do
		evolveResearchMap[evolveId] = PetResearchUtils.genEvolveResearchInfoInitDict(petPrototypeId, evolveId)
	end

	Globals.cachePetHandbookInitDict[petPrototypeId] = {
		traitResearchMap = traitResearchMap,
		evolveResearchMap = evolveResearchMap
	}

	return Globals.cachePetHandbookInitDict[petPrototypeId]
end

function PetResearchUtils.genTraitResearchInfoInitDict(petPrototypeId, traitId)
	local ptdd = PetTraitData[petPrototypeId] and PetTraitData[petPrototypeId][traitId]

	if ptdd == nil then
		return nil
	end

	local dict = {
		status = ptdd.initState
	}

	return dict
end

function PetResearchUtils.genEvolveResearchInfoInitDict(petPrototypeId, evolveId)
	local pedd = PetEvolveData[petPrototypeId] and PetEvolveData[petPrototypeId][evolveId]

	if pedd == nil then
		return nil
	end

	local dict = {
		status = pedd.routeInitState or Const.PET_RESEARCH.STATUS_CLUE,
		normalConditionStatus = {},
		itemConditionStatus = {}
	}

	if pedd.normalCondition0 then
		dict.normalConditionStatus[0] = pedd.normalCondition0[Const.PET_EVOLVE_NORMAL_COND_POS_STATE]
	end

	for condId, condd in pairs(pedd.normalConditions or EMPTY_TABLE) do
		dict.normalConditionStatus[condId] = condd[Const.PET_EVOLVE_NORMAL_COND_POS_STATE]
	end

	for condId, condd in pairs(pedd.itemConditions or EMPTY_TABLE) do
		dict.itemConditionStatus[condId] = condd[Const.PET_EVOLVE_ITEM_COND_POS_STATE]
	end

	return dict
end

function PetResearchUtils.getSumNeededExpForUpgrade(petPrototypeId)
	local needSumExp = {}
	local prcdd = PetResearchContentData[Utils.getBasePetPrototypeId(petPrototypeId)]

	if prcdd == nil or prcdd.needResearchPoint == nil then
		return needSumExp
	end

	local sum = 0

	needSumExp[0] = 0

	for lv, exp in ipairs(prcdd.needResearchPoint) do
		if exp ~= nil then
			sum = sum + exp
			needSumExp[lv] = sum
		end
	end

	return needSumExp
end

return PetResearchUtils
