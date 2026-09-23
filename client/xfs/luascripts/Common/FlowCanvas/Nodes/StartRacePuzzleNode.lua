-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\StartRacePuzzleNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local StartRacePuzzleNode = Class.LiteClass("StartRacePuzzleNode", FlowNode)

function StartRacePuzzleNode:ctor(nodeId, nodeData, graph)
	StartRacePuzzleNode.super.ctor(self, nodeId, nodeData, graph)
end

function StartRacePuzzleNode:registerPorts()
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_PlayerId = self:addValueInput("PlayerId")
	self.flowOut_Out = self:addFlowOutput("Out")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function StartRacePuzzleNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

	if not levelItem then
		self.logger:error("StartRacePuzzleNode:On_In_PortCalled: levelItem is not exit levelItemId=%s ", levelItemId)
		self.flowOut_Out:call(context)

		return
	end

	local ownerPlayerId = space:getSpaceOwnerId()

	levelItem:RPC_CS_StartRacePuzzle(ownerPlayerId)
	self.flowOut_Out:call(context)
end

return StartRacePuzzleNode
