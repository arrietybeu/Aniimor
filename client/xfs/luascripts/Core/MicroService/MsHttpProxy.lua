-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsHttpProxy.lua

local json = require("json")
local base64 = require("base64")
local class = require("Core.Framework.Class")
local ProtoCodec = require("Core.Common.ProtoCodec")
local SafeCallback = require("Core.Framework.SafeCallback")
local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local MsHttpProxy = class.Class("MsHttpProxy")

function MsHttpProxy:ctor(ip, port, timeout, rsaKey)
	self.ip = ip
	self.port = port
	self.codec = ProtoCodec()
	self.proxy = HttpClientProxy()
	self.timeout = timeout or 10000
	self.rsaKey = rsaKey or ""
end

function MsHttpProxy:callService(serviceName, methodName, args, callback, options, ctx)
	local msRequest = {}

	msRequest.rid = 1
	msRequest.service = serviceName
	msRequest.method = methodName

	if args ~= nil then
		msRequest.params = base64.encode(self.codec:encode(args))
	end

	msRequest.callerId = options and options.callerId or ""

	if options ~= nil then
		msRequest.options = base64.encode(self.codec:encode(options))
	end

	if ctx ~= nil then
		msRequest.context = base64.encode(self.codec:encode(ctx))
	end

	local function cb(reply, cObj)
		if reply.err ~= 0 then
			local retStatus = {
				status = false,
				errmsg = "http request err: " .. reply.err
			}

			SafeCallback(callback, retStatus)
		elseif not reply.body or reply.body == "" then
			local retStatus = {
				errmsg = "http resp body nil",
				status = false
			}

			SafeCallback(callback, retStatus)
		else
			local resp = json.decode(reply.body)
			local response = self.codec:decode(base64.decode(resp.params))
			local ret = response.Ret
			local retStatus = {
				status = ret[1],
				errmsg = ret[2]
			}

			response.Ret = nil

			SafeCallback(callback, retStatus, response)
		end
	end

	local body = json.encode(msRequest)
	local request = HttpRequest(self.ip, self.port, "POST", "/rpc", nil, body, false)

	self.proxy:httpRequest(request, self.timeout, cb, false, self.rsaKey)
end

return MsHttpProxy
