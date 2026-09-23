-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphPlayAnimatorStateNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphPlayAnimatorStateNode = DialogueGraphFlowNode.extend("DialogueGraphPlayAnimatorStateNode")

function DialogueGraphPlayAnimatorStateNode.run(ctx)
	local target = ctx:getInput("targetVInput")

	if target == nil then
		return false, "目标不存在！", true
	end

	local stateName = ctx:getInput("stateNameVInput")

	if string.isNilOrEmpty(stateName) then
		return false, "没有配置状态名称！"
	end

	local result = tonumber(ctx:callCmd(NodeFunc.ENTITY_PLAY_ANIMATOR_STATE, target, stateName)) or -3

	if result <= 0 then
		return false, "播放动画片段失败！"
	end

	ctx:triggerFlow("Out")
end

return DialogueGraphPlayAnimatorStateNode
