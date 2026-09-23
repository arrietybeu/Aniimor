-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\MapMarkTipHelper.lua

local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local MapHelper = require("GameApp.Map.MapHelper")
local MapMarkTipHelper = {}

MapMarkTipHelper.InvalidPosValue = -99999

local InvalidPosValue = MapMarkTipHelper.InvalidPosValue
local COMPONENT_IDX_ITEM = Const.COMPONENT_IDX_ITEM
local GetEntityPos = MapHelper.GetEntityPos
local IsChest = Utils.isChest

function MapMarkTipHelper.RotateLocalYOffsetNoGC(rotation, height)
	local qx = rotation[1]
	local qy = rotation[2]
	local qz = rotation[3]
	local qw = rotation[4]
	local doubleHeight = height + height

	return (qx * qy - qw * qz) * doubleHeight, height - (qx * qx + qz * qz) * doubleHeight, (qy * qz + qw * qx) * doubleHeight
end

local rotateLocalYOffsetNoGC = MapMarkTipHelper.RotateLocalYOffsetNoGC

function MapMarkTipHelper.CopyTargetPos(data, targetPos)
	local result = data.oldPos

	result:Set(targetPos[1], targetPos[2], targetPos[3])

	return result
end

local copyTargetPos = MapMarkTipHelper.CopyTargetPos

function MapMarkTipHelper.CopyTargetPosXYZ(data, x, y, z)
	local result = data.oldPos

	result:Set(x, y, z)

	return result
end

local copyTargetPosXYZ = MapMarkTipHelper.CopyTargetPosXYZ

function MapMarkTipHelper.InvalidateTargetPos(data)
	local result = data.oldPos

	result[1] = InvalidPosValue

	return result
end

local invalidateTargetPos = MapMarkTipHelper.InvalidateTargetPos

function MapMarkTipHelper.GetBindTargetPos(data)
	local result = data.oldPos
	local entPos = GetEntityPos(data.boundEntityId)

	if entPos then
		result:Set(entPos[1], entPos[2], entPos[3])
	else
		result[1] = InvalidPosValue
	end

	return result
end

local getBindTargetPos = MapMarkTipHelper.GetBindTargetPos
local getFixedTargetPos

function MapMarkTipHelper.RestoreBaseTargetPos(data)
	return copyTargetPos(data, data.basePos)
end

local restoreBaseTargetPos = MapMarkTipHelper.RestoreBaseTargetPos

function MapMarkTipHelper.GetFixedTargetPos(data)
	return data.oldPos
end

getFixedTargetPos = MapMarkTipHelper.GetFixedTargetPos

function MapMarkTipHelper.GetSandboxTargetPos(data)
	local result = data.oldPos

	if pg.me.space:getSandbox(data.sBstaticId) then
		local basePos = data.basePos

		result:Set(basePos[1], basePos[2], basePos[3])
	else
		result[1] = InvalidPosValue
	end

	return result
end

function MapMarkTipHelper.GetStaticEntityTargetPos(data)
	local entity = data.entity
	local result = data.oldPos

	if not entity or entity.clientVisible == false then
		result[1] = InvalidPosValue

		return result
	end

	local rx, ry, rz = rotateLocalYOffsetNoGC(entity:getRotation(), data.anchorHeight)
	local pos = entity:getPosition()

	result:Set(pos.x + rx, pos.y + ry, pos.z + rz)

	return result
end

local getStaticEntityTargetPos = MapMarkTipHelper.GetStaticEntityTargetPos

function MapMarkTipHelper.CacheChestAnchorHeight(data, entity)
	local halfHeight = entity.eModel:GetMeshSize(COMPONENT_IDX_ITEM, 1) * 0.5
	local offset = data.offset or 0
	local anchorHeight = halfHeight + (halfHeight <= offset and 0 or offset)

	data.anchorHeight = anchorHeight

	return anchorHeight
end

local cacheChestAnchorHeight = MapMarkTipHelper.CacheChestAnchorHeight

function MapMarkTipHelper.GetChestTargetPos(data)
	local entity = data.entity
	local result = data.oldPos

	if not entity or not entity.active or entity.visible == false then
		result[1] = InvalidPosValue

		return result
	end

	local rx, ry, rz = rotateLocalYOffsetNoGC(entity:getRotation(), data.anchorHeight)
	local pos = entity:getPosition()

	result:Set(pos.x + rx, pos.y + ry, pos.z + rz)

	return result
end

local getChestTargetPos = MapMarkTipHelper.GetChestTargetPos

function MapMarkTipHelper.GetLoadingChestTargetPos(data)
	local entity = data.entity
	local result = data.oldPos

	if not entity or not entity.active then
		result[1] = InvalidPosValue

		return result
	end

	if not entity.isModelLoaded then
		local pos = entity:getPosition()

		result:Set(pos.x, pos.y, pos.z)

		return result
	end

	cacheChestAnchorHeight(data, entity)

	data.sourceTargetPosGetter = getChestTargetPos
	data.targetPosGetter = data.boundEntityId and getBindTargetPos or getChestTargetPos

	return getChestTargetPos(data)
end

local getLoadingChestTargetPos = MapMarkTipHelper.GetLoadingChestTargetPos

function MapMarkTipHelper.SetupStaticTargetPosGetter(data, entity)
	local getter

	if IsChest(entity) then
		if data.entity == entity and data.anchorHeight ~= nil then
			getter = getChestTargetPos
		elseif entity.isModelLoaded then
			cacheChestAnchorHeight(data, entity)

			getter = getChestTargetPos
		else
			data.anchorHeight = nil
			getter = getLoadingChestTargetPos
		end
	else
		local halfHeight = entity:getHeight() * 0.5
		local offset = data.offset or 0

		getter = getStaticEntityTargetPos
		data.anchorHeight = halfHeight + (halfHeight <= offset and 0 or offset)
	end

	data.entity = entity
	data.sourceTargetPosGetter = getter
	data.targetPosGetter = data.boundEntityId and getBindTargetPos or getter

	return getter
end

local setupStaticTargetPosGetter = MapMarkTipHelper.SetupStaticTargetPosGetter

function MapMarkTipHelper.GetUnresolvedStaticTargetPos(data)
	local entity = data.entity or pg.me.space:getEntityByStaticId(data.staticId)
	local getter = entity and setupStaticTargetPosGetter(data, entity)

	return getter and getter(data) or invalidateTargetPos(data)
end

function MapMarkTipHelper.RestoreSourceTargetPos(data)
	data.boundEntityId = nil

	local getter = data.sourceTargetPosGetter

	data.targetPosGetter = getter

	return getter == getFixedTargetPos and restoreBaseTargetPos(data) or getter(data)
end

function MapMarkTipHelper.GetTrackTargetPos(data, targetPos)
	if data and data.boundEntityId == nil and data.entity and targetPos and targetPos[1] ~= InvalidPosValue then
		return data.entity:getPosition()
	end

	return targetPos
end

function MapMarkTipHelper.GetDuelTargetPos(data)
	local entity = data.duelEntity or pg.getEntity(data.duelEntityId)

	if not entity then
		return invalidateTargetPos(data)
	end

	data.duelEntity = entity

	local pos = entity:getPosition()
	local height = entity.topLogoData and entity.topLogoData.heightToRoot or 0

	return copyTargetPosXYZ(data, pos.x, pos.y + height, pos.z)
end

return MapMarkTipHelper
