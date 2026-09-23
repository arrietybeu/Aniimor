-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShopAccessoryAdjust\\CashShopAccessoryAdjustModel.lua

local Class = require("Core.Framework.Class")
local CashShopAccessoryAdjustModel = Class.LightClass("CashShopAccessoryAdjustModel")

function CashShopAccessoryAdjustModel:ctor()
	self.selectedAccessoryId = nil
	self.selectedSlotId = nil
	self.selectedPetAccessoryId = nil
	self.selectedPetGenId = nil
	self.selectedPetSlotIdx = 1
end

return CashShopAccessoryAdjustModel
