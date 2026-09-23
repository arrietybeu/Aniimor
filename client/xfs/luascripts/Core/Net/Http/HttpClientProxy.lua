-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpClientProxy.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local IDManager = require("Core.Common.IDManager")
local CallbackManager = require("Core.Net.CallbackManager")
local HttpReply = require("Core.Net.Http.HttpReply")
local CommonRepo = require("Core.Common.CommonRepo")
local _HttpClientWrapper = class.Class("_HttpClientWrapper")

function _HttpClientWrapper:ctor(host, port, method, url, header, body, ssl, timeout, callback, keepAlive, rsaKey, maxRedirects)
	local handlerID = IDManager.genB64ID()
	local remainingRedirects = maxRedirects or 0

	local function realCallback(err, replyHeader, replyBody)
		local httpReply = HttpReply(err, replyHeader, replyBody)

		if err == 0 and replyHeader.HTTP_STATUS == "307" and replyHeader.Location ~= nil then
			if remainingRedirects > 0 then
				remainingRedirects = remainingRedirects - 1

				self.cObj:destroyHttpClient()

				self.cObj = phonestcore.newHttpClient(rsaKey or "")

				self.cObj:startHttpClient(host, port, method, replyHeader.Location, header, body, ssl, timeout, handlerID)

				return
			end

			CommonRepo.logger:error("_HttpClientWrapper exceeds max redirects: host=%s url=%s", host, replyHeader.Location)
		end

		callback(httpReply, self.cObj)

		if not keepAlive or err ~= 0 then
			CallbackManager.unRegisterHandler(handlerID)
			self.cObj:destroyHttpClient()
		end
	end

	CallbackManager.registerHandler(handlerID, realCallback)

	self.cObj = phonestcore.newHttpClient(rsaKey or "")

	self.cObj:startHttpClient(host, port, method, url, header, body, ssl, timeout, handlerID)
end

local _HttpConnection = class.Class("_HttpConnection")
local HTTP_PORT = 80
local HTTPS_PORT = 443

function _HttpConnection:ctor(request, timeout, callback, keepAlive, rsaKey, maxRedirects)
	self.callback = callback

	if request.ssl then
		self.defaultPort = HTTPS_PORT
	else
		self.defaultPort = HTTP_PORT
	end

	self.host = ""
	self.port = nil

	self:_generateHostPort(request)
	_HttpClientWrapper(self.host, self.port, request.method, request.url, request.header, request.body, request.ssl, timeout, callback, keepAlive, rsaKey, maxRedirects)
end

function _HttpConnection:_generateHostPort(request)
	self.host = request.host

	if request.port ~= nil then
		self.port = request.port
	elseif request.ssl ~= true then
		self.port = HTTP_PORT
	else
		self.port = HTTPS_PORT
	end
end

local HttpClientProxy = class.Class("HttpClientProxy")

function HttpClientProxy:ctor()
	return
end

function HttpClientProxy:httpRequest(request, timeoutMs, callback, keepAlive, rsaKey, maxRedirects)
	assert(type(callback) == "function")
	_HttpConnection(request, timeoutMs, callback, keepAlive, rsaKey, maxRedirects)
end

return HttpClientProxy
