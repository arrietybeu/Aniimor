-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetEntityNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local GetEntityNode = Class.LiteClass("GetEntityNode", FlowNode)

function GetEntityNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetEntityNode:registerPorts()
	GetEntityNode.super.registerPorts(self)

	self.valueInput_StaticId = self:addValueInput("StaticId")

	self:addValueOutput("Entity", function(context)
		return self:Get_Value_Entity(context)
	end)
end

function GetEntityNode:Get_Value_Entity(context)
	local space = context:getSpace()

	if not space then
		return
	end

	return space:getEntityByStaticId(self:getContextValue(context, self.valueInput_StaticId))
end

return GetEntityNode
