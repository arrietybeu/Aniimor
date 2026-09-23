-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FirstPetShow\\FirstPetShowModel.lua

local PetResearchData = require("Data.pet_research_content_data")
local PetData = require("Data.pet_data")
local ElementPropData = require("Data.element_prop_data")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local FirstPetShowModel = Class.LightClass("FirstPetShowModel", UIModel)
local remove = table.remove

function FirstPetShowModel:setNewPets(newPets)
	self.newPets = newPets
end

function FirstPetShowModel:getNewPetInfo()
	if #self.newPets > 0 then
		local petInfo = remove(self.newPets)
		local researchInfo = PetResearchData[petInfo.templateId] or {}

		petInfo.numberId = researchInfo.number
		petInfo.desc = researchInfo.firstShowDesc

		local mainElementType = PetData[petInfo.templateId].mainElementType
		local mainElementName = ElementPropData[mainElementType].name

		petInfo.mainElementName = mainElementName

		return petInfo
	end
end

return FirstPetShowModel
