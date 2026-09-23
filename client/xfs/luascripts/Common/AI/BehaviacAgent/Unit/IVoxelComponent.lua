-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IVoxelComponent.lua

local class = require("Core.Framework.Class")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local Utils = require("Common.Utils.Utils")
local IVoxelComponent = class.Component("IVoxelComponent")

function IVoxelComponent:isPosOnWater(posX, posY, posZ, heightRange)
	return VoxelUtils.isPosOnWater(self.ent.space.id, posX, posY, posZ, heightRange)
end

function IVoxelComponent:isOnWater(tgtId, heightRange)
	tgtId = tgtId == 0 and self.ent.actorId or tgtId
	heightRange = heightRange or 0.5

	return VoxelUtils.isEntOnWater(pg.getEntityByActorId(tgtId), heightRange)
end

function IVoxelComponent:isOnGrass(actorId, heightRange)
	actorId = actorId == 0 and self.ent.actorId or actorId
	heightRange = heightRange or 0.5

	return VoxelUtils.isEntOnGrass(pg.getEntityByActorId(actorId), heightRange)
end

function IVoxelComponent:getNearestCreationByTag(tagName, maxRange)
	local creationEnt = Utils.getNearestCreationByTag(self.ent, tagName, maxRange)

	return creationEnt == nil and 0 or creationEnt.actorId
end

return IVoxelComponent
