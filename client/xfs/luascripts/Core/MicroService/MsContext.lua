-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsContext.lua

local Class = require("Core.Framework.Class")
local MsContext = Class.LightClass("MsContext")

function MsContext:ctor()
	self.context = {}
	self.gateId = nil
	self.rid = 0
	self.from = ""
	self.to = ""
	self.version = 0
	self.objMgr = nil
	self.id = ""
end

return MsContext
