-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeOrder\\HomeOrderModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeOrderModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local OrderRefreshData = require("Data.order_refresh_data")
local HomeOrderData = require("Data.home_order_data")
local OrderLibData = require("Data.order_library_data")
local OrderShopTypeData = require("Data.order_shop_type_data")
local OrderShopDescData = require("Data.order_shop_desc_data")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeOrderRedDotUtils = require("Utils.HomeOrderRedDotUtils")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local HomeOrderModel = Class.LightClass("HomeOrderModel", UIModel)

HomeOrderModel.ORDER_STATE = {
	OPEN = 0,
	LOCK = 2,
	CLOSE = 1
}

function HomeOrderModel:isFlushFuncUnlocked()
	local condId = HomelandConfigData.orderFlushUnlockCondition

	if not condId or condId == 0 then
		return true
	end

	return pg.me.triggerMap:isCompleteOrMeetCondition(condId) == true
end

function HomeOrderModel:isPayFlushUnlocked()
	local condId = HomelandConfigData.orderFlushByPayCondition

	if not condId or condId == 0 then
		return true
	end

	return pg.me.triggerMap:isCompleteOrMeetCondition(condId) == true
end

function HomeOrderModel:_appendOrderData(res, orderList)
	if not orderList then
		return
	end

	local rawShowList = orderList.getRawTable and orderList:getRawTable() or orderList

	for k, v in ipairs(rawShowList) do
		local orderData = OrderLibData[v.orderId]

		if orderData then
			local shopTypeCfg = OrderShopTypeData[orderData.shopType] or {}
			local shopDescCfg = OrderShopDescData[v.desId] or {}
			local clientState = self._serverStateToClientState(v.orderStatus)
			local oneOrder = {
				serverIndex = k,
				insId = v.insId,
				orderId = v.orderId,
				state = clientState,
				canRefresh = v.canRefresh,
				orderRedKey = HomeOrderRedDotUtils.getOrderKey(v),
				isNewOrder = HomeOrderRedDotUtils.isNewOrder(v),
				isSeasonOrder = v.orderType == HomeOrderConst.TYPE.Season
			}

			if clientState == HomeOrderModel.ORDER_STATE.OPEN then
				oneOrder.bgImgPath = shopTypeCfg.icon
				oneOrder.isUrgent = v.orderType == HomeOrderConst.TYPE.HighPriority
				oneOrder.urgentMultiple = v.rewardRate
				oneOrder.quality = orderData.orderQuality

				local orderStar = orderData.orderStar or orderData.orderQuality

				oneOrder.starData = self._getStarData(orderStar)
				oneOrder.title = shopTypeCfg.name
				oneOrder.desc = shopDescCfg.levelDes
				oneOrder.needItemData = self._getNeedItemData(orderData)
				oneOrder.rewardData = self._getRewardData(orderData)
				oneOrder.canSubmit = self._checkCanSubmit(oneOrder.needItemData)

				table.insert(res, oneOrder)
			end
		end
	end
end

function HomeOrderModel:getOrderData()
	local res = {}

	self:_appendOrderData(res, pg.me.homeSeasonOrderList)
	self:_appendOrderData(res, pg.me.showList)
	table.sort(res, function(a, b)
		if a.isSeasonOrder ~= b.isSeasonOrder then
			return a.isSeasonOrder == true
		end

		local aSortOrder = self._getSortOrder(a.state)
		local bSortOrder = self._getSortOrder(b.state)

		if aSortOrder ~= bSortOrder then
			return aSortOrder < bSortOrder
		end

		if a.canSubmit ~= b.canSubmit then
			return a.canSubmit == true
		end

		return (a.serverIndex or 0) < (b.serverIndex or 0)
	end)

	return res
end

function HomeOrderModel:getOrderDic()
	local res = {}

	for k, v in ipairs(pg.me.showList) do
		res[k] = {
			orderId = v.orderId,
			isUrgent = v.orderType == HomeOrderConst.TYPE.HighPriority
		}
	end

	return res
end

function HomeOrderModel.getOrderRefreshNum()
	local level = pg.me and pg.me.homeBasicInfo and pg.me.homeBasicInfo.level
	local flushPoints = level and HomeOrderData.flushTimes and HomeOrderData.flushTimes[level]

	if not flushPoints or #flushPoints == 0 then
		return 0
	end

	local currentSecond = Time.secondCache - TimeUtils.getAreaDayBegin(Time.secondCache)

	for _, flushPoint in ipairs(flushPoints) do
		if currentSecond < flushPoint[1] then
			return flushPoint[2] or 0
		end
	end

	return flushPoints[1][2] or 0
end

function HomeOrderModel.getFreeRefreshCnt()
	local levelCfg = OrderRefreshData[pg.me.homeBasicInfo.level]

	if levelCfg then
		return levelCfg.freeRefresh
	else
		return 0
	end
end

function HomeOrderModel.getMaxOrderNum()
	return HomeOrderModel._getMaxOrderCountByLevel(pg.me.homeBasicInfo.level)
end

function HomeOrderModel._getMaxOrderCountByLevel(level)
	for i = level, 1, -1 do
		local levelCfg = OrderRefreshData[i]

		if levelCfg and levelCfg.maxOrderCount then
			return levelCfg.maxOrderCount
		end
	end

	return 0
end

function HomeOrderModel._serverStateToClientState(serverState)
	if serverState == HomeOrderConst.STATUS.Incomplete then
		return HomeOrderModel.ORDER_STATE.OPEN
	else
		return HomeOrderModel.ORDER_STATE.CLOSE
	end
end

function HomeOrderModel._getNeedItemData(orderCfg)
	local res = {}
	local dic = {}
	local sort = {}

	if orderCfg.unlockItem1 then
		table.insert(sort, {
			orderCfg.unlockItem1[1],
			orderCfg.unlockItem1[2]
		})
	end

	if orderCfg.unlockItem2 then
		table.insert(sort, {
			orderCfg.unlockItem2[1],
			orderCfg.unlockItem2[2]
		})
	end

	if orderCfg.unlockItem3 then
		table.insert(sort, {
			orderCfg.unlockItem3[1],
			orderCfg.unlockItem3[2]
		})
	end

	for _, v in ipairs(sort) do
		local id = v[1]
		local num = v[2]

		if dic[id] then
			dic[id] = dic[id] + num
		else
			dic[id] = num
		end
	end

	for _, v in ipairs(sort) do
		local num = dic[v[1]]

		if num and num > 0 then
			table.insert(res, {
				v[1],
				num
			})

			dic[v[1]] = -1
		end
	end

	return res
end

function HomeOrderModel._getRewardData(orderCfg)
	local res = {}

	if orderCfg.reward1 then
		table.insert(res, {
			dropId = orderCfg.reward1
		})
	end

	if orderCfg.reward2 then
		table.insert(res, {
			multiNum = 1,
			dropId = orderCfg.reward2
		})
	end

	if orderCfg.reward3 then
		table.insert(res, {
			dropId = orderCfg.reward3
		})
	end

	return res
end

function HomeOrderModel._checkCanSubmit(itemData)
	for _, v in ipairs(itemData or EMPTY_TABLE) do
		local id, num = v[1], v[2]
		local bagNum = ClientUtils.getItemCountById(id)
		local invNum = ClientUtils.getHomelandItemCountById(id)

		if num > bagNum + invNum then
			return false
		end
	end

	return true
end

function HomeOrderModel._getSortOrder(state)
	if state == HomeOrderModel.ORDER_STATE.OPEN then
		return 0
	elseif state == HomeOrderModel.ORDER_STATE.LOCK then
		return 1
	else
		return 2
	end
end

function HomeOrderModel._getStarData(starNum)
	local res = {}

	for i = 1, starNum do
		res[i] = {}
	end

	return res
end

return HomeOrderModel
