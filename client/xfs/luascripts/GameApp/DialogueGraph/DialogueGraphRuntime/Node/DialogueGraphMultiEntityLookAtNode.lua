-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphMultiEntityLookAtNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphMultiEntityLookAtNode = DialogueGraphFlowNode.extend("DialogueGraphMultiEntityLookAtNode")

function DialogueGraphMultiEntityLookAtNode.run(ctx)
	local groups = ctx:getField("groups")

	ctx:callCmd(NodeFunc.ENTITY_MULTI_LOOK_AT, groups)
	ctx:triggerFlow("Out")
end

setmetatable(DialogueGraphMultiEntityLookAtNode, {
	__index = function(node, key)
		local groupIndex = key:match("^getRelationGroup(%d+)$")

		if groupIndex ~= nil then
			groupIndex = tonumber(groupIndex)

			local function getter(ctx)
				local groups = ctx:getField("groups")

				if groups == nil then
					return nil
				end

				local group = groups[groupIndex]

				return group and group.watchers or nil
			end

			rawset(node, key, getter)

			return getter
		end

		return DialogueGraphFlowNode[key]
	end
})

return DialogueGraphMultiEntityLookAtNode
