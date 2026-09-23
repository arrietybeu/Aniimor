-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphConditionNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphConditionNode = DialogueGraphFlowNode.extend("DialogueGraphConditionNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Logger = LoggerManager.getLogger("DialogueGraphConditionNode")

function DialogueGraphConditionNode.run(ctx)
	local triggerId = ctx:getInput("triggerIdVInput", 0)

	if triggerId <= 0 then
		ctx:triggerFlow("False")

		return false, "没有配置触发器ID"
	end

	local passed = ctx:callCmd(NodeFunc.CONDITION_CHECK_TRIGGER, triggerId) == true

	ctx:triggerFlow(passed and "True" or "False")
end

return DialogueGraphConditionNode
