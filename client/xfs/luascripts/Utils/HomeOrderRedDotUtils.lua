-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomeOrderRedDotUtils.lua

local HomeOrderConst = require("Common.Const.HomeOrderConst")
local Const = require("Common.Const.Const")
local HomeOrderRedDotUtils = {}
local SNAPSHOT_KEY = "read_snapshot"

local function getClientKey()
	return Const.CLIENT_KEY.HOME_ORDER_RED_DOT
end

local function getRawOrderList(orderList)
	if not orderList then
		return {}
	end

	if orderList.getRawTable then
		return orderList:getRawTable()
	end

	return orderList
end

function HomeOrderRedDotUtils.getOrderKey(orderInfo)
	if not orderInfo then
		return ""
	end

	return string.format("%s_%s_%s_%s_%s", tostring(orderInfo.insId or 0), tostring(orderInfo.orderId or 0), tostring(orderInfo.desId or 0), tostring(orderInfo.orderType or 0), tostring(orderInfo.rewardRate or 0))
end

function HomeOrderRedDotUtils.getCurrentOrderSnapshot()
	local snapshot = {}

	if not pg or not pg.me then
		return snapshot
	end

	for _, propertyName in ipairs({
		"showList",
		"homeSeasonOrderList"
	}) do
		for _, orderInfo in ipairs(getRawOrderList(pg.me[propertyName])) do
			if orderInfo and orderInfo.orderStatus == HomeOrderConst.STATUS.Incomplete then
				snapshot[HomeOrderRedDotUtils.getOrderKey(orderInfo)] = true
			end
		end
	end

	return snapshot
end

function HomeOrderRedDotUtils.reconcileNewOrderSet()
	if not pg or not pg.me then
		HomeOrderRedDotUtils.newOrderSet = {}

		return HomeOrderRedDotUtils.newOrderSet
	end

	local readSnapshot = pg.me:getClientInfo(getClientKey(), SNAPSHOT_KEY) or {}
	local curSnapshot = HomeOrderRedDotUtils.getCurrentOrderSnapshot()
	local newOrderSet = {}

	for orderKey, _ in pairs(curSnapshot) do
		if not readSnapshot[orderKey] then
			newOrderSet[orderKey] = true
		end
	end

	HomeOrderRedDotUtils.newOrderSet = newOrderSet

	return newOrderSet
end

function HomeOrderRedDotUtils.isNewOrder(orderInfo)
	if HomeOrderRedDotUtils.newOrderSet == nil then
		HomeOrderRedDotUtils.reconcileNewOrderSet()
	end

	return HomeOrderRedDotUtils.newOrderSet[HomeOrderRedDotUtils.getOrderKey(orderInfo)] == true
end

function HomeOrderRedDotUtils.clearWhenLeave()
	if not pg or not pg.me then
		HomeOrderRedDotUtils.newOrderSet = {}

		return
	end

	pg.me:setClientInfo(getClientKey(), SNAPSHOT_KEY, HomeOrderRedDotUtils.getCurrentOrderSnapshot())

	HomeOrderRedDotUtils.newOrderSet = {}
end

return HomeOrderRedDotUtils
