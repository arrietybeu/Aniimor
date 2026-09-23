-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IFlyComponent.lua

local class = require("Core.Framework.Class")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CalcUtils = require("Common.Utils.CalcUtils")
local enums = require("Common.AI.Behaviac.Enums")
local AiConst = require("Common.Const.AiConst")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local ListPool = require("Common.Container.ListPool")
local VectorPool = require("Common.Container.VectorPool")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Utils = require("Common.Utils.Utils")
local EBTStatus = enums.EBTStatus
local string_notNilOrEmpty = string.notNilOrEmpty
local IFlyComponent = class.Component("IFlyComponent")

function IFlyComponent:checkIsFlying(targetActorId)
	local tgtEnt = (targetActorId == nil or targetActorId == 0) and self.ent or pg.getEntityByActorId(targetActorId)

	return tgtEnt and CharacterStateConst.isChildOfState(tgtEnt.characterState, CharacterStateConst.FLYING) and true or false
end

function IFlyComponent:switchToFly__resetState(resetStateType)
	self.x_switchToFly_state = nil

	self:switchToState__resetState(resetStateType)
	AIControllerUtils.setFlyRiseHeight(self.ent)
end

function IFlyComponent:switchToFly(height, timeout)
	if not self.x_switchToFly_state then
		AIControllerUtils.setFlyRiseHeight(self.ent, height)

		self.x_switchToFly_state = true
	end

	return self:switchToState(CharacterStateConst[CharacterStateConst.FLYING].name, timeout)
end

function IFlyComponent:switchToGround__resetState(resetStateType)
	self:switchToState__resetState(resetStateType)
end

function IFlyComponent:switchToGround()
	return self:switchToState(CharacterStateConst[CharacterStateConst.LOCOMOTION].name)
end

function IFlyComponent:flyToTarget__resetState(resetStateType)
	if self.x_flyToTarget_targetPos then
		VectorPool.returnVector(self.x_flyToTarget_targetPos)

		self.x_flyToTarget_targetPos = nil
	end

	self:_removeCustomTimeout("flyToTarget_minHoldTime")
	self.moveAbility:resetMoveToPos(resetStateType)
end

function IFlyComponent:_getFlyTargetPos(tgtPos, targetActorId, stopDist2d, targetHeight, ignoreVertical, ignoreHorizontal)
	local tgtEnt = (targetActorId == 0 or targetActorId == nil) and self.ent or pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return nil
	end

	Vector3.enableCreateFromCache()

	local selfPos = self.ent:getPosition()

	Vector3.Copy(tgtPos, tgtEnt:getPosition())

	if ignoreVertical then
		tgtPos.y = selfPos.y
	else
		tgtPos.y = tgtPos.y + targetHeight
	end

	if ignoreHorizontal then
		tgtPos.x = selfPos.x
		tgtPos.z = selfPos.z
	end

	local direction = tgtPos:Clone():Sub(selfPos)

	direction.y = 0

	tgtPos:Sub(direction:Normalize():Mul(stopDist2d))
	Vector3.disableCreateFromCache()
end

function IFlyComponent:flyToTarget(targetActorId, stopDist2d, targetHeight, timeout, notFaceToPos, minHoldTime, ignoreVertical, ignoreHorizontal, speed)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self.x_flyToTarget_targetPos == nil then
		if Vector3.HoriSqrDistance(self.ent:getPosition(), tgtEnt:getPosition()) < stopDist2d * stopDist2d then
			return EBTStatus.BT_SUCCESS
		end

		self.x_flyToTarget_targetPos = VectorPool.getVector()

		self:_getFlyTargetPos(self.x_flyToTarget_targetPos, targetActorId, stopDist2d, targetHeight, ignoreVertical, ignoreHorizontal)

		minHoldTime = minHoldTime or 0

		if minHoldTime > 0 then
			self:_settingCustomTimeout("flyToTarget_minHoldTime", minHoldTime)
		end
	end

	if not notFaceToPos then
		self:faceToPos(tgtEnt:getPosition())
	end

	local status = self.moveAbility:moveToPos(self.x_flyToTarget_targetPos, timeout, false, nil, nil, speed)

	if status == EBTStatus.BT_SUCCESS and not self:_checkCustomTimeout("flyToTarget_minHoldTime") then
		return EBTStatus.BT_RUNNING
	end

	return status
end

function IFlyComponent:flyAway__resetState(resetStateType)
	if self.x_flyAway_targetPos then
		VectorPool.returnVector(self.x_flyAway_targetPos)

		self.x_flyAway_targetPos = nil
	end

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IFlyComponent:flyAway(targetActorId, awayDistance, targetHeight, timeout, notFaceToTarget)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self.x_flyAway_targetPos == nil then
		if Vector3.SqrDistance(self.ent:getPosition(), tgtEnt:getPosition()) > awayDistance * awayDistance then
			return EBTStatus.BT_SUCCESS
		end

		self.x_flyAway_targetPos = VectorPool.getVector()

		self:_getFlyTargetPos(self.x_flyAway_targetPos, targetActorId, awayDistance, targetHeight)
	end

	if not notFaceToTarget then
		self:faceToPos(tgtEnt:getPosition())
	end

	return self.moveAbility:moveToPos(self.x_flyAway_targetPos, timeout, false)
end

function IFlyComponent:checkCanFly()
	return AIControllerUtils.checkCanFly(self.ent)
end

function IFlyComponent:isInSpecialRidden()
	return self.ent.isSpecialRidden == true
end

function IFlyComponent:flyAround__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)
	self.moveAbility:resetMoveToPosList(resetStateType)

	self.x_flyAround_step = nil
	self.x_flyAround_targetPos = nil

	if self.x_flyAround_posList then
		for i = 1, AiConst.FLY_AROUND_POS_NUM do
			VectorPool.returnVector(self.x_flyAround_posList[i])
		end

		ListPool.returnList(self.x_flyAround_posList)

		self.x_flyAround_posList = nil
	end

	if self.x_flyAround_endPosList then
		ListPool.returnList(self.x_flyAround_endPosList)

		self.x_flyAround_endPosList = nil
	end

	if self.x_flyAround_animName then
		AIBaseMethodUtils.Base_StopAnimation(self.ent, self.x_flyAround_animName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		self.x_flyAround_animName = nil
	end

	self.x_flyAround_speedRate = nil

	self:_removeCustomTimeout("flyAround_timeout")
	self:_removeCustomTimeout("flyAround_repath")
end

function IFlyComponent:flyAround(radius, center, height, clockwise, maxTransTime, minTransTime, timeout, flyAnimName)
	if self.x_flyAround_step == nil then
		self.x_flyAround_step = 1
		self.x_flyAround_posList = ListPool.getList()

		for i = 1, AiConst.FLY_AROUND_POS_NUM do
			self.x_flyAround_posList[i] = VectorPool.getVector()
		end

		self.x_flyAround_endPosList = ListPool.getList()

		local dir = CalcUtils.getHoriDirection(center, self.ent:getPosition())

		self.x_flyAround_targetPos = center + dir * radius
		self.x_flyAround_targetPos[2] = center[2] + height

		self:_settingCustomTimeout("flyAround_timeout", timeout)

		if string_notNilOrEmpty(flyAnimName) then
			self.x_flyAround_animName = flyAnimName

			AIBaseMethodUtils.Base_PlayAnimation(self.ent, flyAnimName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end
	end

	if self:_checkCustomTimeout("flyAround_timeout") then
		return EBTStatus.BT_FAILURE
	end

	if self.x_flyAround_step == 1 then
		local status = self.moveAbility:moveToPos(self.x_flyAround_targetPos, maxTransTime, true)

		if status == EBTStatus.BT_SUCCESS then
			self.x_flyAround_step = 2
		else
			return status
		end
	end

	if self.x_flyAround_step == 2 then
		local isRepath = false

		if self:_checkCustomTimeout("flyAround_repath") then
			isRepath = self:_checkCustomTimeoutExist("flyAround_repath")

			self:_settingCustomTimeout("flyAround_repath", AiConst.DEFAULT_REPATH_CD)

			local sign = clockwise and -1 or 1

			Vector3.enableCreateFromCache()

			local dirX = CalcUtils.getHoriDirection(center, self.ent:getPosition())
			local dirY = Vector3(-dirX[3], dirX[2], dirX[1])
			local angle, sin, cos

			for i = 1, AiConst.FLY_AROUND_POS_NUM do
				angle = i * AiConst.FLY_AROUND_POS_DELTA_ANGLE
				sin = CalcUtils.quickSin(angle) * sign
				cos = CalcUtils.quickCos(angle)
				self.x_flyAround_posList[i][1] = center[1] + (dirX[1] * cos + dirY[1] * sin) * radius
				self.x_flyAround_posList[i][2] = center[2] + height
				self.x_flyAround_posList[i][3] = center[3] + (dirX[3] * cos + dirY[3] * sin) * radius
			end

			Vector3.disableCreateFromCache()

			self.x_flyAround_endPosList[1] = self.x_flyAround_posList[AiConst.FLY_AROUND_POS_NUM]
			self.x_flyAround_speedRate = BaseEnum.SpeedRateType.Mid
		end

		if isRepath then
			AutoPathFindUtils.clearPath(self.ent)
		end

		self.moveAbility:moveToPosList(self.x_flyAround_posList, self.x_flyAround_endPosList, AiConst.MOVE_CD, true, AiConst.TARGET_POINT_STOP_DIST, self.x_flyAround_speedRate, nil, isRepath, nil, nil, AutoPathFindUtils.PathFindType.ForceMove)
	end

	return EBTStatus.BT_RUNNING
end

function IFlyComponent:flyGrabEntity__resetState(resetStateType)
	self.x_flyGrabEntity_step = nil

	self:switchToState__resetState(resetStateType)
end

function IFlyComponent:flyGrabEntity(targetActorId, timeout)
	local ret = self:switchToState(CharacterStateConst[CharacterStateConst.FLYSTARTGRAB].name, timeout, nil, true)

	if self.x_flyGrabEntity_step == nil then
		if CharacterStateConst.isChildOfState(self.ent.characterState, CharacterStateConst.FLYING) then
			local success = AIBaseMethodUtils.Base_StartGrabEntity(self.ent, targetActorId)

			if not success then
				return EBTStatus.BT_FAILURE
			end

			self.x_flyGrabEntity_step = 1
		else
			return EBTStatus.BT_FAILURE
		end
	end

	return ret
end

function IFlyComponent:flyStopGrab__resetState(resetStateType)
	self.x_flyStopGrab_step = nil

	self:switchToState__resetState(resetStateType)
end

function IFlyComponent:flyStopGrab(timeout)
	local ret = self:switchToState(CharacterStateConst[CharacterStateConst.FLYENDGRAB].name, timeout, nil, true)

	if self.x_flyStopGrab_step == nil then
		local success = AIBaseMethodUtils.Base_StopGrabEntity(self.ent)

		if not success then
			return EBTStatus.BT_FAILURE
		end

		self.x_flyStopGrab_step = 1
	end

	return ret
end

return IFlyComponent
