-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetLevelItemFieldNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local SetLevelItemFieldNode = Class.LiteClass("SetLevelItemFieldNode", FlowNode)

function SetLevelItemFieldNode:ctor(nodeId, nodeData, graph)
	SetLevelItemFieldNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetLevelItemFieldNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
	self.valueInput_FieldName = self:addValueInput("fieldName")
	self.valueInput_FieldValue = self:addValueInput("fieldValue")

	self:addValueOutput("Value", function(context)
		return self:getContextValue(context, self.valueInput_FieldValue)
	end)
end

function SetLevelItemFieldNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local field = self:getContextValue(context, self.valueInput_FieldName)
	local value = self:getContextValue(context, self.valueInput_FieldValue)
	local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

	if levelItem and field and value then
		levelItem:setField(field, value)
		self.flowOut_Out:call(context)
	end
end

function SetLevelItemFieldNode:Get_Field_Value(context, field)
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

return SetLevelItemFieldNode
