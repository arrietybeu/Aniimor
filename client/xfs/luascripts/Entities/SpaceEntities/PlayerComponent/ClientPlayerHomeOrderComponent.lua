-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomeOrderComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ClientPlayerHomeOrderComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local MessageName = require("Const.MessageName")
local ClientPlayerHomeOrderComponent = class.Component("ClientPlayerHomeOrderComponent")

function ClientPlayerHomeOrderComponent:RPC_SC_NotifyHomeOrderTimedRefresh(nextRefreshTime)
	facade:sendMsgToUI(MessageName.ON_HOME_ORDER_REFRESH_TIME_CHANGED, {
		nextRefreshTime = nextRefreshTime
	})
end

function ClientPlayerHomeOrderComponent:reqRefreshHomeOrder(insId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单刷新-%d", insId)
	end

	pg.me:serverMsg("RPC_CS_RefreshHomeOrder", insId, function(res)
		if res == HomeOrderConst.RefreshResult.SUCCESS then
			facade:sendMsgToUI(MessageName.ON_HOME_ORDER_REFRESH, {
				insId
			})
		elseif res ~= HomeOrderConst.RefreshResult.FAIL and res ~= HomeOrderConst.RefreshResult.NOORDER then
			pg.global.showBubbleMessage(res)
		end
	end)
end

function ClientPlayerHomeOrderComponent:reqPayRefreshHomeOrder(insId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单付费刷新-%d", insId)
	end

	pg.me:serverMsg("RPC_CS_RefreshOrderByMoney", insId, function(res)
		if res == HomeOrderConst.RefreshResult.SUCCESS then
			facade:sendMsgToUI(MessageName.ON_HOME_ORDER_REFRESH, {
				insId
			})
		elseif res ~= HomeOrderConst.RefreshResult.FAIL and res ~= HomeOrderConst.RefreshResult.NOORDER then
			pg.global.showBubbleMessage(res)
		end
	end)
end

function ClientPlayerHomeOrderComponent:reqSubmitHomeOrder(insId, onSuccess)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单提交-%d", insId)
	end

	pg.me:serverMsg("RPC_CS_SubmitHomeOrder", insId, function(res)
		if res == NoticeDef.SUCCESS then
			if onSuccess then
				onSuccess()
			end

			facade:sendMsgToUI(MessageName.ON_HOME_ORDER_LIST_CHANGED)
		else
			pg.global.showBubbleMessage(res)
		end
	end)
end

function ClientPlayerHomeOrderComponent:onHomeOrderList_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单变化")
	end

	facade:sendMsgToUI(MessageName.ON_HOME_ORDER_LIST_CHANGED)
end

function ClientPlayerHomeOrderComponent:onHomeOrderUsed_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单刷新次数变化 %d", nv)
	end

	facade:sendMsgToUI(MessageName.ON_HOME_ORDER_USED_COUNT_CHANGED, {
		oldV = ov,
		newV = nv
	})
end

function ClientPlayerHomeOrderComponent:onHomeOrderTime_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("家园订单刷新时间变化")
	end

	facade:sendMsgToUI(MessageName.ON_HOME_ORDER_REFRESH_TIME_CHANGED, {
		oldV = ov,
		newV = nv
	})
end

return ClientPlayerHomeOrderComponent
