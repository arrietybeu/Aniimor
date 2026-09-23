-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphResetAllActionsNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphResetAllActionsNode = DialogueGraphFlowNode.extend("DialogueGraphResetAllActionsNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Time = require("Core.Common.Time")

function DialogueGraphResetAllActionsNode.run(ctx)
	ctx:callCmd(NodeFunc.ENTITY_RESET_PLAYER_ACTIONS)

	if ctx:getInput("waitPlayerIdleVInput", false) ~= true then
		ctx:triggerFlow("Finish")

		return
	end

	local startedAt = Time.realtimeSinceStartup

	local function waitIdle()
		if not ctx:isValid() then
			return
		end

		local isIdle = ctx:callCmd(NodeFunc.ENTITY_IS_PLAYER_IDLE)

		if isIdle or Time.realtimeSinceStartup - startedAt > 5 then
			ctx:triggerFlow("Finish")

			return
		end

		ctx:delayFrame(4, waitIdle)
	end

	waitIdle()
end

return DialogueGraphResetAllActionsNode
