-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientSettingUtils.lua

local M = {}
local UIConst = require("Const.UIConst")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local ClientSettingUtils = require("Utils.ClientSettingUtils")

function M.refreshSettingPanel()
	if pg and pg.global and pg.global.ui and pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function M.setDefault_crossPlatform()
	if PlatformCrossPlatformService:isCrossPlatformSettingReadOnly() then
		M.refreshSettingPanel()

		return
	end

	PlatformCrossPlatformService:setCrossPlatformEnabled(true)
end

function M.get_crossPlatform(optionDatas)
	local state = PlatformCrossPlatformService:isCrossPlatformEnabled() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function M.set_crossPlatform(value)
	if PlatformCrossPlatformService:isCrossPlatformSettingReadOnly() then
		M.refreshSettingPanel()

		return
	end

	if value == 1 then
		PlatformCrossPlatformService:requestEnableCrossPlatform(function(allowed)
			if not allowed then
				M.refreshSettingPanel()
			end
		end)
	else
		PlatformCrossPlatformService:setCrossPlatformEnabled(false)
	end
end

function M.handleAccountBindClick(funcType)
	if not pg.global.platform:isConsoleFamily() then
		return false
	end

	local socialType = ClientSettingUtils.ACCOUNT_BIND_SOCIAL_TYPE[funcType]

	if not socialType then
		return false
	end

	pg.global.sdkManager:bindSocial(socialType)

	return true
end

return M
