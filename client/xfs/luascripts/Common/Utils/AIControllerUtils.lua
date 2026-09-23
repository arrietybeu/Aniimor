-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AIControllerUtils.lua

local CommonConst = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local CalcUtils = require("Common.Utils.CalcUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AiConst = require("Common.Const.AiConst")
local TimerManager = require("Core.Timer.TimerManager")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTRootState = BaseEnum.EBTRootState
local AbilityConst = require("Common.Const.AbilityConst")
local SysConfigData = require("Data.sys_config_data")
local CTRPool = require("Common.AICt.CTRPool")
local SceneUtils = require("Common.Utils.SceneUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local TriggerConst = require("Common.Const.TriggerConst")
local Const = require("Common.Const.Const")
local Vector3 = Vector3
local Quaternion = Quaternion
local AIControllerUtils = {}

function AIControllerUtils.initEntity(entity, initState)
	if Utils.checkClient() and AIControllerUtils.checkOpen(entity) then
		local eModel = entity.eModel

		if eModel then
			local hasSwimmingAbility = AIControllerUtils.checkCanSwim(entity) and true or false
			local hasGlideAbility = AIControllerUtils.checkCanGlide(entity) and true or false
			local hasClimbAbility = AIControllerUtils.checkCanClimb(entity) and true or false
			local hasSneakAbility = AIControllerUtils.checkCanSneak(entity)
			local hasGroundingAbility = true
			local hasSkateBoardAbility = AIControllerUtils.checkCanSkateBoard(entity)
			local hasMimicryAbility = true
			local hasSwimMimicryAbility = AIControllerUtils.checkCanSwimMimicry(entity)
			local hasHideMimicryAbility = AIControllerUtils.checkCanHideMimicry(entity)
			local staticSpawnOverAnimHash = AIControllerUtils.getStaticSpawnOverAnim(entity)

			eModel:SetAIAbility(Const.COMPONENT_AI_CONTROLLER, staticSpawnOverAnimHash, hasSwimmingAbility, hasGlideAbility, hasSneakAbility, hasGroundingAbility, hasClimbAbility, hasSkateBoardAbility, hasMimicryAbility, hasSwimMimicryAbility, hasHideMimicryAbility)
			AIControllerUtils.setFlyRiseHeight(entity)
			eModel:InitAIStateMachine(CommonConst.COMPONENT_AI_CONTROLLER, initState)
		end
	end
end

function AIControllerUtils.setFlyRiseHeight(entity, height)
	if Utils.checkClient() then
		entity.eModel.defaultFlyRiseHeight = height or SysConfigData.defaultFlyHeight
	else
		entity.defaultFlyRiseHeight = height or SysConfigData.defaultFlyHeight
	end
end

function AIControllerUtils.setRotation(entity, rotation, instant)
	if Utils.checkClient() then
		local EModelUtils = require("Entities.Utils.EModelUtils")

		if EModelUtils.setMotionRotation(entity, rotation, instant) then
			return true
		end
	elseif entity.serverSetTargetYaw then
		entity:serverSetTargetYaw(math.deg(rotation:ToYaw()))

		return true
	end

	return false
end

function AIControllerUtils.setRotationXYZW(entity, rotX, rotY, rotZ, rotW, instant)
	if Utils.checkClient() then
		local EModelUtils = require("Entities.Utils.EModelUtils")

		if EModelUtils.setMotionRotationXYZW(entity, rotX, rotY, rotZ, rotW, instant) then
			return true
		end
	elseif entity.serverSetTargetYaw then
		entity:serverSetTargetYaw(math.deg(Quaternion.GetYawByXYZW(rotX, rotY, rotZ, rotW)))

		return true
	end

	return false
end

function AIControllerUtils.setDirection(entity, direction, instant, steeringTime)
	if Utils.checkClient() then
		AIControllerUtils.setOverrideSteeringTime(entity, steeringTime)

		direction.y = 0

		if Vector3.SqrMagnitude(direction) < 1e-12 then
			return false
		end

		local EModelUtils = require("Entities.Utils.EModelUtils")

		return EModelUtils.setMotionDirection(entity, direction, instant or false)
	elseif entity.serverSetTargetYaw then
		if Vector3.SqrMagnitude(direction) < 1e-12 then
			return false
		end

		Vector3.enableCreateFromCache()

		local yawDeg = math.deg(Quaternion.LookRotation(direction, Vector3.constUp):ToYaw())

		Vector3.disableCreateFromCache()
		entity:serverSetTargetYaw(yawDeg)

		return true
	end

	return false
end

function AIControllerUtils.setYawDegrees(entity, yawDeg, instant, steeringTime)
	if Utils.checkClient() then
		AIControllerUtils.setOverrideSteeringTime(entity, steeringTime)

		local EModelUtils = require("Entities.Utils.EModelUtils")

		return EModelUtils.setMotionYaw(entity, yawDeg, instant or false)
	elseif entity.serverSetTargetYaw then
		entity:serverSetTargetYaw(yawDeg)

		return true
	end

	return false
end

function AIControllerUtils.setOverrideSteeringTime(entity, steeringTime)
	if Utils.checkClient() then
		if entity.setOverrideSteeringTime then
			return entity:setOverrideSteeringTime(steeringTime or -1)
		end

		return false
	end

	return false
end

function AIControllerUtils.getRunSpeed(entity, forceCompute)
	if not entity.aiRunSpeed or forceCompute then
		entity.aiRunSpeed = entity.actorCombatAttribute:getRunSpeed()
	end

	return entity.aiRunSpeed
end

function AIControllerUtils.getWalkSpeed(entity, forceCompute)
	if not entity.aiWalkSpeed or forceCompute then
		entity.aiWalkSpeed = entity.actorCombatAttribute:getWalkSpeed()
	end

	return entity.aiWalkSpeed
end

function AIControllerUtils.getSprintSpeed(entity, forceCompute)
	if not entity.aiSpringSpeed or forceCompute then
		entity.aiSpringSpeed = entity.actorCombatAttribute:getSprintSpeed()
	end

	return entity.aiSpringSpeed
end

function AIControllerUtils.getSpeedBurstSpeed(entity, forceCompute)
	if not entity.aiSpeedBurstSpeed or forceCompute then
		entity.aiSpeedBurstSpeed = entity:getConfigData().speedBurstSpeed or 0
	end

	return entity.aiSpeedBurstSpeed
end

function AIControllerUtils.getFlyingSpeed(entity, forceCompute)
	if not entity.aiFlyingSpeed or forceCompute then
		local moveLevel = entity:getConfigData().moveLevel or 1

		entity.aiFlyingSpeed = SysConfigData.defaultFlySpeedRatioBySprint * SysConfigData.sprintSpeedLevels[moveLevel]
	end

	return entity.aiFlyingSpeed
end

function AIControllerUtils.getSwimSpeed(entity, forceCompute)
	local canSwim = AIControllerUtils.checkCanSwim(entity)

	if canSwim and (not entity.aiSwimSpeed or forceCompute) then
		entity.aiSwimSpeed = SysConfigData.swimNormalSpeedLevels[canSwim] * entity.actorCombatAttribute:getSwimSpeedRatio()
	end

	return entity.aiSwimSpeed or 0
end

function AIControllerUtils.getSwimFastSpeed(entity, forceCompute)
	local canSwim = AIControllerUtils.checkCanSwim(entity)

	if canSwim and (not entity.aiSwimFastSpeed or forceCompute) then
		entity.aiSwimFastSpeed = SysConfigData.swimFastSpeedLevels[canSwim] * entity.actorCombatAttribute:getSwimFastSpeedRatio()
	end

	return entity.aiSwimFastSpeed or 0
end

function AIControllerUtils.getClimbSpeed(entity, forceCompute)
	local canClimb = AIControllerUtils.checkCanClimb(entity)

	if canClimb and (not entity.aiClimbSpeed or forceCompute) then
		entity.aiClimbSpeed = SysConfigData.climbSpeedLevels[canClimb]
	end

	return entity.aiClimbSpeed or 0
end

function AIControllerUtils.getSneakSpeed(entity, forceCompute)
	if not entity.aiSneakSpeed or forceCompute then
		entity.aiSneakSpeed = SysConfigData.defaultSneakSpeed
	end

	return entity.aiSneakSpeed or 0
end

function AIControllerUtils.getGroundWalkSpeed(entity, forceCompute)
	if not entity.aiGroundWalkSpeed or forceCompute then
		entity.aiGroundWalkSpeed = SysConfigData.defaultGroundWalkSpeed
	end

	return entity.aiGroundWalkSpeed
end

function AIControllerUtils.getGlideSpeed(entity, forceCompute)
	local canGlide = AIControllerUtils.checkCanGlide(entity)

	if canGlide and (not entity.aiGlideSpeed or forceCompute) then
		entity.aiGlideSpeed = SysConfigData.glideSpeedLevels[canGlide] * entity.actorCombatAttribute:getGlideSpeedRatio()
	end

	return entity.aiGlideSpeed or 0
end

function AIControllerUtils.getSideWalkSpeed(entity, forceCompute)
	if not entity.aiSideWalkSpeed or forceCompute then
		entity.aiSideWalkSpeed = entity.actorCombatAttribute:getSideWalkSpeed()
	end

	return entity.aiSideWalkSpeed
end

function AIControllerUtils.getWalkBackSpeed(entity, forceCompute)
	if not entity.aiWalkBackSpeed or forceCompute then
		entity.aiWalkBackSpeed = entity.actorCombatAttribute:getWalkBackSpeed()
	end

	return entity.aiWalkBackSpeed
end

function AIControllerUtils.getSkateBoardSpeed(entity, forceCompute)
	local canSkateBoard = AIControllerUtils.checkCanSkateBoard(entity)

	if canSkateBoard and (not entity.aiSkateBoardSpeed or forceCompute) then
		entity.aiSkateBoardSpeed = entity.actorCombatAttribute:getRunSpeed()
	end

	return entity.aiSkateBoardSpeed or 0
end

function AIControllerUtils.getVelocity(entity)
	if Utils.checkClient() then
		local entityVelocity = entity:getVelocity()

		return entityVelocity and entityVelocity.magnitude or 0
	end

	return 0
end

function AIControllerUtils.teleport(entity, position, callback)
	local successTeleport = false

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			if entity.serverMsgNoGC then
				entity:serverMsgNoGC("RPC_CS_AICallTeleport", position.x, position.y, position.z, callback)

				return
			else
				successTeleport = eModel:Teleport(CommonConst.COMPONENT_AI_CONTROLLER, position)
			end
		end
	else
		entity:setPosition(position)

		successTeleport = true
	end

	if callback then
		callback(successTeleport)
	end
end

function AIControllerUtils.setMotionWarping(entity, rootMotionIndex, syncPointEnum, targetPosition, targetRotation, warpXZ, warpY, warpRot)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			syncPointEnum = syncPointEnum or AiConst.SYNC_POINT_CUSTOM_INDEX
			warpXZ = warpXZ or false
			warpY = warpY or false
			warpRot = warpRot or false

			eModel:SetMotionWarping(CommonConst.COMPONENT_AI_CONTROLLER, rootMotionIndex, syncPointEnum, targetPosition, targetRotation, warpXZ, warpY, warpRot)
		end
	end
end

function AIControllerUtils.pause(entity, reason)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetAIEnable(CommonConst.COMPONENT_AI_CONTROLLER, false, reason)
		end

		return
	end
end

function AIControllerUtils.resume(entity, reason)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetAIEnable(CommonConst.COMPONENT_AI_CONTROLLER, true, reason)
		end

		return
	end
end

function AIControllerUtils.setUseKCCMove(entity, enabled, controlType)
	if Utils.checkClient() then
		if entity.eModel then
			entity.eModel:EnableKccFullSimulation(Const.COMPONENT_MOTION, enabled, controlType)
		end

		return
	end
end

function AIControllerUtils.checkCanFly(entity)
	if Utils.checkClient() then
		if not entity or not entity.eModel then
			return false
		end

		return entity.eModel:CanFlyNow(Const.COMPONENT_MOTION) or false
	else
		local configData = entity and entity.getConfigData and entity:getConfigData()

		if configData and configData.canFly and configData.canFly > 1 then
			return true
		end

		return false
	end
end

function AIControllerUtils.checkCanSwim(entity)
	if entity then
		local canSwim = entity:getConfigData()[AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM]]

		if not canSwim or canSwim == 0 then
			return false
		end

		return canSwim
	end

	return false
end

function AIControllerUtils.checkCanGlide(entity)
	if entity then
		local canGlide = entity:getConfigData()[AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE]]

		if not canGlide or canGlide == 0 then
			return false
		end

		return canGlide
	end

	return false
end

function AIControllerUtils.checkCanClimb(entity)
	if entity then
		local canClimb = entity:getConfigData()[AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB]]

		if not canClimb or canClimb == 0 then
			return false
		end

		return canClimb
	end

	return false
end

function AIControllerUtils.checkCanSkateBoard(entity)
	if entity then
		local canSkateBoard = entity:getConfigData().canSkateBoard

		return canSkateBoard == true
	end

	return false
end

function AIControllerUtils.checkCanSwimMimicry(entity)
	if entity then
		local canSwimMimicry = entity:getConfigData().canSwimMimicry

		return canSwimMimicry == true
	end

	return false
end

function AIControllerUtils.checkCanSneak(entity)
	if entity then
		local canBurrow = entity:getTemplateData().canBurrow

		return canBurrow == true
	end

	return false
end

function AIControllerUtils.checkCanHideMimicry(entity)
	if entity then
		local canHideMimicry = entity:getConfigData().canHideMimicry

		return canHideMimicry == true
	end

	return false
end

function AIControllerUtils.getStick(entity)
	if Utils.checkClient() and entity.eModel then
		return entity.eModel.Stick or false
	end

	return false
end

function AIControllerUtils.checkFollowTargetSpeed(entity)
	if Utils.checkClient() then
		return entity.characterState == CharacterStateConst.RUN or entity.characterState == CharacterStateConst.SPRINT
	end

	return false
end

function AIControllerUtils.getCurrentAnimationState(entity)
	return entity.characterState or CharacterStateConst.IDLE
end

function AIControllerUtils.getMotionStateValue(entity, ignore0Parent)
	local currentState = AIControllerUtils.getCurrentAnimationState(entity)

	if currentState then
		if not ignore0Parent then
			return CharacterStateConst.getParentState(currentState)
		end

		return CharacterStateConst[currentState].parent
	end

	return nil
end

function AIControllerUtils.getMoveState(entity, SpeedRateType)
	if Utils.isPet(entity) and entity:getMasterEntity():SKATEBOARD_ST() and AIControllerUtils.checkCanSkateBoard(entity) and entity.agent and entity.agent:getRootState() == EBTRootState.ST_Root_Follow then
		return CharacterStateConst.SKATEBOARDMOVE
	end

	local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)
	local parentState = CharacterStateConst.getParentState(tCurrentControllerState)
	local moveStateMap = Utils.checkClient() and AiConst.clientMoveStateMap or AiConst.serverMoveStateMap
	local mapFunc = moveStateMap[parentState]

	if mapFunc then
		return mapFunc(SpeedRateType)
	else
		return moveStateMap[CharacterStateConst.LOCOMOTION](SpeedRateType)
	end
end

function AIControllerUtils.getIdleState(entity)
	if Utils.checkClient() then
		local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)
		local parentState = CharacterStateConst.getParentState(tCurrentControllerState)

		return AiConst.idleStateMap[parentState] or CharacterStateConst.IDLE
	end

	return CharacterStateConst.IDLE
end

function AIControllerUtils.getTurnState(entity)
	if Utils.checkClient() then
		local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)

		if CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.LOCOMOTION) then
			return CharacterStateConst.TURN
		end
	end

	return nil
end

function AIControllerUtils.sendAIEvent(entity, eventName, context)
	if not entity then
		CTRPool.tryReturnContext(context)

		return
	end

	if Utils.checkIsAuthorityMaster(entity) then
		if entity and entity.isAIRunning and entity:isAIRunning() then
			if not entity.AI.btTickLock then
				if entity.emitAIDynamicEvent then
					entity:emitAIDynamicEvent(eventName, context)
				end

				if entity.emitAIEvent then
					entity:emitAIEvent(eventName, context)
				end

				if entity.emitAdditiveAIEvent then
					entity:emitAdditiveAIEvent(eventName, context)
				end

				CTRPool.tryReturnContext(context)
			else
				table.insert(entity.AI.btTickLockEvent, eventName)
				table.insert(entity.AI.btTickLockEventContext, context or false)
			end
		else
			CTRPool.tryReturnContext(context)
		end
	elseif not Utils.checkClient() then
		if Utils.isCreation(entity) or Utils.isEnvObj(entity) then
			return
		end

		entity:clientMsg("RPC_SC_AIEvent", eventName, context or AiConst.DefaultNullTable)
	end
end

function AIControllerUtils.setStateMotionWarpingSyncPoint(entity, state, playableKey, targetPosition, targetRotation, syncPoint, warpXZ, warpY, warpRotation, startTime, endTime)
	if playableKey == 0 then
		return
	end

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			syncPoint = syncPoint or BaseEnum.RootMotionSyncPointEnum.AICustomPoint1

			if warpXZ == nil then
				warpXZ = true
			end

			warpY = warpY or false

			if warpRotation == nil then
				warpRotation = true
			end

			startTime = startTime or 0
			endTime = endTime or -1

			eModel:SetStateMotionWarpingSyncPoint(CommonConst.COMPONENT_AI_CONTROLLER, state, playableKey, targetPosition, targetRotation, syncPoint, warpXZ, warpY, warpRotation, startTime, endTime)
		end
	end
end

function AIControllerUtils.clearStateMotionWarpingSyncPoint(entity, state)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:ClearStateMotionWarpingSyncPoint(CommonConst.COMPONENT_AI_CONTROLLER, state)
		end
	end
end

function AIControllerUtils.setStateInterruptTime(entity, state, interruptTime)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetStateInterruptTime(CommonConst.COMPONENT_AI_CONTROLLER, state, interruptTime)
		end
	end
end

function AIControllerUtils.clearStateInterruptTime(entity, state)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:ClearStateInterruptTime(CommonConst.COMPONENT_AI_CONTROLLER, state)
		end
	end
end

function AIControllerUtils.isInGliding(entity)
	if entity then
		local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)

		return CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.GLIDING)
	end
end

function AIControllerUtils.isClimbing(entity)
	if entity then
		local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)

		return CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.CLIMBING)
	end
end

function AIControllerUtils.isInLocomotion(entity)
	if entity then
		local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(entity)

		return CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.LOCOMOTION)
	end
end

function AIControllerUtils.SetDynamicRVO(entity, rvoRadius, rvoWeight, timeHorizon, maxRVONeighbors)
	if entity.eModel then
		entity.eModel:SetDynamicRVO(Const.COMPONENT_RVO, rvoRadius, rvoWeight, timeHorizon, maxRVONeighbors)
	end
end

function AIControllerUtils.initStaticRVO(entity)
	if entity.eModel then
		entity.eModel:InitStaticRVO(Const.COMPONENT_RVO)
	end
end

function AIControllerUtils.setEnableRVO(entity, enable, rvoDisableControlType)
	if entity.eModel then
		entity.eModel:SetEnableRVO(Const.COMPONENT_RVO, enable, rvoDisableControlType)
	end
end

function AIControllerUtils.setEnableController(entity, enable, controllerDisableControlType)
	if entity.eModel then
		entity.eModel:SetAIEnable(Const.COMPONENT_AI_CONTROLLER, enable, controllerDisableControlType)
	end
end

function AIControllerUtils.refreshAllSpeed(entity)
	if not entity or not entity.eModel or not entity.actorCombatAttribute then
		return
	end

	local runSpeed = AIControllerUtils.getRunSpeed(entity, true)
	local walkSpeed = AIControllerUtils.getWalkSpeed(entity, true)
	local sprintSpeed = AIControllerUtils.getSprintSpeed(entity, true)
	local speedBurstSpeed = AIControllerUtils.getSpeedBurstSpeed(entity, true)
	local glideSpeed = AIControllerUtils.getGlideSpeed(entity, true)
	local sneakSpeed = AIControllerUtils.getSneakSpeed(entity, true)
	local groundWalkSpeed = AIControllerUtils.getGroundWalkSpeed(entity, true)
	local flyingSpeed = AIControllerUtils.getFlyingSpeed(entity, true)
	local swimSpeed = AIControllerUtils.getSwimSpeed(entity, true)
	local swimFastSpeed = AIControllerUtils.getSwimFastSpeed(entity, true)
	local climbSpeed = AIControllerUtils.getClimbSpeed(entity, true)
	local skateBoardSpeed = AIControllerUtils.getSkateBoardSpeed(entity, true)

	entity.eModel:SetAISpeed(CommonConst.COMPONENT_AI_CONTROLLER, runSpeed, walkSpeed, sprintSpeed, speedBurstSpeed, glideSpeed, sneakSpeed, groundWalkSpeed, flyingSpeed, swimSpeed, swimFastSpeed, climbSpeed, skateBoardSpeed)
	AIControllerUtils.getSideWalkSpeed(entity, true)
	AIControllerUtils.getWalkBackSpeed(entity, true)
end

function AIControllerUtils.refreshRunSpeed(entity)
	if entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AIRunSpeed = AIControllerUtils.getRunSpeed(entity, true)
	end
end

function AIControllerUtils.refreshWalkSpeed(entity)
	if entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AIWalkSpeed = AIControllerUtils.getWalkSpeed(entity, true)
	end
end

function AIControllerUtils.refreshSprintSpeed(entity)
	if entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AISprintSpeed = AIControllerUtils.getSprintSpeed(entity, true)
	end
end

function AIControllerUtils.refreshSpeedBurstSpeed(entity)
	if entity.eModel then
		entity.eModel.AISpeedBurstSpeed = AIControllerUtils.getSpeedBurstSpeed(entity, true)
	end
end

function AIControllerUtils.refreshFlyingSpeed(entity)
	if entity.eModel then
		entity.eModel.flySpeed = AIControllerUtils.getFlyingSpeed(entity, true)
	end
end

function AIControllerUtils.refreshSwimSpeed(entity)
	local canSwim = AIControllerUtils.checkCanSwim(entity)

	if canSwim and entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AISwimSpeed = AIControllerUtils.getSwimSpeed(entity, true)
	end
end

function AIControllerUtils.refreshSwimFastSpeed(entity)
	local canSwim = AIControllerUtils.checkCanSwim(entity)

	if canSwim and entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AISwimFastSpeed = AIControllerUtils.getSwimFastSpeed(entity, true)
	end
end

function AIControllerUtils.refreshGlideSpeed(entity)
	local canGlide = AIControllerUtils.checkCanGlide(entity)

	if canGlide and entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AIGlideSpeed = AIControllerUtils.getGlideSpeed(entity, true)
	end
end

function AIControllerUtils.refreshSkateBoardSpeed(entity)
	local canSkateBoard = AIControllerUtils.checkCanSkateBoard(entity)

	if canSkateBoard and entity.eModel and entity.actorCombatAttribute then
		entity.eModel.AISkateBoardSpeed = AIControllerUtils.getSkateBoardSpeed(entity, true)
	end
end

function AIControllerUtils.setAuthority(entity, enable)
	if EnableBotTest then
		return
	end

	if not Utils.checkClient() then
		return
	end

	if enable then
		entity:SetKccEnable(true, Const.KccDisableReason.Authority)

		if entity.eModel then
			entity.eModel:SetMotionEnable(Const.COMPONENT_MOTION, true, Const.MotionDisableReason.Authority)
		end

		entity:dynamicAddEModelComponent(CommonConst.COMPONENT_AUTO_PATH_FIND)

		if not entity:hasEModelComponent(CommonConst.COMPONENT_AI_CONTROLLER) then
			entity:dynamicAddEModelComponent(CommonConst.COMPONENT_AI_CONTROLLER)
			AIControllerUtils.initEntity(entity, CharacterStateConst.getParentState(entity.motionState))
			AIControllerUtils.refreshAllSpeed(entity)
		end
	else
		entity:SetKccEnable(false, Const.KccDisableReason.Authority)
		entity.eModel:SetMotionEnable(Const.COMPONENT_MOTION, false, Const.MotionDisableReason.Authority)
		entity:delEModelComponent(CommonConst.COMPONENT_AI_CONTROLLER)
		entity:delEModelComponent(CommonConst.COMPONENT_AUTO_PATH_FIND)
	end
end

function AIControllerUtils.checkOpen(entity)
	if Utils.checkClient() then
		local ClientModelUtils = require("Utils.ClientModelUtils")
		local configData = entity:getConfigData()

		return ClientModelUtils.getAnimController(configData) ~= nil
	else
		return false
	end
end

function AIControllerUtils.getStaticSpawnOverAnim(entity)
	local sceneEntityData = SceneUtils.getSceneEntityData(entity.space.sceneId, entity.space.id)
	local staticData = entity.staticId and sceneEntityData[entity.staticId]
	local animName = staticData and staticData.staticSpawnOverAnimName

	return animName and PlayableConst[animName] or 0
end

function AIControllerUtils.getStaticSpawnEntityTagList(entity)
	local sceneEntityData = SceneUtils.getSceneEntityData(entity.space.sceneId, entity.space.id)
	local staticData = entity.staticId and sceneEntityData[entity.staticId]

	return staticData and staticData.staticSpawnEntityTagList or AiConst.DefaultNullTable
end

function AIControllerUtils.startGrabEntity(entity, beGrabActorId)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			return eModel:StartGrabEntity(CommonConst.COMPONENT_AI_CONTROLLER, beGrabActorId)
		end
	end

	return false
end

function AIControllerUtils.stopGrabEntity(entity)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			return eModel:EndGrabEntity(CommonConst.COMPONENT_AI_CONTROLLER)
		end
	end

	return false
end

function AIControllerUtils.ignoreAILod(entity, ignore)
	if Utils.checkClient() then
		local eModel = entity and entity.eModel

		if eModel then
			entity.eModel:SetIgnoreAILod(CommonConst.COMPONENT_AI_CONTROLLER, ignore, AiConst.IgnoreAILuaLodReason)
		end
	end
end

function AIControllerUtils.setSteeringDeceleration(entity, enable, reason)
	if entity.eModel then
		entity.eModel:SetSteeringDeceleration(Const.COMPONENT_MOTION, enable, reason)
	end
end

function AIControllerUtils.setJumpInRunWarping(entity, targetPos, needAirDumping)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetJumpInRunWarping(CommonConst.COMPONENT_AI_CONTROLLER, targetPos, needAirDumping)
		end
	end
end

function AIControllerUtils.resetJumpInRunWarping(entity)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:ResetJumpInRunWarping(CommonConst.COMPONENT_AI_CONTROLLER)
		end
	end
end

function AIControllerUtils.setHideMimicryOutType(entity, needPlayAnim)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetHideMimicryOutType(CommonConst.COMPONENT_AI_CONTROLLER, needPlayAnim)
		end
	end
end

function AIControllerUtils.setPerformParams(entity, startAnimKey, loopAnimKey, endAnimKey, loopAnimTime)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetPerformParams(CommonConst.COMPONENT_AI_CONTROLLER, startAnimKey, loopAnimKey, endAnimKey, loopAnimTime)
		end
	end
end

return AIControllerUtils
