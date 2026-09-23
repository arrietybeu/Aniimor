-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSetPlayerCameraFocusFovNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphSetPlayerCameraFocusFovNode = DialogueGraphFlowNode.extend("DialogueGraphSetPlayerCameraFocusFovNode")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local NodeFunc = DialogueGraphConst.NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")

function DialogueGraphSetPlayerCameraFocusFovNode.run(ctx)
	local maxLockTime = ctx:getInput("maxLockTimeVInput", 0)

	if maxLockTime > 0 then
		ctx:delay(maxLockTime, function()
			if ctx:isValid() then
				ctx:triggerFlow("LockTimeOut")
			end
		end)
	end

	local param = {}
	local faceToTarget = ctx:getInput("faceToTargetVInput")

	if faceToTarget ~= nil then
		param.faceToTarget = faceToTarget
		param.heightDelta = ctx:getInput("heightDeltaVInput", 0)
		param.shoulder = DialogueGraphUtils.toVector3(ctx:getInput("shoulderVInput"))
		param.transitionSpeed = ctx:getInput("transitionSpeedVInput", 0.5)
		param.rotSpeedCurve = ctx:getInput("rotSpeedCurveVInput")
		param.maxLockTime = maxLockTime
		param.resetOnFinish = ctx:getInput("resetOnFinishVInput", false)
	end

	local fov = ctx:getInput("blendToFovVInput", 0)

	if fov ~= nil and fov > 0 then
		param.fov = fov
		param.fovBlendTime = ctx:getInput("fovBlendTimeVInput", 0)

		local fovBlendFunc = ctx:getInput("fovBlendFuncVInput", "EaseInOut")

		param.fovBlendFunc = DialogueGraphUtils.getCameraBlendFunction(fovBlendFunc)
	end

	local targetZoom = ctx:getInput("targetZoomVInput", 0)

	if targetZoom ~= nil and targetZoom > 0 then
		param.targetZoom = targetZoom
	end

	local yawSpeedRatio = ctx:getInput("yawSpeedRatioVInput", 0)

	if yawSpeedRatio ~= nil and yawSpeedRatio > 0 then
		param.yawSpeedRatio = yawSpeedRatio
	end

	local pitchSpeedRatio = ctx:getInput("pitchSpeedRatioVInput", 0)

	if pitchSpeedRatio ~= nil and pitchSpeedRatio > 0 then
		param.pitchSpeedRatio = pitchSpeedRatio
	end

	param.playerCamShoulder = DialogueGraphUtils.toVector3(ctx:getInput("playerCamShoulderVInput"))
	param.playerCamTransitionSpeed = ctx:getInput("playerCamTransitionSpeedVInput", 5)

	ctx:callCmd(NodeFunc.CAMERA_PLAYER_MODIFY_INFO, param)
	ctx:triggerFlow("Out")
end

return DialogueGraphSetPlayerCameraFocusFovNode
