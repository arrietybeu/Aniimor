-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\WorldRiftStageNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local WorldRiftStageNode = Class.LiteClass("WorldRiftStageNode", FlowNode)

function WorldRiftStageNode:ctor(nodeId, nodeData, graph)
	WorldRiftStageNode.super.ctor(self, nodeId, nodeData, graph)

	self.curStageKey = "riftCurStage" .. self.nodeId
end

function WorldRiftStageNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_TotalStage = self:addValueInput("TotalStage")
end

function WorldRiftStageNode:On_In_PortCalled(context, inputPortName)
	local stage = (context:getContextValue(self.curStageKey) or 0) + 1

	context:setContextValue(self.curStageKey, stage)

	local totalStage = self:getContextValue(context, self.valueInput_TotalStage) or 0
	local space = context:getSpace()
	local sandbox = space and space.sandboxes and space.sandboxes[context.sandboxId]

	if space and sandbox and space.sandboxClientMsg then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("WorldRiftStageNode showStage sandboxId=%s stage=%s totalStage=%s", context.sandboxId, stage, totalStage)
		end

		space:sandboxClientMsg(sandbox, "RPC_SC_ShowStage", stage, totalStage)
	end

	self.flowOut_Out:call(context)
end

return WorldRiftStageNode
