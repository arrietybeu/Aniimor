-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpRequestTiktok.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local StringEx = require("Core.Framework.String")
local json = require("json")
local Time = require("Core.Common.Time")
local GameServerRepo = require("Core.Server.GameServerRepo")
local LoggerManager = require("Core.Log.LoggerManager")
local Logger = LoggerManager.getLogger("HttpRequestTiktok")
local HttpRequestTiktok = class.Class("HttpRequestTiktok")

HttpRequestTiktok.Method = {
	GET = "GET",
	PUT = "PUT",
	POST = "POST"
}
HttpRequestTiktok.HOST = "usdk.dailygn.com"
HttpRequestTiktok.PATH = "/webcast/gamecp/attribute/channel/conversion"
HttpRequestTiktok.SECRET = "eK1hzuNe9ydm4BJVI8Oh9rmUM9nd4myC"
HttpRequestTiktok.OAUTH_HOST = "open.douyin.com"
HttpRequestTiktok.OAUTH_PATH = "/webcast/game/oauth/access_token/"
HttpRequestTiktok.USER_HASH_MOBILE_PATH = "/api/douyin/v1/user/get_user_hash_mobile/"
HttpRequestTiktok.BIND_PATH = "/webcast/gamecp/role/bind"
HttpRequestTiktok.SIGN_ALG = "HMAC-SHA256"
HttpRequestTiktok.SIGN_VERSION = "2.0"
HttpRequestTiktok.EventType = {
	play_session = "play_session",
	login_account = "login_account",
	register_account = "register_account",
	launch = "launch",
	active = "active"
}
HttpRequestTiktok.Config = {
	os = "ios",
	game_type = 0,
	environment = 0,
	open_game_url = "",
	attribution_ex = "",
	package_name = "cn.x.aniimos",
	package_channel = "official",
	is_official_package = 1,
	app_id = "772523"
}

function HttpRequestTiktok:ctor()
	self.host = HttpRequestTiktok.HOST
	self.method = HttpRequestTiktok.Method.POST
	self.url = HttpRequestTiktok.PATH
	self.header = {
		["x-game-sign"] = "",
		["Content-Type"] = "application/json",
		Accept = "application/json",
		["x-game-version"] = "V2"
	}
	self.body = ""
	self.ssl = false
end

function HttpRequestTiktok:generateSignature(body, method, path, timestamp, nonce, secret)
	method = method or self.Method.POST
	path = path or self.PATH
	timestamp = timestamp or tostring(Time.millisecondCache)
	nonce = nonce or StringEx.randomString(10)
	secret = secret or self.SECRET

	local message = table.concat({
		method,
		path,
		timestamp,
		nonce,
		body
	}, "\n") .. "\n"
	local signature = phonestcore.hmac256Base64(message, secret)

	self.body = body
	self.header["x-game-sign"] = string.format("alg=\"%s\",v=\"%s\",appid=\"%s\",nonce=\"%s\",timestamp=\"%s\",signature=\"%s\"", self.SIGN_ALG, self.SIGN_VERSION, self.Config.app_id, nonce, timestamp, signature)

	return signature
end

function HttpRequestTiktok:buildBody(player, event_type, extra_data)
	local sdkInfoMap = {}

	if not string.isNilOrEmpty(player.sdkInfo) then
		sdkInfoMap = json.decode(player.sdkInfo)
	end

	local identity = {
		ip = sdkInfoMap.ip or "",
		model = sdkInfoMap.model or "",
		idfa = sdkInfoMap.idfa or "",
		imei = sdkInfoMap.imei or "",
		caid = sdkInfoMap.caid or "",
		oaid = sdkInfoMap.oaid or "",
		encrypted_idfa = sdkInfoMap.encrypted_idfa or "",
		encrypted_imei = sdkInfoMap.encrypted_imei or "",
		encrypted_caid = sdkInfoMap.encrypted_caid or "",
		encrypted_oaid = sdkInfoMap.encrypted_oaid or "",
		os_version = sdkInfoMap.os_version or "",
		device_brand = sdkInfoMap.device_brand or "",
		device_manufacturer = sdkInfoMap.device_manufacturer or ""
	}
	local cfg = self.Config
	local body = {
		app_id = cfg.app_id,
		is_official_package = cfg.is_official_package,
		package_channel = cfg.package_channel,
		package_name = cfg.package_name,
		event_type = event_type,
		os = cfg.os,
		event_id = player.uid .. Time.millisecondCache .. StringEx.randomString(6),
		extra_data = extra_data,
		timestamp = Time.millisecondCache,
		attribution_ex = cfg.attribution_ex,
		open_game_url = cfg.open_game_url,
		environment = cfg.environment,
		game_type = cfg.game_type,
		launch_id = sdkInfoMap.launch_id,
		app_version = sdkInfoMap.app_version,
		app_version_code = sdkInfoMap.app_version_code,
		identity = identity
	}

	return json.encode(body)
end

local EXTRA_DATA_BUILDERS = {
	active = function()
		return ""
	end,
	launch = function()
		return ""
	end,
	register_account = function(player)
		return json.encode({
			game_user_id = player.uid
		})
	end,
	login_account = function(player)
		return json.encode({
			game_user_id = player.uid
		})
	end,
	play_session = function(player, extraData)
		return json.encode({
			active_start_time = extraData.active_start_time or Time.millisecondCache - 100,
			active_end_time = extraData.active_end_time or Time.millisecondCache,
			active_duration = extraData.active_duration or 100,
			game_role_id = player.username,
			game_user_id = player.uid
		})
	end
}

function HttpRequestTiktok:build(player, eventType, extraData)
	local builder = EXTRA_DATA_BUILDERS[eventType]

	if not builder then
		return nil
	end

	local extra_data = builder(player, extraData)
	local body = self:buildBody(player, eventType, extra_data)

	return self:generateSignature(body)
end

function HttpRequestTiktok:build_active(player)
	return self:build(player, self.EventType.active)
end

function HttpRequestTiktok:build_launch(player)
	return self:build(player, self.EventType.launch)
end

function HttpRequestTiktok:build_register_account(player)
	return self:build(player, self.EventType.register_account)
end

function HttpRequestTiktok:build_login_account(player)
	return self:build(player, self.EventType.login_account)
end

function HttpRequestTiktok:build_play_session(player, extraData)
	return self:build(player, self.EventType.play_session, extraData)
end

function HttpRequestTiktok:request_access_token(appId, code, appSecret)
	self.host = self.OAUTH_HOST
	self.url = self.OAUTH_PATH
	self.method = self.Method.POST
	self.ssl = true
	self.header = {
		Accept = "application/json",
		["Content-Type"] = "application/json"
	}
	self.body = json.encode({
		app_id = appId,
		app_secret = appSecret or self.SECRET,
		code = code
	})

	GameServerRepo.httpClientProxy:httpRequest(self, 5000, function(reply)
		Logger:debug("access_token send:", inspect(self), inspect(reply))
	end, false, "", 3)
end

function HttpRequestTiktok:request_user_hash_mobile(accessToken, openId)
	self.host = self.OAUTH_HOST
	self.url = self.USER_HASH_MOBILE_PATH .. "?open_id=" .. StringEx.urlencode(openId)
	self.method = self.Method.GET
	self.ssl = true
	self.header = {
		["Content-Type"] = "application/json",
		Accept = "application/json",
		["access-token"] = accessToken
	}
	self.body = ""

	GameServerRepo.httpClientProxy:httpRequest(self, 5000, function(reply)
		Logger:debug("user_hash_mobile send:", inspect(self), inspect(reply))
	end, false, "", 3)
end

function HttpRequestTiktok:request_bind_player(username, uid, openId, alliedId)
	self.host = self.OAUTH_HOST
	self.url = self.BIND_PATH
	self.method = self.Method.POST
	self.ssl = true
	self.header = {
		["x-game-sign"] = "",
		["Content-Type"] = "application/json",
		Accept = "application/json",
		["x-game-version"] = "V2"
	}

	local body = {
		bind_type = 0,
		bind = 1,
		app_id = tonumber(self.Config.app_id),
		game_user_id = username,
		role_id = uid,
		open_id = openId,
		allied_id = alliedId,
		tm = math.floor(Time.secondCache)
	}
	local bodyStr = json.encode(body)

	self:generateSignature(bodyStr, self.Method.POST, self.BIND_PATH)
	GameServerRepo.httpClientProxy:httpRequest(self, 5000, function(reply)
		Logger:debug("bind_player send:", inspect(self), inspect(reply))
	end, false, "", 3)
end

return HttpRequestTiktok
