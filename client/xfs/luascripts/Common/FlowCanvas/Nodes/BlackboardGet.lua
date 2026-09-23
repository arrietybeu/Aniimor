-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\BlackboardGet.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local BlackboardGet = Class.LiteClass("BlackboardGet", FlowNode)

function BlackboardGet:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)

	self.variableName = nodeData.variableName
end

function BlackboardGet:registerPorts()
	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function BlackboardGet:Get_Value_Value(context)
	return context:getBlackboardVariable(self.variableName)
end

return BlackboardGet
