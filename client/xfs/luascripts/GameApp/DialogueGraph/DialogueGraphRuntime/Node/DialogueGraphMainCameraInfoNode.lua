-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphMainCameraInfoNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphMainCameraInfoNode = DialogueGraphFlowNode.extend("DialogueGraphMainCameraInfoNode")

local function getCamera()
	return appFacade ~= nil and appFacade.cameraManager ~= nil and appFacade.cameraManager.worldCameraInst or nil
end

function DialogueGraphMainCameraInfoNode.getTransform(ctx)
	local camera = getCamera()

	return camera ~= nil and camera.transform or nil
end

function DialogueGraphMainCameraInfoNode.getPosition(ctx)
	local transform = DialogueGraphMainCameraInfoNode.getTransform(ctx)

	return transform ~= nil and transform.position or Vector3.zero
end

function DialogueGraphMainCameraInfoNode.getEulerAngle(ctx)
	local transform = DialogueGraphMainCameraInfoNode.getTransform(ctx)

	return transform ~= nil and transform.eulerAngles or Vector3.zero
end

function DialogueGraphMainCameraInfoNode.getFov(ctx)
	local camera = getCamera()

	return camera ~= nil and camera.fieldOfView or 0
end

return DialogueGraphMainCameraInfoNode
