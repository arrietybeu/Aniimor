-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphModeNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphModeNode = DialogueGraphFlowNode.extend("DialogueGraphModeNode")

local function cloneTable(source)
	local result = {}

	for key, value in pairs(source or EMPTY_TABLE) do
		result[key] = value
	end

	return result
end

function DialogueGraphModeNode.run(ctx)
	local param = cloneTable(ctx:getField("modeInfo", {}) or {})
	local onSkipStartConnected = ctx:getField("onSkipStartConnected", false)
	local hasOnSkipStartFlow = ctx:hasFlowConnection("OnSkipStart")

	if onSkipStartConnected or hasOnSkipStartFlow then
		param.turnOnPlayback = true

		function param.onSkipFinishCallback()
			if ctx:refreshFlowPassToken() then
				ctx:triggerFlow("OnSkipStart")
			end
		end
	end

	ctx:callCmd(NodeFunc.DIALOGUE_SET_MODEL, param)
	ctx:triggerFlow("Out")
end

return DialogueGraphModeNode
