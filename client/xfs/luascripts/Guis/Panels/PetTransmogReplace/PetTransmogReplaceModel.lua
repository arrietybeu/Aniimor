-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogReplace\\PetTransmogReplaceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogReplaceModel = Class.LightClass("PetTransmogReplaceModel", UIModel)

function PetTransmogReplaceModel:ctor()
	self.petId = nil
	self.mode = PetTransmogUtils.REPLACE_MODE.SAVE_TEMP
	self.newTempIndex = 0
	self.selectedCustomIndex = nil
end

function PetTransmogReplaceModel:setContext(petId, mode, newTempIndex)
	self.petId = petId
	self.mode = mode or PetTransmogUtils.REPLACE_MODE.SAVE_TEMP
	self.newTempIndex = newTempIndex or 0
	self.selectedCustomIndex = nil
end

function PetTransmogReplaceModel:getPetId()
	return self.petId
end

function PetTransmogReplaceModel:getMode()
	return self.mode
end

function PetTransmogReplaceModel:getNewTempIndex()
	return self.newTempIndex
end

function PetTransmogReplaceModel:getCustomSchemes()
	return PetTransmogUtils.getCustomSchemes(self.petId)
end

function PetTransmogReplaceModel:setSelected(customIndex)
	self.selectedCustomIndex = customIndex
end

function PetTransmogReplaceModel:getSelected()
	return self.selectedCustomIndex
end

return PetTransmogReplaceModel
