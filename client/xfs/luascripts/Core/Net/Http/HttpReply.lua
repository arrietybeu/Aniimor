-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Http\\HttpReply.lua

local class = require("Core.Framework.Class")
local HttpReply = class.Class("HttpReply")

function HttpReply:ctor(err, header, body)
	self.err = err
	self.header = header or {}
	self.body = body or ""
end

return HttpReply
