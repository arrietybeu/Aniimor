-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\TimeTravelStateNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local TimeTravelStateNode = Class.LiteClass("TimeTravelStateNode", FlowNode)
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local Const = require("Common.Const.Const")

function TimeTravelStateNode:ctor(nodeId, nodeData, graph)
	TimeTravelStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function TimeTravelStateNode:registerPorts()
	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)

	self.State = self.nodeData.State or 0
end

function TimeTravelStateNode:Get_Value_Value(context)
	local space = context:getSpace()

	if not space then
		return false
	end

	local count = 0
	local state = self.State

	for _, player in pairs(context:getGraphPlayers()) do
		local regeVal = EntityCacheValueUtils.getCacheValue(player, Const.TravelState)
		local pet = player:getControllingPet()

		if pet then
			regeVal = EntityCacheValueUtils.getCacheValue(pet, Const.TravelState)
		end

		if regeVal and regeVal == state then
			count = count + 1
		end
	end

	if count > 0 then
		return true
	else
		return false
	end
end

return TimeTravelStateNode
