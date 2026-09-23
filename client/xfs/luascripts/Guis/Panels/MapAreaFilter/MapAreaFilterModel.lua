-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MapAreaFilter\\MapAreaFilterModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuestModel")
local UIModel = require("Guis.UIModel")
local CountryAreaData = require("Data.country_area_data")
local NationConfigData = require("Data.nation_config_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local Class = require("Core.Framework.Class")
local MapAreaFilterModel = Class.LightClass("MapAreaFilterModel", UIModel)

function MapAreaFilterModel:getCountryConfig(countryId)
	return CountryAreaData[countryId]
end

function MapAreaFilterModel:getNationConfig(countryId)
	return NationConfigData[countryId]
end

function MapAreaFilterModel:getMapAreaConfig(mapAreaId)
	return MapAreaConfigData[mapAreaId]
end

function MapAreaFilterModel:getSmallMapAreaConfig(smallMapAreaId)
	return MapBlockConfigData[smallMapAreaId]
end

return MapAreaFilterModel
