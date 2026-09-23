-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityShowBubbleEmojiNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntityShowBubbleEmojiNode = DialogueGraphFlowNode.extend("DialogueGraphEntityShowBubbleEmojiNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")

function DialogueGraphEntityShowBubbleEmojiNode.run(ctx)
	local duration = ctx:getField("duration", 0)
	local emojiName = ctx:getField("emojiName")

	if duration == 0 or string.isNilOrEmpty(emojiName) then
		return false, "duration or emoji name is invalid"
	end

	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput")
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		return false, string.format("找不到对应实体！EntityId:%s StaticId:%s", tostring(entityId), tostring(staticId)), true
	end

	ctx:callCmd(NodeFunc.ENTITY_SHOW_BUBBLE_EMOJI, entity.id, emojiName, duration)
	ctx:triggerFlow("Out")
end

return DialogueGraphEntityShowBubbleEmojiNode
