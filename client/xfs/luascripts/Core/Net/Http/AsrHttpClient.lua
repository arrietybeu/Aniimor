-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\AsrHttpClient.lua

local json = require("json")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local Class = require("Core.Framework.Class")
local AsrHttpClient = Class.LightClass("AsrHttpClient")

local function safeCallback(callback, ...)
	if type(callback) == "function" then
		callback(...)
	end
end

function AsrHttpClient:isHttpSuccess(reply)
	if reply == nil or reply.err ~= 0 then
		return false
	end

	local status = tonumber(reply.header and reply.header.HTTP_STATUS)

	return status == nil or status >= 200 and status < 300
end

function AsrHttpClient:makeError(reply, fallback)
	if reply == nil then
		return fallback or "empty http reply"
	end

	if reply.err ~= 0 then
		return "http request error: " .. tostring(reply.err)
	end

	local status = reply.header and reply.header.HTTP_STATUS

	return "HTTP " .. tostring(status or "unknown") .. ": " .. tostring(reply.body or "")
end

function AsrHttpClient:escapeQuoted(value)
	return tostring(value):gsub("[\r\n]", "_"):gsub("\\", "\\\\"):gsub("\"", "\\\"")
end

function AsrHttpClient:makeBoundary()
	return string.format("----WorldXAsrBoundary%x%x", os.time(), math.random(0, 2147483647))
end

function AsrHttpClient:getAudioContentType(filename)
	local extension = tostring(filename):lower():match("%.([^.]+)$")

	if extension == "ogg" or extension == "oga" then
		return "audio/ogg"
	elseif extension == "flac" then
		return "audio/flac"
	end

	return "audio/wav"
end

function AsrHttpClient:buildMultipartAudio(audioBytes, filename, boundary)
	local crlf = "\r\n"

	return table.concat({
		"--",
		boundary,
		crlf,
		"Content-Disposition: form-data; name=\"audio\"; filename=\"",
		self:escapeQuoted(filename),
		"\"",
		crlf,
		"Content-Type: ",
		self:getAudioContentType(filename),
		crlf,
		crlf,
		audioBytes,
		crlf,
		"--",
		boundary,
		"--",
		crlf
	})
end

function AsrHttpClient:health(host, port, ssl, timeoutMs, callback)
	local request = HttpRequest(host, port, HttpRequest.Method.GET, "/health", nil, nil, ssl == true)

	HttpClientProxy():httpRequest(request, timeoutMs or 5000, function(reply)
		if not self:isHttpSuccess(reply) then
			safeCallback(callback, false, nil, self:makeError(reply))

			return
		end

		local ok, result = pcall(json.decode, reply.body)

		if ok then
			safeCallback(callback, true, result, nil)
		else
			safeCallback(callback, true, reply.body, nil)
		end
	end, false)
end

function AsrHttpClient:recognize(host, port, audioBytes, filename, ssl, timeoutMs, callback)
	if type(audioBytes) ~= "string" or #audioBytes == 0 then
		safeCallback(callback, false, nil, "audioBytes must be a non-empty binary string")

		return
	end

	local boundary = self:makeBoundary()
	local headers = {
		Accept = "application/json",
		["Content-Type"] = "multipart/form-data; boundary=" .. boundary
	}
	local body = self:buildMultipartAudio(audioBytes, filename or "audio.wav", boundary)
	local request = HttpRequest(host, port, HttpRequest.Method.POST, "/recognize", headers, body, ssl == true)

	HttpClientProxy():httpRequest(request, timeoutMs or 60000, function(reply)
		if not self:isHttpSuccess(reply) then
			safeCallback(callback, false, nil, self:makeError(reply))

			return
		end

		local ok, result = pcall(json.decode, reply.body)

		if not ok or type(result) ~= "table" then
			safeCallback(callback, false, nil, "invalid ASR JSON response: " .. tostring(reply.body))

			return
		end

		safeCallback(callback, true, result, nil)
	end, false)
end

return AsrHttpClient
