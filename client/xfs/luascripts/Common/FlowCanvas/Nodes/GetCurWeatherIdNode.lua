-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetCurWeatherIdNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local GetCurWeatherIdNode = Class.LiteClass("GetCurWeatherIdNode", FlowNode)

function GetCurWeatherIdNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetCurWeatherIdNode:registerPorts()
	self:addValueOutput("WeatherId", function(context)
		return self:Get_Weather_Id(context)
	end)
end

function GetCurWeatherIdNode:Get_Weather_Id(context)
	local space = context:getSpace()

	if not space then
		return 0
	end

	local player = space:getMainPlayer()

	if not player then
		return 0
	end

	return Utils.getCurWeatherId(player) or 0
end

return GetCurWeatherIdNode
