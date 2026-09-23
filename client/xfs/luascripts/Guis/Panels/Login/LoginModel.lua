-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\LoginModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local LoginModel = Class.LightClass("LoginModel", UIModel)
local Time = require("Core.Common.Time")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local SysConfigData = require("Data.sys_config_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("LoginModel")

function LoginModel:getQuitQrCodeUrlAndTip()
	local isWeGame = pg.global.platform and pg.global.platform:isWeGame()

	if not isWeGame then
		return nil
	end

	local weGameDistributeId = csSDKManager.GetWeGameDistributeID()
	local showQrCode = false

	if weGameDistributeId then
		for _, distributeId in ipairs(SysConfigData.WEGAME_DISTRIBUTE_ID_LIST) do
			if weGameDistributeId == distributeId then
				showQrCode = true

				break
			end
		end
	end

	if not showQrCode then
		return nil
	end

	local timestamp = Time.getSecond()
	local preRegisterEndTime = SysConfigData.OBT_PRE_REGISTER_END_TIME
	local qrCodeTip = timestamp < preRegisterEndTime and SysConfigData.OBT_MOBILE_PRE_REGISTER_TIP or SysConfigData.OBT_MOBILE_DOWNLOAD_TIP or ""
	local qrCodeUrl = SysConfigData.OBT_MOBILE_PRE_REGISTER_URL

	return qrCodeUrl, qrCodeTip
end

return LoginModel
