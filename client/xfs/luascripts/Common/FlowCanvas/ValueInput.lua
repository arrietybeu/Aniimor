-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\ValueInput.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.FlowCanvas.Const")
local ValueInput = Class.LiteClass("ValueInput")

function ValueInput:ctor(name, serializedValue)
	self.name = name
	self.getter = nil
	self.serializedValue = serializedValue
	self.isClient = false
	self.outPutNodeId = nil
end

function ValueInput:bindTo(output, outPutNodeId)
	self.getter = output.getter
	self.outPutNodeId = outPutNodeId
end

return ValueInput
