-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CreateSpawnerNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local CreateSpawnerNode = Class.LiteClass("CreateSpawnerNode", FlowNode)

function CreateSpawnerNode:ctor(nodeId, nodeData, graph)
	CreateSpawnerNode.super.ctor(self, nodeId, nodeData, graph)
end

function CreateSpawnerNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_SpawnerId = self:addValueInput("SpawnerId")
	self.valueInput_Pos = self:addValueInput("Pos")
end

function CreateSpawnerNode:On_In_PortCalled(context, inputPortName)
	local spawnerId = self:getContextValue(context, self.valueInput_SpawnerId)
	local pos = self:getContextValue(context, self.valueInput_Pos)

	if pos and pos[1] == 0 and pos[2] == 0 and pos[3] == 0 then
		pos = nil
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("CreateSpawnerNode:create spawner:", spawnerId, inspect(pos))
	end

	self:createSpawner(context, spawnerId, pos)
	self.flowOut_Out:call(context)
end

function CreateSpawnerNode:createSpawner(context, spawnerId, pos)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawner = space:getSpawner(spawnerId)

	if spawner and spawner.loadSpawnEntityManual then
		spawner:loadSpawnEntityManual({
			forcePosition = pos
		})
	elseif spawner and spawner.loadSpawnEntityTask then
		spawner:loadSpawnEntityTask({
			forcePosition = pos
		})
	elseif spawner and spawner.loadSpawnEntityLoop then
		spawner:loadSpawnEntityLoop()
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("CreateSpawnerNode:spawnerId not found:", spawnerId)
	end
end

return CreateSpawnerNode
