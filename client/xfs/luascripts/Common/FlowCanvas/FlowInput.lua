-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\FlowInput.lua

local Class = require("Core.Framework.Class")
local FlowInput = Class.LiteClass("FlowInput")

function FlowInput:ctor(name, pointer)
	self.name = name
	self.pointer = pointer
end

function FlowInput:call(context)
	if self.pointer then
		self.pointer(context)
	end
end

return FlowInput
