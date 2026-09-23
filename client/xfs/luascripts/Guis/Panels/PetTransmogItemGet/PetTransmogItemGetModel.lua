-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogItemGet\\PetTransmogItemGetModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogItemGetModel = Class.LightClass("PetTransmogItemGetModel", UIModel)

function PetTransmogItemGetModel:ctor()
	self.commodityId = nil
	self.buyCount = 1
end

function PetTransmogItemGetModel:setContext(commodityId, defaultBuyCount)
	self.commodityId = commodityId
	self.buyCount = defaultBuyCount or 1
end

function PetTransmogItemGetModel:getCommodityId()
	return self.commodityId
end

function PetTransmogItemGetModel:setBuyCount(n)
	self.buyCount = n and n > 0 and n or 1
end

function PetTransmogItemGetModel:getBuyCount()
	return self.buyCount
end

return PetTransmogItemGetModel
