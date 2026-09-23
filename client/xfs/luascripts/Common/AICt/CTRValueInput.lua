-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRValueInput.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.FlowCanvas.Const")
local CTRValueInput = Class.LightClass("CTRValueInput")
local Utils = require("Common.Utils.Utils")
local TablePool = require("Common.Container.TablePool")

function CTRValueInput:ctor(name, nodeId, serializedValue)
	self.name = name
	self.nodeId = nodeId
	self.output = nil
	self.getter = nil
	self.serializedValue = serializedValue
	self.instanceValue = {}
	self.isClient = false
end

function CTRValueInput:bindTo(output)
	self.getter = output.getter
	self.output = output
end

function CTRValueInput:getValue(flow)
	if self.getter then
		return self.getter(flow)
	end

	if self.serializedValue == nil then
		return nil
	end

	if type(self.serializedValue) ~= "table" and type(self.serializedValue) ~= "userdata" then
		return self.serializedValue
	end

	local lookup = TablePool.getTable()

	Utils.deepCopyTable(self.serializedValue, lookup, self.instanceValue)
	TablePool.returnTable(lookup)

	return self.instanceValue
end

function CTRValueInput:getDefaultValue()
	return self.serializedValue
end

function CTRValueInput:getOutputPortNodeId()
	return self.output and self.output.nodeId or 0
end

function CTRValueInput:getOutputPortName()
	return self.output and self.output.name or ""
end

return CTRValueInput
