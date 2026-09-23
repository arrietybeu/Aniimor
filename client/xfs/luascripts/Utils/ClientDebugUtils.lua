-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientDebugUtils.lua

local AbilityConst = require("Common.Const.AbilityConst")
local CreationData = require("Data.creation_data")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local ClientSwitch = require("Common.ClientSwitch")
local Vector3 = Vector3
local Quaternion = Quaternion
local DebugDraw = CS.FunPlus.WorldX.Utils.DebugDraw
local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh
local ClientDebugUtils = {}

ClientDebugUtils.timelineDebugCache = {}

function ClientDebugUtils.drawCreationHitBox(creationId, pos, rot)
	local creationInfo = CreationData[creationId]

	if creationInfo then
		local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[creationInfo.shapeKind]

		if shapeKind then
			ClientDebugUtils.drawDebugHitBodyMesh(pos, rot, shapeKind, creationInfo.shapeArgs, 0.1)
		end

		if creationInfo.timelineId then
			ClientDebugUtils.drawTimelineHitBox(creationInfo.timelineId, pos, rot)
		end
	end
end

function ClientDebugUtils.clearCache()
	ClientDebugUtils.timelineDebugCache = {}
end

function ClientDebugUtils.translatePoint(origin, rot, translation)
	return origin + rot:MulVec3(translation)
end

function ClientDebugUtils.drawTimelineHitBox(timelineId, pos, rot)
	local cacheData = ClientDebugUtils.timelineDebugCache[timelineId]

	if not cacheData then
		local timelineData = require("Common.Data.SkillBPData.TimelineBP.Timeline_" .. tostring(timelineId)) or {}
		local events = timelineData.events or {}

		cacheData = {}

		for _, actionData in ipairs(events) do
			if actionData and actionData.action and actionData.action.name == "actOnTargets" then
				cacheData = actionData.action.target

				break
			end

			if actionData and actionData.onUpdate and actionData.onUpdate.name == "actOnTargets" then
				cacheData = actionData.onUpdate.target

				break
			end
		end

		ClientDebugUtils.timelineDebugCache[timelineId] = cacheData
	end

	if cacheData and next(cacheData) then
		for _, targetData in cacheData do
			local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind]
			local offsetXYZ = Vector3.New(unpack(targetData.offsetXYZ))
			local offsetRotation = Vector3.New(unpack(targetData.offsetRotation))

			pos = ClientDebugUtils.translatePoint(pos, rot, offsetXYZ)

			if offsetRotation.x ~= 0 then
				rot = rot * Quaternion.AngleAxis(offsetRotation.x, Vector3.left)
			end

			if offsetRotation.y ~= 0 then
				rot = rot * Quaternion.AngleAxis(offsetRotation.y, Vector3.up)
			end

			if offsetRotation.z ~= 0 then
				rot = rot * Quaternion.AngleAxis(offsetRotation.z, Vector3.forward)
			end

			if shapeKind then
				ClientDebugUtils.drawDebugHitBodyMesh(pos, rot, shapeKind, targetData.shapeArgs, 0.1)
			end
		end
	end
end

function ClientDebugUtils.drawDebugHitBoxMesh(pos, rot, shapeKind, shapeArgs, duration, color)
	ClientDebugUtils.drawDebugMesh(pos, rot, shapeKind, shapeArgs, duration, color or ClientAbilityConst.MESH_HIT_BOX_COLOR)
end

function ClientDebugUtils.drawUniqueDebugHitBoxMesh(uid, pos, rot, shapeKind, shapeArgs, duration, color)
	ClientDebugUtils.drawUniqueDebugMesh(uid, pos, rot, shapeKind, shapeArgs, duration, color or ClientAbilityConst.MESH_HIT_BOX_COLOR)
end

function ClientDebugUtils.drawDebugHitBodyMesh(pos, rot, shapeKind, shapeArgs, duration)
	ClientDebugUtils.drawDebugMesh(pos, rot, shapeKind, shapeArgs, duration, ClientAbilityConst.MESH_HIT_BODY_COLOR)
end

function ClientDebugUtils.drawDebugMesh(pos, rot, shapeKind, shapeArgs, duration, color)
	if not ClientSwitch.EnableDrawAbilityGizmo then
		return
	end

	rot = rot or Quaternion(0, 0, 0, 1)
	duration = duration or 3
	color = color or ClientAbilityConst.MESH_HIT_BOX_COLOR

	LxGeometryMesh.DrawMesh(pos, rot, shapeKind, shapeArgs, duration, color)
end

function ClientDebugUtils.drawUniqueDebugMesh(uid, pos, rot, shapeKind, shapeArgs, duration, color)
	rot = rot or Quaternion(0, 0, 0, 1)
	duration = duration or 1
	color = color or ClientAbilityConst.MESH_HIT_BOX_COLOR

	LxGeometryMesh.DrawUniqueMesh(uid, pos, rot, shapeKind, shapeArgs, duration, color)
end

function ClientDebugUtils.drawDebugShape(pos, rot, shapeKind, shapeArgs, color, duration)
	color = color or Color(0, 1, 0, 1)
	duration = duration or 1

	if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SEGMENT then
		local startPoint, endPoint = unpack(shapeArgs)

		DebugDraw.DrawLine(startPoint, endPoint, color, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
		local radius = shapeArgs[1]
		local heightUp = shapeArgs[2]
		local heightDown = shapeArgs[3]
		local center = pos:Clone()

		center.y = center.y - heightDown

		DebugDraw.DrawCylinder(center, radius, heightUp + heightDown, color, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
		local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)
		local center = pos:Clone()

		center.y = center.y - heightDown

		DebugDraw.DrawIsoscelesTrapezoid(center, rot, startRadius, endRadius, distance, heightUp + heightDown, color, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
		local radius = unpack(shapeArgs)

		DebugDraw.DrawWireSphere(pos, color, radius, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_BOX then
		local len_x, len_y, len_z = unpack(shapeArgs)
		local extents = Vector3(len_x, len_y, len_z)

		DebugDraw.DrawBox(pos, rot, extents, color, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
		local radius, theta, heightUp, heightDown = unpack(shapeArgs)
		local center = pos:Clone()

		center.y = center.y - heightDown

		DebugDraw.DrawSector(center, rot, theta, radius, heightDown + heightUp, color, duration)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
		local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)
		local center = pos:Clone()

		center.y = center.y - heightDown

		DebugDraw.DrawAnnularSector(center, rot, theta, innerRadius, outerRadius, heightDown + heightUp, color, duration)
	end
end

function ClientDebugUtils.drawBoxSweep(startPos, rotation, boxExtendX, boxExtendY, boxExtendZ, sweepDistance, color, uid)
	if not ClientSwitch.EnableDrawAbilityGizmo then
		return false
	end

	startPos = startPos - Quaternion.MulVec3(rotation, Vector3.forward) * boxExtendZ * 0.5

	local startRadius = boxExtendX / 2
	local endRadius = startRadius
	local distance = boxExtendZ + sweepDistance
	local heightDown = boxExtendY / 2
	local heightUp = boxExtendY / 2

	if ClientSwitch.OnlyDrawLatestAttackBox and not string.isNilOrEmpty(uid) then
		ClientDebugUtils.drawUniqueDebugMesh(uid, startPos, rotation, AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D, {
			startRadius,
			endRadius,
			distance,
			heightDown,
			heightUp
		}, nil, color)
	else
		ClientDebugUtils.drawDebugMesh(startPos, rotation, AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D, {
			startRadius,
			endRadius,
			distance,
			heightDown,
			heightUp
		}, nil, color)
	end
end

return ClientDebugUtils
