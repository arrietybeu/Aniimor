-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistory\\TradeMarketHistoryModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local TradeConst = require("Common.Const.TradeConst")
local TradeMarketHistoryModel = Class.LightClass("TradeMarketHistoryModel", UIModel)

TradeMarketHistoryModel.HistoryType = {
	Buy = 1,
	Sell = 2
}

function TradeMarketHistoryModel.getHistoryTabData()
	local ret = {}

	table.insert(ret, {
		tIndex = 0,
		name = "SHOP_BUY",
		historyType = TradeMarketHistoryModel.HistoryType.Buy
	})
	table.insert(ret, {
		tIndex = 2,
		name = "CONSIGNMENT",
		historyType = TradeMarketHistoryModel.HistoryType.Sell
	})

	return ret
end

function TradeMarketHistoryModel:getItemHistoryData(historyType)
	return self:getHistoryData(TradeConst.TRADE_TYPE_ITEM, historyType)
end

function TradeMarketHistoryModel:getPetHistoryData(historyType)
	return self:getHistoryData(TradeConst.TRADE_TYPE_PET, historyType)
end

function TradeMarketHistoryModel:getBuyHistoryData(subPageType)
	return self:getHistoryData(subPageType, self.HistoryType.Buy)
end

function TradeMarketHistoryModel:getSellHistoryData(subPageType)
	return self:getHistoryData(subPageType, self.HistoryType.Sell)
end

function TradeMarketHistoryModel:clearHistoryData()
	self.recordsByDisplayType = {}
	self.recordTotalByDisplayType = {}
end

function TradeMarketHistoryModel:setHistoryData(displayType, records, total)
	self.recordsByDisplayType = self.recordsByDisplayType or {}
	self.recordTotalByDisplayType = self.recordTotalByDisplayType or {}
	self.recordsByDisplayType[displayType] = records or {}
	self.recordTotalByDisplayType[displayType] = total or 0
end

function TradeMarketHistoryModel:hasHistoryData(displayType)
	return self.recordsByDisplayType and self.recordsByDisplayType[displayType] ~= nil
end

function TradeMarketHistoryModel:getHistoryData(displayType, historyType)
	local records = self.recordsByDisplayType and self.recordsByDisplayType[displayType] or {}
	local isBuyer

	if historyType == self.HistoryType.Buy then
		isBuyer = true
	elseif historyType == self.HistoryType.Sell then
		isBuyer = false
	else
		return {}
	end

	local ret = {}

	for _, record in ipairs(records) do
		if record.isBuyer == isBuyer then
			ret[#ret + 1] = record
		end
	end

	return ret
end

return TradeMarketHistoryModel
