-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientShopComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientShopComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientUtils = require("Utils.ClientUtils")
local AudioConst = require("Const.AudioConst")
local ClientShopComponent = class.Component("ClientShopComponent")

function ClientShopComponent:ctor()
	return
end

function ClientShopComponent:start()
	return
end

function ClientShopComponent:on_shopLimitCounts_changed(oldVal, newVal, k)
	return
end

function ClientShopComponent:on_shopLevelCounts_changed(oldVal, newVal, k)
	return
end

function ClientShopComponent:buyCommodity(shopClassifyId, commodityId, num)
	self:serverMsg("RPC_CS_BuyCommodity", shopClassifyId, commodityId, num, CallbackHandler(self, "callbackOnBuyCommodity", commodityId, num))
end

function ClientShopComponent:callbackOnBuyCommodity(commodityId, num, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("callbackOnBuyCommodity %d", retStatus)
	end

	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.SHOP_ON_BUY_ITEMS, {
			shopItemId = commodityId,
			count = num
		})
		pg.game.audio:playEvent(AudioConst.SFX_UI_SHOP_BUY)
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientShopComponent:sellItemByConfigId(items)
	self:serverMsg("RPC_CS_SellItemByConfigId", items, CallbackHandler(self, "callbackOnSellItemByConfigId"))
end

function ClientShopComponent:callbackOnSellItemByConfigId(retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("callbackOnSellItemByConfigId")
	end

	if retStatus ~= 0 then
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientShopComponent:sellItemByGenId(invId, items, costItem, totalPrice)
	self:serverMsg("RPC_CS_SellItemByGenId", invId, items, CallbackHandler(self, "callbackOnSellItemByGenId", costItem, totalPrice))
end

function ClientShopComponent:callbackOnSellItemByGenId(costItem, totalPrice, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("callbackOnSellItemByGenId")
	end

	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.SHOP_ON_SELL_ITEMS_BY_GENID, {
			itemId = costItem,
			count = totalPrice
		})
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientShopComponent:RPC_SC_ShopMallGiveCommodity(retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_ShopMallGiveCommodity %s", tostring(retStatus))
	end

	ClientCashShopUtils.onGiveItemResult(retStatus)
end

return ClientShopComponent
