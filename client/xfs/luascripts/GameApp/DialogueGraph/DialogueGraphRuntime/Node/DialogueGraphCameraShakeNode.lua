-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCameraShakeNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphCameraShakeNode = DialogueGraphFlowNode.extend("DialogueGraphCameraShakeNode")

function DialogueGraphCameraShakeNode.run(ctx)
	local shakeConfig = ctx:getField("cameraShakeItem", nil)

	if shakeConfig == nil then
		return false, "相机震动配置shakeConfig不存在！"
	end

	local shakeType = shakeConfig.shakeType or ctx:getField("shakeType", 0)

	if ctx:callCmd(NodeFunc.CAMERA_START_SHAKE, ctx:nodeId(), shakeType, shakeConfig) == false then
		return false, "相机震动启动失败！"
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphCameraShakeNode.onGraphFinished(ctx)
	local shakeConfig = ctx:getField("cameraShakeItem", nil)

	if shakeConfig ~= nil and shakeConfig.holdForever == true then
		ctx:callCmd(NodeFunc.CAMERA_STOP_SHAKE, ctx:nodeId())
	end
end

return DialogueGraphCameraShakeNode
