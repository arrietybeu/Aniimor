-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPanicBuy\\TradeMarketPanicBuyView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketPanicBuyView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketPanicBuyView = Class.LightClass("TradeMarketPanicBuyView", UIView)

function TradeMarketPanicBuyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
end

function TradeMarketPanicBuyView:registerObjects()
	return
end

function TradeMarketPanicBuyView:initView()
	return
end

return TradeMarketPanicBuyView
