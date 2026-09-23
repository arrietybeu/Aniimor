-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogVideo\\PetTransmogVideoModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogVideoModel = Class.LightClass("PetTransmogVideoModel", UIModel)

function PetTransmogVideoModel:ctor()
	self.petId = nil
	self.videoUrl = nil
end

function PetTransmogVideoModel:setContext(petId, videoUrl)
	self.petId = petId
	self.videoUrl = videoUrl
end

function PetTransmogVideoModel:getPetId()
	return self.petId
end

function PetTransmogVideoModel:getVideoUrl()
	return self.videoUrl
end

return PetTransmogVideoModel
