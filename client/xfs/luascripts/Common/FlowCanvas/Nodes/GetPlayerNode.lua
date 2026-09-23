-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetPlayerNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local GetPlayerNode = Class.LiteClass("GetPlayerNode", FlowNode)

function GetPlayerNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetPlayerNode:registerPorts()
	GetPlayerNode.super.registerPorts(self)

	self.allPlayers = self.nodeData.AllPlayers or false

	self:addValueOutput("Players", function(context)
		return self:Get_Value_Players(context)
	end)
end

function GetPlayerNode:Get_Value_Players(context)
	local space = context:getSpace()

	if not space then
		return
	end

	if self.allPlayers then
		return lume.getTableValues(context:getGraphPlayers())
	end

	return {
		space:getMainPlayer()
	}
end

return GetPlayerNode
