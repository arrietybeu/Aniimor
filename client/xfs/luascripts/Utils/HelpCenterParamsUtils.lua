-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HelpCenterParamsUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("HelpCenterParamsUtils")
local json = require("json")
local GameVersion = require("Common.GameVersion")
local ConfigVersion = require("Common.ConfigVersion")
local GlobalData = require("Core.Client.GlobalData")
local ClientConst = require("Const.ClientConst")
local HelpCenterParamsUtils = {}

local function safeNumber(v)
	return tonumber(v) or 0
end

local function safeString(v)
	if v == nil then
		return ""
	end

	return tostring(v)
end

function HelpCenterParamsUtils.getRoleId()
	if pg and pg.me then
		return safeString(pg.me.uid)
	end

	return ""
end

function HelpCenterParamsUtils.getFpId()
	if pg and pg.global and pg.global.sdkManager then
		return safeString(pg.global.sdkManager:getFpId())
	end

	return ""
end

function HelpCenterParamsUtils.getAccountId()
	if pg and pg.global and pg.global.sdkManager then
		return safeString(pg.global.sdkManager:getAccountId())
	end

	return ""
end

function HelpCenterParamsUtils.getSessionKey()
	if pg and pg.global and pg.global.sdkManager then
		return safeString(pg.global.sdkManager:getSessionKey())
	end

	return ""
end

function HelpCenterParamsUtils.getVipLevel()
	return 0
end

function HelpCenterParamsUtils.getRoleName()
	if pg and pg.me then
		return safeString(pg.me.playerName)
	end

	return ""
end

function HelpCenterParamsUtils.getRoleLevel()
	if pg and pg.me then
		return safeNumber(pg.me.level)
	end

	return 0
end

function HelpCenterParamsUtils.getLanguageTag()
	if pg and pg.game and pg.game.setting and pg.game.setting.getLanguageType then
		local ok, lang = pcall(pg.game.setting.getLanguageType, pg.game.setting)

		if ok and lang ~= nil then
			local desc = ClientConst.SDK_ANNOUNCEMENT_LANGUAGE_TYPE_DESC_MAP and ClientConst.SDK_ANNOUNCEMENT_LANGUAGE_TYPE_DESC_MAP[lang]

			if desc ~= nil then
				return safeString(desc)
			end

			return safeString(lang)
		end
	end

	return ""
end

function HelpCenterParamsUtils.getServerId()
	return safeString(GlobalData.ServerId)
end

function HelpCenterParamsUtils.getCurrentSceneId()
	if pg and pg.me and pg.me.space then
		return safeString(pg.me.space.sceneId)
	end

	return ""
end

function HelpCenterParamsUtils.getClientVersion()
	return safeNumber(GameVersion)
end

function HelpCenterParamsUtils.getServerVersion()
	if ConfigVersion and ConfigVersion.server then
		return safeString(ConfigVersion.server)
	end

	return ""
end

function HelpCenterParamsUtils.getAvatarUrl()
	if not pg or not pg.me then
		return ""
	end

	return pg.me.headIconCdn
end

function HelpCenterParamsUtils.getTotalPay()
	if not pg or not pg.me then
		return 0
	end

	return pg.me.PcPayTotalMoney
end

function HelpCenterParamsUtils.buildJsonDataTable()
	return {
		role_id = HelpCenterParamsUtils.getRoleId(),
		account_id = HelpCenterParamsUtils.getAccountId(),
		session_key = HelpCenterParamsUtils.getSessionKey(),
		vip_level = HelpCenterParamsUtils.getVipLevel(),
		nick_name = HelpCenterParamsUtils.getRoleName(),
		role_level = HelpCenterParamsUtils.getRoleLevel(),
		lang = HelpCenterParamsUtils.getLanguageTag(),
		sid = HelpCenterParamsUtils.getServerId(),
		current_scene = HelpCenterParamsUtils.getCurrentSceneId(),
		client_version = HelpCenterParamsUtils.getClientVersion(),
		server_version = HelpCenterParamsUtils.getServerVersion(),
		avatar_url = HelpCenterParamsUtils.getAvatarUrl(),
		total_pay = HelpCenterParamsUtils.getTotalPay()
	}
end

function HelpCenterParamsUtils.printAll(tag)
	local label = tag or ""
	local fields = HelpCenterParamsUtils.buildJsonDataTable()

	if fields.session_key ~= "" then
		fields.session_key = "***"
	end

	logger:info("[HelpCenterParams] ==== dump begin (%s) ====", label)

	local ok, encoded = pcall(json.encode, fields)

	if ok then
		logger:info("[HelpCenterParams] lua_part = %s", encoded)
	else
		logger:info("[HelpCenterParams] lua_part = <encode failed>")
	end

	logger:info("[HelpCenterParams] ==== dump end (%s) ====", label)
end

return HelpCenterParamsUtils
