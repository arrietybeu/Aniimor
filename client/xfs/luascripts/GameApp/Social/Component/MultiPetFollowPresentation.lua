-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\MultiPetFollowPresentation.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local MultiPetFollowPresentation = Class.LiteClass("MultiPetFollowPresentation")

MultiPetFollowPresentation.POSITION_EPSILON_SQR = 1e-06
MultiPetFollowPresentation.ROTATION_DOT_EPSILON = 1e-05
MultiPetFollowPresentation.TRAIL_POINT_EPSILON_SQR = 0.0004
MultiPetFollowPresentation.TRAIL_KEEP_EXTRA_DISTANCE = 2

function MultiPetFollowPresentation:isSamePosition(value, x, y, z)
	if not value or x == nil then
		return false
	end

	local deltaX = value.x - x
	local deltaY = value.y - y
	local deltaZ = value.z - z

	return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ <= self.POSITION_EPSILON_SQR
end

function MultiPetFollowPresentation:isSameRotation(value, x, y, z, w)
	if not value or x == nil then
		return false
	end

	local dot = value.x * x + value.y * y + value.z * z + value.w * w

	return math.abs(1 - math.abs(dot)) <= self.ROTATION_DOT_EPSILON
end

function MultiPetFollowPresentation:saveBaseTransform(override, position, rotation)
	override.basePositionX = position.x
	override.basePositionY = position.y
	override.basePositionZ = position.z
	override.baseRotationX = rotation.x
	override.baseRotationY = rotation.y
	override.baseRotationZ = rotation.z
	override.baseRotationW = rotation.w
end

function MultiPetFollowPresentation:saveAppliedTransform(override, position, rotation)
	override.appliedPositionX = position.x
	override.appliedPositionY = position.y
	override.appliedPositionZ = position.z
	override.appliedRotationX = rotation.x
	override.appliedRotationY = rotation.y
	override.appliedRotationZ = rotation.z
	override.appliedRotationW = rotation.w
end

function MultiPetFollowPresentation:getModelRoot(ent)
	local eModel = ent and ent.eModel
	local skeletonView = eModel and eModel.modelSkeletonView or nil
	local skeletonRoot = NotNil(skeletonView) and skeletonView.skeletonRoot or nil

	if NotNil(skeletonRoot) then
		return skeletonRoot
	end

	local modelRoot = eModel and eModel.modelRoot or nil

	return NotNil(modelRoot) and modelRoot or nil
end

function MultiPetFollowPresentation:getAgentDisplayTransform(ent)
	local eModel = ent and ent.eModel

	if not eModel then
		return nil, nil
	end

	local positionX, positionY, positionZ = eModel:GetPositionAgentPosEx()
	local _, yaw = eModel:GetPositionAgentEulerEx()

	return Vector3.New(positionX, positionY, positionZ), Quaternion.Euler(0, yaw, 0)
end

function MultiPetFollowPresentation:getPositionSqrDistance(positionA, positionB)
	local deltaX = positionA.x - positionB.x
	local deltaY = positionA.y - positionB.y
	local deltaZ = positionA.z - positionB.z

	return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
end

function MultiPetFollowPresentation:newTrailPoint(position, rotation, distance)
	return {
		x = position.x,
		y = position.y,
		z = position.z,
		rotation = rotation,
		distance = distance or 0
	}
end

function MultiPetFollowPresentation:getPointPosition(point)
	return Vector3.New(point.x, point.y, point.z)
end

function MultiPetFollowPresentation:getPointForwardRotation(fromPoint, toPoint, fallbackRotation)
	local deltaX = toPoint.x - fromPoint.x
	local deltaZ = toPoint.z - fromPoint.z
	local sqrDistance = deltaX * deltaX + deltaZ * deltaZ

	if sqrDistance <= self.POSITION_EPSILON_SQR then
		return fallbackRotation
	end

	return Quaternion.LookRotation(Vector3.New(deltaX, 0, deltaZ), Vector3.up)
end

function MultiPetFollowPresentation:getStraightMemberTransform(creatorPosition, creatorRotation, memberIndex)
	local stepOffset = Quaternion.MulVec3(creatorRotation, self.localStepOffset)

	return Vector3.New(creatorPosition.x + stepOffset.x * memberIndex, creatorPosition.y + stepOffset.y * memberIndex, creatorPosition.z + stepOffset.z * memberIndex), creatorRotation
end

function MultiPetFollowPresentation:isValidTrainAction(action, creatorUid)
	return action and action.actionId and action.actionId > 0 and action.petPrototypeId and action.petPrototypeId > 0 and action.start_ts and action.start_ts > 0 and action.creatorId == creatorUid
end

function MultiPetFollowPresentation:isMatchingMemberAction(memberAction, creatorAction, creatorUid)
	return memberAction and memberAction.actionId == creatorAction.actionId and memberAction.creatorId == creatorUid and memberAction.start_ts == creatorAction.start_ts and memberAction.petPrototypeId and memberAction.petPrototypeId > 0
end

function MultiPetFollowPresentation:ctor(followDistance)
	self.followDistance = followDistance
	self.localStepOffset = Vector3.New(0, 0, -followDistance)
	self.frameId = 0
	self.overrides = {}
	self.claimedUids = {}
	self.trails = {}
	self.activeTrailUids = {}
end

function MultiPetFollowPresentation:getTrail(creatorUid, action)
	local trail = self.trails[creatorUid]

	if not trail or trail.actionId ~= action.actionId or trail.start_ts ~= action.start_ts or trail.creatorId ~= creatorUid then
		trail = {
			totalDistance = 0,
			actionId = action.actionId,
			start_ts = action.start_ts,
			creatorId = creatorUid,
			points = {}
		}
		self.trails[creatorUid] = trail
	end

	return trail
end

function MultiPetFollowPresentation:appendTrailPoint(trail, position, rotation)
	local points = trail.points
	local count = #points

	if count <= 0 then
		local point = self:newTrailPoint(position, rotation, 0)

		table.insert(points, point)

		trail.totalDistance = point.distance

		return
	end

	local lastPoint = points[count]
	local lastPosition = self:getPointPosition(lastPoint)
	local sqrDistance = self:getPositionSqrDistance(position, lastPosition)

	if sqrDistance <= self.TRAIL_POINT_EPSILON_SQR then
		lastPoint.rotation = rotation

		return
	end

	local point = self:newTrailPoint(position, rotation, lastPoint.distance + math.sqrt(sqrDistance))

	table.insert(points, point)

	trail.totalDistance = point.distance
end

function MultiPetFollowPresentation:trimTrail(trail, keepDistance)
	local points = trail.points
	local minDistance = trail.totalDistance - keepDistance

	while #points > 2 and minDistance > points[2].distance do
		table.remove(points, 1)
	end
end

function MultiPetFollowPresentation:refreshTrail(creatorUid, action, position, rotation, memberCount)
	local trail = self:getTrail(creatorUid, action)

	self.activeTrailUids[creatorUid] = true

	self:appendTrailPoint(trail, position, rotation)
	self:trimTrail(trail, self.followDistance * (memberCount + 1) + self.TRAIL_KEEP_EXTRA_DISTANCE)

	return trail
end

function MultiPetFollowPresentation:sampleTrail(trail, targetDistance, fallbackRotation)
	local points = trail and trail.points
	local count = points and #points or 0

	if count <= 0 then
		return nil, nil
	end

	if targetDistance < points[1].distance then
		return nil, nil
	end

	if count == 1 or targetDistance >= points[count].distance then
		local point = points[count]

		return self:getPointPosition(point), point.rotation or fallbackRotation
	end

	for index = 2, count do
		local curPoint = points[index]

		if targetDistance <= curPoint.distance then
			local prevPoint = points[index - 1]
			local segmentDistance = curPoint.distance - prevPoint.distance

			if segmentDistance <= 0 then
				return self:getPointPosition(curPoint), curPoint.rotation or fallbackRotation
			end

			local ratio = (targetDistance - prevPoint.distance) / segmentDistance
			local position = Vector3.New(prevPoint.x + (curPoint.x - prevPoint.x) * ratio, prevPoint.y + (curPoint.y - prevPoint.y) * ratio, prevPoint.z + (curPoint.z - prevPoint.z) * ratio)
			local rotation = self:getPointForwardRotation(prevPoint, curPoint, curPoint.rotation or fallbackRotation)

			return position, rotation
		end
	end

	return nil, nil
end

function MultiPetFollowPresentation:getSnakeMemberTransform(creatorUid, action, creatorPosition, creatorRotation, memberIndex, memberCount)
	local trail = self:refreshTrail(creatorUid, action, creatorPosition, creatorRotation, memberCount)
	local targetDistance = trail.totalDistance - self.followDistance * memberIndex
	local position, rotation = self:sampleTrail(trail, targetDistance, creatorRotation)

	if position and rotation then
		return position, rotation
	end

	return self:getStraightMemberTransform(creatorPosition, creatorRotation, memberIndex)
end

function MultiPetFollowPresentation:restoreOverride(override)
	local modelRoot = override and override.modelRoot

	if not NotNil(modelRoot) then
		return
	end

	local owner = override.actorId and pg.getEntityByActorId(override.actorId)

	if not owner or self:getModelRoot(owner) ~= modelRoot then
		return
	end

	local localPosition = modelRoot.localPosition
	local localRotation = modelRoot.localRotation

	if self:isSamePosition(localPosition, override.appliedPositionX, override.appliedPositionY, override.appliedPositionZ) and self:isSameRotation(localRotation, override.appliedRotationX, override.appliedRotationY, override.appliedRotationZ, override.appliedRotationW) then
		modelRoot.localPosition = Vector3.New(override.basePositionX, override.basePositionY, override.basePositionZ)
		modelRoot.localRotation = Quaternion.New(override.baseRotationX, override.baseRotationY, override.baseRotationZ, override.baseRotationW)
	end
end

function MultiPetFollowPresentation:getOverride(uid, ent, modelRoot)
	local override = self.overrides[uid]

	if override and (override.actorId ~= ent.actorId or override.modelRoot ~= modelRoot) then
		self:restoreOverride(override)

		override = nil
	end

	local localPosition = modelRoot.localPosition
	local localRotation = modelRoot.localRotation

	if not override then
		override = {
			actorId = ent.actorId,
			modelRoot = modelRoot
		}

		self:saveBaseTransform(override, localPosition, localRotation)

		self.overrides[uid] = override
	elseif not self:isSamePosition(localPosition, override.appliedPositionX, override.appliedPositionY, override.appliedPositionZ) or not self:isSameRotation(localRotation, override.appliedRotationX, override.appliedRotationY, override.appliedRotationZ, override.appliedRotationW) then
		self:saveBaseTransform(override, localPosition, localRotation)
	end

	return override
end

function MultiPetFollowPresentation:applyMember(uid, ent, position, rotation)
	local modelRoot = self:getModelRoot(ent)

	if not modelRoot then
		return
	end

	local override = self:getOverride(uid, ent, modelRoot)

	modelRoot:SetPositionAndRotation(position, rotation)
	self:saveAppliedTransform(override, modelRoot.localPosition, modelRoot.localRotation)

	override.frameId = self.frameId
end

function MultiPetFollowPresentation:getMemberDisplayTransform(creatorUid, memberUid, memberIndex)
	if not creatorUid or not memberUid or not memberIndex or memberIndex <= 0 then
		return nil, nil
	end

	local creator = pg.getEntityByUid(creatorUid)
	local member = pg.getEntityByUid(memberUid)
	local action = creator and creator.multiInteractAction
	local memberAction = member and member.multiInteractAction
	local memberIds = action and action.memberIds

	if not creator or not member or not self:isValidTrainAction(action, creatorUid) or not self:isMatchingMemberAction(memberAction, action, creatorUid) or not memberIds or memberIds[memberIndex] ~= memberUid then
		return nil, nil
	end

	local creatorPosition, creatorRotation = self:getAgentDisplayTransform(creator)

	if not creatorPosition then
		return nil, nil
	end

	return self:getSnakeMemberTransform(creatorUid, action, creatorPosition, creatorRotation, memberIndex, #memberIds)
end

function MultiPetFollowPresentation:applyTrain(creatorUid, creator, action, claimedUids)
	local memberIds = action.memberIds or {}
	local creatorPosition, creatorRotation = self:getAgentDisplayTransform(creator)

	if not creatorPosition then
		return
	end

	self:refreshTrail(creatorUid, action, creatorPosition, creatorRotation, #memberIds)

	for index, uid in ipairs(memberIds) do
		if uid ~= creatorUid and not claimedUids[uid] then
			local ent = pg.getEntityByUid(uid)
			local memberAction = ent and ent.multiInteractAction

			if ent and self:isMatchingMemberAction(memberAction, action, creatorUid) then
				claimedUids[uid] = true

				local displayPosition, displayRotation = self:getSnakeMemberTransform(creatorUid, action, creatorPosition, creatorRotation, index, #memberIds)

				self:applyMember(uid, ent, displayPosition, displayRotation)
			end
		end
	end
end

function MultiPetFollowPresentation:tick(multiInteractionSessions)
	self.frameId = self.frameId + 1

	local claimedUids = self.claimedUids

	for uid in pairs(claimedUids) do
		claimedUids[uid] = nil
	end

	for creatorUid in pairs(multiInteractionSessions or EMPTY_TABLE) do
		local creator = pg.getEntityByUid(creatorUid)
		local action = creator and creator.multiInteractAction

		if creator and self:isValidTrainAction(action, creatorUid) then
			self:applyTrain(creatorUid, creator, action, claimedUids)
		end
	end

	for uid in pairs(self.trails) do
		if not self.activeTrailUids[uid] then
			self.trails[uid] = nil
		end

		self.activeTrailUids[uid] = nil
	end

	for uid, override in pairs(self.overrides) do
		if override.frameId ~= self.frameId then
			self:restoreOverride(override)

			self.overrides[uid] = nil
		end
	end
end

function MultiPetFollowPresentation:clear()
	for uid, override in pairs(self.overrides) do
		self:restoreOverride(override)

		self.overrides[uid] = nil
	end

	for uid in pairs(self.trails) do
		self.trails[uid] = nil
	end
end

return MultiPetFollowPresentation
