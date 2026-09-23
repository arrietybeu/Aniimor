-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RpcContext.lua

local class = require("Core.Framework.Class")
local DeepCopy = require("Core.Framework.DeepCopy")
local RpcContext = class.Class("RpcContext")

function RpcContext:ctor()
	self.context = {}
end

function RpcContext:refresh(protoCodec, stream)
	if stream ~= nil then
		self.context = protoCodec:decode(stream) or {}
	else
		self.context = {}
	end
end

function RpcContext:clear()
	self.context = {}
end

function RpcContext:empty()
	return next(self.context) == nil
end

return RpcContext
