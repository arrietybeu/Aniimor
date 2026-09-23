-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCancelPlayerCameraFocusFovNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCancelPlayerCameraFocusFovNode = DialogueGraphFlowNode.extend("DialogueGraphCancelPlayerCameraFocusFovNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCancelPlayerCameraFocusFovNode.run(ctx)
	local param = {
		fovBlendOutFunc = DialogueGraphUtils.getCameraBlendFunction(ctx:getInput("fovBlendOutFuncVInput", "EaseInOut"))
	}

	if ctx:getInput("cancelFocusToTargetVInput", false) then
		param.cancelFaceToTarget = true
	end

	if ctx:getInput("cancelBlendFovVInput", false) then
		param.cancelFovBlend = true
		param.fovBlendOutTime = ctx:getInput("fovBlendOutTimeVInput", 0)
	end

	if ctx:getInput("cancelModifyYawSpeedRatioVInput", false) then
		param.cancelModifyYawSpeedRatioZoom = true
	end

	if ctx:getInput("cancelModifyPitchSpeedRatioVInput", false) then
		param.cancelModifyPitchSpeedRatioZoom = true
	end

	if ctx:getInput("cancelSetPlayerCamShoulderVInput", false) then
		param.cancelSetPlayerCamShoulder = true
	end

	ctx:callCmd(NodeFunc.CAMERA_PLAYER_CANCEL_MODIFY_INFO, param)
	ctx:triggerFlow("Out")
end

return DialogueGraphCancelPlayerCameraFocusFovNode
