-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CheckNumItemIdNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local CheckNumItemIdNode = Class.LiteClass("CheckNumItemIdNode", FlowNode)

function CheckNumItemIdNode:ctor(nodeId, nodeData, graph)
	CheckNumItemIdNode.super.ctor(self, nodeId, nodeData, graph)
end

function CheckNumItemIdNode:registerPorts()
	self.itemId = self.nodeData.ItemId
	self.valueInput_Num = self:addValueInput("Num")

	self:addValueOutput("Result", function(context)
		return self:Get_Result_Value(context)
	end)
end

function CheckNumItemIdNode:Get_Result_Value(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	local curCoin = player:getItemCountById(self.itemId)
	local num = self:getContextValue(context, self.valueInput_Num)

	return num <= curCoin
end

return CheckNumItemIdNode
