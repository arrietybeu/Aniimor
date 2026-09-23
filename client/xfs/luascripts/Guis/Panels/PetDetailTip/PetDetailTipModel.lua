-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDetailTip\\PetDetailTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetProtoTypeData = require("Data.pet_prototype_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Utils = require("Common.Utils.Utils")
local PetDetailTipModel = Class.LightClass("PetDetailTipModel", UIModel)

function PetDetailTipModel:ctor()
	return
end

function PetDetailTipModel:getTitlePetList(templateIds)
	local res = {}
	local baseIds = self:getBaseTemplateIdList(templateIds)

	for index, templateId in ipairs(baseIds) do
		local confProtoData = PetProtoTypeData[templateId]

		if confProtoData == nil then
			return
		end

		res[#res + 1] = {
			headRes = LuaUIUtils.getPetIcon(confProtoData.iconName, LuaUIUtils.PET_ICON),
			id = templateId
		}
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)

	return res
end

function PetDetailTipModel:getCatchRogueTemplateIdList(gameId)
	local ids = CatchRoguePhaseData[gameId].catchpetType or {}

	return ids
end

function PetDetailTipModel:getBaseTemplateIdList(ids)
	local res = {}

	for index, id in ipairs(ids) do
		local baseId = Utils.getBasePetPrototypeId(id)

		if not table.contains(res, baseId) then
			res[#res + 1] = baseId
		end
	end

	return res
end

return PetDetailTipModel
