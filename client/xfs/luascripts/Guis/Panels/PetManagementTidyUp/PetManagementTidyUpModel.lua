-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementTidyUp\\PetManagementTidyUpModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local PetManagementTidyUpModel = Class.LightClass("PetManagementTidyUpModel", UIModel)

function PetManagementTidyUpModel:getOptionsInfo()
	local sortInfos = {
		{
			idx = 0,
			name = pg.getGameString("SORT_TYPE_1")
		},
		{
			idx = 1,
			name = pg.getGameString("SORT_TYPE_4")
		},
		{
			idx = 2,
			name = pg.getGameString("SORT_TYPE_2")
		},
		{
			idx = 3,
			name = pg.getGameString("SORT_TYPE_5")
		},
		{
			idx = 4,
			name = pg.getGameString("SORT_TYPE_6")
		},
		{
			idx = 5,
			name = pg.getGameString("PET_FAMILY")
		},
		{
			idx = 6,
			name = pg.getGameString("PET_TIDY_COMPACT")
		}
	}

	return sortInfos
end

function PetManagementTidyUpModel:getBoxNameById(id)
	local petBoxMap = pg.me.petBoxMap
	local customName = petBoxMap[id].customName

	if customName and customName ~= "" then
		return customName
	end

	return pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. id
end

return PetManagementTidyUpModel
