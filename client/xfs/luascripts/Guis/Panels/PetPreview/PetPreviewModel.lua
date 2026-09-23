-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetPreview\\PetPreviewModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetPreviewModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetPreviewModel = Class.LightClass("PetPreviewModel", UIModel)
local Const = require("Common.Const.Const")

function PetPreviewModel:getPreviewInfo(templateIds)
	local rainbowPets = {}
	local weatherPets = {}
	local otherPets = {}

	for index, templateId in ipairs(templateIds) do
		if Utils.isRainbowType(templateId) then
			table.insert(rainbowPets, {
				templateId = templateId
			})
		elseif Utils.matchFormTypeByTempId(templateId, {
			Const.FormName2Id.thunderstorm,
			Const.FormName2Id.snow
		}) then
			table.insert(weatherPets, {
				templateId = templateId
			})
		else
			table.insert(otherPets, {
				templateId = templateId
			})
		end
	end

	local result = {
		{
			typeName = pg.getGameString("CATCH_ROGUE_SHOW_SPECIAL_PET"),
			petData = rainbowPets
		},
		{
			typeName = pg.getGameString("CATCH_ROGUE_SHOW_WEATHER_PET"),
			petData = weatherPets
		},
		{
			typeName = pg.getGameString("CATCH_ROGUE_SHOW_OTHER_PET"),
			petData = otherPets
		}
	}

	return result
end

function PetPreviewModel:getBaseTemplateIds(templateIds)
	local res = {}

	for index, templateId in ipairs(templateIds) do
		local baseId = Utils.getBasePetPrototypeId(templateId)

		if not table.contains(res, baseId) then
			res[#res + 1] = baseId
		end
	end

	return res
end

return PetPreviewModel
