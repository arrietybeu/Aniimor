-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCalcination\\GrabEggsCalcinationModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCalcinationModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsCalcinationModel = Class.LightClass("GrabEggsCalcinationModel", UIModel)
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local RobEggCollectionCalcineData = require("Data.rob_egg_collection_calcine_data")
local RobEggCollectionTagData = require("Data.rob_egg_collection_tag_data")
local RobEggCollectionCalcineRankData = require("Data.rob_egg_collection_calcine_rank_data")
local CALCINE_INV_ID = ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE
local ANTIQUE_DATA_KEY = ItemConst.ItemPropertyDef.AntiqueData

local function getAntiqueData(item)
	if not item or not ItemUtils.isRefineable(item.id) then
		return nil
	end

	return item.props[ANTIQUE_DATA_KEY]
end

local function getRemainCount(item)
	local antiqueData = getAntiqueData(item)

	if not antiqueData then
		return 0
	end

	return math.max(0, (antiqueData.max_affix_num or 0) - (antiqueData.affix_num or 0))
end

local function getTagConfig(tagId)
	return RobEggCollectionTagData[tagId]
end

local function getRankConfig(rankId)
	return RobEggCollectionCalcineRankData[rankId]
end

function GrabEggsCalcinationModel:ctor()
	UIModel.ctor(self)

	self.selectedGenID = nil
	self.CALCINE_INV_ID = CALCINE_INV_ID
end

function GrabEggsCalcinationModel:getCalcinableItems(retainedCompletedGenIDs)
	local ret = {}
	local props = LuaUIUtils.getInventoryProps(CALCINE_INV_ID)

	for i = 1, #props do
		local data = props[i]
		local isRetainedCompleted = retainedCompletedGenIDs and retainedCompletedGenIDs[data.genID]

		if getRemainCount(data.packSlot) > 0 or isRetainedCompleted then
			ret[#ret + 1] = data
		end
	end

	return ret
end

function GrabEggsCalcinationModel:getItemByGenID(genID)
	if not genID then
		return nil
	end

	return ItemUtils.getItem(pg.me, CALCINE_INV_ID, genID)
end

function GrabEggsCalcinationModel:setSelectedGenID(genID)
	self.selectedGenID = genID
end

function GrabEggsCalcinationModel:getSelectedGenID()
	return self.selectedGenID
end

function GrabEggsCalcinationModel:getSelectedItem()
	return self:getItemByGenID(self.selectedGenID)
end

function GrabEggsCalcinationModel:getItemTags(item)
	local tags = {}

	if not item then
		return tags
	end

	item:forEachAntiqueAffix(function(idx, affixId, score)
		local tagCfg = getTagConfig(affixId)

		tags[#tags + 1] = {
			idx = idx,
			affixId = affixId,
			score = score,
			tagName = tagCfg and pg.getLocalizationText(tagCfg.tagName) or "",
			tagLevel = tagCfg and tagCfg.tagLevel,
			tagIcon = tagCfg and tagCfg.tagIcon,
			effect = tagCfg and tagCfg.effect
		}
	end)

	return tags
end

function GrabEggsCalcinationModel:getRemainNodeCount(item)
	return getRemainCount(item)
end

function GrabEggsCalcinationModel:getCalcinedNodeCount(item)
	local antiqueData = getAntiqueData(item)

	return antiqueData and (antiqueData.affix_num or 0) or 0
end

function GrabEggsCalcinationModel:isCalcineCostEnough(item)
	local costTable = self:getCalcineCost(item)

	return costTable ~= nil and ItemUtils.simpleCheckItemCountEnough(pg.me, costTable)
end

function GrabEggsCalcinationModel:canCalcine()
	local item = self:getSelectedItem()

	return getRemainCount(item) > 0 and self:isCalcineCostEnough(item)
end

function GrabEggsCalcinationModel:getCalcineCost(item)
	if not item then
		return nil
	end

	local calcineCfg = RobEggCollectionCalcineData[item.id]

	if not calcineCfg then
		return nil
	end

	local antiqueData = getAntiqueData(item)

	if not antiqueData then
		return calcineCfg.calcCost1
	end

	local affix_num = antiqueData.affix_num or 0

	if affix_num == 0 then
		return calcineCfg.calcCost1
	elseif affix_num == 1 then
		return calcineCfg.calcCost2
	else
		return calcineCfg.calcCost3
	end
end

function GrabEggsCalcinationModel:getAntiqueScore(item)
	local total = 0

	if not item then
		return total
	end

	item:forEachAntiqueAffix(function(_, _, score)
		total = total + (score or 0)
	end)

	return total
end

function GrabEggsCalcinationModel:calcRatingInfo(item)
	local antiqueData = getAntiqueData(item)

	if not antiqueData then
		return {
			progress = 0,
			finalValue = 0,
			score = 0,
			valueRate = 1,
			levelName = "",
			level = ItemConst.AntiqueLevel.INIT
		}
	end

	local level = antiqueData.degree or ItemConst.AntiqueLevel.INIT
	local rankCfg = getRankConfig(level)
	local score = self:getAntiqueScore(item)
	local valueRate = rankCfg and rankCfg.doubleMul or 1
	local progress = 0

	if level > 0 then
		local currentThreshold = rankCfg and rankCfg.reqTagScr or 0
		local nextRankCfg = getRankConfig(level + 1)

		if nextRankCfg then
			local nextThreshold = nextRankCfg.reqTagScr
			local range = nextThreshold - currentThreshold

			if range > 0 then
				progress = math.min(1, math.max(0, (score - currentThreshold) / range))
			end
		else
			progress = 1
		end
	end

	local itemCfg = ItemData[item.id]
	local baseValue = itemCfg and itemCfg.sellPrice or 0
	local finalValue = math.ceil(baseValue * valueRate)

	return {
		level = level,
		levelName = rankCfg and pg.getLocalizationText(rankCfg.rankName) or "",
		valueRate = valueRate,
		score = score,
		progress = progress,
		finalValue = finalValue
	}
end

function GrabEggsCalcinationModel:requestCalcine(callback)
	local genID = self.selectedGenID

	if not genID then
		logger:warn("[Calcination] requestCalcine failed: no selected item")

		return false
	end

	pg.me:serverMsg("RPC_CS_RefineRobEggAntique", genID, callback)

	return true
end

return GrabEggsCalcinationModel
