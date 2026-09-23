-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\VoxelUtils.lua

local VoxelConst = require("Common.Const.VoxelConst")
local AbilityConst = require("Common.Const.AbilityConst")
local LxGeometry = require("Common.Ability.LxGeometry")
local VoxelReactionData = require("Common.Data.voxel_reaction_data")
local Utils = require("Common.Utils.Utils")
local VoxelUtils = {}
local CheckShape, CountShape
local Vector3 = Vector3
local CannotStandOnVoxelMaterialDef = VoxelConst.CannotStandOnVoxelMaterialDef
local VoxelNavParam = {
	startSearchUpRange = 10,
	characterHeight = 1,
	jumpHeight = 10,
	climbHeight = 10,
	max_depth = 10,
	maxSearchCount = 30,
	ignoreEndCheck = 1,
	characterSize = 1,
	swimType = 0,
	waterStandHeight = 10,
	endSearchDownRange = 10,
	endSearchUpRange = 10,
	startSearchDownRange = 10
}

function VoxelUtils.doVoxelReact(spaceId, reactionName, shapeKind, shape)
	local actions = VoxelReactionData[reactionName]

	if actions == nil then
		return
	end

	for _, action in ipairs(actions) do
		if action.name == "modifyVoxel" then
			pg.world.modifyVoxels(spaceId, shapeKind, shape, action.voxel_event, action.duration or 0)
		elseif action.name == "modifyVoxelWithSpread" then
			pg.world.modifyVoxelsWithSpread(spaceId, shapeKind, shape, action.voxel_event, action.duration or 0, action.spread_range or 0)
		end
	end
end

function VoxelUtils.doSweepBoxVoxelReact(spaceId, reactionName, startPos, rotation, extendX, extendY, extendZ, distance)
	local actions = VoxelReactionData[reactionName]

	if actions == nil then
		return
	end

	for _, action in ipairs(actions) do
		if action.name == "modifyVoxel" then
			pg.world.boxSweepModifyVoxels(spaceId, startPos, rotation, extendX, extendY, extendZ, distance, action.voxel_event, action.duration or 0)
		end
	end
end

function VoxelUtils.checkVoxelTag(spaceId, checkTag, posX, posY, posZ, radius, heightUp, heightDown)
	if CheckShape == nil then
		CheckShape = LxGeometry.LxCircle3D(Vector3(0, 0, 0), 0, 0, 0, 0)
	end

	radius = radius or 0.25
	heightUp = heightUp or 1
	heightDown = heightDown or 0.5
	CheckShape.center.x = posX
	CheckShape.center.y = posY
	CheckShape.center.z = posZ
	CheckShape.radius = radius
	CheckShape.heightUp = heightUp
	CheckShape.heightDown = heightDown

	return pg.world.checkVoxelSpanByTag(spaceId, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, CheckShape, checkTag)
end

function VoxelUtils.countVoxelByTag(spaceId, checkTag, posX, posY, posZ, radius, heightUp, heightDown)
	if CountShape == nil then
		CountShape = LxGeometry.LxCircle3D(Vector3(0, 0, 0), 0, 0, 0, 0)
	end

	radius = radius or 0.25
	heightUp = heightUp or 1
	heightDown = heightDown or 0.5
	CountShape.center.x = posX
	CountShape.center.y = posY
	CountShape.center.z = posZ
	CountShape.radius = radius
	CountShape.heightUp = heightUp
	CountShape.heightDown = heightDown

	return pg.world.countVoxelSpanByTag(spaceId, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, CountShape, checkTag)
end

function VoxelUtils.findVoxelTag(spaceId, findTag, posX, posY, posZ, radius, heightUp, heightDown)
	radius = math.min(radius or 1, 30)
	heightUp = heightUp or 1
	heightDown = heightDown or 0.5

	local result, x, y, z = pg.world.findVoxelSpanByTag(spaceId, posX, posY, posZ, radius, heightUp, heightDown, findTag)

	return result, x, y, z
end

function VoxelUtils.loadPartitionRegionsByPoint(spaceId, posX, posY, posZ, loadRange, unloadRange)
	loadRange = loadRange or 2
	unloadRange = unloadRange or 2

	pg.world.loadPartitionRegionsByPoint(spaceId, posX, posY, posZ, loadRange, unloadRange)
end

function VoxelUtils.isLoadingRegion(spaceId)
	if FREE_WALK then
		return false
	end

	if pg.component == "game" then
		return false
	end

	return pg.world.isLoadingRegion(spaceId)
end

function VoxelUtils.getLoadRegionProgress(spaceId)
	if pg.component == "game" then
		return 0, 0
	end

	local totalCount, loadedCount = pg.world.getLoadRegionProgress(spaceId)

	return totalCount, loadedCount
end

function VoxelUtils.setMutableRegionRange(spaceId, posX, posY, posZ, regionSize)
	regionSize = regionSize or 2

	pg.world.setMutableRegionRange(spaceId, posX, posY, posZ, regionSize)
end

function VoxelUtils.getVoxelDataByPos(spaceId, posX, posY, posZ, heightRange)
	heightRange = heightRange or 1

	local minLayer, maxLayer, customData, state = pg.world.getVoxelDataByPos(spaceId, posX, posY, posZ, heightRange)

	return minLayer, maxLayer, customData, state
end

function VoxelUtils.getVoxelDataList(spaceId, posX, posZ)
	local dataList = pg.world.getVoxelDataListByPos(spaceId, posX, posZ) or {}

	return dataList
end

function VoxelUtils.scanVoxelDataByPos(spaceId, posX, posY, posZ, heightRange)
	heightRange = heightRange or 0.5

	local customData, state = pg.world.scanVoxelDataByPos(spaceId, posX, posY, posZ, heightRange)

	return customData, state
end

function VoxelUtils.scanVoxelData(spaceId, posX, posY, posZ, radius, heightUp, heightDown)
	if CountShape == nil then
		CountShape = LxGeometry.LxCircle3D(Vector3(0, 0, 0), 0, 0, 0, 0)
	end

	radius = radius or 0.25
	heightUp = heightUp or 1
	heightDown = heightDown or 0.5
	CountShape.center.x = posX
	CountShape.center.y = posY
	CountShape.center.z = posZ
	CountShape.radius = radius
	CountShape.heightUp = heightUp
	CountShape.heightDown = heightDown

	local customData, state = pg.world.scanVoxelData(spaceId, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, CountShape)

	return customData, state
end

function VoxelUtils.checkCanStandOn(material)
	for i = 2, #CannotStandOnVoxelMaterialDef do
		if bit.band(material, CannotStandOnVoxelMaterialDef[i]) ~= 0 then
			return false
		end
	end

	return true
end

function VoxelUtils.getGroundY(spaceId, pos, range)
	range = range or 2

	local voxelList = VoxelUtils.getVoxelDataList(spaceId, pos.x, pos.z)
	local voxelListNum = #voxelList
	local tGroundHeightMinLayer = pos.y
	local tGroundHeightMaxLayer = pos.y + range
	local upSearch = false
	local searchIndex = voxelListNum
	local groundHeight = pos.y

	for i = 1, voxelListNum do
		local minLayer, maxLayer, material, state, _ = unpack(voxelList[i])

		if tGroundHeightMaxLayer < minLayer then
			upSearch = false
			searchIndex = i - 1

			break
		end

		if tGroundHeightMinLayer < maxLayer then
			if not VoxelUtils.checkCanStandOn(material) then
				upSearch = false
				searchIndex = i - 1
				tGroundHeightMinLayer = minLayer
				tGroundHeightMaxLayer = minLayer + range
				groundHeight = minLayer

				break
			end

			upSearch = true
			searchIndex = i
			tGroundHeightMinLayer = maxLayer
			tGroundHeightMaxLayer = maxLayer + range
			groundHeight = maxLayer

			break
		end
	end

	if upSearch then
		for i = searchIndex, voxelListNum do
			local minLayer, maxLayer, material, state, _ = unpack(voxelList[i])

			if not VoxelUtils.checkCanStandOn(material) then
				if tGroundHeightMaxLayer < maxLayer then
					break
				end
			elseif tGroundHeightMaxLayer < minLayer then
				tGroundHeightMinLayer = maxLayer
				tGroundHeightMaxLayer = maxLayer + range
				groundHeight = maxLayer
			else
				break
			end
		end
	else
		for i = searchIndex, 1, -1 do
			local minLayer, maxLayer, material, state = unpack(voxelList[i])

			if VoxelUtils.checkCanStandOn(material) then
				groundHeight = maxLayer

				break
			end
		end
	end

	return groundHeight
end

function VoxelUtils.getGroundHeight(spaceId, pos)
	local voxelList = VoxelUtils.getVoxelDataList(spaceId, pos.x, pos.z)

	for i = #voxelList, 1, -1 do
		local minLayer, maxLayer, material, state, _ = unpack(voxelList[i])

		if material == VoxelConst.VoxelMaterialDef.Default or material == VoxelConst.VoxelMaterialDef.Ice or bit.band(material, VoxelConst.VoxelMaterialDef.Ground) ~= 0 then
			if maxLayer <= pos.y then
				return pos.y - maxLayer
			elseif minLayer <= pos.y and maxLayer > pos.y then
				return pos.y - minLayer
			end
		end
	end

	return 0
end

function VoxelUtils.getGroundPos(spaceId, refPos)
	local height = VoxelUtils.getGroundHeight(spaceId, refPos)

	refPos.y = refPos.y - height

	return refPos, height ~= 0
end

function VoxelUtils.isPosOnWater(spaceId, posX, posY, posZ, heightRange)
	local material, state = VoxelUtils.scanVoxelDataByPos(spaceId, posX, posY, posZ, heightRange)

	if bit.band(material, VoxelConst.VoxelMaterialDef.Water) ~= 0 or bit.band(material, VoxelConst.VoxelMaterialDef.WaterBottom) ~= 0 or bit.band(state, VoxelConst.VoxelStateDef.WaterPool) ~= 0 then
		return true
	end

	return false
end

function VoxelUtils.isEntOnWater(ent, heightRange)
	if ent == nil then
		return false
	end

	local eModel = ent.eModel
	local waterDepth = eModel and eModel.waterVoxelDepth

	if heightRange < 0 and waterDepth then
		return waterDepth > -heightRange
	else
		local targetEntPos = ent:getPosition()

		return VoxelUtils.isPosOnWater(ent.space.id, targetEntPos.x, targetEntPos.y, targetEntPos.z, heightRange)
	end

	return false
end

function VoxelUtils.isEntOnGrass(ent, heightRange)
	if ent == nil then
		return false
	end

	local material, state = VoxelUtils.scanVoxelDataByPos(ent.space.id, ent:getPosition().x, ent:getPosition().y, ent:getPosition().z, heightRange)

	return bit.band(material, VoxelConst.VoxelMaterialDef.Grass) ~= 0
end

function VoxelUtils.getMaxLayer(spaceId, pos)
	local voxelList = VoxelUtils.getVoxelDataList(spaceId, pos.x, pos.z)

	for i = #voxelList, 1, -1 do
		local minLayer, maxLayer, material, state, yIndex = unpack(voxelList[i])

		if material == VoxelConst.VoxelMaterialDef.Default or bit.band(material, VoxelConst.VoxelMaterialDef.Ground) ~= 0 then
			return maxLayer
		end
	end

	return 0
end

function VoxelUtils.verticalRayCast(entity, startPosX, startPosY, startPosZ, maxDistance, voxelMaterialExcludeMask)
	voxelMaterialExcludeMask = voxelMaterialExcludeMask or VoxelConst.VoxelMaterialDef.Water

	if Utils.checkClient() then
		return pg.world.verticalRayCast(startPosX, startPosY, startPosZ, maxDistance, voxelMaterialExcludeMask)
	else
		if not entity.space then
			return false, 0, 0, 0
		end

		return pg.world.verticalRayCast(entity.space.id, startPosX, startPosY, startPosZ, maxDistance, voxelMaterialExcludeMask)
	end
end

function VoxelUtils.rayCast(entity, startPosX, startPosY, startPosZ, endPosX, endPosY, endPosZ, voxelMaterialExcludeMask)
	voxelMaterialExcludeMask = voxelMaterialExcludeMask or VoxelConst.VoxelMaterialDef.Water

	if Utils.checkClient() then
		return pg.world.rayCast(startPosX, startPosY, startPosZ, endPosX, endPosY, endPosZ, voxelMaterialExcludeMask)
	else
		return pg.world.rayCast(entity.space.id, startPosX, startPosY, startPosZ, endPosX, endPosY, endPosZ, voxelMaterialExcludeMask)
	end
end

function VoxelUtils.findPathToPos(entity, startPos, endPos, needSmooth)
	local maxDepth, maxSearchCount = VoxelUtils._getMaxCostLengthByDiffXYZ(endPos[1] - startPos[1], endPos[2] - startPos[2], endPos[3] - startPos[3], entity.bodySize)

	VoxelNavParam.maxSearchCount = maxSearchCount
	VoxelNavParam.max_depth = maxDepth

	VoxelUtils._setDefaultVoxelNavParam(entity)

	VoxelNavParam.ignoreEndCheck = 1

	if Utils.checkClient() then
		return pg.world.findPathToPos(startPos[1], startPos[2], startPos[3], endPos[1], endPos[2], endPos[3], VoxelNavParam, needSmooth)
	else
		return pg.world.findPathToPos(entity.space.id, startPos[1], startPos[2], startPos[3], endPos[1], endPos[2], endPos[3], VoxelNavParam, needSmooth)
	end
end

function VoxelUtils._getMaxCostLengthByDiff(posDiff, characterSize)
	return VoxelUtils._getMaxCostLengthByDiffXYZ(posDiff.x, posDiff.y, posDiff.z, characterSize)
end

function VoxelUtils._getMaxCostLengthByDiffXYZ(diffX, diffY, diffZ, characterSize)
	local absX = math.abs(diffX)
	local absY = math.abs(diffY)
	local absZ = math.abs(diffZ)
	local calcMaxDepth = math.floor(absX + absZ) * 5 + math.min(absY * 0.1, 10) * 2 + 8
	local maxDepth = math.min(calcMaxDepth, VoxelConst.MAX_VOXEL_NAV_DEPTH)
	local xDiff = math.floor(absX * VoxelConst.InvCellSize)
	local zDiff = math.floor(absZ * VoxelConst.InvCellSize)
	local extraRatio = characterSize < 1 and 1 or characterSize > 1 and 1.5 or 1.3
	local disSearchCount = (xDiff * xDiff + zDiff * zDiff) * 0.25 + (xDiff + zDiff) * math.clamp(absY * 0.1, 1, 5) + VoxelConst.MIN_NAV_ASTAR_SEARCH_COUNT
	local maxSearchCount = math.floor(math.min(disSearchCount, VoxelConst.MAX_NAV_ASTAR_SEARCH_COUNT) * extraRatio)

	return maxDepth, maxSearchCount
end

function VoxelUtils.tryGetStandSpanWithRange(entity, pos, upRangeInt, downRangeInt, rangeCount, maxDistance)
	VoxelUtils._setDefaultVoxelNavParam(entity)

	if Utils.checkClient() then
		return pg.world.tryGetStandSpanWithRange(pos[1], pos[2], pos[3], upRangeInt, downRangeInt, rangeCount, maxDistance, VoxelNavParam)
	else
		return pg.world.tryGetStandSpanWithRange(entity.space.id, pos[1], pos[2], pos[3], upRangeInt, downRangeInt, rangeCount, maxDistance, VoxelNavParam)
	end
end

function VoxelUtils.findVoxelRandomPos(entity, pos, minDistance, maxDistance)
	local validPosX, validPosY, validPosZ = pos.x, pos.y, pos.z
	local iterCount = 10
	local randomNavParam = VoxelNavParam

	randomNavParam.ignoreEndCheck = 0

	VoxelUtils._setDefaultVoxelNavParam(entity)

	while iterCount > 0 do
		iterCount = iterCount - 1

		local randomDirectionX = math.random() * 2 - 1
		local randomDirectionZ = math.random() * 2 - 1
		local randomDirectionLength = math.sqrt(randomDirectionX * randomDirectionX + randomDirectionZ * randomDirectionZ)

		if randomDirectionLength > 1e-05 then
			randomDirectionX = randomDirectionX / randomDirectionLength
			randomDirectionZ = randomDirectionZ / randomDirectionLength
		else
			randomDirectionX = 0
			randomDirectionZ = 0
		end

		local randomRadius = math.random() * (maxDistance - minDistance) + minDistance
		local randomPointX = pos.x + randomDirectionX * randomRadius
		local randomPointY = pos.y
		local randomPointZ = pos.z + randomDirectionZ * randomRadius
		local randomDistance = maxDistance - randomRadius
		local rangeCount = math.ceil(randomDistance * VoxelConst.InvCellSize)
		local maxDepth, maxSearchCount = VoxelUtils._getMaxCostLengthByDiffXYZ(pos.x - randomPointX, pos.y - randomPointY, pos.z - randomPointZ, entity.bodySize)

		randomNavParam.maxSearchCount = maxSearchCount
		randomNavParam.max_depth = maxDepth

		local found, x, y, z

		if Utils.checkClient() then
			found, x, y, z = pg.world.tryGetStandSpanWithRange(randomPointX, randomPointY, randomPointZ, 2 * VoxelConst.InvCellHeight, 2 * VoxelConst.InvCellHeight, rangeCount, randomDistance, randomNavParam)
		else
			found, x, y, z = pg.world.tryGetStandSpanWithRange(entity.space.id, randomPointX, randomPointY, randomPointZ, 2 * VoxelConst.InvCellHeight, 2 * VoxelConst.InvCellHeight, rangeCount, randomDistance, randomNavParam)
		end

		if found then
			return true, x, y, z
		end
	end

	return false, validPosX, validPosY, validPosZ
end

function VoxelUtils._setDefaultVoxelNavParam(entity)
	local bodyHeight = entity.bodyHeight
	local bodySize = entity.bodySize
	local stepHeightDown = entity:getConfigData().stepHeightDown or bodyHeight * 0.3
	local stepHeightUp = entity:getConfigData().stepHeightUp or bodyHeight * 0.7

	VoxelNavParam.climbHeight = math.floor(math.max(1, stepHeightUp * VoxelConst.InvCellHeight))
	VoxelNavParam.jumpHeight = math.floor(math.max(1, stepHeightDown * VoxelConst.InvCellHeight))
	VoxelNavParam.characterHeight = math.floor(math.max(1, bodyHeight * VoxelConst.InvCellHeight))
	VoxelNavParam.startSearchUpRange = math.floor(math.max(1, bodyHeight * VoxelConst.InvCellHeight))
	VoxelNavParam.startSearchDownRange = math.floor(math.max(1, bodyHeight * 3 * VoxelConst.InvCellHeight))
	VoxelNavParam.endSearchUpRange = math.floor(math.max(1, stepHeightDown * VoxelConst.InvCellHeight))
	VoxelNavParam.endSearchDownRange = math.floor(math.max(1, stepHeightUp * VoxelConst.InvCellHeight))
	VoxelNavParam.waterStandHeight = math.floor(math.max(1, bodyHeight * 0.4 * VoxelConst.InvCellHeight))
	VoxelNavParam.waterStandHeight = math.min(VoxelNavParam.characterHeight - 1, VoxelNavParam.waterStandHeight)

	local AIControllerUtils = require("Common.Utils.AIControllerUtils")

	VoxelNavParam.swimType = AIControllerUtils.checkCanSwim(entity) and VoxelConst.VoxelNavSwimType.VOXEL_NAV_CAN_SWIM or VoxelConst.VoxelNavSwimType.VOXEL_NAV_CANT_SWIM
	VoxelNavParam.characterSize = 0
end

function VoxelUtils.getSpanDataFilter(spaceId)
	return pg.world.getSpanDataFilter(spaceId)
end

function VoxelUtils.setSpanDataFilter(spaceId, filterValue)
	pg.world.setSpanDataFilter(spaceId, filterValue)
end

function VoxelUtils.setVoxelTickFrameCount(spaceId, frameCount)
	if pg.world.setVoxelTickFrameCount then
		pg.world.setVoxelTickFrameCount(spaceId, frameCount)
	end
end

function VoxelUtils.setVoxelTimeScale(spaceId, timeScale)
	if pg.world.setVoxelTimeScale then
		pg.world.setVoxelTimeScale(spaceId, timeScale)
	end
end

function VoxelUtils.createDynamicBoxVoxelObject(spaceId, shareKey, boundMin, boundMax, customData, position, yaw, size)
	customData = customData or 0

	return pg.world.createDynamicBoxVoxelObject(spaceId, shareKey, boundMin, boundMax, customData, position, yaw, size)
end

function VoxelUtils.destroyDynamicVoxelObject(spaceId, objectId)
	return pg.world.destroyDynamicVoxelObject(spaceId, objectId)
end

function VoxelUtils.updateDynamicVoxelObject(spaceId, objectId, position, yaw, size)
	return pg.world.updateDynamicVoxelObject(spaceId, objectId, position, yaw, size)
end

function VoxelUtils.setDynamicVoxelObjectEnable(spaceId, objectId, enable)
	return pg.world.setDynamicVoxelObjectEnable(spaceId, objectId, enable)
end

return VoxelUtils
