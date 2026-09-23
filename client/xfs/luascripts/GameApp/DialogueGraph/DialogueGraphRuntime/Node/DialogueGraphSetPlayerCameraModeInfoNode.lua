-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSetPlayerCameraModeInfoNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphSetPlayerCameraModeInfoNode = DialogueGraphFlowNode.extend("DialogueGraphSetPlayerCameraModeInfoNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Quaternion = Quaternion

function DialogueGraphSetPlayerCameraModeInfoNode.run(ctx)
	local param = {}
	local zoom = ctx:getInput("zoomVInput", 0)

	if zoom > 0 then
		param.zoomValue = zoom
	end

	local rotationValue = ctx:getInput("controlRotationVInput")
	local rotation = DialogueGraphUtils.toVector3(rotationValue)

	if rotation.x ~= 0 or rotation.y ~= 0 or rotation.z ~= 0 then
		param.controlRotation = Quaternion.Euler(rotation.x, rotation.y, rotation.z)
	end

	ctx:callCmd(NodeFunc.CAMERA_PLAYER_SET_ZOOM_AND_ROTATION, param)
	ctx:triggerFlow("Out")
end

return DialogueGraphSetPlayerCameraModeInfoNode
