-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerGetLevelItemPositionNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ServerGetLevelItemPositionNode = Class.LiteClass("ServerGetLevelItemPositionNode", FlowNode)

function ServerGetLevelItemPositionNode:ctor(nodeId, nodeData, graph)
	ServerGetLevelItemPositionNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerGetLevelItemPositionNode:registerPorts()
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")

	self:addValueOutput("Position", function(context)
		return self:callbackPosition(context)
	end)
end

function ServerGetLevelItemPositionNode:callbackPosition(context)
	local space = context:getSpace()

	if not space then
		return {
			x = 0,
			z = 0,
			y = 0
		}
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem then
		return {
			x = 0,
			z = 0,
			y = 0
		}
	end

	local position = levelItem:getPosition()

	return position
end

return ServerGetLevelItemPositionNode
