-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerStageInfo\\TowerStageInfoModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local RoguelikeData = require("Data.roguelike_data")
local TowerStageInfoModel = Class.LightClass("TowerStageInfoModel", UIModel)
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")

function TowerStageInfoModel:getSelectedPets(petIds)
	local data = {
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		}
	}

	for index, petId in ipairs(petIds) do
		local pet = pg.me.pets[petId]

		if pet then
			data[index] = LuaUIUtils.generatePetInfo(pet)
		end
	end

	return data
end

function TowerStageInfoModel:getAllPets()
	local data = {
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true,
			isLock = not RogueTalentUtils.func(pg.me, "rogueExtraSlot")
		}
	}

	for id, pet in pairs(pg.me.pets) do
		if pet and pg.me.selectRoguePets[id] then
			data[pg.me.selectRoguePets[id]] = LuaUIUtils.generatePetInfo(pet)
		end
	end

	return data
end

function TowerStageInfoModel:getAllPetMap()
	local data = {}

	for id, pet in pairs(pg.me.pets) do
		if pet and pg.me.selectRoguePets[id] then
			data[id] = LuaUIUtils.generatePetInfo(pet)
		end
	end

	return data
end

function TowerStageInfoModel:refreshPetInfo(pets)
	local newPetInfoMap = self:getAllPetMap()

	for i, pet in pairs(pets) do
		if not pet.isEmpty and not pet.isLock then
			pets[i] = newPetInfoMap[pet.id] or pet
		end
	end
end

return TowerStageInfoModel
