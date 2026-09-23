-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpRequestPsn.lua

local class = require("Core.Framework.Class")
local json = require("json")
local base64 = require("base64")
local StringEx = require("Core.Framework.String")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local GameServerRepo = require("Core.Server.GameServerRepo")
local LoggerManager = require("Core.Log.LoggerManager")
local Logger = LoggerManager.getLogger("HttpRequestPsn")
local HttpRequestPsn = class.Class("HttpRequestPsn")

HttpRequestPsn.AUTH_HOST = "s2s.sp-int.playstation.net"
HttpRequestPsn.AUTH_PATH = "/api/authz/v3/oauth/token"
HttpRequestPsn.USER_HOST = "s2s.sp-int.playstation.net"
HttpRequestPsn.BLOCKS_PATH = "/api/userProfile/v1/users/me/blocks"
HttpRequestPsn.BLOCK_STATES_PATH = "/api/userProfile/v1/users/%s/blocks/states"
HttpRequestPsn.CLIENT_ID = "8e8011f3-040a-466c-b257-8e42ac9dc655"
HttpRequestPsn.CLIENT_SECRET = "iGYBWfQAMh7arT6o"

local DEFAULT_TIMEOUT_MS = 5000
local DEFAULT_RETRY = 3

local function getPsnHostByIssuerId(issuerId)
	local id = tonumber(issuerId)

	if id == 256 then
		return "s2s.np.playstation.net"
	end

	if id == 8 then
		return "s2s.prod-qa.playstation.net"
	end

	return HttpRequestPsn.AUTH_HOST
end

function HttpRequestPsn:getAccessTokenWithAuthorizationCode(authorizationCode, redirectUri, callback, clientId, clientSecret, issuerId)
	clientId = clientId or self.CLIENT_ID
	clientSecret = clientSecret or self.CLIENT_SECRET

	local basic = base64.encode(clientId .. ":" .. clientSecret)
	local header = {
		Accept = "application/json",
		["Content-Type"] = "application/x-www-form-urlencoded",
		Authorization = "Basic " .. basic
	}
	local body = table.concat({
		"grant_type=authorization_code",
		"redirect_uri=" .. StringEx.urlencode(redirectUri),
		"code=" .. StringEx.urlencode(authorizationCode)
	}, "&")
	local request = HttpRequest(getPsnHostByIssuerId(issuerId), nil, HttpRequest.Method.POST, self.AUTH_PATH, header, body, true)

	GameServerRepo.httpClientProxy:httpRequest(request, DEFAULT_TIMEOUT_MS, function(reply)
		Logger:info("getAccessTokenWithAuthorizationCode request: %s, reply: %s", inspect(request), inspect(reply))

		local response

		if reply and reply.body and reply.body ~= "" then
			local ok, decoded = pcall(json.decode, reply.body)

			if ok then
				response = decoded
			else
				Logger:error("getAccessTokenWithAuthorizationCode decode failed: %s", reply.body)
			end
		end

		if callback then
			callback(reply, response)
		end
	end, false, "", DEFAULT_RETRY)
end

function HttpRequestPsn:getBlockingUsers(accessToken, offset, limit, callback, issuerId)
	local query = {}

	if offset and offset > 0 then
		table.insert(query, "offset=" .. tostring(offset))
	end

	if limit and limit > 0 then
		table.insert(query, "limit=" .. tostring(limit))
	end

	local url = self.BLOCKS_PATH

	if #query > 0 then
		url = url .. "?" .. table.concat(query, "&")
	end

	local header = {
		Accept = "application/json",
		Authorization = "Bearer " .. accessToken
	}
	local request = HttpRequest(getPsnHostByIssuerId(issuerId), nil, HttpRequest.Method.GET, url, header, "", true)

	GameServerRepo.httpClientProxy:httpRequest(request, DEFAULT_TIMEOUT_MS, function(reply)
		Logger:info("getBlockingUsers request: %s, reply: %s", inspect(request), inspect(reply))

		local response

		if reply and reply.body and reply.body ~= "" then
			local ok, decoded = pcall(json.decode, reply.body)

			if ok then
				response = decoded
			else
				Logger:error("getBlockingUsers decode failed: %s", reply.body)
			end
		end

		if callback then
			callback(reply, response)
		end
	end, false, "", DEFAULT_RETRY)
end

function HttpRequestPsn:getBlockUsersStates(accessToken, accountId, targetAccountIds, callback, issuerId)
	local ids = type(targetAccountIds) == "table" and table.concat(targetAccountIds, ",") or tostring(targetAccountIds)
	local url = string.format(self.BLOCK_STATES_PATH, accountId) .. "?accountIds=" .. StringEx.urlencode(ids)
	local header = {
		Accept = "application/json",
		Authorization = "Bearer " .. accessToken
	}
	local request = HttpRequest(getPsnHostByIssuerId(issuerId), nil, HttpRequest.Method.GET, url, header, "", true)

	GameServerRepo.httpClientProxy:httpRequest(request, DEFAULT_TIMEOUT_MS, function(reply)
		Logger:info("getBlockUsersStates request: %s, reply: %s", inspect(request), inspect(reply))

		local response

		if reply and reply.body and reply.body ~= "" then
			local ok, decoded = pcall(json.decode, reply.body)

			if ok then
				response = decoded
			else
				Logger:error("getBlockUsersStates decode failed: %s", reply.body)
			end
		end

		if callback then
			callback(reply, response)
		end
	end, false, "", DEFAULT_RETRY)
end

function HttpRequestPsn:refreshAccessToken(refreshToken, scope, callback, clientId, clientSecret, issuerId)
	clientId = clientId or self.CLIENT_ID
	clientSecret = clientSecret or self.CLIENT_SECRET

	local basic = base64.encode(clientId .. ":" .. clientSecret)
	local header = {
		Accept = "application/json",
		["Content-Type"] = "application/x-www-form-urlencoded",
		Authorization = "Basic " .. basic
	}
	local parts = {
		"grant_type=refresh_token",
		"refresh_token=" .. StringEx.urlencode(refreshToken)
	}

	if scope and scope ~= "" then
		table.insert(parts, "scope=" .. StringEx.urlencode(scope))
	end

	local request = HttpRequest(getPsnHostByIssuerId(issuerId), nil, HttpRequest.Method.POST, self.AUTH_PATH, header, table.concat(parts, "&"), true)

	GameServerRepo.httpClientProxy:httpRequest(request, DEFAULT_TIMEOUT_MS, function(reply)
		Logger:info("refreshAccessToken reply: %s", inspect(reply))

		local response

		if reply and reply.body and reply.body ~= "" then
			local ok, decoded = pcall(json.decode, reply.body)

			if ok then
				response = decoded
			else
				Logger:error("refreshAccessToken decode failed: %s", reply.body)
			end
		end

		if callback then
			callback(reply, response)
		end
	end, false, "", DEFAULT_RETRY)
end

return HttpRequestPsn
