-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSetEntityVisibleNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphSetEntityVisibleNode = DialogueGraphFlowNode.extend("DialogueGraphSetEntityVisibleNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

local function parseIdList(value)
	if type(value) == "table" then
		return value
	end

	local result = {}

	if type(value) == "string" then
		for id in string.gmatch(value, "([^,]+)") do
			id = string.match(id, "^%s*(.-)%s*$")

			if id ~= "" then
				result[#result + 1] = id
			end
		end
	end

	return result
end

function DialogueGraphSetEntityVisibleNode.run(ctx)
	local param = {
		nodeId = ctx:nodeId(),
		entityIds = parseIdList(ctx:getInput("entityIdListVInput", ctx:getField("entityIdList", {}))),
		staticIds = parseIdList(ctx:getInput("staticIdListVInput", ctx:getField("staticIdList", {}))),
		isFadeIn = ctx:getInput("isVisibleVInput", false),
		duration = ctx:getInput("durationVInput", 0.6),
		resetOnFinish = ctx:getInput("resetOnFinishVInput", false)
	}

	ctx:callCmd(NodeFunc.ENTITY_PLAY_VISIBILITY_EFFECTS, param, function()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Out")
	end)
end

return DialogueGraphSetEntityVisibleNode
