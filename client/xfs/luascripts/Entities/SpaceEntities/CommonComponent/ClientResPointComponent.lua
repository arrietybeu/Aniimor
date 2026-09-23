-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientResPointComponent.lua

local Class = require("Core.Framework.Class")
local ResPoint = require("Common.AI.ResPoint.ResPoint")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local ResPointConst = require("Common.Const.ResPointConst")
local Const = require("Common.Const.Const")
local ClientResPointComponent = Class.Component("ClientResPointComponent")

function ClientResPointComponent:ctor()
	self.resPoints = {}
	self.resPointSyncInfo = nil
	self.ResPoint = {
		followTargetActorId = 0,
		followTargetIntegralValue = 0,
		followTargetLastDistance = 0,
		followTargetIndex = 0,
		followTargetPointId = 0,
		entityLastPos = Vector3.zero,
		virtualRotation = Quaternion.identity,
		followTargetPos = Vector3.zero
	}
end

function ClientResPointComponent:init(dict)
	self.resPointSyncInfo = dict.resPointSyncInfo
end

function ClientResPointComponent:_addResPoint(pointId, pointInfo)
	if pointId == nil then
		ResPointUtils.LogError("ClientResPointComponent._addResPoint failed, pointId is nil, actorId: %d", self.actorId)

		return
	end

	if self.resPoints[pointId] then
		ResPointUtils.LogError("ClientResPointComponent._addResPoint failed, resPoint already exist, actorId: %d, pointId: %d", self.actorId, pointId)

		return
	end

	local resPoint = ResPoint.new()

	resPoint:init(self, pointId, pointInfo)

	self.resPoints[pointId] = resPoint
end

function ClientResPointComponent:_removeAllResPoint()
	for _, resPoint in pairs(self.resPoints) do
		resPoint:destroy()
	end

	self.resPoints = {}
end

function ClientResPointComponent:onEnterSpace()
	if self.resPointSyncInfo == nil then
		return
	end

	for pointId, pointInfo in pairs(self.resPointSyncInfo) do
		self:_addResPoint(pointId, pointInfo)
	end
end

function ClientResPointComponent:onLeaveSpace()
	self:_removeAllResPoint()
end

function ClientResPointComponent:destroy()
	self:_removeAllResPoint()
end

function ClientResPointComponent:setFormationFollowActive(flag)
	if flag then
		if not self.ResPoint.virtualRotationCalcFunc then
			self.ResPoint.virtualRotationCalcFunc = CallbackHandler(self, "_updateFormationFollowRotation")
		end

		if not self.ResPoint.virtualRotationCalcTimer then
			self.ResPoint.entityLastPos:Copy(self:getPosition())
			self.ResPoint.virtualRotation:Copy(self:getRotation())

			self.ResPoint.virtualRotationCalcTimer = self:addLODRepeatTimer(self.ResPoint.virtualRotationCalcFunc)
		end
	elseif self.ResPoint.virtualRotationCalcTimer then
		self:removeLODTimer(self.ResPoint.virtualRotationCalcTimer)

		self.ResPoint.virtualRotationCalcTimer = nil
	end
end

function ClientResPointComponent:_updateFormationFollowRotation()
	local curPos = self:getPosition()
	local dx = curPos[1] - self.ResPoint.entityLastPos[1]
	local dz = curPos[3] - self.ResPoint.entityLastPos[3]
	local sqrHoriDist = dx * dx + dz * dz

	if sqrHoriDist < math.epsilon then
		return
	end

	Vector3.enableCreateFromCache()
	self.ResPoint.virtualRotation:Copy(Quaternion.Slerp(self.ResPoint.virtualRotation, self:getRotation(), ResPointConst.FormationRotationLerpParam))
	Vector3.disableCreateFromCache()
	self.ResPoint.entityLastPos:Copy(curPos)
end

function ClientResPointComponent:setFormationFollowTarget(targetActorId, targetPointId, followIndex)
	self.ResPoint.followTargetActorId = targetActorId
	self.ResPoint.followTargetPointId = targetPointId
	self.ResPoint.followTargetIndex = followIndex

	local point = ResPointUtils.GetResPointInEntity(targetActorId, targetPointId)

	point:getFormationFollowPointWorldPosition(followIndex, self.ResPoint.followTargetPos)

	self.ResPoint.followTargetLastDistance = Vector3.Distance(self:getPosition(), self.ResPoint.followTargetPos)
	self.ResPoint.followTargetLastSpeedRateType = BaseEnum.SpeedRateType.Mid
	self.ResPoint.followTargetIntegralValue = 0
end

function ClientResPointComponent:getFormationFollowTargetRotation()
	return self.ResPoint.virtualRotation
end

function ClientResPointComponent:getFormationFollowTargetPosAndSpeed(walkDist, sprintDist)
	local targetEntity = pg.getEntityByActorId(self.ResPoint.followTargetActorId)

	if not targetEntity then
		return
	end

	local point = ResPointUtils.GetResPointInEntity(self.ResPoint.followTargetActorId, self.ResPoint.followTargetPointId)

	point:getFormationFollowPointWorldPosition(self.ResPoint.followTargetIndex, self.ResPoint.followTargetPos)

	local dist = Vector3.Distance(self:getPosition(), self.ResPoint.followTargetPos)
	local deltaDist = dist - self.ResPoint.followTargetLastDistance
	local walkSpeed = AIControllerUtils.getWalkSpeed(self)
	local runSpeed = AIControllerUtils.getRunSpeed(self)
	local sprintSpeed = AIControllerUtils.getSprintSpeed(self)
	local unit = (sprintSpeed - walkSpeed) / math.max(sprintDist - walkDist, 0.01)
	local p = ResPointConst.FormationSpeedPropParam
	local i = ResPointConst.FormationSpeedInteParam
	local d = ResPointConst.FormationSpeedDiffParam
	local t = ResPointConst.FormationSpeedRateTypeTolerance
	local r = ResPointConst.FormationMaxSprintSpeedRatio
	local inteVal = self.ResPoint.followTargetIntegralValue
	local speed = walkSpeed + unit * (math.max(dist - walkDist, 0) * p + deltaDist * d + inteVal * i)

	speed = math.min(math.max(speed, 0), sprintSpeed * r)

	local speedRateType = self.ResPoint.followTargetLastSpeedRateType

	if self.ResPoint.followTargetLastSpeedRateType == BaseEnum.SpeedRateType.Slow then
		if speed > runSpeed + (sprintSpeed - runSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Fast
		elseif speed > walkSpeed + (runSpeed - walkSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Mid
		end
	elseif self.ResPoint.followTargetLastSpeedRateType == BaseEnum.SpeedRateType.Mid then
		if speed > runSpeed + (sprintSpeed - runSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Fast
		elseif speed < runSpeed - (runSpeed - walkSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Slow
		end
	elseif self.ResPoint.followTargetLastSpeedRateType == BaseEnum.SpeedRateType.Fast then
		if speed < runSpeed - (runSpeed - walkSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Slow
		elseif speed < sprintSpeed - (sprintSpeed - runSpeed) * t then
			speedRateType = BaseEnum.SpeedRateType.Mid
		end
	end

	self.ResPoint.followTargetLastDistance = dist
	self.ResPoint.followTargetLastSpeedRateType = speedRateType

	local integralValue = self.ResPoint.followTargetIntegralValue + math.clamp(dist, 0, ResPointConst.FormationSpeedInteRelativeDist * 2) - ResPointConst.FormationSpeedInteRelativeDist

	integralValue = math.clamp(integralValue, 0, ResPointConst.FormationSpeedInteMax)
	self.ResPoint.followTargetIntegralValue = integralValue

	return self.ResPoint.followTargetPos, speed, speedRateType
end

return ClientResPointComponent
