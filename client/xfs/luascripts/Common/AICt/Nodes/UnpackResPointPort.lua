-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\UnpackResPointPort.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local UnpackResPointPort = Class.LightClass("UnpackResPointPort", CTRNode)

function UnpackResPointPort:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function UnpackResPointPort:registerPorts()
	self.valueResPointPort = self:addValueInput("resPointPort")

	self:addValueOutput("pointId", function(flow)
		return self:Get_PointId_Value(flow)
	end)
	self:addValueOutput("portId", function(flow)
		return self:Get_PortId_Value(flow)
	end)
end

function UnpackResPointPort:Get_PointId_Value(flow)
	local port = self:getInputValue(self.valueResPointPort, flow)

	if type(port) ~= "table" then
		return 0
	end

	return port[1]
end

function UnpackResPointPort:Get_PortId_Value(flow)
	local port = self:getInputValue(self.valueResPointPort, flow)

	if type(port) ~= "table" then
		return 0
	end

	return port[2]
end

return UnpackResPointPort
