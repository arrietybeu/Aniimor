-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DestroySpawnerEntityNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local DestroySpawnerEntityNode = Class.LiteClass("DestroySpawnerEntityNode", FlowNode)

function DestroySpawnerEntityNode:ctor(nodeId, nodeData, graph)
	DestroySpawnerEntityNode.super.ctor(self, nodeId, nodeData, graph)
end

function DestroySpawnerEntityNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_SpawnerId = self:addValueInput("SpawnerId")
end

function DestroySpawnerEntityNode:On_In_PortCalled(context, inputPortName)
	if not context or context._destroyed then
		return
	end

	local spawnerId = self:getContextValue(context, self.valueInput_SpawnerId)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("DestroySpawnerEntityNode:destroy spawner:", spawnerId)
	end

	self:destroySpawner(context, spawnerId)
	self.flowOut_Out:call(context)
end

function DestroySpawnerEntityNode:destroySpawner(context, spawnerId)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawner = space:getSpawner(spawnerId)

	if spawner then
		spawner:destroySpawnerEntity()
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("DestroySpawnerEntityNode:spawnerId not found:", spawnerId)
	end
end

return DestroySpawnerEntityNode
