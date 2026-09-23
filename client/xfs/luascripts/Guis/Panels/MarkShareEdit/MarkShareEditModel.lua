-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareEdit\\MarkShareEditModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InfoStampConcatContentData = require("Data.info_stamp_concat_content_data")
local InfoStampConcatCatalogData = require("Data.info_stamp_concat_catalog_data")
local InfoStampCostConfigData = require("Data.info_stamp_cost_config_data")
local InfoStampAnimationConfigData = require("Data.info_stamp_animation_config_data")
local InfoStampCustomBubbleConfigData = require("Data.info_stamp_custom_bubble_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local Utils = require("Common.Utils.Utils")
local MarkShareEditModel = Class.LightClass("MarkShareEditModel", UIModel)

MarkShareEditModel.CONTENT_TYPE = {
	CONJ = 3,
	WORD = 2,
	SENTENCE = 1
}

function MarkShareEditModel:getSentenceData()
	local ret = {}

	for k, v in pairs(InfoStampConcatContentData) do
		if v.contentType == MarkShareEditModel.CONTENT_TYPE.SENTENCE then
			ret[#ret + 1] = {
				name = pg.getLocalizationText(v.categoryName),
				key = k,
				sequence = v.sequence
			}
		end
	end

	table.sort(ret, function(a, b)
		return a.sequence < b.sequence
	end)

	return ret
end

function MarkShareEditModel:getWordTabData()
	local ret = {}

	for k, v in pairs(InfoStampConcatCatalogData[MarkShareEditModel.CONTENT_TYPE.WORD]) do
		ret[#ret + 1] = {
			icon = v.icon,
			key = k,
			tpName = pg.getLocalizationText(v.categoryName)
		}
	end

	return ret
end

function MarkShareEditModel:getWordsData(tab)
	local ret = {}

	for k, v in pairs(InfoStampConcatContentData) do
		if v.contentType == MarkShareEditModel.CONTENT_TYPE.WORD and v.categoryId == tab then
			ret[#ret + 1] = {
				name = pg.getLocalizationText(v.categoryName),
				key = k,
				sequence = v.sequence
			}
		end
	end

	table.sort(ret, function(a, b)
		return a.sequence < b.sequence
	end)

	return ret
end

function MarkShareEditModel:getConjData()
	local ret = {}

	for k, v in pairs(InfoStampConcatContentData) do
		if v.contentType == MarkShareEditModel.CONTENT_TYPE.CONJ then
			ret[#ret + 1] = {
				name = pg.getLocalizationText(v.categoryName),
				key = k,
				sequence = v.sequence
			}
		end
	end

	table.sort(ret, function(a, b)
		return a.sequence < b.sequence
	end)

	return ret
end

function MarkShareEditModel:getConsumeCostData(type)
	local ret = {}
	local costTable = InfoStampCostConfigData[type].cost

	for _, v in pairs(costTable) do
		ret[#ret + 1] = {
			id = v[1],
			num = v[2]
		}
	end

	return ret
end

function MarkShareEditModel:getDefaultAnimation()
	return Utils.getInfoStampDefaultAnimation()
end

function MarkShareEditModel:getAnimationData()
	local temp = {}

	for k, v in pairs(InfoStampAnimationConfigData) do
		temp[#temp + 1] = {
			key = k,
			icon = v[1].icon,
			order = v[1].order
		}
	end

	temp[#temp + 1] = {
		key = -1,
		order = math.maxInt
	}

	table.sort(temp, function(a, b)
		return a.order < b.order
	end)

	return temp
end

function MarkShareEditModel:getBubbleData()
	local ret = {}

	for k, v in pairs(InfoStampCustomBubbleConfigData) do
		ret[k] = {
			icon = v.bubbleRes,
			key = k
		}
	end

	return ret
end

function MarkShareEditModel:getBubbleRes(bubbleType)
	return InfoStampCustomBubbleConfigData[bubbleType].bubbleRes
end

function MarkShareEditModel:getIconByAnimationIndex(index)
	if index == -1 then
		return nil
	end

	return InfoStampAnimationConfigData[index][1].icon
end

function MarkShareEditModel:getIconByBubbleTypeIndex(index)
	if not index then
		return AddressDataConst.DEFAULT_BUBBLE_TYPE
	end

	return InfoStampCustomBubbleConfigData[index].bubbleResMini
end

return MarkShareEditModel
