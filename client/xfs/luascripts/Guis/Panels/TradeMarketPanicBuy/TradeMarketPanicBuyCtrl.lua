-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPanicBuy\\TradeMarketPanicBuyCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketPanicBuyCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local TradeMarketPanicBuyCtrl = Class.LightClass("TradeMarketPanicBuyCtrl", UICtrl)
local AUTO_CLOSE_DELAY_OFFSET = 5

TradeMarketPanicBuyCtrl.messages = {}

function TradeMarketPanicBuyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function TradeMarketPanicBuyCtrl:addListener()
	return
end

function TradeMarketPanicBuyCtrl:onDestroy()
	self:stopAutoCloseTimer()
	UICtrl.onDestroy(self)
end

function TradeMarketPanicBuyCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TradeMarketPanicBuyCtrl:onShow()
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("TRADE_MARKET_PANIC_BUY"))
	self:startAutoCloseTimer()
end

function TradeMarketPanicBuyCtrl:onHide()
	self:stopAutoCloseTimer()
end

function TradeMarketPanicBuyCtrl:startAutoCloseTimer()
	self:stopAutoCloseTimer()

	local rushDuration = SysConfigData.TRADE_RUSH_TIME or 5

	self.autoCloseTimer = TimerManager.addTimer(rushDuration + AUTO_CLOSE_DELAY_OFFSET, function()
		self.autoCloseTimer = nil

		self:dismiss()
	end)
end

function TradeMarketPanicBuyCtrl:stopAutoCloseTimer()
	if not self.autoCloseTimer then
		return
	end

	TimerManager.removeTimer(self.autoCloseTimer)

	self.autoCloseTimer = nil
end

return TradeMarketPanicBuyCtrl
