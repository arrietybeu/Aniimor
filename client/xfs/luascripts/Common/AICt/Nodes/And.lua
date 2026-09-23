-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\And.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Class = require("Core.Framework.Class")
local CTRNode = require("Common.AICt.CTRNode")
local And = Class.LightClass("And", CTRNode)

function And:ctor(nodeId, nodeData, graph)
	And.super.ctor(self, nodeId, nodeData, graph)
end

function And:registerPorts()
	local cdCount = self.nodeData.numb

	self.conditions = {}

	for i = 1, cdCount do
		self.conditions[i] = self:addValueInput("comp" .. i - 1)
	end

	self:addValueOutput("out", function(f)
		return self:Get_Value_Value(f)
	end)
end

function And:Get_Value_Value(flow)
	for _, v in ipairs(self.conditions) do
		local cur = self:getInputValue(v, flow)

		if not cur then
			return false
		end
	end

	return true
end

return And
