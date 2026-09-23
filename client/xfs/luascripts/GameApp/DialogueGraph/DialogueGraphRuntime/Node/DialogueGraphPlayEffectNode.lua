-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphPlayEffectNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphPlayEffectNode = DialogueGraphFlowNode.extend("DialogueGraphPlayEffectNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")

function DialogueGraphPlayEffectNode.run(ctx)
	local effectKey = ctx:getInput("effectKeyVInput")

	if string.isNilOrEmpty(effectKey) then
		ctx:triggerFlow("Finish")

		return
	end

	local entityId = ctx:getInput("entityIdVInput")

	if entityId == "" then
		entityId = nil
	end

	local generatorId = ctx:callCmd(NodeFunc.EFFECT_GET_GENERATOR_ID, entityId)

	if generatorId == nil or generatorId == 0 then
		ctx:triggerFlow("Finish")

		return
	end

	local effectId

	if string.isNilOrEmpty(entityId) then
		local position = DialogueGraphUtils.toVector3(ctx:getInput("postionVInput", nil))
		local rotation = DialogueGraphUtils.toVector3(ctx:getInput("rotationVInput", nil))

		effectId = ctx:callCmd(NodeFunc.EFFECT_PLAY, generatorId, effectKey, position, rotation)
	else
		effectId = ctx:callCmd(NodeFunc.EFFECT_PLAY, generatorId, effectKey)
	end

	ctx:stateSet("effectId", effectId)
	ctx:stateSet("generatorId", generatorId)
	ctx:triggerFlow("Finish")
end

function DialogueGraphPlayEffectNode.getEffectID(ctx)
	return ctx:stateGet("effectId", nil)
end

function DialogueGraphPlayEffectNode.getGeneratorID(ctx)
	return ctx:stateGet("generatorId", nil)
end

return DialogueGraphPlayEffectNode
