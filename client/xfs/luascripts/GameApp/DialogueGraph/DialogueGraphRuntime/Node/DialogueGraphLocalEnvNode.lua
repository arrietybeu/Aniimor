-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphLocalEnvNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphLocalEnvNode = DialogueGraphFlowNode.extend("DialogueGraphLocalEnvNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphLocalEnvNode.run(ctx)
	local resId = ctx:getField("localEnvResID")

	if string.isNilOrEmpty(resId) then
		return false, "没有配置局部环境资源ID！"
	end

	local position = DialogueGraphUtils.toVector3(ctx:getInput("positionVInput", nil))

	if not ctx:callCmd(NodeFunc.SCENE_START_LOCAL_ENVIRONMENT, ctx:nodeId(), resId, position) then
		return false, "局部环境启动失败！"
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphLocalEnvNode.onGraphFinished(ctx)
	ctx:callCmd(NodeFunc.SCENE_STOP_LOCAL_ENVIRONMENT, ctx:nodeId())
end

return DialogueGraphLocalEnvNode
