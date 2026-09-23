-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEnterDialogsetNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEnterDialogsetNode = DialogueGraphFlowNode.extend("DialogueGraphEnterDialogsetNode")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local NodeFunc = DialogueGraphConst.NODE_FUNC_TYPE
local Quaternion = Quaternion
local EnterType = {
	Teleport = 1,
	Move = 2
}
local ExitType = {
	KeepOriginal = 2,
	ResetPosition = 1
}

local function enumValue(value, values, defaultValue)
	return tonumber(value) or values[value] or defaultValue
end

local function rememberPose(ctx, entityId, csEntity, position, euler)
	if entityId == nil or position == nil or euler == nil then
		return
	end

	local resetEntities = ctx:stateGet("resetEntities")

	if resetEntities == nil then
		resetEntities = {}

		ctx:stateSet("resetEntities", resetEntities)
	end

	if resetEntities[entityId] == nil then
		resetEntities[entityId] = {
			entity = csEntity,
			position = position,
			euler = euler
		}
	end
end

local function reset(ctx)
	local param = ctx:stateGet("dialogsetParam")

	ctx:stateSet("dialogsetParam", nil)

	if param ~= nil then
		ctx:callCmd(NodeFunc.DIALOGUE_CANCEL_PENDING_DIALOGSET, param)
	end

	if not ctx:stateGet("needReset", false) then
		return
	end

	ctx:stateSet("needReset", false)

	local resetEntities = ctx:stateGet("resetEntities")

	if resetEntities ~= nil then
		for _, data in pairs(resetEntities) do
			if data.entity ~= nil then
				if data.entity == pg.pawn then
					ctx:callCmd(NodeFunc.ENTITY_FORBID_POSITION_CHECK, data.position)
				end

				DialogueGraphUtils.setEntityPosition(data.entity, data.position)

				local rotation = Quaternion.Euler(data.euler.x or 0, data.euler.y or 0, data.euler.z or 0)

				DialogueGraphUtils.setEntityRotation(data.entity, rotation.x, rotation.y, rotation.z, rotation.w, true)
			end
		end
	end

	ctx:stateSet("resetEntities", nil)
	ctx:callCmd(NodeFunc.CAMERA_RESET_DIALOGSET)
end

local function buildMovementData(ctx)
	local movementType = enumValue(ctx:getInput("cameraMovementTypeVInput", 0), DialogueGraphConst.MovementType, 0)
	local blendTime = ctx:getInput("cameraMovementTimeVInput", 0)

	if movementType == 0 or blendTime == 0 then
		return nil
	end

	local data = {
		type = movementType,
		blendTime = blendTime,
		blendFunc = enumValue(ctx:getInput("cameraMovementFuncVInput", 2), DialogueGraphConst.BlendFunction, 2),
		blendExp = ctx:getInput("cameraMovementExpVInput", 2),
		mode = enumValue(ctx:getInput("cameraMovementModeVInput", 0), DialogueGraphConst.MovementMode, 0)
	}

	if movementType == 1 then
		data.vector = DialogueGraphUtils.toVector3(ctx:getInput("cameraMovementVectorVInput"))
	else
		data.angle = ctx:getInput("cameraMovementAngleVInput", 0)
	end

	return data
end

function DialogueGraphEnterDialogsetNode.run(ctx)
	if ctx:inputPort() ~= nil and ctx:inputPort() ~= "In" then
		reset(ctx)

		return
	end

	local enterType = enumValue(ctx:getInput("enterTypeVInput", 1), EnterType, 1)
	local exitType = enumValue(ctx:getInput("exitTypeVInput", 1), ExitType, 1)
	local oldParam = ctx:stateGet("dialogsetParam")

	if oldParam ~= nil then
		ctx:callCmd(NodeFunc.DIALOGUE_CANCEL_PENDING_DIALOGSET, oldParam)
	end

	local param = {
		enterType = enterType,
		exitType = exitType,
		taskId = ctx:nodeId()
	}

	ctx:stateSet("dialogsetParam", param)

	function param.recordEntityCallback(entityId)
		if param.cancelled or not ctx:isValid() then
			return
		end

		local entity = DialogueGraphUtils.getEntityByGlobalId(entityId)

		if entity == nil then
			return
		end

		if exitType == ExitType.ResetPosition then
			rememberPose(ctx, entityId, entity, entity:getPosition(), entity:getRotation():ToEulerAngles())
		end
	end

	local cameraId = ctx:getInput("cameraIdVInput", 0)

	if cameraId > 0 then
		param.cameraId = cameraId
		param.cameraBlendInTime = ctx:getInput("blendInTimeVInput", -1)
		param.cameraBlendOutTime = ctx:getInput("blendOutTimeVInput", -1)
		param.cameraBlendFuction = enumValue(ctx:getInput("blendFuctionVInput", 2), DialogueGraphConst.BlendFunction, 2)
		param.cameraOpenDOF = ctx:getInput("openDOFVInput", true)
		param.movementData = buildMovementData(ctx)

		function param.applyCameraFinishCallback()
			if param.cancelled or not ctx:tryConsumeRunToken() then
				return
			end

			ctx:triggerFlow("Finish")
		end
	end

	ctx:stateSet("needReset", true)
	ctx:callCmd(NodeFunc.DIALOGUE_ENTER_DIALOGSET, param)

	if cameraId <= 0 then
		ctx:triggerFlow("Finish")
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphEnterDialogsetNode.onGraphFinished(ctx)
	reset(ctx)
end

return DialogueGraphEnterDialogsetNode
