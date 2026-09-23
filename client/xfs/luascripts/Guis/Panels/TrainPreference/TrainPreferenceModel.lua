-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TrainPreference\\TrainPreferenceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local TrainPreferenceModel = Class.LightClass("TrainPreferenceModel", UIModel)
local SpecialTrainTypeData = require("Data.special_train_type_data")
local QuestConst = require("Common.Const.QuestConst")

function TrainPreferenceModel:ctor()
	return
end

function TrainPreferenceModel:getTypePageConfig(pageType)
	return SpecialTrainTypeData[pageType]
end

function TrainPreferenceModel:getPageTypeTb()
	local typeTb = {}

	for _, tp in pairs(QuestConst.QUEST_TRAIN_SUB_TYPE) do
		if tp > 1 then
			local temp = {}

			temp.trainType = tp

			table.insert(typeTb, temp)
		end
	end

	table.sort(typeTb, function(a, b)
		return a.trainType < b.trainType
	end)

	return typeTb
end

return TrainPreferenceModel
