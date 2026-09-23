-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetTideStateNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local GetTideStateNode = Class.LiteClass("GetTideStateNode", FlowNode)

function GetTideStateNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetTideStateNode:registerPorts()
	GetTideStateNode.super.registerPorts(self)
	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetTideStateNode:Get_Value_Value(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if player ~= nil and Utils.getTideStateId then
		return Utils.getTideStateId(player)
	end
end

return GetTideStateNode
