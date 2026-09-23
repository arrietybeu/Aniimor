-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Voxel\\VoxelSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local Lume = require("Core.Common.lume")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local VoxelReactionData = require("Common.Data.voxel_reaction_data")
local ClientConst = require("Const.ClientConst")
local VoxelConst = require("Common.Const.VoxelConst")
local MessageName = require("Const.MessageName")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local VoxelSystem = Class.LightClass("VoxelSystem", SystemBase)

function VoxelSystem:getMessageBindMap()
	return {
		[MessageName.TIMESCALE_CHANGE] = "onTimeScaleChange"
	}
end

function VoxelSystem:onTimeScaleChange(timeScale)
	local space = pg.space

	if not space then
		return
	end

	VoxelUtils.setVoxelTimeScale(space.id, timeScale or 1)
end

function VoxelSystem:resetMutableRegionCache()
	self.mutableRegionSpaceId = nil
end

function VoxelSystem:onCtor()
	self.loadedCallback = nil
	self.loadedRegionIdMap = {}

	local fireEffectIds = {
		AddressDataConst.VOXEL_EFF_FIRE
	}
	local fireCombineEffectIds = {
		AddressDataConst.VOXEL_EFF_FIRE_BIG
	}

	pg.global.voxelMgr.fireEffectManager:SetResIds(fireEffectIds, fireCombineEffectIds, nil, nil, 5, 10)

	local hgFireEffectIds = {
		AddressDataConst.VOXEL_EFF_TALL_FIRE
	}
	local hgFireCombineEffectIds = {
		AddressDataConst.VOXEL_EFF_TALL_FIRE_BIG
	}

	pg.global.voxelMgr.highGrassFireEffectManager:SetResIds(hgFireEffectIds, hgFireCombineEffectIds, nil, nil, 10, 20)

	local electEffectIds = {
		AddressDataConst.VOXEL_EFF_ELECTRIC
	}
	local electCombineEffectIds = {
		AddressDataConst.VOXEL_EFF_ELECTRIC_BIG
	}

	pg.global.voxelMgr.electricEffectManager:SetResIds(electEffectIds, electCombineEffectIds, nil, nil, 5, 10)

	local grassEffectIds = {}
	local grassCombineEffectIds = {
		AddressDataConst.GRASS_CUBE
	}
	local csGrass = CS.FunPlus.WorldX.Voxel.GrassEffectManager

	csGrass.voxelFoliageInterval = 0.5
	csGrass.grassDuration = VoxelReactionData.plantGrass[1].duration

	local burnEffectIds = {
		AddressDataConst.VOXEL_EFF_BURN
	}
	local burnCombineEffectIds = {
		AddressDataConst.VOXEL_EFF_BURN_BIG
	}

	pg.global.voxelMgr.burnEffectManager:SetResIds(burnEffectIds, burnCombineEffectIds, {
		1
	}, {
		2.8
	}, 10, 15)

	local windEffectIds = {}
	local windCombineEffectIds = {
		AddressDataConst.VOXEL_EFF_WIND
	}

	pg.global.voxelMgr.windEffectManager:SetResIds(windEffectIds, windCombineEffectIds, nil, nil, 5, 10)
end

function VoxelSystem:onTick()
	self:loadNearbyRegions()

	if self.loadedCallback and not self:isLoadingRegion() then
		self.loadedCallback()

		self.loadedCallback = nil
	end

	self:checkVoxelLoadChangeCallback()
end

function VoxelSystem:loadNearbyRegions()
	if FREE_WALK then
		return
	end

	local pawn = pg.pawn
	local space = pawn and pawn.space

	if not space or space:getVoxelLoadType() == ClientConst.VoxelLoadType.MAP_LOAD_ALL then
		return
	end

	local pos = pawn:getPosition()
	local spaceId = space.id

	VoxelUtils.loadPartitionRegionsByPoint(spaceId, pos.x, pos.y, pos.z, 2, 3)

	local regionX = math.floor(pos.x / VoxelConst.REGION_LENGTH)
	local regionZ = math.floor(pos.z / VoxelConst.REGION_LENGTH)
	local regionSize = space:checkEnableMutableVoxel() and 2 or -1

	if self.mutableRegionSpaceId ~= spaceId or self.mutableRegionX ~= regionX or self.mutableRegionZ ~= regionZ or self.mutableRegionSize ~= regionSize then
		self.mutableRegionSpaceId = spaceId
		self.mutableRegionX = regionX
		self.mutableRegionZ = regionZ
		self.mutableRegionSize = regionSize

		VoxelUtils.setMutableRegionRange(spaceId, pos.x, pos.y, pos.z, regionSize)
	end
end

function VoxelSystem:isLoadingRegion()
	local pawn = pg.pawn

	if pawn and pawn.space then
		return VoxelUtils.isLoadingRegion(pawn.space.id)
	end

	return false
end

function VoxelSystem:setRegionLoadedCallback(callback)
	self.loadedCallback = callback
end

function VoxelSystem:registerVoxelRegionLoadCallback(space)
	table.clear(self.loadedRegionIdMap)

	local spaceId = space.id

	self.loadedRegionIdMap._spaceId = spaceId
	self.loadedRegionIdMap.loadType = space:getVoxelLoadType()
	self.loadedRegionIdMap._count = 0

	if self.loadedRegionIdMap.loadType ~= ClientConst.VoxelLoadType.MAP_LOAD_ALL then
		local loadedRegions = pg.world.getVoxelRegionLoadedIdList(spaceId)

		for _, regionId in pairs(loadedRegions) do
			self.loadedRegionIdMap[regionId] = true
		end
	end

	pg.world.registerVoxelRegionLoadCallback(spaceId, function(loadSpaceId, regionId, loaded)
		if loadSpaceId ~= self.loadedRegionIdMap._spaceId then
			return
		end

		if loaded then
			self.loadedRegionIdMap[regionId] = loaded
		else
			self.loadedRegionIdMap[regionId] = nil
		end

		self.voxelChangeDirty = true
	end)

	self.voxelChangeDirty = true
end

function VoxelSystem:checkVoxelLoadChangeCallback()
	if self.voxelChangeDirty then
		self.voxelChangeDirty = false

		local entities = pg.getEntities()

		for _, ent in pairs(entities) do
			if ent.voxelRegionChanged then
				ent:voxelRegionChanged()
			end
		end
	end
end

function VoxelSystem:updateVoxelPath(voxelPath)
	if pg.world.getSpaceVoxelPath() == voxelPath then
		return
	end

	Lume.clear(self.loadedRegionIdMap)
	pg.world.updateSceneVoxelPath(voxelPath)
	self:registerVoxelRegionLoadCallback(pg.me.space)
end

function VoxelSystem:onSceneLoaded(sceneId, sceneName)
	pg.global.voxelMgr:OnSceneLoaded(sceneId, sceneName)
end

function VoxelSystem:onSceneUnloaded(sceneId, sceneName)
	pg.global.voxelMgr:OnSceneUnloaded(sceneId, sceneName)
end

function VoxelSystem:testPlanGrass()
	local shapeInfo = {
		heightDown = 0.5,
		heightUp = 1,
		radius = 5,
		rot = 0,
		center = pg.me:getPosition()
	}
	local voxel_event = 8
	local AbilityConst = require("Common.Const.AbilityConst")

	pg.world.modifyVoxels(pg.me.space.id, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shapeInfo, voxel_event, 10)
end

function VoxelSystem:testIgnite()
	local shapeInfo = {
		heightDown = 0.5,
		heightUp = 1,
		radius = 5,
		rot = 0,
		center = pg.me:getPosition()
	}
	local voxel_event = 9
	local AbilityConst = require("Common.Const.AbilityConst")

	pg.world.modifyVoxels(pg.me.space.id, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shapeInfo, voxel_event, 200)
end

function VoxelSystem:testForceIgnite()
	local shapeInfo = {
		heightDown = 0.5,
		heightUp = 1,
		radius = 5,
		rot = 0,
		center = pg.me:getPosition()
	}
	local voxel_event = 6
	local AbilityConst = require("Common.Const.AbilityConst")

	pg.world.modifyVoxels(pg.me.space.id, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shapeInfo, voxel_event, 200)
end

function VoxelSystem:testGrowFlower()
	local shapeInfo = {
		heightDown = 0.5,
		heightUp = 1,
		radius = 5,
		rot = 0,
		center = pg.me:getPosition()
	}
	local voxel_event = 12
	local AbilityConst = require("Common.Const.AbilityConst")

	pg.world.modifyVoxels(pg.me.space.id, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shapeInfo, voxel_event, 10)
end

function VoxelSystem:testBurn()
	local shapeInfo = {
		heightDown = 0.5,
		heightUp = 1,
		radius = 5,
		rot = 0,
		center = pg.me:getPosition()
	}
	local voxel_event = 9
	local AbilityConst = require("Common.Const.AbilityConst")

	pg.world.modifyVoxels(pg.me.space.id, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shapeInfo, voxel_event, 200)
end

function VoxelSystem:testGetGrowFlowerNum()
	local AbilityConst = require("Common.Const.AbilityConst")
	local voxelTag = AbilityConst.TAG_GRASS_GROW_FLOWER
	local radius = 3
	local position = pg.me:getPosition()
	local count = VoxelUtils.countVoxelByTag(pg.me.space.id, voxelTag, position[1], position[2], position[3], radius, radius, radius)

	return count
end

function VoxelSystem:testBoxSweepPlantGrass()
	local spaceId = pg.me.space.id
	local reactionName = "plantGrass"

	EModelUtils.setAgentPositionAndRotation(pg.pawn, Vector3(0, 0, 0), Quaternion(0, 0, 0, 1), true)

	local startPos = pg.pawn:getPosition()
	local rotation = pg.pawn:getRotation()
	local extendX = 1
	local extendY = 1
	local extendZ = 1
	local distance = 10

	VoxelUtils.doSweepBoxVoxelReact(spaceId, reactionName, startPos, rotation, extendX, extendY, extendZ, distance)

	local ClientDebugUtils = require("Utils.ClientDebugUtils")

	ClientDebugUtils.drawBoxSweep(startPos, rotation, extendX, extendY, extendZ, distance)
end

function VoxelSystem:test(param)
	return
end

return VoxelSystem
