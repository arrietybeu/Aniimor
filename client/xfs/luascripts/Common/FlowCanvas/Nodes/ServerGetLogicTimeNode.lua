-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerGetLogicTimeNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ServerGetLogicTimeNode = Class.LiteClass("ServerGetLogicTimeNode", FlowNode)

function ServerGetLogicTimeNode:ctor(nodeId, nodeData, graph)
	ServerGetLogicTimeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerGetLogicTimeNode:registerPorts()
	self:addValueOutput("Hour", function(context)
		return self:callbackHourAndMinute(context)[1]
	end)
	self:addValueOutput("Minute", function(context)
		return self:callbackHourAndMinute(context)[2]
	end)
end

function ServerGetLogicTimeNode:callbackHourAndMinute(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return {
			0,
			0
		}
	end

	local curHour, curMinute = space:getLogicHourAndMin()

	return {
		curHour,
		curMinute
	}
end

return ServerGetLogicTimeNode
