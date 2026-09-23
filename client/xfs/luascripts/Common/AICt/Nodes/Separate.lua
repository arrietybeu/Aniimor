-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Separate.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local Separate = Class.LightClass("Separate", CTRNode)

function Separate:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function Separate:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_flowIn_PortCalled(flow)
	end)

	local cdCount = self.nodeData.numb

	self.conditions = {}

	for i = 1, cdCount do
		self.conditions[i] = self:addValueInput("condition" .. i - 1)
	end

	self.flowOuts = {}

	for i = 1, cdCount do
		self.flowOuts[i] = self:addFlowOutput("flowOut" .. i - 1)
	end
end

function Separate:On_flowIn_PortCalled(flow)
	for i, v in ipairs(self.conditions) do
		if self:getInputValue(v, flow) then
			self:callFlowOut(self.flowOuts[i], flow)

			break
		end
	end
end

return Separate
