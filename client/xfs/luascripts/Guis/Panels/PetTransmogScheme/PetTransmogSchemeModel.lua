-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogScheme\\PetTransmogSchemeModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogSchemeModel = Class.LightClass("PetTransmogSchemeModel", UIModel)

function PetTransmogSchemeModel:ctor()
	self.petId = nil
	self.selectedTempIndex = nil
end

function PetTransmogSchemeModel:setPetId(petId)
	self.petId = petId
end

function PetTransmogSchemeModel:getPetId()
	return self.petId
end

function PetTransmogSchemeModel:setSelected(idx)
	self.selectedTempIndex = idx
end

function PetTransmogSchemeModel:getSelected()
	return self.selectedTempIndex
end

function PetTransmogSchemeModel:getTempSchemes()
	return PetTransmogUtils.getTempSchemes(self.petId)
end

function PetTransmogSchemeModel:getCustomSchemes()
	return PetTransmogUtils.getCustomSchemes(self.petId)
end

return PetTransmogSchemeModel
