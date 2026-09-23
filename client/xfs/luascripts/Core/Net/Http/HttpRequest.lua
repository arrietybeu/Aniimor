-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpRequest.lua

local class = require("Core.Framework.Class")
local HttpRequest = class.Class("HttpRequest")

HttpRequest.Method = {
	GET = "GET",
	PATCH = "PATCH",
	PUT = "PUT",
	POST = "POST"
}

function HttpRequest:ctor(host, port, method, url, header, body, ssl)
	self.host = host
	self.method = method
	self.url = url
	self.header = header or {}
	self.body = body or ""
	self.ssl = ssl or false
	self.port = port
end

return HttpRequest
