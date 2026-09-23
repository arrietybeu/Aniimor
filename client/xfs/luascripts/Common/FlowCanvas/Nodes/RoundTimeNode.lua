-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RoundTimeNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local RoundTimeNode = Class.LiteClass("RoundTimeNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function RoundTimeNode:ctor(nodeId, nodeData, graph)
	RoundTimeNode.super.ctor(self, nodeId, nodeData, graph)
end

function RoundTimeNode:registerPorts()
	RoundTimeNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("LevelItemIn", function(context, inputPortName)
		self:On_LevelItemIn_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Cancel", function(context, inputPortName)
		self:On_Cancel_PortCalled(context, inputPortName)
	end)

	self.targetId = self.nodeData.gameplayId
	self.spawnerIdList = self.nodeData.spawnerList
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function RoundTimeNode:On_LevelItemIn_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox.targetId = self.targetId
end

function RoundTimeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox.targetId = self.targetId

	self:loadSpawner(context)

	local eventName = ServerEventConst.FINISH_TARGET .. self.targetId

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self:onFinish(args, context)
	end

	self:addEventListen(context, eventName, listener)

	local gameplay = sandbox:getGameplay()

	if gameplay and gameplay.startRoundTime then
		gameplay:startRoundTime(self)
	else
		local player = space:getMainPlayer()

		if player then
			player:showTarget(self.targetId)
		end
	end
end

function RoundTimeNode:On_Cancel_PortCalled(context, inputPortName)
	RoundTimeNode.super.On_Cancel_PortCalled(self, context, inputPortName)
	self:unloadSpawner(context)

	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if player then
		player:delTarget(self.targetId)
	end
end

function RoundTimeNode:onFinish(args, context)
	self:unloadSpawner(context)
	self:endRoundTime(context, args.result)

	if args.result then
		self.flowOut_Success:call(context)
	else
		self.flowOut_Fail:call(context)
	end
end

function RoundTimeNode:endRoundTime(context, result)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local gameplay = sandbox:getGameplay()

	if gameplay and gameplay.endRoundTime then
		gameplay:endRoundTime(self.targetId, result)
	else
		local player = space:getMainPlayer()

		if player and player.delTarget then
			player:delTarget(self.targetId)
		end

		self:destroy(space)
	end
end

function RoundTimeNode:loadSpawner(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawner

	for _, spawnerId in ipairs(self.spawnerIdList or EMPTY_TABLE) do
		spawner = space:getSpawner(spawnerId)

		if spawner and spawner.loadSpawnEntityManual then
			spawner:loadSpawnEntityManual()
		elseif spawner and spawner.spawnType == Const.SPAWN_TYPE_LOOP then
			spawner:loadSpawnEntityLoop()
		else
			self.logger:debug("RoundTimeNode:loadSpawner: spawnerId not found, spawnerId is %s", spawnerId)
		end
	end
end

function RoundTimeNode:unloadSpawner(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local spawner

	for _, spawnerId in ipairs(self.spawnerIdList or EMPTY_TABLE) do
		spawner = space:getSpawner(spawnerId)

		if spawner then
			spawner:unloadEntity()
		end
	end
end

function RoundTimeNode:destroy(space)
	if not space then
		return
	end

	local spawner

	for _, spawnerId in ipairs(self.spawnerIdList or EMPTY_TABLE) do
		spawner = space:getSpawner(spawnerId)

		if spawner then
			spawner:unloadEntity()
		end
	end

	local player = space:getMainPlayer()

	if player and player.delTarget then
		player:delTarget(self.targetId)
	end
end

return RoundTimeNode
