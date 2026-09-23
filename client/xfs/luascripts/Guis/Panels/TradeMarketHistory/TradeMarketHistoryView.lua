-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistory\\TradeMarketHistoryView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketHistoryView = Class.LightClass("TradeMarketHistoryView", UIView)

function TradeMarketHistoryView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.listPropUList = objectReference:GetRefValue("listPropUList")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
end

function TradeMarketHistoryView:registerObjects()
	return
end

function TradeMarketHistoryView:initView()
	return
end

return TradeMarketHistoryView
