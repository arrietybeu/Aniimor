-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpExchange\\BpExchangeModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpExchangeModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Utils = require("Common.Utils.Utils")
local BpExchangeModel = Class.LightClass("BpExchangeModel", UIModel)

function BpExchangeModel:requestFriendShopStatus(friendIds, commodityId, callback)
	if not friendIds or #friendIds == 0 or not commodityId then
		callback({})

		return
	end

	ServiceUtils.userDataBatchGetAttribute(friendIds, {
		"commodityDic"
	}, function(result, resp)
		local hasGiftMap = {}

		if not result or not result.status then
			logger:error("BpExchangeModel:requestFriendShopStatus failed, result=%s, resp=%s", inspect(result), inspect(resp))
			callback(hasGiftMap)

			return
		end

		local results = resp and resp.Results

		if results then
			for _, item in ipairs(results) do
				local attr = item.AttributesMap
				local commodityDic = attr and attr.commodityDic

				if Utils.isTable(commodityDic) and (commodityDic[commodityId] ~= nil or commodityDic[tostring(commodityId)] ~= nil) then
					hasGiftMap[tostring(item.Uid)] = true
				end
			end
		end

		callback(hasGiftMap)
	end, pg.me.uid)
end

return BpExchangeModel
