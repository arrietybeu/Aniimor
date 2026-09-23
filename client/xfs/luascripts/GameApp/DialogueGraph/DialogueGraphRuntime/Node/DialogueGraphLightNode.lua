-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphLightNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphLightNode = DialogueGraphFlowNode.extend("DialogueGraphLightNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

local function nodeFields(ctx)
	local runtime = ctx.runtime
	local node = runtime and runtime.nodes and runtime.nodes[ctx:nodeId()] or nil

	return node and node.fields or {}
end

function DialogueGraphLightNode.run(ctx)
	if ctx:inputPort() == "Close" then
		ctx:callCmd(NodeFunc.SCENE_DISABLE_LIGHT, ctx:nodeId())

		return
	end

	local fields = nodeFields(ctx)
	local color = DialogueGraphUtils.toColor(fields.color)
	local position = DialogueGraphUtils.toVector3(ctx:getInput("positionVInput", nil))
	local rotation = DialogueGraphUtils.toVector3(ctx:getInput("rotationVInput", nil))
	local started = ctx:callCmd(NodeFunc.SCENE_START_LIGHT, ctx:nodeId(), fields, color, position, rotation)

	if started then
		DynamicValueRuntime.bindAll(ctx)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphLightNode.onGraphFinished(ctx)
	ctx:callCmd(NodeFunc.SCENE_STOP_LIGHT, ctx:nodeId())
end

return DialogueGraphLightNode
