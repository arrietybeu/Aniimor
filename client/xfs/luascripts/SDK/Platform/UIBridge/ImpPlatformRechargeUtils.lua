-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformRechargeUtils.lua

local M = {}

function M.getProductsPrice(data)
	local sdkInfo = data and data.sdkInfo

	if sdkInfo == nil then
		return nil
	end

	if pg.global.platform:isPS() then
		return sdkInfo.price
	end

	if sdkInfo.currency == nil or sdkInfo.currency == "" or sdkInfo.amount == nil or sdkInfo.amount == "" then
		return nil
	end

	return pg.getFormatText("{0}{1}", sdkInfo.currency, tonumber(sdkInfo.amount))
end

return M
