-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SnapshotNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local Quaternion = Quaternion
local unpack = unpack
local SnapshotNode = Class.LiteClass("SnapshotNode", FlowNode)

function SnapshotNode:ctor(nodeId, nodeData, graph)
	SnapshotNode.super.ctor(self, nodeId, nodeData, graph)
end

function SnapshotNode:registerPorts()
	self:addFlowInput("Apply", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.snapshot = self.nodeData.snapshot or {}
end

function SnapshotNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	for k, v in ipairs(self.snapshot.levelItemEntry or EMPTY_TABLE) do
		local levelItemId, state = unpack(v)
		local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

		levelItem:setField("state", state)
	end

	for k, v in pairs(self.snapshot.spawnerStateEntry or EMPTY_TABLE) do
		local spawnerId, created = unpack(v)
		local spawner = space:getSpawner(spawnerId)

		if spawner then
			if created then
				if not self:isSpawnerDisabled(space, spawnerId) then
					if spawner.loadSpawnEntityManual then
						spawner:loadSpawnEntityManual()
					elseif spawner.loadSpawnEntityTask then
						spawner:loadSpawnEntityTask()
					elseif spawner.loadSpawnEntityLoop then
						spawner:loadSpawnEntityLoop()
					end
				end
			else
				spawner:unloadEntity()
			end
		end
	end

	for k, v in pairs(self.snapshot.entityPositionEntry or EMPTY_TABLE) do
		local staticId, pos, rot = unpack(v)
		local entity = space:getEntityByStaticId(staticId)

		if entity then
			entity:setPosition(Vector3(unpack(pos)))
			entity:setRotation(Quaternion(unpack(rot)))
		end
	end

	for k, v in pairs(self.snapshot.playerPositionEntry or EMPTY_TABLE) do
		local pos, rot = unpack(v)
		local player

		if not player and space.getOwnerPlayer then
			player = space:getOwnerPlayer()
		end

		if player and pos and rot then
			player:setPlayerPosition(Vector3(unpack(pos)))

			local yaw = Quaternion.ToEulerAngles(rot).y
			local rotation = Quaternion.Euler(0, yaw, 0)

			player:setPlayerRotation(rotation)
		end
	end

	self.flowOut_Out:call(context)
end

function SnapshotNode:isSpawnerDisabled(space, spawnerId)
	if not space then
		return true
	end

	local spaceType = space.spaceType

	if not Utils.isSpaceSingleWorld(spaceType) and not Utils.isHomeland(spaceType) then
		return false
	end

	if not space.getOwnerPlayer then
		return false
	end

	local ownerPlayer = space:getOwnerPlayer()

	if not ownerPlayer then
		return false
	end

	return ownerPlayer:getTaskSpawnerEffectiveState(space.sceneId, spawnerId) == 0
end

return SnapshotNode
