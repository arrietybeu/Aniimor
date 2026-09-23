-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\Utils\\EModelUtils.lua

local Const = require("Common.Const.Const")
local AgentTransformReasonConst = Const.AgentTransformReasonConst
local EModelUtils = {}

function EModelUtils.setMotionRotation(entity, rotation, instant)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:SetRotation(Const.COMPONENT_MOTION, rotation, instant) or false
end

function EModelUtils.setMotionRotationXYZW(entity, rotX, rotY, rotZ, rotW, instant)
	if not entity or not entity.eModel then
		return false
	end

	entity.eModel:SetRotation(Const.COMPONENT_MOTION, rotX, rotY, rotZ, rotW, instant)

	return true
end

function EModelUtils.setAgentRotation(entity, rotation, instant, transformReason)
	if not entity or not entity.eModel then
		return false
	end

	if instant == nil then
		instant = true
	end

	entity.eModel:SetAgentRotationEx(rotation[1], rotation[2], rotation[3], rotation[4], instant, transformReason or AgentTransformReasonConst.LogicFromLua)

	if instant then
		entity:onSyncRot(rotation[1], rotation[2], rotation[3], rotation[4])
	end

	return true
end

function EModelUtils.setAgentRotationXYZW(entity, x, y, z, w, instant, transformReason)
	if not entity or not entity.eModel then
		return false
	end

	if instant == nil then
		instant = true
	end

	entity.eModel:SetAgentRotationEx(x, y, z, w, instant, transformReason or AgentTransformReasonConst.LogicFromLua)

	if instant then
		entity:onSyncRot(x, y, z, w)
	end

	return true
end

function EModelUtils.setAgentPositionAndRotation(entity, position, rotation, instant, transformReason)
	if not entity or not entity.eModel then
		return false
	end

	if instant == nil then
		instant = true
	end

	entity.eModel:SetAgentPositionAndRotationEx(position[1], position[2], position[3], rotation[1], rotation[2], rotation[3], rotation[4], instant, transformReason or AgentTransformReasonConst.LogicFromLua)
	entity:onSyncPos(position[1], position[2], position[3])

	if instant then
		entity:onSyncRot(rotation[1], rotation[2], rotation[3], rotation[4])
	end

	return true
end

function EModelUtils.setAgentPosition(entity, position, transformReason)
	if not entity or not entity.eModel then
		return false
	end

	entity.eModel:SetAgentPositionEx(position[1], position[2], position[3], transformReason or AgentTransformReasonConst.LogicFromLua)
	entity:onSyncPos(position[1], position[2], position[3])

	return true
end

function EModelUtils.setAgentPositionXYZ(entity, x, y, z, transformReason)
	if not entity or not entity.eModel then
		return false
	end

	entity.eModel:SetAgentPositionEx(x, y, z, transformReason or AgentTransformReasonConst.LogicFromLua)
	entity:onSyncPos(x, y, z)

	return true
end

function EModelUtils.setMotionPositionByNumber(entity, positionX, positionY, positionZ, instant)
	if not entity or not entity.eModel then
		return false
	end

	instant = instant == nil and true or instant

	return entity.eModel:SetPosition(Const.COMPONENT_MOTION, positionX, positionY, positionZ, instant) or false
end

function EModelUtils.setMotionDisplacementOffset(entity, offset, isWorld)
	if not entity or not entity.eModel then
		return false
	end

	isWorld = isWorld == nil and true or isWorld

	return entity.eModel:SetMotionDisplacementOffset(Const.COMPONENT_MOTION, offset, isWorld) or false
end

function EModelUtils.setDisplacementVelocitySource(entity, source, velocity, isWorld, resetTargetVelocity)
	if not entity or not entity.eModel then
		return false
	end

	isWorld = isWorld == nil and true or isWorld

	return entity.eModel:SetDisplacementVelocitySource(Const.COMPONENT_MOTION, source, velocity, isWorld, resetTargetVelocity or false) or false
end

function EModelUtils.setDisplacementVelocitySourceByOffset(entity, source, offset, deltaSeconds, isWorld, resetTargetVelocity)
	if not entity or not entity.eModel then
		return false
	end

	if not entity.hasEModelComponent or not entity:hasEModelComponent(Const.COMPONENT_MOTION) then
		isWorld = isWorld == nil and true or isWorld

		entity.eModel:SetDisplacementOffsetEx(offset[1], offset[2], offset[3], isWorld)

		return true
	end

	if deltaSeconds == nil or deltaSeconds <= 0 then
		return EModelUtils.clearDisplacementVelocitySource(entity, source)
	end

	return EModelUtils.setDisplacementVelocitySource(entity, source, offset / deltaSeconds, isWorld, resetTargetVelocity)
end

function EModelUtils.clearDisplacementVelocitySource(entity, source)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, source) or false
end

function EModelUtils.setMotionDirection(entity, direction, instant)
	if not entity or not entity.eModel then
		return false
	end

	if instant == nil then
		instant = false
	end

	return entity.eModel:SetDirection(Const.COMPONENT_MOTION, direction, instant) or false
end

function EModelUtils.setMotionYaw(entity, yawDeg, instant)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:SetYaw(Const.COMPONENT_MOTION, yawDeg, instant) or false
end

function EModelUtils.setMotionTargetRotation(entity, targetRotation)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:SetTargetRotation(Const.COMPONENT_MOTION, targetRotation) or false
end

function EModelUtils.clearAllVelocity(entity)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:ClearAllVelocity(Const.COMPONENT_MOTION) or false
end

function EModelUtils.clearDisplacementVelocity(entity)
	if not entity or not entity.eModel then
		return false
	end

	return entity.eModel:ClearDisplacementVelocity(Const.COMPONENT_MOTION) or false
end

return EModelUtils
