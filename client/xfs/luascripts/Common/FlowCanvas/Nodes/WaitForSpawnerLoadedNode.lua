-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\WaitForSpawnerLoadedNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local Time = require("Core.Common.Time")
local WaitForSpawnerLoadedNode = Class.LiteClass("WaitForSpawnerLoadedNode", ListenBaseNode)

function WaitForSpawnerLoadedNode:ctor(nodeId, nodeData, graph)
	WaitForSpawnerLoadedNode.super.ctor(self, nodeId, nodeData, graph)

	self.checkTimerKey = self.nodeId .. "checkTimer"
end

function WaitForSpawnerLoadedNode:registerPorts()
	WaitForSpawnerLoadedNode.super.registerPorts(self)

	self.valueInput_spawnerIds = self:addValueInput("spawnerIds")
	self.flowOut_completed = self:addFlowOutput("completed")
end

function WaitForSpawnerLoadedNode:On_In_PortCalled(context, inputPortName)
	if inputPortName == "In" then
		self:waitForSpawners(context)
	end
end

function WaitForSpawnerLoadedNode:waitForSpawners(context)
	local space = context:getSpace()

	if not space then
		self.logger:error("WaitForSpawnerLoadedNode: Space not found")

		return
	end

	local spawnerIds = self:getContextValue(context, self.valueInput_spawnerIds)

	if not spawnerIds or type(spawnerIds) ~= "table" or #spawnerIds == 0 then
		self.logger:error("WaitForSpawnerLoadedNode: spawnerIds is invalid")

		return
	end

	context:setContextValue(self.nodeId .. "_spawnerIds", spawnerIds)
	context:setContextValue(self.nodeId .. "_totalCount", #spawnerIds)

	if self:checkSpawnersLoaded(context, space, spawnerIds) then
		self:onAllLoaded(context)

		return
	end

	context:addContextRepeatTimer(self.checkTimerKey, 0.5, self, "onTimerCheck")
end

function WaitForSpawnerLoadedNode:checkSpawnersLoaded(context, space, spawnerIds)
	for _, spawnerId in ipairs(spawnerIds) do
		local spawner = space:getSpawner(spawnerId)

		if not spawner or not spawner:spawnLoaded() then
			return false
		end
	end

	return true
end

function WaitForSpawnerLoadedNode:onTimerCheck(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawnerIds = context:getContextValue(self.nodeId .. "_spawnerIds")

	if not spawnerIds then
		self:stopTimer(context)

		return
	end

	if self:checkSpawnersLoaded(context, space, spawnerIds) then
		self:stopTimer(context)
		self:onAllLoaded(context)
	end
end

function WaitForSpawnerLoadedNode:stopTimer(context)
	if context then
		context:removeContextTimer(self.checkTimerKey)
	end
end

function WaitForSpawnerLoadedNode:onAllLoaded(context)
	if context then
		self:checkDoOnce(context)
	end

	self.flowOut_completed:call(context)
end

function WaitForSpawnerLoadedNode:On_Cancel_PortCalled(context, inputPortName)
	self:stopTimer(context)
	WaitForSpawnerLoadedNode.super.On_Cancel_PortCalled(context, inputPortName)
end

function WaitForSpawnerLoadedNode:removeListen(context)
	if context then
		self:stopTimer(context)
		WaitForSpawnerLoadedNode.super.removeListen(self, context)
	end
end

return WaitForSpawnerLoadedNode
