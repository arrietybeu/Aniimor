-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCameraBlendNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCameraBlendNode = DialogueGraphFlowNode.extend("DialogueGraphCameraBlendNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Quaternion = Quaternion

local function stopDof(ctx)
	ctx:callCmd(NodeFunc.CAMERA_SET_DOF_ACTIVE, false)
end

function DialogueGraphCameraBlendNode.run(ctx)
	if ctx:inputPort() == "StopDof" then
		stopDof(ctx)

		return
	end

	local blendTime = ctx:getInput("blendTimeVInput", 0)
	local position = DialogueGraphUtils.toVector3(ctx:getInput("positionVInput"))
	local eulerAngle = DialogueGraphUtils.toVector3(ctx:getInput("rotationVInput"))
	local rotation = Quaternion.Euler(eulerAngle.x, eulerAngle.y, eulerAngle.z)
	local fov = ctx:getInput("fovVInput", 45)
	local extraParam = {
		blendExponent = ctx:getInput("blendExponentVInput", 2),
		blendFunction = DialogueGraphUtils.getCameraBlendFunction(ctx:getInput("blendFuncVInput", "EaseInOut")),
		cameraId = ctx:getField("cameraId", 0)
	}

	local function triggerFinish()
		ctx:cancelTimeout()
		ctx:triggerFlow("Finish")
	end

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		if blendTime > 0 then
			triggerFinish()
		else
			ctx:cancelTimeout()
			ctx:delayFrame(1, function()
				triggerFinish()
			end)
		end
	end

	ctx:startTimeout(blendTime + 2, function()
		if not ctx:tryConsumeRunToken() then
			return
		end

		triggerFinish()
	end)
	ctx:callCmd(NodeFunc.CAMERA_START_GRAPH_BLEND, position, rotation, fov, blendTime, finishCallback, extraParam)

	if ctx:getField("openDof", false) then
		local dofTarget = ctx:getInput("dofTargetVInput", nil)

		ctx:callCmd(NodeFunc.CAMERA_APPLY_DOF, ctx:nodeId(), {
			openDof = true,
			dofTarget = dofTarget,
			focalDistance = ctx:getField("focalDistance", 200),
			fStop = ctx:getField("fStop", 4),
			sensorWidth = ctx:getField("sensorWidth", 360),
			squeezeFactor = ctx:getField("squeezeFactor", 1),
			recombineQuality = ctx:getField("recombineQuality", 0),
			visualizeDOF = ctx:getField("visualizeDOF", false),
			focalDistanceOffset = ctx:getInput("focalDistanceOffsetVInput", 0)
		})
	end

	ctx:triggerFlow("Out")
end

return DialogueGraphCameraBlendNode
