-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityMoveNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntityMoveNode = DialogueGraphFlowNode.extend("DialogueGraphEntityMoveNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphEntityMoveNode.run(ctx)
	local targetPosition = DialogueGraphUtils.toVector3(ctx:getInput("targetPositionVInput"))
	local targetEulerAngle = DialogueGraphUtils.toVector3(ctx:getInput("targetEulerAngleVInput"))
	local moveMode = ctx:getInput("moveModeVInput", 0)
	local moveType = ctx:getInput("moveTypeVInput", 1)

	if targetPosition == nil or moveMode == 0 and moveType == 0 then
		return false, "实体移动参数异常"
	end

	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		return false, string.format("实体不存在 entityId：%s staticId:%s", tostring(entityId), tostring(staticId)), true
	end

	local autoPathfinding = ctx:getInput("autoPathfindingVInput", false)
	local finishToSteer = ctx:getField("finishToSteer", false)
	local speed = ctx:getInput("speedVInput", 1)
	local maxLimitTime = ctx:getInput("maxLimitTimeVInput", 5)
	local duration = ctx:getInput("durationVInput", 1)
	local faceMoveDirection = ctx:getInput("faceMoveDirectionVInput", true)
	local speedCurve = ctx:getField("speedCurve", nil)

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:stateSet("moveEntityId", nil)
		ctx:triggerFlow("FinishOut")
	end

	local moveConfig = {
		staticId = 0,
		taskId = ctx:nodeId(),
		entityId = entity.id,
		moveMode = moveMode,
		moveType = moveType,
		targetPosition = targetPosition,
		targetEulerAngle = targetEulerAngle,
		speed = speed,
		autoPathfinding = autoPathfinding,
		duration = duration,
		faceMoveDirection = faceMoveDirection,
		finishToSteer = finishToSteer,
		maxLimitTime = maxLimitTime,
		callback = finishCallback
	}

	if moveMode == 1 then
		moveConfig.speedCurve = speedCurve
	end

	local started = ctx:callCmd(NodeFunc.ENTITY_START_MOVE, moveConfig)

	if not started then
		return false, "对话图移动失败！"
	else
		ctx:stateSet("moveEntityId", entity.id)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphEntityMoveNode.onGraphFinished(ctx)
	local entityId = ctx:stateGet("moveEntityId")

	if entityId == nil then
		return
	end

	ctx:stateSet("moveEntityId", nil)
	ctx:callCmd(NodeFunc.ENTITY_DISABLE_DIALOGUE_CONTROLLER, entityId)
end

return DialogueGraphEntityMoveNode
