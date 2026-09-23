-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IMimicryComponent.lua

local class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTStatus = enums.EBTStatus
local IMimicryComponent = class.Component("IMimicryComponent")

function IMimicryComponent:switchToMimicryOut__resetState(resetStateType)
	self.x_switchToMimicryOut_state = nil
end

function IMimicryComponent:switchToMimicryOut()
	if self.x_switchToMimicryOut_state == nil then
		self.x_switchToMimicryOut_state = 1

		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.MIMICRYOUT)
	end

	if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.MIMICRYOUT then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IMimicryComponent:startMimicry()
	return EBTStatus.BT_SUCCESS
end

function IMimicryComponent:switchToHideMimicryIn__resetState(resetStateType)
	self.x_switchToHideMimicryIn_state = nil

	AIBaseMethodUtils.Base_StopAnimation(self.ent, PlayableConst.HideMimicry_Start, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function IMimicryComponent:switchToHideMimicryIn(targetPos)
	if self.x_switchToHideMimicryIn_state == nil then
		self.x_switchToHideMimicryIn_state = 1

		AIControllerUtils.setJumpInRunWarping(self.ent, targetPos, false)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.HIDEMIMICRYIN)

		return EBTStatus.BT_RUNNING
	end

	if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.HIDEMIMICRYIN then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IMimicryComponent:switchToHideMimicryOut__resetState(resetStateType)
	self.x_switchToHideMimicryOut_findPos = nil
	self.x_switchToHideMimicryOut_state = nil
	self.x_switchToHideMimicryOut_targetPos = nil

	self:calcQualifiedPosByTarget__resetState(resetStateType)
end

function IMimicryComponent:switchToHideMimicryOut(needPlayAnim, jumpDistance)
	if needPlayAnim and self.x_switchToHideMimicryOut_findPos == nil then
		local status = self:calcQualifiedPosByTarget(self.ent.actorId, 0, jumpDistance, nil, 1, 0, true, false)

		if status == EBTStatus.BT_SUCCESS then
			self.x_switchToHideMimicryOut_findPos = true
		else
			return status
		end
	end

	if self.x_switchToHideMimicryOut_state == nil then
		self.x_switchToHideMimicryOut_state = true

		if needPlayAnim then
			self.x_switchToHideMimicryOut_targetPos = self.envQueryAbility:queryBestPosByTarget(self.ent.actorId)

			AIControllerUtils.setJumpInRunWarping(self.ent, self.x_switchToHideMimicryOut_targetPos, true)
		end

		AIControllerUtils.setHideMimicryOutType(self.ent, needPlayAnim)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.HIDEMIMICRYOUT)

		return EBTStatus.BT_RUNNING
	end

	if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.HIDEMIMICRYOUT then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

return IMimicryComponent
