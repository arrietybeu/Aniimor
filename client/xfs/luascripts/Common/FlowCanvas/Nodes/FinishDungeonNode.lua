-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FinishDungeonNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local FinishDungeonNode = Class.LiteClass("FinishDungeonNode", FlowNode)
local Utils = require("Common.Utils.Utils")

function FinishDungeonNode:ctor(nodeId, nodeData, graph)
	FinishDungeonNode.super.ctor(self, nodeId, nodeData, graph)
end

function FinishDungeonNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_Result = self:addValueInput("Success")
	self.valueInput_RewardPosition = self:addValueInput("RewardPosition")
end

function FinishDungeonNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if Utils.isSpaceDungeon(space.spaceType) then
		local inputResult = self:getContextValue(context, self.valueInput_Result)

		if inputResult == nil then
			inputResult = false
		end

		local rewardPosition = self:getContextValue(context, self.valueInput_RewardPosition)

		if rewardPosition ~= nil and space.setRewardPosition then
			space:setRewardPosition(rewardPosition)
		end

		space:onDungeonFinish(inputResult, context.sandboxId)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("FinishDungeonNode fail, %s space is not dungeon", space:repr())
	end

	self.flowOut_Out:call(context)
end

return FinishDungeonNode
