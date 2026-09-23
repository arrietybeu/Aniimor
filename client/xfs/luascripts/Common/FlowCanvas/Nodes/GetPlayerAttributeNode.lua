-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetPlayerAttributeNode.lua

local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local GetPlayerAttributeNode = Class.LiteClass("GetPlayerAttributeNode", FlowNode)

function GetPlayerAttributeNode:ctor(nodeId, nodeData, graph)
	GetPlayerAttributeNode.super.ctor(self, nodeId, nodeData, graph)
end

function GetPlayerAttributeNode:registerPorts()
	self.valueInput_attributeType = self:addValueInput("attributeType")
	self.valueOutput_attributeValue = self:addValueOutput("attributeValue", function(context)
		return self:Get_Attribute_Value(context)
	end)
end

function GetPlayerAttributeNode:Get_Attribute_Value(context)
	local attributeType = self:getContextValue(context, self.valueInput_attributeType)
	local space = context:getSpace()

	if not space then
		return 0
	end

	local attributeId = AttributeConst[attributeType]

	if attributeId == nil then
		return 0
	end

	return space.ownerPlayer.actorCombatAttribute:getAttribValue(attributeId)
end

return GetPlayerAttributeNode
