-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IResPointComponent.lua

local Class = require("Core.Framework.Class")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ResPointConst = require("Common.Const.ResPointConst")
local AiConst = require("Common.Const.AiConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Utils = require("Common.Utils.Utils")
local enums = require("Common.AI.Behaviac.Enums")
local EBTStatus = enums.EBTStatus
local IResPointComponent = Class.Component("IResPointComponent")

function IResPointComponent:moveToResPointPort__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	self.x_moveToResPointPort_targetPos = nil

	self:_removeCustomTimeout("moveToResPointPort_repath")
end

function IResPointComponent:moveToResPointPort(fixPointId, portId, timeout, speedRateType, speed, useAccurateArrive)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)
	local isRepath = false

	if self.x_moveToResPointPort_targetPos == nil then
		local dirDescId = ResPointUtils.GetPreJoinPortDirDescId(self.ent.actorId, actorId, pointId, portId)
		local pos, _ = ResPointUtils.GetNearestInteractPosition(self.ent.actorId, actorId, pointId, portId, dirDescId)

		if pos and dirDescId then
			self.x_moveToResPointPort_targetPos = pos

			if not point.isStatic then
				self:_settingCustomTimeout("moveToResPointPort_repath", ResPointConst.DynamicPointRepathCd)
			end
		end
	end

	if self:_checkCustomTimeoutExist("moveToResPointPort_repath") and self:_checkCustomTimeout("moveToResPointPort_repath") then
		local dirDescId = ResPointUtils.GetPreJoinPortDirDescId(self.ent.actorId, actorId, pointId, portId)
		local pos, _ = ResPointUtils.GetNearestInteractPosition(self.ent.actorId, actorId, pointId, portId, dirDescId)

		if pos and dirDescId then
			isRepath = true
			self.x_moveToResPointPort_targetPos = pos

			self:_settingCustomTimeout("moveToResPointPort_repath", ResPointConst.DynamicPointRepathCd)
		end
	end

	local status = self.moveAbility:moveToPos(self.x_moveToResPointPort_targetPos, timeout, true, 0, speedRateType, speed, nil, isRepath, useAccurateArrive)

	if status == EBTStatus.BT_SUCCESS then
		local canInteract = ResPointUtils.CheckCanInteract(self.ent.actorId, actorId, pointId, portId)

		if not canInteract then
			status = EBTStatus.BT_FAILURE
		end
	end

	if status ~= EBTStatus.BT_RUNNING then
		ResPointUtils.Log(self.ent.actorId, "IResPointComponent.moveToResPointPort fixPointId: %s, portId: %d, timeout: %f, speedRateType: %d, speed: %f, result: %s", fixPointId, portId, timeout, speedRateType, speed, enums.EBTStatusName[status])
	end

	return status
end

function IResPointComponent:moveToResPointPortInDist__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	self.x_moveToResPointPortInDist_targetPos = nil

	self:_removeCustomTimeout("moveToResPointPortInDist_repath")
end

function IResPointComponent:moveToResPointPortInDist(fixPointId, portId, timeout, speedRateType, speed, interactDist, ignoreSelfBodySize, ignorePointBodySize, useAccurateArrive)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)
	local isRepath = false

	if self.x_moveToResPointPortInDist_targetPos == nil then
		local dirDescId = ResPointUtils.GetPreJoinPortDirDescId(self.ent.actorId, actorId, pointId, portId)
		local pos, _ = ResPointUtils.GetNearestInteractPositionInDist(self.ent.actorId, actorId, pointId, portId, dirDescId, interactDist, ignoreSelfBodySize, ignorePointBodySize)

		if pos and dirDescId then
			self.x_moveToResPointPortInDist_targetPos = pos

			if not point.isStatic then
				self:_settingCustomTimeout("moveToResPointPortInDist_repath", ResPointConst.DynamicPointRepathCd)
			end
		end
	end

	if self:_checkCustomTimeoutExist("moveToResPointPortInDist_repath") and self:_checkCustomTimeout("moveToResPointPortInDist_repath") then
		local dirDescId = ResPointUtils.GetPreJoinPortDirDescId(self.ent.actorId, actorId, pointId, portId)
		local pos, _ = ResPointUtils.GetNearestInteractPositionInDist(self.ent.actorId, actorId, pointId, portId, dirDescId, interactDist, ignoreSelfBodySize, ignorePointBodySize)

		if pos and dirDescId then
			isRepath = true
			self.x_moveToResPointPortInDist_targetPos = pos

			self:_settingCustomTimeout("moveToResPointPortInDist_repath", ResPointConst.DynamicPointRepathCd)
		end
	end

	local status = self.moveAbility:moveToPos(self.x_moveToResPointPortInDist_targetPos, timeout, true, 0, speedRateType, speed, nil, isRepath, useAccurateArrive)

	if status == EBTStatus.BT_SUCCESS then
		local canInteract = ResPointUtils.CheckCanInteract(self.ent.actorId, actorId, pointId, portId)

		if not canInteract then
			status = EBTStatus.BT_FAILURE
		end
	end

	if status ~= EBTStatus.BT_RUNNING then
		ResPointUtils.Log(self.ent.actorId, "IResPointComponent.moveToResPointPortInDist fixPointId: %s, portId: %d, timeout: %f, speedRateType: %d, speed: %f, interactDist: %f, ignoreSelfBodySize: %s, ignorePointBodySize: %s, result: %s", fixPointId, portId, timeout, speedRateType, speed, interactDist, ignoreSelfBodySize, ignorePointBodySize, enums.EBTStatusName[status])
	end

	return status
end

function IResPointComponent:turnToResPointPort__resetState(resetStateType)
	self:turnToYaw__resetState(resetStateType)

	self.x_turnToResPointPort_targetYaw = nil
end

function IResPointComponent:turnToResPointPort(fixPointId, portId, useTurnAnim, timeout)
	if self.x_turnToResPointPort_targetYaw == nil then
		local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)

		self.x_turnToResPointPort_targetYaw = ResPointUtils.GetInteractDirectionYaw(self.ent.actorId, actorId, pointId, portId)
	end

	if self.x_turnToResPointPort_targetYaw == nil then
		return EBTStatus.BT_SUCCESS
	end

	return self:turnToYaw(self.x_turnToResPointPort_targetYaw, useTurnAnim, timeout)
end

function IResPointComponent:getDistanceFromEntityToResPointPort(entityActorId, resPointPortTab)
	entityActorId = entityActorId == 0 and self.ent.actorId or entityActorId

	local ent = pg.getEntityByActorId(entityActorId)
	local actorId, pointId = ResPointUtils.FromFixPointId(resPointPortTab[1])
	local portId = resPointPortTab[2]
	local resPointPort = ResPointUtils.GetPortInResPoint(actorId, pointId, portId)

	if ent and resPointPort then
		return Vector3.Distance(ent:getPosition(), resPointPort:getWorldPosition())
	end

	return -1
end

function IResPointComponent:getEntityIdByResPointId(fixPointId)
	local actorId, _ = ResPointUtils.FromFixPointId(fixPointId)

	return actorId
end

function IResPointComponent:getResPointPortPosition(fixPointId, portId)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)

	if portId <= 0 then
		local resPoint = ResPointUtils.GetResPointInEntity(actorId, pointId)

		return resPoint:getWorldPosition()
	else
		local resPointPort = ResPointUtils.GetPortInResPoint(actorId, pointId, portId)

		return resPointPort:getWorldPosition()
	end
end

function IResPointComponent:getClimbDataIdFromResPoint(fixPointId)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)

	return ResPointUtils.GetClimbDataIdFromResPoint(actorId, pointId)
end

function IResPointComponent:checkHasFormation(targetActorId)
	local resPoint = ResPointUtils.GetResPointInEntity(targetActorId, ResPointConst.FormationPointIndex)

	return resPoint ~= nil
end

function IResPointComponent:followTargetWithFormation__resetState(resetStateType)
	self.moveAbility:resetFollowTargetByRelativePos(resetStateType)

	if self.x_followTargetWithFormation_actorId then
		ResPointUtils.ExitFormationFollow(self.ent.actorId, self.x_followTargetWithFormation_actorId)

		self.x_followTargetWithFormation_actorId = nil

		self:_removeCustomTimeout("followTargetWithFormation")
	end
end

function IResPointComponent:followTargetWithFormation(targetActorId, maxTime, stopDist, walkDist, sprintDist)
	if not Utils.checkClient() then
		return EBTStatus.BT_FAILURE
	end

	if not self.x_followTargetWithFormation_actorId then
		local ret = ResPointUtils.JoinFormationFollow(self.ent.actorId, targetActorId)

		if not ret then
			return EBTStatus.BT_FAILURE
		end

		self.x_followTargetWithFormation_actorId = targetActorId

		if maxTime > 0 then
			self:_settingCustomTimeout("followTargetWithFormation", maxTime)
		end
	end

	if self:_checkCustomTimeoutExist("followTargetWithFormation") and self:_checkCustomTimeout("followTargetWithFormation") then
		return EBTStatus.BT_FAILURE
	end

	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return EBTStatus.BT_FAILURE
	end

	local targetPos, targetSpeed, targetSpeedRateType = self.ent:getFormationFollowTargetPosAndSpeed(walkDist, sprintDist)

	self.moveAbility:moveToPos(targetPos, AiConst.MOVE_CD, true, stopDist, targetSpeedRateType, targetSpeed, AutoPathFindUtils.PathFindType.Voxel, true, false)

	return EBTStatus.BT_RUNNING
end

return IResPointComponent
