-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelectFilter\\GrowthGiftSelectFilterModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ElementNameToId = require("Data.element_name_to_id")
local ElementPropData = require("Data.element_prop_data")
local PetConfigData = require("Data.pet_config_data")
local GrowthGiftSelectFilterModel = Class.LightClass("GrowthGiftSelectFilterModel", UIModel)

function GrowthGiftSelectFilterModel:getAllElements()
	local data = {}

	for k, v in pairs(ElementNameToId) do
		if k ~= "null" and ElementPropData[v] and ElementPropData[v].isShow == 1 then
			local d = {}

			d.name = k
			d.icon = AddressDataConst["FILTER_ELEMENT_" .. v]
			d.order = v
			data[#data + 1] = d
		end
	end

	table.sort(data, function(a, b)
		return a.order < b.order
	end)

	return data
end

function GrowthGiftSelectFilterModel:getAllPetTypes()
	local energyTextKey = UIConst.PET_FUNCTION_TEXT_MAP[UIConst.NEW_PET_BATTLE_TYPE.ENERGY]
	local energyTextId = energyTextKey and PetConfigData[energyTextKey]

	return {
		{
			name = pg.getGameString("FILTER_DPS"),
			type = UIConst.NEW_PET_BATTLE_TYPE.DPS,
			icon = AddressDataConst.FILTER_ROLE_DPS
		},
		{
			name = pg.getGameString("FILTER_SUP"),
			type = UIConst.NEW_PET_BATTLE_TYPE.SUP,
			icon = AddressDataConst.FILTER_ROLE_SUP
		},
		{
			name = pg.getGameString("FILTER_HEAL"),
			type = UIConst.NEW_PET_BATTLE_TYPE.HEAL,
			icon = AddressDataConst.FILTER_ROLE_HEAL
		},
		{
			name = pg.getGameString("ATTRIBUTE_NAT"),
			type = UIConst.NEW_PET_BATTLE_TYPE.BREAK,
			icon = AddressDataConst.FILTER_ROLE_BREAK
		},
		{
			name = energyTextId and pg.getLocalizationText(energyTextId) or "",
			type = UIConst.NEW_PET_BATTLE_TYPE.ENERGY,
			icon = AddressDataConst.FILTER_ROLE_ENERGY
		}
	}
end

return GrowthGiftSelectFilterModel
