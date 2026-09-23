-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpServer.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local IDManager = require("Core.Common.IDManager")
local CallbackManager = require("Core.Net.CallbackManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local _Request = class.Class("_Request")

function _Request:ctor(server, version, method, path, args, header, body, sessionid)
	self.server = server
	self.version = version
	self.method = method
	self.path = path
	self.args = args
	self.header = header
	self.body = body
	self.sessionid = sessionid
end

function _Request:reply(statusCode, header, body)
	self.server:sendResponse(self.sessionid, statusCode, self.version, header, body)
end

local HttpServer = class.Class("HttpServer")

function HttpServer:ctor(name, host, port, reqCb)
	self.cobj = phonestcore.newHttpServer(name)
	self.name = name
	self.host = host
	self.port = port
	self.reqCb = reqCb
	self.logger = LoggerManager.getLogger("HttpServer")
end

function HttpServer:start()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("HttpServer start: name=%s, host=%s, port=%d", self.name, self.host, self.port)
	end

	local handlerId = IDManager.genB64ID()

	CallbackManager.registerHandler(handlerId, CallbackHandler(self, "onRequest"))
	self.cobj:startHttpServer(self.host, self.port, handlerId)
end

function HttpServer:stop()
	if self.cobj then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("HttpServer stop: name=%s, host=%s, port=%d", self.name, self.host, self.port)
		end

		self.cobj:destroyHttpServer()

		self.cobj = nil
	end
end

function HttpServer:onRequest(version, method, target, header, body, sessionid)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("HttpServer onRequest: version=%s, method=%s, target=%s, header=%s, body=%s", version, method, target, inspect(header), body)
	end

	if self.reqCb then
		local path, args
		local argsStart = string.find(target, "?")

		if argsStart then
			path = string.sub(target, 1, argsStart - 1)
			args = {}

			local queryString = string.sub(target, argsStart + 1)

			for key, value in string.gmatch(queryString, "([^&=]+)=([^&=]+)") do
				args[key] = value
			end
		else
			path = target
		end

		local request = _Request(self, version, method, path, args, header, body, sessionid)

		self.reqCb(request)
	else
		self:sendResponse(sessionid, 404, version, {}, "no response")
	end
end

function HttpServer:sendResponse(sessionid, statusCode, version, header, body)
	if self.cobj then
		self.cobj:sendHttpResponse(sessionid, statusCode, version, header, body)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("HttpServer:sendResponse: server is not running")
	end
end

return HttpServer
