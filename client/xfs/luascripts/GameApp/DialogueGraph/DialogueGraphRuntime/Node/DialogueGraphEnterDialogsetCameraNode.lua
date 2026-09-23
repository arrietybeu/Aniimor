-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEnterDialogsetCameraNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEnterDialogsetCameraNode = DialogueGraphFlowNode.extend("DialogueGraphEnterDialogsetCameraNode")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

local function enumValue(value, values, defaultValue)
	return tonumber(value) or values[value] or defaultValue
end

local function reset(ctx)
	if not ctx:stateGet("needReset", false) then
		return
	end

	ctx:stateSet("needReset", false)
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
		data.vector = DialogueGraphUtils.toVector3(ctx:getInput("cameraMovementVectorVInput", nil))
	else
		data.angle = ctx:getInput("cameraMovementAngleVInput", 0)
	end

	return data
end

function DialogueGraphEnterDialogsetCameraNode.run(ctx)
	if ctx:inputPort() == "Stop" then
		reset(ctx)

		return
	end

	local cameraId = ctx:getInput("cameraIdVInput", 0)

	if cameraId <= 0 then
		return false, "CameraId为空！"
	end

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Out")
	end

	local param = {
		applyCameraFinishCallback = finishCallback,
		cameraId = cameraId,
		cameraBlendInTime = ctx:getInput("blendInTimeVInput", -1),
		cameraBlendOutTime = ctx:getInput("blendOutTimeVInput", -1),
		cameraBlendFuction = enumValue(ctx:getInput("blendFuctionVInput", 2), DialogueGraphConst.BlendFunction, 2),
		cameraOpenDOF = ctx:getInput("openDOFVInput", true),
		movementData = buildMovementData(ctx)
	}

	ctx:stateSet("needReset", true)
	ctx:callCmd(NodeFunc.DIALOGUE_APPLY_DIALOGSET_CAMERA, param)
end

function DialogueGraphEnterDialogsetCameraNode.onGraphFinished(ctx)
	reset(ctx)
end

return DialogueGraphEnterDialogsetCameraNode
