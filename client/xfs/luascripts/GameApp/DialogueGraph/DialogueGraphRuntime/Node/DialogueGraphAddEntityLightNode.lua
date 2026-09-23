-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphAddEntityLightNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphAddEntityLightNode = DialogueGraphFlowNode.extend("DialogueGraphAddEntityLightNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphAddEntityLightNode.run(ctx)
	if ctx:inputPort() == "Remove" then
		ctx:callCmd(NodeFunc.SCENE_DISABLE_ENTITY_LIGHT, ctx:nodeId())

		return
	end

	local lightResId = ctx:getField("lightResId")

	if string.isNilOrEmpty(lightResId) then
		return false, "灯光资源没配!"
	end

	local started = ctx:callCmd(NodeFunc.SCENE_START_ENTITY_LIGHT, ctx:nodeId(), lightResId, DialogueGraphUtils.toVector3(ctx:getInput("positionVInput", nil)), DialogueGraphUtils.toVector3(ctx:getInput("rotationVInput", nil)))

	if not started then
		return false, "灯光启动失败！"
	end

	ctx:triggerFlow("Out")
end

return DialogueGraphAddEntityLightNode
