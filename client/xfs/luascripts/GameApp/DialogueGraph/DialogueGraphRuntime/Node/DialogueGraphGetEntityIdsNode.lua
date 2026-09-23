-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphGetEntityIdsNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphGetEntityIdsNode = DialogueGraphFlowNode.extend("DialogueGraphGetEntityIdsNode")

function DialogueGraphGetEntityIdsNode.getEntityIDs(ctx)
	local values = {}
	local portCount = tonumber(ctx:getField("portCount", 1)) or 1

	for index = 1, portCount do
		local value = ctx:getInput(string.format("%dEntityIDVInput", index))

		if value ~= nil and not string.isNilOrEmpty(value) then
			values[#values + 1] = tostring(value)
		end
	end

	return table.concat(values, ",")
end

return DialogueGraphGetEntityIdsNode
