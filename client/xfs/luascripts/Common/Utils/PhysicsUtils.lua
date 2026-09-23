-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PhysicsUtils.lua

local CalcUtils = require("Common.Utils.CalcUtils")
local Utils = require("Common.Utils.Utils")
local layer = require("Common.Const.PhysicsLayerConst")
local VectorPool = require("Common.Container.VectorPool")
local PhysicsUtils = {}
local Vector3 = Vector3
local Quaternion = Quaternion

function PhysicsUtils.getRaycastInfo(position, direction, maxDistance, layerMask)
	if Utils.checkClient() then
		return pg.global.physicsMgr:GetRaycastInfo(position, direction, maxDistance, layerMask)
	end

	return nil, false
end

function PhysicsUtils.checkLinecast(position, endPosition, layerMask)
	if Utils.checkClient() then
		return pg.global.physicsMgr:CheckLinecast(position, endPosition, layerMask)
	end

	return false
end

function PhysicsUtils.checkLinecastXYZ(x1, y1, z1, x2, y2, z2, layerMask)
	if Utils.checkClient() then
		return pg.global.physicsMgr:CheckLinecastXYZ(x1, y1, z1, x2, y2, z2, layerMask)
	end

	return false
end

function PhysicsUtils.getGroundPosByDirection(pos, direction)
	local hitResult, succ = PhysicsUtils.getRaycastInfo(pos, direction, 100, CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS)

	if succ then
		return hitResult.point
	end

	return nil
end

function PhysicsUtils.getGroundHeight(pos, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)
	if isOnWater == nil then
		isOnWater = false
	end

	if checkEntity == nil then
		checkEntity = true
	end

	heightLimit = heightLimit or 4
	downLimit = downLimit or 100

	if Utils.checkClient() then
		local ret, height = pg.global.physicsMgr:GetGroundHeight(pos, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)

		return ret, height
	end

	return false, 0
end

function PhysicsUtils.getGroundHeightByPosXYZ(px, py, pz, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)
	if isOnWater == nil then
		isOnWater = false
	end

	if checkEntity == nil then
		checkEntity = true
	end

	heightLimit = heightLimit or 4
	downLimit = downLimit or 100

	if Utils.checkClient() then
		local ret, height = pg.global.physicsMgr:GetGroundHeightByPosXYZ(px, py, pz, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)

		return ret, height
	end

	return false, 0
end

function PhysicsUtils.getGroundPos(pos, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)
	downLimit = downLimit or heightLimit

	if checkEntity == nil then
		checkEntity = true
	end

	local hitResult, groundHeight = PhysicsUtils.getGroundHeight(pos, heightLimit, ignoreRigidBody, isOnWater, checkEntity)
	local ret = Vector3.Clone(pos)

	if hitResult then
		if heightLimit and downLimit < groundHeight then
			return ret
		end

		ret.y = pos.y - groundHeight

		return ret, true
	else
		return pos, false
	end
end

function PhysicsUtils.getGroundPosXYZ(px, py, pz, heightLimit, ignoreRigidBody, isOnWater, checkEntity, downLimit)
	downLimit = downLimit or heightLimit

	if checkEntity == nil then
		checkEntity = true
	end

	local hitResult, groundHeight = PhysicsUtils.getGroundHeightByPosXYZ(px, py, pz, heightLimit, ignoreRigidBody, isOnWater, checkEntity)

	if hitResult then
		if heightLimit and downLimit < groundHeight then
			return false, px, py, pz
		end

		return true, px, py - groundHeight, pz
	else
		return false, px, py, pz
	end
end

if EnableBotTest then
	function PhysicsUtils.getGroundPos(pos)
		return pos
	end
end

function PhysicsUtils.getWaterPos(pos, heightLimit, ignoreRigidBody)
	heightLimit = heightLimit or 2

	if Utils.checkClient() then
		return pg.global.physicsMgr:GetWaterPos(pos, heightLimit, ignoreRigidBody)
	end

	return pos
end

function PhysicsUtils.getGroundTangentRotation(pos, heightLimit)
	heightLimit = heightLimit or 2

	if Utils.checkClient() then
		local ret = pg.global.physicsMgr:GetGroundTangentRotation(pos, heightLimit)

		return ret
	end

	return Quaternion.identity
end

function PhysicsUtils.getGroundTangentRotationEx(pos, rot, radius, heightLimit)
	heightLimit = heightLimit or 2

	if Utils.checkClient() then
		local ret = pg.global.physicsMgr:GetGroundTangentRotationEx(pos, rot, radius, heightLimit)

		return ret
	end

	return Quaternion.identity
end

function PhysicsUtils.getScreenCenterPos(maxDist)
	maxDist = maxDist or 100

	local x, y, z = pg.global.physicsMgr:GetScreenCenterPosXYZ(maxDist)

	return Vector3.ForceNew(x, y, z)
end

function PhysicsUtils.getScreenCenterPosXYZ(maxDist)
	maxDist = maxDist or 100

	return pg.global.physicsMgr:GetScreenCenterPosXYZ(maxDist)
end

function PhysicsUtils.getScreenCenterPosXYZIgnoreCollision()
	return pg.global.physicsMgr:GetScreenCenterPosXYZIgnoreCollision()
end

function PhysicsUtils.getScreenCenterPosXYZFurtherThanEntity(entity, maxDist)
	local entActorId = entity and entity.actorId or 0

	maxDist = maxDist or 100

	return pg.global.physicsMgr:GetScreenCenterPosXYZFurtherThanEntity(entActorId, maxDist)
end

function PhysicsUtils.getScreenCenterPosFurtherThanEntity(entity, maxDist)
	local entActorId = entity and entity.actorId or 0

	maxDist = maxDist or 100

	return pg.global.physicsMgr:GetScreenCenterPosFurtherThanEntity(entActorId, maxDist)
end

function PhysicsUtils.checkCameraRayCastToPosBlocked(pos)
	if not Utils.checkClient() then
		return false
	end

	return pg.global.physicsMgr:CheckCameraRaycastToPosEx(pos.x, pos.y, pos.z, CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS)
end

function PhysicsUtils.checkTargetBlocked(targetActorId1, targetActorId2)
	if Utils.checkClient() then
		local targetEnt = pg.getEntityByActorId(targetActorId1)
		local targetEnt2 = pg.getEntityByActorId(targetActorId2)

		if targetEnt == nil or targetEnt2 == nil then
			return false
		end

		local pos1 = VectorPool.getVector(3, targetEnt:getPosition())

		if targetEnt.getRealHeight then
			pos1.y = pos1.y + targetEnt:getRealHeight() / 2
		else
			pos1.y = pos1.y + targetEnt:getHeight() / 2
		end

		local pos2 = VectorPool.getVector(3, targetEnt2:getPosition())

		if targetEnt2.getRealHeight then
			pos2.y = pos2.y + targetEnt2:getRealHeight() / 2
		else
			pos2.y = pos2.y + targetEnt2:getHeight() / 2
		end

		local layerMask = bit.lshift(1, layer.eDefault) + bit.lshift(1, layer.eGround)

		return PhysicsUtils.checkLinecast(pos1, pos2, layerMask)
	end

	return false
end

function PhysicsUtils.checkTargetBlockedByPos(targetActorId, pos)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if targetEnt == nil then
		return false
	end

	local targetPos = VectorPool.getVector(3, targetEnt:getPosition())

	if targetEnt.getRealHeight then
		targetPos.y = targetPos.y + targetEnt:getRealHeight() / 2
	else
		targetPos.y = targetPos.y + targetEnt:getHeight() / 2
	end

	local layerMask = bit.lshift(1, layer.eDefault) + bit.lshift(1, layer.eGround)

	return not PhysicsUtils.checkLinecast(targetPos, pos, layerMask)
end

return PhysicsUtils
