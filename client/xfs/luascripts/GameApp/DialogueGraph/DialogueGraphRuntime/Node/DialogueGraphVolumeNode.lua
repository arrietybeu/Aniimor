-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphVolumeNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local DialogueGraphVolumeNode = DialogueGraphFlowNode.extend("DialogueGraphVolumeNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

local function nodeData(ctx)
	local runtime = ctx.runtime
	local node = runtime and runtime.nodes and runtime.nodes[ctx:nodeId()] or nil

	return node and node.fields or {}
end

function DialogueGraphVolumeNode.run(ctx)
	local inputPort = ctx:inputPort()

	if inputPort == "Stop" then
		ctx:callCmd(NodeFunc.SCENE_DISABLE_VOLUME, ctx:nodeId())

		return
	end

	if inputPort == "开始动画" then
		DynamicValueRuntime.bindAll(ctx)

		return
	end

	if inputPort == "停止动画" then
		ctx:callCmd(NodeFunc.SCENE_STOP_VOLUME_ANIMATION, ctx:nodeId())

		return
	end

	local data = nodeData(ctx)
	local applied = ctx:callCmd(NodeFunc.SCENE_APPLY_VOLUME, ctx:nodeId(), data)

	if applied and ctx:getInput("autoStartAniVInput", true) then
		DynamicValueRuntime.bindAll(ctx)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphVolumeNode.onGraphFinished(ctx)
	ctx:callCmd(NodeFunc.SCENE_RESET_VOLUME, ctx:nodeId())
end

return DialogueGraphVolumeNode
