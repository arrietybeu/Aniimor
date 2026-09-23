-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\MultiPetFollowStateMachine.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PlayableConst = require("Common.Const.PlayableConst")
local PlayableAnimGroupKey = CS.FunPlus.WorldX.Animations.PlayableAnimGroupKey
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local FollowStateName = {
	Run = 2,
	Idle = 1
}
local MultiPetFollowIdleState = Class.LiteClass("MultiPetFollowIdleState", State)

function MultiPetFollowIdleState:onEnter(controller)
	controller:syncIdleState()
end

function MultiPetFollowIdleState:onRun(controller, owner, target)
	controller:syncIdleState(owner)
end

local MultiPetFollowRunState = Class.LiteClass("MultiPetFollowRunState", State)

function MultiPetFollowRunState:onEnter(controller)
	controller:syncRunState()
end

function MultiPetFollowRunState:onRun(controller, owner, target)
	controller:syncRunState(owner, target)
end

function MultiPetFollowRunState:onExit(controller)
	controller:clearMoveInput()
end

local MultiPetFollowStateMachine = Class.LiteClass("MultiPetFollowStateMachine", FiniteStateMachine)

MultiPetFollowStateMachine.StateName = FollowStateName

function MultiPetFollowStateMachine:ctor(ownerActorId, targetUid, followDistance, stateSourceUid)
	FiniteStateMachine.ctor(self)

	self.ownerActorId = ownerActorId
	self.targetUid = targetUid
	self.stateSourceUid = stateSourceUid or targetUid
	self.followDistance = followDistance
	self.inputOwner = nil

	self:addState(MultiPetFollowIdleState.new(FollowStateName.Idle))
	self:addState(MultiPetFollowRunState.new(FollowStateName.Run))
	self:addTransitionByStateName(FollowStateName.Idle, FollowStateName.Run)
	self:addTransitionByStateName(FollowStateName.Run, FollowStateName.Idle)
	self:applyRunAnimOverride()
end

function MultiPetFollowStateMachine:isValidEntity(ent)
	return ent and ent.actorId and ent.eModel ~= nil
end

function MultiPetFollowStateMachine:isValidOwner(ent)
	return self:isValidEntity(ent) and ent.hasEModelComponent and ent:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
end

function MultiPetFollowStateMachine:getOwner()
	local owner = self.ownerActorId and pg.getEntityByActorId(self.ownerActorId)

	return self:isValidOwner(owner) and owner or nil
end

function MultiPetFollowStateMachine:getTarget()
	local target = self.targetUid and pg.getEntityByUid(self.targetUid)

	return self:isValidEntity(target) and target or nil
end

function MultiPetFollowStateMachine:getStateSource()
	local stateSource = self.stateSourceUid and pg.getEntityByUid(self.stateSourceUid)

	return self:isValidEntity(stateSource) and stateSource or nil
end

function MultiPetFollowStateMachine:getFollowState(target)
	local tagMasks = target.animTagMasks

	if tagMasks then
		if tagMasks:Has(TagMask.Run) and tagMasks:Has(TagMask.Movement) then
			return FollowStateName.Run
		end

		if tagMasks:Has(TagMask.Idle) then
			return FollowStateName.Idle
		end
	end

	if target.characterState == CharacterStateConst.RUN then
		return FollowStateName.Run
	end

	if target.characterState == CharacterStateConst.IDLE then
		return FollowStateName.Idle
	end

	return FollowStateName.Idle
end

function MultiPetFollowStateMachine:tickInput()
	local owner = self:getOwner()
	local stateSource = self:getStateSource()

	if not owner or not stateSource or owner.actorId == stateSource.actorId then
		self:clearMoveInput()

		return false
	end

	local followState = self:getFollowState(stateSource)

	if not self._curState then
		if not followState then
			self:clearMoveInput()

			return true
		end

		MultiPetFollowStateMachine.super.start(self, followState)
	elseif followState and not self:checkIsCurState(followState) then
		self:transitionTo(followState)
	end

	self:onRun(owner, stateSource)

	return true
end

function MultiPetFollowStateMachine:tickTransform(displayPosition, displayRotation)
	local owner = self:getOwner()
	local target = self:getTarget()

	if not owner or not target or owner.actorId == target.actorId then
		return false
	end

	if displayPosition and displayRotation then
		self:syncTransformValue(owner, displayPosition, displayRotation)
	else
		self:syncTransform(owner, target)
	end

	return true
end

function MultiPetFollowStateMachine:stop()
	self:clearRunAnimOverride()
	self:clearMoveInput()
	MultiPetFollowStateMachine.super.stop(self)

	self.inputOwner = nil
end

function MultiPetFollowStateMachine:setMoveInput(owner, worldDirection)
	owner = owner or self:getOwner()

	if not self:isValidOwner(owner) then
		return
	end

	local inputX, inputY = 0, 0

	if worldDirection then
		local cameraMgr = pg.global and pg.global.cameraMgr
		local camera = cameraMgr and cameraMgr.worldCameraInst

		if camera and NotNil(camera.transform) then
			local localDirection = Quaternion.MulVec3(Quaternion.Inverse(camera.transform.rotation), worldDirection)

			inputX = localDirection.x
			inputY = localDirection.z
		else
			inputY = 1
		end
	end

	owner.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, inputX, inputY, 0)

	self.inputOwner = owner
end

function MultiPetFollowStateMachine:clearMoveInput()
	local owner = self.inputOwner or self:getOwner()

	if self:isValidOwner(owner) then
		owner.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0, 0, 0)
	end

	self.inputOwner = nil
end

function MultiPetFollowStateMachine:forceCharacterState(owner, characterState)
	owner = owner or self:getOwner()

	if self:isValidOwner(owner) and owner.characterState ~= characterState then
		owner.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, characterState)
	end
end

function MultiPetFollowStateMachine:applyRunAnimOverride()
	local owner = self:getOwner()

	if not owner or not owner.setAnimGroupData then
		return
	end

	local overrideData = {
		[PlayableAnimGroupKey.RunLoop] = PlayableConst.EnvBehav_RunInLine_Loop
	}

	owner:setAnimGroupData(PlayableConst.AnimGroupKey.Max, {
		canJump = false,
		canDash = false,
		playSpecialIdle = false,
		overrideData = overrideData
	})
end

function MultiPetFollowStateMachine:clearRunAnimOverride()
	local owner = self.ownerActorId and pg.getEntityByActorId(self.ownerActorId)

	if owner and owner.setAnimGroupData then
		owner:setAnimGroupData(PlayableConst.AnimGroupKey.Max, nil)
	end
end

function MultiPetFollowStateMachine:syncIdleState(owner)
	self:setMoveInput(owner, nil)
	self:forceCharacterState(owner, CharacterStateConst.IDLE)
end

function MultiPetFollowStateMachine:syncRunState(owner, target)
	owner = owner or self:getOwner()
	target = target or self:getTarget()

	if not owner or not target then
		self:clearMoveInput()

		return
	end

	local targetRotation = Quaternion.Euler(0, target:getYaw(), 0)
	local forward = Quaternion.MulVec3(targetRotation, Vector3.forward)

	forward.y = 0

	local sqrMagnitude = forward.x * forward.x + forward.z * forward.z

	if sqrMagnitude > 1e-06 then
		local inverseMagnitude = 1 / math.sqrt(sqrMagnitude)

		forward.x = forward.x * inverseMagnitude
		forward.z = forward.z * inverseMagnitude
	else
		forward.x = 0
		forward.z = 1
	end

	self:setMoveInput(owner, forward)
	self:forceCharacterState(owner, CharacterStateConst.RUN)
end

function MultiPetFollowStateMachine:syncTransform(owner, target)
	if not owner or not target then
		return
	end

	local targetRotation = Quaternion.Euler(0, target:getYaw(), 0)
	local offset = Quaternion.MulVec3(targetRotation, Vector3.New(0, 0, -self.followDistance))
	local targetPosition = target:getPosition()

	self:syncTransformValue(owner, Vector3.New(targetPosition.x + offset.x, targetPosition.y + offset.y, targetPosition.z + offset.z), targetRotation)
end

function MultiPetFollowStateMachine:syncTransformValue(owner, position, rotation)
	owner:setPosition(position, Const.AgentTransformReasonConst.LogicFromLua)
	owner:setRotation(rotation, true, Const.AgentTransformReasonConst.LogicFromLua)
end

return MultiPetFollowStateMachine
