-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphTriggerConditionNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphTriggerConditionNode = DialogueGraphFlowNode.extend("DialogueGraphTriggerConditionNode")

function DialogueGraphTriggerConditionNode.run(ctx)
	local condition = ctx:getField("condition", {})
	local triggerName = ctx:getInput("triggerNameInput", nil)

	if not string.isNilOrEmpty(triggerName) then
		local configuredCondition = condition or {}

		condition = {}

		for key, value in pairs(configuredCondition) do
			condition[key] = value
		end

		condition[1] = triggerName
	end

	local passed = ctx:callCmd(NodeFunc.CONDITION_CHECK_STATUS, condition)

	if passed then
		ctx:triggerFlow("True")
	else
		ctx:triggerFlow("False")
	end
end

return DialogueGraphTriggerConditionNode
