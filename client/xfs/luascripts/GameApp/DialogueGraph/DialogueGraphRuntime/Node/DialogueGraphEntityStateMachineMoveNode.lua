-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityStateMachineMoveNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEntityStateMachineMoveNode = DialogueGraphFlowNode.extend("DialogueGraphEntityStateMachineMoveNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local MoveState = {
	CharacterStateConst.WALK,
	CharacterStateConst.RUN,
	CharacterStateConst.CROUCHING,
	CharacterStateConst.SPRINT
}
local MoveType = {
	EMT_SPRINT = 4,
	EMT_CROUCH = 3,
	EMT_RUN = 2,
	EMT_WALK = 1,
	EMT_NONE = 0
}
local Quaternion = Quaternion

local function stopEntityMovement(ctx)
	local param = ctx:stateGet("moveParam")

	if param then
		param.finished = true

		ctx:stateSet("moveParam", nil)
	end

	local entityId = ctx:stateGet("entityId")

	if string.isNilOrEmpty(entityId) then
		return
	end

	ctx:stateSet("entityId", nil)
	ctx:callCmd(NodeFunc.ENTITY_SET_ANIM_SPEED, entityId, -1)
	ctx:callCmd(NodeFunc.ENTITY_STOP_AUTO_PATH_FINDING, entityId)
	ctx:callCmd(NodeFunc.ENTITY_DISABLE_DIALOGUE_CONTROLLER, entityId)
end

local function moveTypeValue(value)
	return tonumber(value) or MoveType[value] or 0
end

local function approximately(left, right, threshold)
	if left == nil or right == nil then
		return false
	end

	local dx = left.x - right.x
	local dy = left.y - right.y
	local dz = left.z - right.z

	return dx * dx + dy * dy + dz * dz <= threshold * threshold
end

function DialogueGraphEntityStateMachineMoveNode.run(ctx)
	stopEntityMovement(ctx)

	local idStr = ctx:getInput("entityIdVInput")
	local moveType = moveTypeValue(ctx:getInput("moveTypeVInput", 1))
	local targetPosition = DialogueGraphUtils.toVector3(ctx:getInput("targetPositionVInput", nil))
	local targetEuler = DialogueGraphUtils.toVector3(ctx:getInput("targetEulerAngleVInput", nil))

	if string.isNilOrEmpty(idStr) or moveType == 0 or targetPosition == nil then
		return false, "movement parameters are invalid"
	end

	local entity = DialogueGraphUtils.getEntity(idStr)

	if entity == nil then
		return false, string.format("找不到对应实体！idStr:%s", tostring(idStr)), true
	end

	local entityId = entity.id

	ctx:callCmd(NodeFunc.ENTITY_PAUSE_BT, entityId, 0)

	if ctx:callCmd(NodeFunc.ENTITY_SET_ENTITY_TAKE_OVER, entityId) == false then
		return false, "entity takeover failed"
	end

	ctx:stateSet("entityId", entityId)

	local finishToSteer = ctx:getField("finishToSteer", false)

	local function finishCallback(stopMove)
		if not ctx:tryConsumeRunToken() then
			return
		end

		if stopMove then
			stopEntityMovement(ctx)
		end

		local curPosition = entity:getPosition()

		if not approximately(curPosition, targetPosition, 0.1) then
			DialogueGraphUtils.setEntityPosition(entity, targetPosition)

			if finishToSteer then
				local rotation = Quaternion.Euler(targetEuler.x, targetEuler.y, targetEuler.z)

				DialogueGraphUtils.setEntityRotation(entity, rotation.x, rotation.y, rotation.z, rotation.w, true)
			end
		end

		ctx:stateSet("moveParam", nil)
		ctx:stateSet("entityId", nil)
		ctx:triggerFlow("FinishOut")
	end

	local curPosition = entity:getPosition()

	if approximately(curPosition, targetPosition, 0.05) and not finishToSteer then
		finishCallback()
		ctx:triggerFlow("Out")

		return
	end

	local timeout = ctx:getInput("maxLimitTimeVInput", 10)

	ctx:delay(timeout > 0 and timeout or 5, function()
		finishCallback(true)
	end)
	ctx:callCmd(NodeFunc.ENTITY_DISABLE_DIALOGUE_CONTROLLER, entityId)

	local function startMoveWhenIdle()
		if not ctx:isValid() then
			return
		end

		if not ctx:callCmd(NodeFunc.ENTITY_IS_IDLE, 0, entityId) then
			ctx:delayFrame(4, startMoveWhenIdle)

			return
		end

		local param = {
			entityId = entityId,
			toPos = targetPosition,
			pathFindingType = ctx:getInput("autoPathfindingVInput", false) and 5 or 3,
			arriveCallback = finishCallback,
			animSpeed = ctx:getInput("speedVInput", 1),
			moveState = MoveState[moveType]
		}

		if finishToSteer then
			param.steerToRot = targetEuler
		end

		ctx:stateSet("moveParam", param)
		ctx:callCmd(NodeFunc.ENTITY_AUTO_PATH_FINDING, param)
	end

	startMoveWhenIdle()
	ctx:triggerFlow("Out")
end

function DialogueGraphEntityStateMachineMoveNode.onGraphFinished(ctx)
	return
end

return DialogueGraphEntityStateMachineMoveNode
