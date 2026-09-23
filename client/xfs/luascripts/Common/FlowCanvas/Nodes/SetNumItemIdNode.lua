-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetNumItemIdNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SetNumItemIdNode = Class.LiteClass("SetNumItemIdNode", FlowNode)
local ItemConstSourceData = require("Data.item_const_source_data")

function SetNumItemIdNode:ctor(nodeId, nodeData, graph)
	SetNumItemIdNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetNumItemIdNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.itemId = self.nodeData.ItemId
	self.valueInput_Count = self:addValueInput("Count")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function SetNumItemIdNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	local count = self:getContextValue(context, self.valueInput_Count)
	local curCoin = player:getItemCountById(self.itemId)
	local changeCoin = curCoin - count

	if changeCoin > 0 then
		player:reduceMoneyWithDeficit(pg.getNUID(), ItemConstSourceData.ITEM_SOURCE_SANDBOX_GRAPH, self.itemId, changeCoin)
	elseif changeCoin < 0 then
		player:addItemById(self.itemId, math.abs(changeCoin), ItemConstSourceData.ITEM_SOURCE_SANDBOX_GRAPH)
	end

	self.flowOut_Out:call(context)
end

return SetNumItemIdNode
