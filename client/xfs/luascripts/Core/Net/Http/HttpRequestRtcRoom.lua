-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpRequestRtcRoom.lua

local class = require("Core.Framework.Class")
local json = require("json")
local base64 = require("base64")
local phonestcore = require("phonestcore")
local zlib = require("zlib")
local bit = bit or require("bit")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local LoggerManager = require("Core.Log.LoggerManager")
local Logger = LoggerManager.getLogger("HttpRequestRtcRoom")
local HttpRequestRtcRoom = class.Class("HttpRequestRtcRoom")
local host = "gme.tencentcloudapi.com"
local USER_SIG_DEFAULT_EXPIRE = 15552000

local function toHex(s)
	return (s:gsub(".", function(c)
		return string.format("%02x", string.byte(c))
	end))
end

local function hmacSha256Raw(key, msg)
	local b64 = phonestcore.hmac256Base64(msg, key)

	return base64.decode(b64)
end

local function hmacSha256Hex(key, msg)
	return toHex(hmacSha256Raw(key, msg))
end

local SHA256_K = {
	1116352408,
	1899447441,
	3049323471,
	3921009573,
	961987163,
	1508970993,
	2453635748,
	2870763221,
	3624381080,
	310598401,
	607225278,
	1426881987,
	1925078388,
	2162078206,
	2614888103,
	3248222580,
	3835390401,
	4022224774,
	264347078,
	604807628,
	770255983,
	1249150122,
	1555081692,
	1996064986,
	2554220882,
	2821834349,
	2952996808,
	3210313671,
	3336571891,
	3584528711,
	113926993,
	338241895,
	666307205,
	773529912,
	1294757372,
	1396182291,
	1695183700,
	1986661051,
	2177026350,
	2456956037,
	2730485921,
	2820302411,
	3259730800,
	3345764771,
	3516065817,
	3600352804,
	4094571909,
	275423344,
	430227734,
	506948616,
	659060556,
	883997877,
	958139571,
	1322822218,
	1537002063,
	1747873779,
	1955562222,
	2024104815,
	2227730452,
	2361852424,
	2428436474,
	2756734187,
	3204031479,
	3329325298
}

local function _u32(n)
	n = bit.tobit(n)

	return n < 0 and n + 4294967296 or n
end

local function _rotr(x, n)
	return bit.bor(bit.rshift(x, n), bit.lshift(x, 32 - n))
end

local function _sha256Binary(msg)
	local bitLen = #msg * 8

	msg = msg .. string.char(128)

	local padLen = (56 - #msg % 64) % 64

	msg = msg .. string.rep("\x00", padLen)

	local high = math.floor(bitLen / 4294967296)
	local low = bitLen % 4294967296

	msg = msg .. string.char(bit.band(bit.rshift(high, 24), 255)) .. string.char(bit.band(bit.rshift(high, 16), 255)) .. string.char(bit.band(bit.rshift(high, 8), 255)) .. string.char(bit.band(high, 255)) .. string.char(bit.band(bit.rshift(low, 24), 255)) .. string.char(bit.band(bit.rshift(low, 16), 255)) .. string.char(bit.band(bit.rshift(low, 8), 255)) .. string.char(bit.band(low, 255))

	local h0, h1, h2, h3 = 1779033703, 3144134277, 1013904242, 2773480762
	local h4, h5, h6, h7 = 1359893119, 2600822924, 528734635, 1541459225
	local w = {}

	for offset = 1, #msg, 64 do
		for i = 0, 15 do
			local b1, b2, b3, b4 = msg:byte(offset + i * 4, offset + i * 4 + 3)

			w[i + 1] = bit.tobit(bit.lshift(b1, 24) + bit.lshift(b2, 16) + bit.lshift(b3, 8) + b4)
		end

		for i = 17, 64 do
			local w15 = w[i - 15]
			local w2 = w[i - 2]
			local s0 = bit.bxor(_rotr(w15, 7), _rotr(w15, 18), bit.rshift(w15, 3))
			local s1 = bit.bxor(_rotr(w2, 17), _rotr(w2, 19), bit.rshift(w2, 10))

			w[i] = bit.tobit(w[i - 16] + s0 + w[i - 7] + s1)
		end

		local a, b, c, d = h0, h1, h2, h3
		local e, f, g, h = h4, h5, h6, h7

		for i = 1, 64 do
			local s1 = bit.bxor(_rotr(e, 6), _rotr(e, 11), _rotr(e, 25))
			local ch = bit.bxor(bit.band(e, f), bit.band(bit.bnot(e), g))
			local t1 = bit.tobit(h + s1 + ch + SHA256_K[i] + w[i])
			local s0 = bit.bxor(_rotr(a, 2), _rotr(a, 13), _rotr(a, 22))
			local maj = bit.bxor(bit.band(a, b), bit.band(a, c), bit.band(b, c))
			local t2 = bit.tobit(s0 + maj)

			h, g, f = g, f, e
			e = bit.tobit(d + t1)
			d, c, b = c, b, a
			a = bit.tobit(t1 + t2)
		end

		h0 = bit.tobit(h0 + a)
		h1 = bit.tobit(h1 + b)
		h2 = bit.tobit(h2 + c)
		h3 = bit.tobit(h3 + d)
		h4 = bit.tobit(h4 + e)
		h5 = bit.tobit(h5 + f)
		h6 = bit.tobit(h6 + g)
		h7 = bit.tobit(h7 + h)
	end

	local digest = {
		h0,
		h1,
		h2,
		h3,
		h4,
		h5,
		h6,
		h7
	}
	local out = {}

	for _, n in ipairs(digest) do
		local u = _u32(n)

		out[#out + 1] = string.char(bit.band(bit.rshift(u, 24), 255))
		out[#out + 1] = string.char(bit.band(bit.rshift(u, 16), 255))
		out[#out + 1] = string.char(bit.band(bit.rshift(u, 8), 255))
		out[#out + 1] = string.char(bit.band(u, 255))
	end

	return table.concat(out)
end

local function sha256Hex(msg)
	if phonestcore.sha256Hex then
		return string.lower(phonestcore.sha256Hex(msg))
	end

	local ok, sha2 = pcall(require, "sha2")

	if ok and sha2 and sha2.sha256hex then
		return string.lower(sha2.sha256hex(msg))
	end

	return toHex(_sha256Binary(msg or ""))
end

local function buildTc3Authorization(secretId, secretKey, host, service, timestamp, body, action)
	local algorithm = "TC3-HMAC-SHA256"
	local date = os.date("!%Y-%m-%d", timestamp)
	local signedHeaders = "content-type;host;x-tc-action"
	local contentType = "application/json"
	local httpRequestMethod = "POST"
	local canonicalUri = "/"
	local canonicalQueryString = ""
	local payload = body or "{}"
	local hashedRequestPayload = sha256Hex(payload)
	local canonicalHeaders = "content-type:" .. contentType .. "\n" .. "host:" .. host .. "\n" .. "x-tc-action:" .. string.lower(action) .. "\n"
	local canonicalRequest = httpRequestMethod .. "\n" .. canonicalUri .. "\n" .. canonicalQueryString .. "\n" .. canonicalHeaders .. "\n" .. signedHeaders .. "\n" .. hashedRequestPayload
	local credentialScope = date .. "/" .. service .. "/tc3_request"
	local stringToSign = algorithm .. "\n" .. tostring(timestamp) .. "\n" .. credentialScope .. "\n" .. sha256Hex(canonicalRequest)
	local secretDate = hmacSha256Raw("TC3" .. secretKey, date)
	local secretService = hmacSha256Raw(secretDate, service)
	local secretSigning = hmacSha256Raw(secretService, "tc3_request")
	local signature = toHex(hmacSha256Raw(secretSigning, stringToSign))
	local authorization = algorithm .. " Credential=" .. secretId .. "/" .. credentialScope .. ", SignedHeaders=" .. signedHeaders .. ", Signature=" .. signature

	return authorization
end

function HttpRequestRtcRoom:test()
	local secretId = Utils.getServerSecretId()
	local secretKey = Utils.getServerSecretKey()
	local body = "{\"Limit\": 1, \"Filters\": [{\"Values\": [\"\\u672a\\u547d\\u540d\"], \"Name\": \"instance-name\"}]}"
	local authorization = buildTc3Authorization(secretId, secretKey, "cvm.tencentcloudapi.com", "cvm", 1551113065, body, "describeinstances")

	print("Authorization:", authorization)

	return authorization
end

function HttpRequestRtcRoom:rtcHttpRequest(action, body, callback)
	local GameServerRepo = require("Core.Server.GameServerRepo")
	local secretId = Utils.getServerSecretId()
	local secretKey = Utils.getServerSecretKey()
	local Authorization = buildTc3Authorization(secretId, secretKey, host, "gme", math.floor(Time.secondCache), body, action)
	local header = {
		["Content-Type"] = "application/json",
		["X-TC-Version"] = "2018-07-11",
		["X-TC-Action"] = action,
		["X-TC-Timestamp"] = math.floor(Time.secondCache),
		Authorization = Authorization
	}
	local request = HttpRequest(host, nil, HttpRequest.Method.POST, "/", header, body, true)

	GameServerRepo.httpClientProxy:httpRequest(request, 5000, function(reply)
		if callback then
			local response = json.decode(reply.body).Response

			callback(response)
		end
	end, false, "", 3)
end

function HttpRequestRtcRoom:kickRtcRoomMember(rtcRoomId, uids, callback)
	local action = "DeleteRoomMember"
	local body = json.encode({
		DeleteType = 2,
		RoomId = tostring(rtcRoomId),
		BizId = Utils.getServerAppId(),
		Uids = uids
	})

	self:rtcHttpRequest(action, body, callback)
end

function HttpRequestRtcRoom:setRtcRoomMute(rtcRoomId, uid, isMute, callback)
	local action = "ModifyUserMicStatus"
	local body = json.encode({
		RoomId = tostring(rtcRoomId),
		BizId = Utils.getServerAppId(),
		Users = {
			{
				EnableMic = isMute and 1 or 2,
				StrUid = uid
			}
		}
	})

	self:rtcHttpRequest(action, body, callback)
end

local function base64UrlSafe(s)
	s = s:gsub("%+", "*")
	s = s:gsub("/", "-")
	s = s:gsub("=", "_")

	return s
end

function HttpRequestRtcRoom:generateUserSig(userId, expire, sdkAppId, permissionKey)
	expire = expire or USER_SIG_DEFAULT_EXPIRE
	sdkAppId = sdkAppId or Utils.getServerAppId()
	permissionKey = permissionKey or Utils.getServerGmePermissionKey()

	local currTime = math.floor(Time.secondCache)
	local userIdStr = tostring(userId)
	local sdkAppIdStr = tostring(sdkAppId)
	local timeStr = tostring(currTime)
	local expireStr = tostring(expire)
	local raw = "TLS.identifier:" .. userIdStr .. "\n" .. "TLS.sdkappid:" .. sdkAppIdStr .. "\n" .. "TLS.time:" .. timeStr .. "\n" .. "TLS.expire:" .. expireStr .. "\n"
	local sigBase64 = phonestcore.hmac256Base64(raw, permissionKey)
	local payload = {
		["TLS.ver"] = "2.0",
		["TLS.identifier"] = userIdStr,
		["TLS.sdkappid"] = sdkAppId,
		["TLS.expire"] = expire,
		["TLS.time"] = currTime,
		["TLS.sig"] = sigBase64
	}
	local jsonStr = json.encode(payload)
	local compressed = zlib.deflate()(jsonStr, "finish")
	local userSig = base64UrlSafe(base64.encode(compressed))

	return userSig, currTime + expire
end

return HttpRequestRtcRoom
