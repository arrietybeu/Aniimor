-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DestroySpawnerNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local DestroySpawnerNode = Class.LiteClass("DestroySpawnerNode", FlowNode)

function DestroySpawnerNode:ctor(nodeId, nodeData, graph)
	DestroySpawnerNode.super.ctor(self, nodeId, nodeData, graph)
end

function DestroySpawnerNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_SpawnerId = self:addValueInput("SpawnerId")
end

function DestroySpawnerNode:On_In_PortCalled(context, inputPortName)
	local spawnerId = self:getContextValue(context, self.valueInput_SpawnerId)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("DestroySpawnerNode:destroy spawner:", spawnerId)
	end

	self:destroySpawner(context, spawnerId)
	self.flowOut_Out:call(context)
end

function DestroySpawnerNode:destroySpawner(context, spawnerId)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawner = space:getSpawner(spawnerId)

	if spawner then
		spawner:unloadEntity()
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("DestroySpawnerNode:spawnerId not found:", spawnerId)
	end
end

return DestroySpawnerNode
