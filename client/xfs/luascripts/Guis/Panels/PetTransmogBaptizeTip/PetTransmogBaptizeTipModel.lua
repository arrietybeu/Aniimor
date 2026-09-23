-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogBaptizeTip\\PetTransmogBaptizeTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogBaptizeTipModel = Class.LightClass("PetTransmogBaptizeTipModel", UIModel)

function PetTransmogBaptizeTipModel:ctor()
	self.petId = nil
	self.holeIndex = nil
end

function PetTransmogBaptizeTipModel:setContext(petId, holeIndex)
	self.petId = petId
	self.holeIndex = holeIndex
end

function PetTransmogBaptizeTipModel:getPetId()
	return self.petId
end

function PetTransmogBaptizeTipModel:getHoleIndex()
	return self.holeIndex
end

return PetTransmogBaptizeTipModel
