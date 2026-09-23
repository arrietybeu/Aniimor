-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityPlayFacialAnimationNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphEntityPlayFacialAnimationNode = DialogueGraphFlowNode.extend("DialogueGraphEntityPlayFacialAnimationNode")

local function getEntityId(ctx)
	return ctx:getInput("entityIdVInput")
end

local function stopFacial(ctx, stopLip, stopEmotion)
	local entityId = ctx:stateGet("entityId", nil) or getEntityId(ctx)

	if not string.isNilOrEmpty(entityId) then
		local noBlink = ctx:getField("noBlink", false)

		ctx:callCmd(NodeFunc.ENTITY_STOP_FACIAL_ANIMATION, entityId, stopLip, stopEmotion, noBlink)
	end
end

function DialogueGraphEntityPlayFacialAnimationNode.run(ctx)
	local inputPort = ctx:inputPort()

	if inputPort == "StopLip" then
		stopFacial(ctx, ctx:getField("activePlayLip", false), false)

		return
	end

	if inputPort == "StopEmotion" then
		stopFacial(ctx, false, ctx:getField("activePlayEmotion", false))

		return
	end

	local entityId = getEntityId(ctx)

	if string.isNilOrEmpty(entityId) then
		return false, "实体id为空！", true
	end

	local resolvedEntityId = ctx:callCmd(NodeFunc.ENTITY_PLAY_FACIAL_ANIMATION, entityId, ctx:getField("activePlayLip", false), ctx:getField("activePlayEmotion", false), ctx:getInput("facialEmotionVInput"), ctx:getField("noBlink", false))

	if string.isNilOrEmpty(resolvedEntityId) then
		return false, string.format("找不到对应实体！EntityId:%s", tostring(entityId)), true
	end

	ctx:stateSet("entityId", resolvedEntityId)
	ctx:triggerFlow("Out")
end

function DialogueGraphEntityPlayFacialAnimationNode.onGraphFinished(ctx)
	stopFacial(ctx, ctx:getField("activePlayLip", false), ctx:getField("activePlayEmotion", false))
end

return DialogueGraphEntityPlayFacialAnimationNode
