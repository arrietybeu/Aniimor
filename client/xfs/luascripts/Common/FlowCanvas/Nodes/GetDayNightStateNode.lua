-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetDayNightStateNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetDayNightStateNode = Class.LiteClass("GetDayNightStateNode", FlowNode)

function GetDayNightStateNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetDayNightStateNode:registerPorts()
	self:addValueOutput("State", function(context)
		return self:Get_State_Value(context)
	end)
end

function GetDayNightStateNode:Get_State_Value(context)
	local space = context:getSpace()

	if not space then
		return -1
	end

	return space.timePeriod
end

return GetDayNightStateNode
