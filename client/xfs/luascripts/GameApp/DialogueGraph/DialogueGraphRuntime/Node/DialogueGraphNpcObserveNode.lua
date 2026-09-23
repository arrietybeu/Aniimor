-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphNpcObserveNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphNpcObserveNode = DialogueGraphFlowNode.extend("DialogueGraphNpcObserveNode")
local ERROR_PORT = "ErrorOut"

local function selectError(ctx)
	if ctx:hasFlowConnection(ERROR_PORT) then
		ctx:triggerFlow(ERROR_PORT)
	else
		ctx:finishGraph(-1)
	end
end

function DialogueGraphNpcObserveNode.run(ctx)
	local portCount = math.max(0, ctx:getField("portCount", 2))
	local info = {
		dialogueGraph = true,
		npcObserveId = ctx:getField("observeId", 0),
		clueCall = function(luaIndex)
			if not ctx:tryConsumeRunToken() then
				return
			end

			local index = math.floor((tonumber(luaIndex) or 0) + 0.5) - 1

			if index < 0 or index >= portCount then
				selectError(ctx)
			else
				ctx:triggerFlow(tostring(index))
			end
		end,
		errorCall = function()
			if ctx:tryConsumeRunToken() then
				selectError(ctx)
			end
		end
	}

	ctx:callCmd(NodeFunc.DIALOGUE_OPEN_NPC_OBSERVE, info)
end

function DialogueGraphNpcObserveNode.onGraphFinished(ctx)
	ctx:callCmd(NodeFunc.DIALOGUE_CLEAR_NPC_OBSERVE)
end

return DialogueGraphNpcObserveNode
