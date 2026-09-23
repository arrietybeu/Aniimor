-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPayComponent.lua

local class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientPayComponent = class.Component("ClientPayComponent")

function ClientPayComponent:ctor()
	return
end

function ClientPayComponent:destroy()
	return
end

function ClientPayComponent:createPayOrder(packageId, productId, packageName, giftUid)
	self.logger:debug("createPayOrder packageId=%s productId=%s packageName=%s", packageId, productId, packageName)
	self:serverMsg("RPC_CS_CreatePayOrder", packageId, productId, packageName, giftUid)
end

function ClientPayComponent:RPC_SC_NotifyCreatePayOrder(flag, code, packageId, productId, orderId, callBackUrl)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_NotifyCreatePayOrder flag=%s code=%s packageId=%s productId=%s orderId=%s callBackUrl=%s", flag, code, packageId, productId, orderId, callBackUrl)
	end

	if flag then
		pg.game.recharge:onOrderResponse(packageId, productId, orderId, callBackUrl)
	else
		pg.game.recharge:onOrderFail(productId, code)
	end
end

function ClientPayComponent:RPC_SC_NotifyPaySuccess(items)
	self.logger:debug("RPC_SC_NotifyPaySuccess items=%s", inspect(items))
end

function ClientPayComponent:deletePayOrder(orderId)
	self:serverMsg("RPC_CS_DeletePayOrder", orderId)
end

function ClientPayComponent:setDirectBuySwitchChecked(enabled)
	self:serverMsg("RPC_CS_SetDirectBuySwitchChecked", enabled)
end

function ClientPayComponent:claimRechargeRebateReward()
	self:serverMsg("RPC_CS_ClaimRechargeRebateReward")
end

function ClientPayComponent:RPC_SC_NotifyPayCoinSuccess(packageId, packageAmount, firstItems, realItems, extraItems)
	self.logger:debug("RPC_SC_NotifyPayCoinSuccess packageId=%s packageAmount=%s firstItems=%s realItems=%s extraItems=%s", packageId, packageAmount, firstItems, realItems, extraItems)
	pg.game.recharge:payCoinSuccess(packageId, packageAmount, firstItems, realItems, extraItems)
end

function ClientPayComponent:RPC_SC_NotifyRechargeRebateRewardGuide(rewardNum)
	local recharge = pg.game and pg.game.recharge

	if recharge then
		recharge:onRechargeRebateRewardGuide(rewardNum)
	end
end

function ClientPayComponent:RPC_SC_NotifyPayMonthCardSuccess(packageId, packageAmount, firstItems, realItems, extraItems, oversells)
	self.logger:debug("RPC_SC_NotifyPayMonthCardSuccess packageId=%s packageAmount=%s firstItems=%s realItems=%s extraItems=%s oversells=%s", packageId, packageAmount, firstItems, realItems, extraItems, oversells)
end

function ClientPayComponent:RPC_SC_NotifyPayBattlePassSuccess(packageId, packageAmount)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_NotifyPayBattlePassSuccess packageId=%s packageAmount=%s", packageId, packageAmount)
	end
end

return ClientPayComponent
