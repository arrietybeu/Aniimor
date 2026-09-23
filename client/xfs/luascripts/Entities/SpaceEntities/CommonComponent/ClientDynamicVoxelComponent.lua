-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientDynamicVoxelComponent.lua

local Class = require("Core.Framework.Class")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local ClientDynamicVoxelComponent = Class.Component("ClientDynamicVoxelComponent")

function ClientDynamicVoxelComponent:ctor()
	self.dynamicVoxelObjects = {}
end

function ClientDynamicVoxelComponent:init(initDict)
	if not initDict or not initDict.dynamicVoxelObjects then
		return
	end

	for _, entry in ipairs(initDict.dynamicVoxelObjects) do
		local objectId = VoxelUtils.createDynamicBoxVoxelObject(self.id, entry.shareKey, entry.boundMin, entry.boundMax, entry.customData, entry.position, entry.yaw, entry.size)

		if objectId ~= 0 then
			if entry.enable == false then
				VoxelUtils.setDynamicVoxelObjectEnable(self.id, objectId, false)
			end

			self.dynamicVoxelObjects[entry.handleId] = {
				objectId = objectId,
				shareKey = entry.shareKey,
				boundMin = entry.boundMin,
				boundMax = entry.boundMax,
				customData = entry.customData,
				position = entry.position,
				yaw = entry.yaw,
				size = entry.size,
				enable = entry.enable
			}
		end
	end
end

function ClientDynamicVoxelComponent:destroy()
	for handleId, obj in pairs(self.dynamicVoxelObjects) do
		if obj.objectId ~= 0 then
			VoxelUtils.destroyDynamicVoxelObject(self.id, obj.objectId)
		end
	end

	self.dynamicVoxelObjects = {}
end

function ClientDynamicVoxelComponent:RPC_SC_CreateDynamicVoxelObject(handleId, shareKey, boundMin, boundMax, customData, position, yaw, size, enable)
	local existed = self.dynamicVoxelObjects[handleId]

	if existed and existed.objectId ~= 0 then
		VoxelUtils.destroyDynamicVoxelObject(self.id, existed.objectId)
	end

	local objectId = VoxelUtils.createDynamicBoxVoxelObject(self.id, shareKey, boundMin, boundMax, customData, position, yaw, size)

	if objectId == 0 then
		self.dynamicVoxelObjects[handleId] = nil

		return
	end

	if not enable then
		VoxelUtils.setDynamicVoxelObjectEnable(self.id, objectId, false)
	end

	self.dynamicVoxelObjects[handleId] = {
		objectId = objectId,
		shareKey = shareKey,
		boundMin = boundMin,
		boundMax = boundMax,
		customData = customData,
		position = position,
		yaw = yaw,
		size = size,
		enable = enable
	}
end

function ClientDynamicVoxelComponent:RPC_SC_DestroyDynamicVoxelObject(handleId)
	local obj = self.dynamicVoxelObjects[handleId]

	if not obj then
		return
	end

	if obj.objectId ~= 0 then
		VoxelUtils.destroyDynamicVoxelObject(self.id, obj.objectId)
	end

	self.dynamicVoxelObjects[handleId] = nil
end

function ClientDynamicVoxelComponent:RPC_SC_UpdateDynamicVoxelObject(handleId, position, yaw, size)
	local obj = self.dynamicVoxelObjects[handleId]

	if not obj or obj.objectId == 0 then
		return
	end

	obj.position = position
	obj.yaw = yaw
	obj.size = size

	VoxelUtils.updateDynamicVoxelObject(self.id, obj.objectId, position, yaw, size)
end

function ClientDynamicVoxelComponent:RPC_SC_SetDynamicVoxelObjectEnable(handleId, enable)
	local obj = self.dynamicVoxelObjects[handleId]

	if not obj or obj.objectId == 0 then
		return
	end

	if obj.enable == enable then
		return
	end

	obj.enable = enable

	VoxelUtils.setDynamicVoxelObjectEnable(self.id, obj.objectId, enable)
end

return ClientDynamicVoxelComponent
