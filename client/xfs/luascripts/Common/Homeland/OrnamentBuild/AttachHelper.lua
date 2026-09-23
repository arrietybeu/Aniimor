-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\OrnamentBuild\\AttachHelper.lua

local Class = require("Core.Framework.Class")
local HomelandConfigData = require("Data.homeland_config_data")
local BuildConst = require("Common.Homeland.OrnamentBuild.BuildConst")
local AttachHelper = {}

AttachHelper.emptyTable = {}
AttachHelper.DEFAULT_ATTACH_DISTANCE_XZ = 0.5
AttachHelper.DEFAULT_ATTACH_DISTANCE_Y = 0.5

function AttachHelper.checkAttachTypeMatch(attachType, attachPlaneType)
	local OrnamentAttachType = BuildConst.OrnamentAttachType
	local AttachPlaneType = BuildConst.AttachPlaneType

	if attachType == OrnamentAttachType.None or attachPlaneType == AttachPlaneType.None then
		return false
	end

	if attachType == OrnamentAttachType.Up then
		return attachPlaneType == AttachPlaneType.Up
	elseif attachType == OrnamentAttachType.Down then
		return attachPlaneType == AttachPlaneType.Down
	elseif attachType == OrnamentAttachType.Wall then
		return attachPlaneType == AttachPlaneType.Front or attachPlaneType == AttachPlaneType.Back or attachPlaneType == AttachPlaneType.Left or attachPlaneType == AttachPlaneType.Right
	elseif attachType == OrnamentAttachType.Slope then
		return attachPlaneType == AttachPlaneType.Slope
	end

	return false
end

function AttachHelper.getPlaneRotation(attachPlaneType, baseRotation, configNormal)
	local AttachPlaneType = BuildConst.AttachPlaneType
	local localNormal, localDepth

	if attachPlaneType == AttachPlaneType.Up then
		localNormal, localDepth = Vector3.constUp, Vector3.constForward
	elseif attachPlaneType == AttachPlaneType.Down then
		localNormal, localDepth = Vector3.constDown, Vector3.constForward
	elseif attachPlaneType == AttachPlaneType.Front then
		localNormal, localDepth = Vector3.constForward, Vector3.constUp
	elseif attachPlaneType == AttachPlaneType.Back then
		localNormal, localDepth = Vector3.constBack, Vector3.constUp
	elseif attachPlaneType == AttachPlaneType.Right then
		localNormal, localDepth = Vector3.constRight, Vector3.constUp
	elseif attachPlaneType == AttachPlaneType.Left then
		localNormal, localDepth = Vector3.constLeft, Vector3.constUp
	elseif attachPlaneType == AttachPlaneType.Slope then
		if not configNormal then
			return baseRotation
		end

		localNormal = Vector3.New(configNormal[1], configNormal[2], configNormal[3])

		if localNormal:Magnitude() < 1e-05 then
			return baseRotation
		end

		localNormal:SetNormalize()

		local ref = Vector3.constForward

		if math.abs(Vector3.Dot(Vector3.constUp, localNormal)) < math.abs(Vector3.Dot(ref, localNormal)) then
			ref = Vector3.constUp
		end

		localDepth = ref - localNormal * Vector3.Dot(ref, localNormal)

		localDepth:SetNormalize()
	else
		return baseRotation
	end

	local worldNormal = Quaternion.MulVec3(baseRotation, localNormal)
	local worldDepth = Quaternion.MulVec3(baseRotation, localDepth)

	return Quaternion.LookRotation(worldDepth, worldNormal)
end

function AttachHelper.tryAttachPlane(attachPlaneType, planeCenter, planeRotation, planeWidth, planeHeight, ornamentAttachRootPosition, ornamentRotation, buildExtraConfig)
	buildExtraConfig = buildExtraConfig or AttachHelper.emptyTable

	if not planeWidth or not planeHeight then
		return false
	end

	local planeNormal = Quaternion.MulVec3(planeRotation, Vector3.constUp)
	local yAttachRatio = 1
	local xzAttachRatio = 1
	local AttachPlaneType = BuildConst.AttachPlaneType
	local rotDot
	local projectSourcePos = ornamentAttachRootPosition

	if attachPlaneType == AttachPlaneType.Up then
		rotDot = Vector3.Dot(Quaternion.MulVec3(ornamentRotation, Vector3.constUp), planeNormal)
		xzAttachRatio = 0.5
	elseif attachPlaneType == AttachPlaneType.Down then
		rotDot = -Vector3.Dot(Quaternion.MulVec3(ornamentRotation, Vector3.constUp), planeNormal)
		xzAttachRatio = 0.5
	elseif attachPlaneType == AttachPlaneType.Slope then
		rotDot = Vector3.Dot(Quaternion.MulVec3(ornamentRotation, Vector3.constUp), Vector3.constUp)
		xzAttachRatio = 0.5

		local denom = planeNormal.y

		if math.abs(denom) < 1e-05 then
			return false
		end

		local t = Vector3.Dot(planeCenter - ornamentAttachRootPosition, planeNormal) / denom

		projectSourcePos = Vector3.New(ornamentAttachRootPosition.x, ornamentAttachRootPosition.y + t, ornamentAttachRootPosition.z)
	else
		rotDot = Vector3.Dot(Quaternion.MulVec3(ornamentRotation, Vector3.constForward), planeNormal)
		yAttachRatio = 0.5
	end

	local rotationDotThreshold = buildExtraConfig.rotationDotThreshold or 0.95

	if rotDot < rotationDotThreshold then
		return false
	end

	local offset = projectSourcePos - planeCenter
	local invRotation = Quaternion.Inverse(planeRotation)
	local localOffset = Quaternion.MulVec3(invRotation, offset)
	local halfWidth = planeWidth * 0.5
	local halfHeight = planeHeight * 0.5
	local localX = math.clamp(localOffset.x, -halfWidth, halfWidth)
	local localZ = math.clamp(localOffset.z, -halfHeight, halfHeight)
	local clampedLocal = Vector3.New(localX, 0, localZ)
	local worldOffset = Quaternion.MulVec3(planeRotation, clampedLocal)
	local attachPosition = planeCenter + worldOffset
	local moveDelta = attachPosition - ornamentAttachRootPosition
	local yAttachDistance = (buildExtraConfig.yAttachDistance or HomelandConfigData.attachDistanceY or AttachHelper.DEFAULT_ATTACH_DISTANCE_Y) * yAttachRatio

	if yAttachDistance < math.abs(moveDelta.y) then
		return false
	end

	local xzAttachDistance = (buildExtraConfig.xzAttachDistance or HomelandConfigData.attachDistanceXZ or AttachHelper.DEFAULT_ATTACH_DISTANCE_XZ) * xzAttachRatio

	if xzAttachDistance < math.abs(moveDelta.x) or xzAttachDistance < math.abs(moveDelta.z) then
		return false
	end

	return true, attachPosition, ornamentRotation, moveDelta
end

return AttachHelper
