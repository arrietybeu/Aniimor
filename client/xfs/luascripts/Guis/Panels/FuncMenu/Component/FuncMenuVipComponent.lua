-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenu\\Component\\FuncMenuVipComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local json = require("json")
local logger = require("Core.Log.LoggerManager").getLogger("FuncMenuVipComponent")
local ClientUtils = require("Utils.ClientUtils")
local FuncMenuVipComponent = Class.LightClass("FuncMenuVipComponent", UIComponent)
local VIP_NORMAL_RED_DOT_RECORD_KEY = "FuncMenuVipRedDotLastReadDay"
local VIP_SPECIAL_RED_DOT_RECORD_KEY_PREFIX = "FuncMenuVipSpecialRedDotRead_"
local ISO_8601_UTC_PATTERN = "^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z$"
local RED_DOT_PATH = "/api/game/red-dot"
local JUMP_BASE_URLS = {
	test = {
		global = "https://park-web-test.funplus.com",
		cn = "https://park-web-test.funplus.com.cn"
	},
	stage = {
		global = "https://park-web-stage.funplus.com",
		cn = "https://park-web-stage.funplus.com.cn"
	},
	prod = {
		global = "https://park-web.aniimo.com",
		cn = "https://park-web.yimo.com"
	}
}
local POST_HOSTS = {
	test = {
		global = "priv-platform-yimoo-api-test.funplus.com",
		cn = "priv-platform-yimoo-api-test.funplus.com.cn"
	},
	stage = {
		global = "priv-platform-yimoo-api-stage.funplus.com",
		cn = "priv-platform-yimoo-api-stage.funplus.com.cn"
	},
	prod = {
		global = "priv-platform-yimoo-api.funplus.com",
		cn = "priv-platform-yimoo-api.funplus.com.cn"
	}
}

function FuncMenuVipComponent:getCurrentDay()
	local dayBegin = TimeUtils.getAreaDayBegin(Time.secondCache)

	return math.floor(dayBegin / Const.SECONDS_ONE_DAY)
end

function FuncMenuVipComponent:getEnvironmentKey()
	if _G_IsDebugMode then
		if string.lower(ClientUtils.getServerListGroup()) == "ver001" then
			return "stage"
		else
			return "test"
		end
	else
		return "prod"
	end
end

function FuncMenuVipComponent:getRegionKey()
	return Utils.isOverseas() and "global" or "cn"
end

function FuncMenuVipComponent:escapeUrlQueryValue(value)
	local text = tostring(value or "")
	local ok, escaped = pcall(CS.System.Uri.EscapeDataString, text)

	return ok and escaped or text
end

function FuncMenuVipComponent:onCtor()
	self.redDotStyle = RedDotConst.RedDotStyle.NONE
	self.normalRedDot = false
	self.specialRedDot = false
	self.specialRedDotRecordKey = ""
	self.specialJumpUrl = ""
end

function FuncMenuVipComponent:updateRedDotStyle()
	if self.specialRedDot then
		self.redDotStyle = RedDotConst.RedDotStyle.NEW
	elseif self.normalRedDot then
		self.redDotStyle = RedDotConst.RedDotStyle.POINT
	else
		self.redDotStyle = RedDotConst.RedDotStyle.NONE
	end
end

function FuncMenuVipComponent:bindRedDot(button)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_VIP, button, function()
		return self.redDotStyle or RedDotConst.RedDotStyle.NONE
	end)
end

function FuncMenuVipComponent:open()
	local url = self:getJumpBaseUrl()

	if string.isNilOrEmpty(url) then
		return
	end

	if pg.global.platform:isConsole() or pg.global.platform:isXboxPC() then
		pg.global.ui:open(UIConst.UI_ID_VIP_JUMP_SCAN_CODE, {
			url = url
		})
	elseif pg.global.platform:isMobile() or pg.global.platform:isPC() then
		pg.global.sdkManager:openUrl("FuncMenuCtrl", "VIP_CENTER", url)
	else
		logger:error("VIP跳转平台未识别")
	end

	if self.redDotStyle == RedDotConst.RedDotStyle.NEW then
		pg.global.prefsCacheUtils:setBoolImmediately(self.specialRedDotRecordKey, true, ClientConst.CACHE_TYPE_FLAG.USER)

		self.specialRedDot = false
	elseif self.redDotStyle == RedDotConst.RedDotStyle.POINT then
		pg.global.prefsCacheUtils:setIntImmediately(VIP_NORMAL_RED_DOT_RECORD_KEY, self:getCurrentDay(), ClientConst.CACHE_TYPE_FLAG.USER)

		self.normalRedDot = false
	end

	self:updateRedDotStyle()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_VIP)
end

function FuncMenuVipComponent:getJumpBaseUrl()
	local baseUrl = JUMP_BASE_URLS[self:getEnvironmentKey()][self:getRegionKey()]

	if self.specialRedDot and not string.isNilOrEmpty(self.specialJumpUrl) then
		baseUrl = self.specialJumpUrl
	end

	local source = ""

	if pg.global.platform:isMobile() then
		source = "mobile_game"
	elseif pg.global.platform:isConsole() or pg.global.platform:isXboxPC() or pg.global.platform:isPC() then
		source = "pc_game"
	end

	local sdkManager = pg and pg.global and pg.global.sdkManager
	local osName = ""
	local channel = ""
	local pkgChannel = ""

	if sdkManager and sdkManager.getTrackingInfo then
		local trackingOk, trackingInfo = pcall(sdkManager.getTrackingInfo, sdkManager)

		if trackingOk and not string.isNilOrEmpty(trackingInfo) then
			local decodeOk, data = pcall(json.decode, trackingInfo)

			if decodeOk and Utils.isTable(data) and Utils.isTable(data.properties) then
				osName = tostring(data.properties.os or "")
				channel = tostring(data.properties.channel_id or "")
				pkgChannel = tostring(data.properties.pkg_channel or "")
			end
		end
	end

	local sessionKey = sdkManager and sdkManager:getSessionKey() or ""
	local uid = pg.me and pg.me.uid or ""

	return string.format("%s?session_key=%s&uid=%s&os=%s&channel=%s&pkg_channel=%s&lang=%s&source=%s", baseUrl, self:escapeUrlQueryValue(sessionKey), self:escapeUrlQueryValue(uid), self:escapeUrlQueryValue(osName), self:escapeUrlQueryValue(channel), self:escapeUrlQueryValue(pkgChannel), self:escapeUrlQueryValue(pg.game.setting:getLanguage()), source)
end

function FuncMenuVipComponent:refreshRedDot(reply)
	local status = reply and reply.header and tonumber(reply.header.HTTP_STATUS)

	if status ~= 200 or type(reply.body) ~= "string" then
		return
	end

	local decodeOk, response = pcall(json.decode, reply.body)

	if not decodeOk or type(response) ~= "table" or type(response.data) ~= "table" then
		logger:error("[FuncMenuVipComponent] JSON解析失败:", tostring(response))

		return
	end

	if response.code ~= 0 or response.msg ~= "success" then
		return
	end

	local normalRedDot = response.data.normal_red_dot == true
	local specialRedDot = response.data.special_red_dot == true
	local specialId = tostring(response.data.special_id or "")
	local specialJumpUrl = tostring(response.data.jump_url or "")
	local specialStartTime = math.floor(TimeUtils.stringToTimestampByUtcOffset(response.data.special_start_time, 0, ISO_8601_UTC_PATTERN) or 0)
	local specialEndTime = math.floor(TimeUtils.stringToTimestampByUtcOffset(response.data.special_end_time, 0, ISO_8601_UTC_PATTERN) or 0)
	local prefsCacheUtils = pg.global.prefsCacheUtils
	local lastReadDay = prefsCacheUtils:getInt(VIP_NORMAL_RED_DOT_RECORD_KEY, -1, ClientConst.CACHE_TYPE_FLAG.USER)
	local specialRedDotRecordKey = string.format("%s%s", VIP_SPECIAL_RED_DOT_RECORD_KEY_PREFIX, specialId)
	local specialRedDotRead = prefsCacheUtils:getBool(specialRedDotRecordKey, false, ClientConst.CACHE_TYPE_FLAG.USER)

	self.normalRedDot = normalRedDot and lastReadDay ~= self:getCurrentDay()
	self.specialRedDotRecordKey = specialRedDotRecordKey
	self.specialJumpUrl = specialJumpUrl
	self.specialRedDot = specialRedDot and specialStartTime <= Time.secondCache and specialEndTime > Time.secondCache and not specialRedDotRead

	self:updateRedDotStyle()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_VIP)
end

function FuncMenuVipComponent:requestRedDot()
	local host = POST_HOSTS[self:getEnvironmentKey()][self:getRegionKey()]
	local accountId = ""

	if pg and pg.global and pg.global.sdkManager then
		local value = pg.global.sdkManager:getAccountId()

		if value ~= nil then
			accountId = tostring(value)
		end
	end

	local roleId = ""

	if pg and pg.me and pg.me.uid ~= nil then
		roleId = tostring(pg.me.uid)
	end

	local body = json.encode({
		account_id = accountId,
		uid = roleId
	})
	local timestamp = tostring(math.floor(Time.getSecond()))
	local headers = {
		["Content-Type"] = "application/json",
		["X-Timestamp"] = timestamp
	}
	local request = HttpRequest(host, nil, HttpRequest.Method.POST, RED_DOT_PATH, headers, body, true)

	HttpClientProxy():httpRequest(request, 10000, function(reply)
		self:refreshRedDot(reply)
	end, false)
end

return FuncMenuVipComponent
