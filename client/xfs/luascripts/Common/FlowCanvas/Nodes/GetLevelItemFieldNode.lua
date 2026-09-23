-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetLevelItemFieldNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local GetLevelItemFieldNode = Class.LiteClass("GetLevelItemFieldNode", FlowNode)

function GetLevelItemFieldNode:ctor(nodeId, nodeData, graph)
	GetLevelItemFieldNode.super.ctor(self, nodeId, nodeData, graph)
end

function GetLevelItemFieldNode:registerPorts()
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_FieldName = self:addValueInput("fieldName")

	for _, field in pairs(self._outputPortValues) do
		self:addValueOutput(field, function(context)
			return self:Get_Field_Value(context, field)
		end)
	end
end

function GetLevelItemFieldNode:Get_Field_Value(context, field)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem then
		return
	end

	if not field or field == "" then
		field = "state"
	end

	return levelItem[field]
end

return GetLevelItemFieldNode
