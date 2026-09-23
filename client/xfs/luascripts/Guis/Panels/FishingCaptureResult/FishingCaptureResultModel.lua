-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureResult\\FishingCaptureResultModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local FishingCaptureResultModel = Class.LightClass("FishingCaptureResultModel", UIModel)

function FishingCaptureResultModel:ctor()
	UIModel.ctor(self)

	self._settlementData = nil
end

function FishingCaptureResultModel:setSettlementData(data)
	self._settlementData = data
end

function FishingCaptureResultModel:getSettlementData()
	return self._settlementData
end

function FishingCaptureResultModel:loadSettlementData(data, callback)
	if data and data.petId then
		self:setSettlementData(data)
		callback(data)

		return
	end

	local cachedData = pg.me and pg.me.getFishingCaptureContractSettlementData and pg.me:getFishingCaptureContractSettlementData()

	if cachedData then
		self:setSettlementData(cachedData)
		callback(cachedData)

		return
	else
		callback()
	end
end

return FishingCaptureResultModel
