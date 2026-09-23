-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RandNumItemIdNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local RandNumItemIdNode = Class.LiteClass("RandNumItemIdNode", FlowNode)
local ItemConstSourceData = require("Data.item_const_source_data")
local ItemConst = require("Common.Const.ItemConst")
local math_floor = math.floor

function RandNumItemIdNode:ctor(nodeId, nodeData, graph)
	RandNumItemIdNode.super.ctor(self, nodeId, nodeData, graph)
end

function RandNumItemIdNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.itemId = self.nodeData.ItemId
	self.canNegative = self.nodeData.canNegative
	self.valueInput_OpType = self:addValueInput("OpType")
	self.valueInput_Min = self:addValueInput("Min")
	self.valueInput_Max = self:addValueInput("Max")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueOutput_Count = self:addValueOutput("Count", function(context)
		return self:Get_Count_Value(context)
	end)

	self:addValueOutput("TotalCount", function(context)
		return self:Get_TotalCount_Value(context)
	end)
end

function RandNumItemIdNode:Get_Count_Value(context)
	local space = context:getSpace()
	local player = space:getMainPlayer()

	if not player then
		return
	end

	return self:getContextValue(context, self.valueOutput_Count)
end

function RandNumItemIdNode:Get_TotalCount_Value(context)
	local space = context:getSpace()
	local player = space:getMainPlayer()

	if not player then
		return
	end

	return player:getItemCountById(self.itemId)
end

function RandNumItemIdNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	local min = self:getContextValue(context, self.valueInput_Min)
	local max = self:getContextValue(context, self.valueInput_Max)
	local opType = self:getContextValue(context, self.valueInput_OpType)
	local result = math.random(min, max - 1)
	local changeCoin = 0

	if opType == 2 then
		local curCoin = player:getItemCountById(self.itemId)

		changeCoin = curCoin * math.abs(result) / 100
	elseif opType == 1 then
		changeCoin = result
	end

	changeCoin = math_floor(changeCoin)

	self:setContextValue(context, self.valueOutput_Count, changeCoin)

	if result <= 0 then
		if self.canNegative then
			player:reduceMoneyWithDeficit(pg.getNUID(), ItemConstSourceData.ITEM_SOURCE_SANDBOX_GRAPH, self.itemId, math.abs(changeCoin))
		else
			player:delItemById(self.itemId, math.abs(changeCoin), ItemConstSourceData.ITEM_SOURCE_SANDBOX_GRAPH)
		end
	else
		local realCount = changeCoin

		if self.itemId == ItemConst.ITEM_SPECIAL_ROGUE_COIN then
			local coinAddP, coinAddV = player:getRogueCoinAddAttrPV()

			realCount = math_floor(realCount * (1 + coinAddP) + coinAddV)
		end

		player:addItemById(self.itemId, realCount, ItemConstSourceData.ITEM_SOURCE_SANDBOX_GRAPH)
	end

	self.flowOut_Out:call(context)
end

return RandNumItemIdNode
