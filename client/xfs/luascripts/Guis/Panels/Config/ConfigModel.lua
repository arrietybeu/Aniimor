-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Config\\ConfigModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ConfigModel = Class.LightClass("ConfigModel", UIModel)
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local SceneData = require("Data.scene_data")
local ItemData = require("Data.item_data")
local GmToolUtils = require("Utils.GmToolUtils")

local function cmpByValue(a, b)
	if a.value == b.value then
		return false
	end

	return a.value < b.value
end

function ConfigModel:getSceneList()
	local sceneList = {}

	for k, v in pairs(SceneData) do
		if v.canEnterByAltX and v.canEnterByAltX ~= 0 then
			sceneList[#sceneList + 1] = {
				tIndex = 0,
				label = k .. " " .. GmToolUtils.getGmLocalizationText(v.name),
				value = k
			}
		end
	end

	table.sort(sceneList, cmpByValue)

	return sceneList
end

function ConfigModel:getPuppetList()
	local puppetList = {}

	for k, v in pairs(PuppetData) do
		if k >= 10000000 and k <= 29999999 and k % 100 == 0 or k == 9999 or k == 10000 or k == 10001 then
			puppetList[#puppetList + 1] = {
				tIndex = 0,
				label = k .. " " .. GmToolUtils.getGmLocalizationText(v.name),
				iconUrl = LuaUIUtils.getPetIcon(v.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL),
				value = k
			}
		end
	end

	table.sort(puppetList, cmpByValue)

	return puppetList
end

function ConfigModel:getPetList()
	local petList = {}

	for k, v in pairs(PetData) do
		petList[#petList + 1] = {
			tIndex = 0,
			label = k .. " " .. GmToolUtils.getGmLocalizationText(v.name),
			value = k,
			iconName = v.iconName,
			iconUrl = LuaUIUtils.getPetIcon(v.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)
		}
	end

	table.sort(petList, cmpByValue)

	return petList
end

function ConfigModel:getItemList()
	local itemList = {}

	for key, value in pairs(ItemData) do
		itemList[#itemList + 1] = {
			tIndex = 0,
			label = key .. " " .. GmToolUtils.getGmLocalizationText(value.itemName),
			iconUrl = LuaUIUtils.getIconByIconId(value.icon),
			value = key
		}
	end

	table.sort(itemList, cmpByValue)

	return itemList
end

function ConfigModel:getFrameList()
	local frameList = {
		{
			label = "30",
			value = 30
		},
		{
			label = "60",
			value = 60
		},
		{
			label = "90",
			value = 90
		},
		{
			label = "120",
			value = 120
		}
	}

	return frameList
end

return ConfigModel
