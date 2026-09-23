-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRValueOutput.lua

local Class = require("Core.Framework.Class")
local CTRValueOutput = Class.LightClass("CTRValueOutput")

function CTRValueOutput:ctor(name, nodeId, getter)
	self.name = name
	self.nodeId = nodeId
	self.getter = getter
end

return CTRValueOutput
