-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\GlobalMsProxy4Client.lua

local class = require("Core.Framework.Class")
local MsProxy = require("Core.Client.MsProxy")
local GlobalMsProxy4Client = class.Class("GlobalMsProxy4Client", MsProxy)

function GlobalMsProxy4Client:ctor(config)
	GlobalMsProxy4Client.super.ctor(self)

	self.config = config or {}
	self.needBind = true
end

function GlobalMsProxy4Client:setNeedBind(needBind)
	self.needBind = needBind
end

function GlobalMsProxy4Client:bind(id, auth, clusterId, cb)
	if self.needBind then
		self:callService("PhonestGate", "bind", {
			id,
			auth,
			clusterId
		}, cb)
	end
end

function GlobalMsProxy4Client:unbind()
	if self.needBind then
		self:callService("PhonestGate", "unbind", {})
	end
end

function GlobalMsProxy4Client:getGateInfo(cb)
	if not self:isExtraConnect() then
		self:callService("PhonestGate", "getGateInfo", {}, cb)
	end
end

return GlobalMsProxy4Client
