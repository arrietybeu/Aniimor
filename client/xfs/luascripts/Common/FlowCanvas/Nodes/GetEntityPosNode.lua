-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetEntityPosNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local GetEntityPosNode = Class.LiteClass("GetEntityPosNode", FlowNode)

function GetEntityPosNode:ctor(nodeId, nodeData, graph)
	GetEntityPosNode.super.ctor(self, nodeId, nodeData, graph)
end

function GetEntityPosNode:registerPorts()
	self.valueInput_StaticId = self:addValueInput("staticId")
	self.valueOutput_Position = self:addValueOutput("pos", function(context)
		return self:Get_Position_Value(context)
	end)
	self.valueOutput_Yaw = self:addValueOutput("yaw", function(context)
		return self:Get_Yaw_Value(context)
	end)
end

function GetEntityPosNode:Get_Position_Value(context)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local space = context:getSpace()
	local ent = space:getEntityByStaticId(staticId)

	return ent and ent:getPosition() or {
		0,
		0,
		0
	}
end

function GetEntityPosNode:Get_Yaw_Value(context)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local space = context:getSpace()
	local ent = space:getEntityByStaticId(staticId)

	return ent and ent:getYaw() or 0
end

return GetEntityPosNode
