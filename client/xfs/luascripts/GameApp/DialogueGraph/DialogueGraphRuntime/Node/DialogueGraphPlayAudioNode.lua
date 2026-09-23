-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphPlayAudioNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphPlayAudioNode = DialogueGraphFlowNode.extend("DialogueGraphPlayAudioNode")

function DialogueGraphPlayAudioNode.run(ctx)
	if ctx:inputPort() == "Stop" then
		local resId = ctx:stateGet("resId")

		if not string.isNilOrEmpty(resId) then
			ctx:callCmd(NodeFunc.STOP_SOUND, resId)
		end

		return
	end

	local resId = ctx:getInput("audioEventVInput")

	if string.isNilOrEmpty(resId) then
		return false, "没有配置音效资源"
	end

	ctx:stateSet("resId", resId)

	local isBGM = ctx:getInput("isBGMVInput", false) == true
	local audioTransform = ctx:getInput("audioTransformVInput", nil)
	local audioPlayer = audioTransform ~= nil and audioTransform.gameObject or nil

	ctx:callCmd(NodeFunc.PLAY_SOUND, resId, isBGM, audioPlayer)
	ctx:triggerFlow("Out")
end

return DialogueGraphPlayAudioNode
