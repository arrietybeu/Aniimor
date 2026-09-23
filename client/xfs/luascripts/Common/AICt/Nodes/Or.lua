-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Or.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Class = require("Core.Framework.Class")
local CTRNode = require("Common.AICt.CTRNode")
local Or = Class.LightClass("Or", CTRNode)

function Or:ctor(nodeId, nodeData, graph)
	Or.super.ctor(self, nodeId, nodeData, graph)
end

function Or:registerPorts()
	local cdCount = self.nodeData.numb

	self.conditions = {}

	for i = 1, cdCount do
		self.conditions[i] = self:addValueInput("comp" .. i - 1)
	end

	self:addValueOutput("out", function(f)
		return self:Get_Value_Value(f)
	end)
end

function Or:Get_Value_Value(flow)
	for _, v in ipairs(self.conditions) do
		local cur = self:getInputValue(v, flow)

		if cur then
			return true
		end
	end

	return false
end

return Or
