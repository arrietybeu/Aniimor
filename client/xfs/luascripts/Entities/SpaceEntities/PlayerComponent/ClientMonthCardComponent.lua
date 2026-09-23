-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientMonthCardComponent.lua

local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local ClientMonthCardComponent = class.Component("ClientMonthCardComponent")

function ClientMonthCardComponent:ctor()
	return
end

function ClientMonthCardComponent:destroy()
	return
end

function ClientMonthCardComponent:RPC_SC_NotifyOpenMonthCardSuccess(type)
	facade:sendMsgToUI(MessageName.CASH_SHOP_REWARD_CHANGED)
	facade:sendMsgToUI(MessageName.MONTH_CARD_ACTIVATE)
	pg.game.monthCard:tryShowDailyRewardPopup()
end

function ClientMonthCardComponent:monthCardReceiveDailyAward()
	self:serverMsg("RPC_CS_MonthCardReceiveDailyAward", CallbackHandler(self, "onReceiveDailyAwardCallback"))
end

function ClientMonthCardComponent:onReceiveDailyAwardCallback(code)
	if code ~= 0 then
		return
	end

	pg.game.monthCard:onDailyRewardClaimed()
	facade:sendMsgToUI(MessageName.CASH_SHOP_REWARD_CHANGED)
end

function ClientMonthCardComponent:monthCardReceiveStoreAward()
	self:serverMsg("RPC_CS_MonthCardReceiveStoreAward", CallbackHandler(self, "onReceiveStoreAwardCallback"))
end

function ClientMonthCardComponent:onReceiveStoreAwardCallback(code)
	if code ~= 0 then
		return
	end
end

function ClientMonthCardComponent:on_mcStoreDailyAwards_changed(oldV, newV)
	facade:sendMsgToUI(MessageName.CASH_SHOP_REWARD_CHANGED)
end

return ClientMonthCardComponent
