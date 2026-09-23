-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetCurMeteorologyIdNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local GetCurMeteorologyIdNode = Class.LiteClass("GetCurMeteorologyIdNode", FlowNode)

function GetCurMeteorologyIdNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetCurMeteorologyIdNode:registerPorts()
	self:addValueOutput("MeteorologyId", function(context)
		return self:Get_Meteorology_Id(context)
	end)
end

function GetCurMeteorologyIdNode:Get_Meteorology_Id(context)
	local space = context:getSpace()

	if not space then
		return 0
	end

	local player = space:getMainPlayer()

	if not player then
		return 0
	end

	return Utils.getCurMeteorologyId(player) or 0
end

return GetCurMeteorologyIdNode
