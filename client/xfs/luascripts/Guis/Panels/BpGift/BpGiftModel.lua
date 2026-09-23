-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpGift\\BpGiftModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpGiftModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local BpGiftModel = Class.LightClass("BpGiftModel", UIModel)

function BpGiftModel:requestFriendBpStatus(friendIds, callback)
	if not friendIds or #friendIds == 0 then
		callback({})

		return
	end

	ServiceUtils.userDataBatchGetAttribute(friendIds, {
		"bpGear"
	}, function(result, resp)
		local hasGiftMap = {}

		if not result or not result.status then
			logger:error("BpGiftModel:requestFriendBpStatus failed, result=%s, resp=%s", inspect(result), inspect(resp))
			callback(hasGiftMap)

			return
		end

		local results = resp and resp.Results
		local hasGiftCount = 0

		if results then
			for _, item in ipairs(results) do
				local attr = item.AttributesMap
				local bpGear = attr and attr.bpGear or 0

				if bpGear > 0 then
					hasGiftMap[tostring(item.Uid)] = true
					hasGiftCount = hasGiftCount + 1
				end
			end
		end

		callback(hasGiftMap)
	end, {
		callerId = pg.me.uid
	})
end

return BpGiftModel
