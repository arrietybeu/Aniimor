-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDisableVegetationCullingNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphDisableVegetationCullingNode = DialogueGraphFlowNode.extend("DialogueGraphDisableVegetationCullingNode")

function DialogueGraphDisableVegetationCullingNode.run(ctx)
	local disableVegetationCulling = ctx:getField("disableVegetationCullingVInput", false)
	local succeeded = ctx:callCmd(NodeFunc.SCENE_SET_VEGETATION_CULLING_DISABLED, disableVegetationCulling)

	if succeeded ~= true then
		return false, "设置植被剔除状态失败！"
	end

	ctx:stateSet("reset", true)
	ctx:triggerFlow("Out")
end

function DialogueGraphDisableVegetationCullingNode.onGraphFinished(ctx)
	if ctx:stateGet("reset") ~= true then
		return
	end

	ctx:callCmd(NodeFunc.SCENE_RESET_VEGETATION_CULLING)
end

return DialogueGraphDisableVegetationCullingNode
